variable "project_id" {
  type = string
}

variable "router_updater_permissions" {
  type    = list(string)
  default = ["compute.routes.create", "compute.networks.updatePolicy", "compute.routes.list"]
}

variable "service_account_email" {
  type = string
}