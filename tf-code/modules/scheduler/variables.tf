variable "name" {
  type        = string
  description = "Name of the Cloud Scheduler job."
}

variable "project_id" {
  type        = string
  description = "Project to deploy the resources to."
}

variable "region" {
  type        = string
  description = "Region to deploy the scheduler into."
}

variable "pubsub_topic_id" {
  type        = string
  description = "Topic that is created for the cloud scheduler and function to interact"
}

variable "pub_message" {
  type        = string
  description = "Message to publish to the pubsub topic."
}

variable "description" {
  type        = string
  default     = "Job to initiate function Dashboard update"
  description = "The description for the Cloud Scheduler job."
}