terraform {
  backend "gcs" {
    bucket = "sap-ems-systec-sandbox-terraform-state"
    prefix = "terraform/state"
  }
} 