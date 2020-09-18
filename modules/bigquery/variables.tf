
variable "project_id" {
  type        = string
  description = "Project to deploy the resources to."
}

variable "dataset_id" {
  type        = string
  description = "dashboard dataset id"
}

variable "dataset_description" {
  type        = string
  description = "description of the dataset"
}

variable "location" {
  type        = string
  description = "dataset location"
}

variable "mck_views" {
  type        = map(string)
  description = "list of views needs to created"
}




