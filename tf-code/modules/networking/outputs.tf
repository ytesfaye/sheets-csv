output "connector_name" {
  value = google_vpc_access_connector.connector.name
}

output "vpc_network" {
  value = google_compute_network.vpc_network.name
}