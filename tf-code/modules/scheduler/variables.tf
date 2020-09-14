variable "target" {
  type = string
}

variable "name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "pubsub_topic_id" {
  type = string
}

variable "pub_message" {
  type = string
}

variable "description" {
  type    = string
  default = "job to keep gcp routes up to date"
}