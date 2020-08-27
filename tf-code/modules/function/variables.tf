variable "project_id" {
  type        = string
  description = "GCP Project id to deploy the function to."
}

variable "region" {
  type        = string
  description = "Region to deploy the function to."
}

variable "bucket_name" {
  type        = string
  description = "Bucket name containing the Zip of the source code."
}

variable "object_name" {
  type        = string
  description = "Zip name within the bucket with the source code."
}

variable "connector_name" {
  type        = string
  description = "VPC connector name for the function to have network connectivity."
}

variable "service_account_email" {
  type        = string
  description = "Service Account email the function will run as."
}

variable "pubsub_topic_id" {
  type        = string
  description = "Name of the pub/sub to trigger the function."
}

variable "function_name" {
  type        = string
  default     = "gcp-route-updates"
  description = "Name of the function"
}

variable "entry_point" {
  type        = string
  default     = "route_pubsub"
  description = "Function that serves the entry point."
}