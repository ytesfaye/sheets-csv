locals {
  email_ids = values(google_monitoring_notification_channel.compute_email_notification)[*].name
}

resource "google_logging_metric" "function_metric" {
  project = var.project_id
  name    = var.log_name
  filter  = var.log_filter
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

/*******************************
  Monitoring notification channel
*******************************/

resource "google_monitoring_notification_channel" "compute_email_notification" {
  for_each     = var.notification_email_list
  project      = var.workspace_id
  display_name = each.key
  type         = "email"
  labels = {
    email_address = each.value
  }
}

/******************************************
Alert policy for CPU metrics 
*******************************************/

resource "google_monitoring_alert_policy" "function_alert_policy" {
  project      = var.workspace_id
  display_name = var.display_name
  combiner     = "OR"

  conditions {
    display_name = var.display_name
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/cloud-function-log-metrics\" AND resource.type=\"cloud_function\""
      duration        = var.duration
      comparison      = var.comparison
      threshold_value = var.threshold_value
      aggregations {
        alignment_period     = var.alignment_period
        per_series_aligner   = var.per_series_aligner
        cross_series_reducer = var.cross_series_reducer
      }
      trigger {
        count = 1
      }
    }
  }
  notification_channels = local.email_ids

  documentation {
    content = var.document_content
  }
}