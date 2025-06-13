output "instance_name" {
  description = "The name of the VM instance"
  value       = google_compute_instance.ubuntu_vm.name
}

output "instance_external_ip" {
  description = "The external IP address of the VM instance"
  value       = google_compute_instance.ubuntu_vm.network_interface[0]
}

output "instance_zone" {
  description = "The zone where the VM instance is located"
  value       = google_compute_instance.ubuntu_vm.zone
} 