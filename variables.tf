variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "instance_name" {
  description = "The name of the VM instance"
  type        = string
  default     = "ubuntu-vm"
}

variable "machine_type" {
  description = "The machine type for the VM"
  type        = string
  default     = "e2-medium"
}

variable "zone" {
  description = "The GCP zone where the VM will be created"
  type        = string
  default     = "europe-west3-a"
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "europe-west3"
}

variable "disk_size_gb" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 20
}

variable "ssh_user" {
  description = "The SSH user for the VM"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
}

variable "network_tags" {
  description = "Network tags for the VM"
  type        = list(string)
  default     = ["http-server", "https-server", "ssh"]
}

variable "ssh_source_ranges" {
  description = "Source IP address ranges for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
} 