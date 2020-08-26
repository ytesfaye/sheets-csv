locals {
  wait-time = 60
}

resource "google_project_service" "project_services" {
  project = var.project_id
  service = "vpcaccess.googleapis.com"
}

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  description             = "network resource needed for vpc connector"
  auto_create_subnetworks = false
  project                 = var.project_id
}

# ensures the api is active and ready before deploying vpc connector
resource "null_resource" "resource-to-wait-on" {
  provisioner "local-exec" {
    command = "sleep ${local.wait-time}"
  }
  depends_on = [google_project_service.project_services]
}

resource "google_vpc_access_connector" "connector" {
  name          = "gcp-vpc-connector"
  region        = var.region
  network       = google_compute_network.vpc_network.name
  project       = var.project_id
  ip_cidr_range = var.subnet_ip
  depends_on    = [null_resource.resource-to-wait-on]
}
