
variable "project_id" {
  type        = string
  default     = "mig-dashboard-dev-e918"
  description = "Project to deploy the resources to."
}

variable "log_name" {
  type        = string
  default     = "cloud-function-log-metrics"
  description = "Log for the Alerts to watch"
}

variable "function_name" {
  type        = string
  description = "name of the function used to created log based metrics"
}

variable "workspace_id" {
  type        = string
  description = "GCP project id"
}

variable "notification_email_list" {
  type = map(string)
  default = {
    ashwani-sharma = "ashwani.sharma@mavenwave.com"
    travis-mcvey   = "travis.mcvey@mavenwave.com"
  }
  description = "Map of a name to an email for notifications."
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

variable "document_content" {
  type    = string
  default = "This is notify that alert condition $${condition.display_name} has generated this alert for the policy $${metric.display_name}."
}

variable "display_name" {
  type        = string
  default     = "alert-cloud-function-error"
  description = "Name of the alert."
}

variable "duration" {
  type        = string
  default     = "60s"
  description = "How often to check."
}

variable "comparison" {
  type        = string
  default     = "COMPARISON_GT"
  description = "How to compare the log filters versus the threshold value"
}

variable "threshold_value" {
  type        = string
  default     = "0.001"
  description = "Threshold to be compared against"
}

variable "region" {
  type        = string
  description = "Region used in the log filter"
}




