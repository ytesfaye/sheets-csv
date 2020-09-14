terraform {
  backend "gcs" {
    bucket = "terraform-state-files"
    prefix = "mig-dashboard-dev-e918/state"
  }
}
