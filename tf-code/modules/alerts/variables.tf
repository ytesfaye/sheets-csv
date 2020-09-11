
variable "project_id" {
  type = string
}

variable "log_name" {
  type = string
}

variable "log_filter" {
  type = string
}

variable "workspace_id" {
  type        = string
  description = "GCP project id"
}

variable "notification_email_list" {
  type = map(string)
}

variable "alignment_period" {
  type        = string
  default     = "60s"
  description = "Advanced aggregration alignment period"
}

variable "per_series_aligner" {
  type        = string
  default     = "ALIGN_COUNT"
  description = "Advanced aggregration aligner"
}

variable "cross_series_reducer" {
  type        = string
  default     = "REDUCE_NONE"
  description = "cross serier reducer"
}



variable "document_content" {
  type    = string
  default = "This is notify that alert condition $${condition.display_name} has generated this alert for the policy $${metric.display_name}."
}

variable "display_name" {
  type = string
}

variable "duration" {
  type = string
}

variable "comparison" {
  type = string
}

variable "threshold_value" {
  type = string
}




