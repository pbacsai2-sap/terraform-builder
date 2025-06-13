resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_id}-terraform-state"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "scripts" {
  name     = "${var.project_id}-ubuntu-scripts"
  location = "EU"
  force_destroy = true
}

resource "google_storage_bucket_object" "init_script" {
  name   = "init-script.sh"
  bucket = google_storage_bucket.scripts.name
  source = "scripts/init-script.sh"
}

resource "google_compute_instance" "ubuntu_vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      labels = {
        my_label = "ubuntu-os-cloud"
      }
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    gsutil cp gs://${google_storage_bucket.scripts.name}/${google_storage_bucket_object.init_script.name} /tmp/init-script.sh
    chmod +x /tmp/init-script.sh
    /tmp/init-script.sh
  EOF

  tags = var.network_tags
} 

resource "google_compute_network" "vpc_network" {
  name                    = "ubuntu-vpc-network"
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "subnet" {
  name          = "ubuntu-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = var.network_tags
}