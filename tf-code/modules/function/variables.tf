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

variable "function_mem_amount" {
  type        = number
  default     = 256
  description = "Amount of memory to allocate to the cloud function."
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
  description = "Name of the Cloud Function"
}

variable "entry_point" {
  type        = string
  description = "The specific entry function that serves as the entry point."
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "Environment variables for the function"
}
