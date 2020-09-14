terraform {
  backend "gcs" {
    bucket = "mck-terraform-state-files"
    prefix = "mig-dashboard-dev-e918/state"
  }
}
