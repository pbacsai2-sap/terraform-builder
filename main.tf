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
    set -e
    exec > >(tee /var/log/startup-script.log) 2>&1
    
    echo "Starting startup script at $(date)"
    
    # Install gsutil if not present
    if ! command -v gsutil &> /dev/null; then
      echo "Installing gsutil..."
      apt-get update
      apt-get install -y python3-pip
      pip3 install gsutil
    fi
    
    echo "Downloading init script from gs://${google_storage_bucket.scripts.name}/${google_storage_bucket_object.init_script.name}"
    gsutil cp gs://${google_storage_bucket.scripts.name}/${google_storage_bucket_object.init_script.name} /tmp/init-script.sh
    
    echo "Making init script executable"
    chmod +x /tmp/init-script.sh
    
    echo "Executing init script"
    /tmp/init-script.sh
    
    echo "Startup script completed at $(date)"
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