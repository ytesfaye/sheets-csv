variable "region" {
  type    = string
  default = "us-central1" 
}

variable "project_id" {
  type    = string
  default = "my-project-1"
}

variable "prefix" {
  type    = string
  default = ""
}

variable "labels" {
  type = map(string)
  default = {
    environment = "development"
  }
  description = "Map of labels for project"
}

variable "cf_bucket_name" {
  type    = string
  default = "dashboard-update"
}

variable "cf_service_account_name" {
  type    = string
  default = "sa-dashboard-updater"
}

variable "cf_service_account_roles" {
  type    = set(string)
  default = ["roles/bigquery.admin"]
}

variable "cf_subnet_ip" {
  type    = string
  default = "10.132.0.0/28"
}

variable "sheet_information" {
  type = object({
    sheet_id = string
    data_set = string
    sheets   = list(map(string))
  })
  default = {
    sheet_id = "my_private_sheet123456789"
    data_set = "myproject.data_set"
    sheets = [
      {
        name  = "dc_cogent"
        range = "Cogent Dashboard!F1:J25"
      },
      {
        name  = "dc_markham"
        range = "Markham Dashboard!F1:J25"
      }
    ]
  }
}

variable "app_location" {
  type    = string
  default = "us-central"
}