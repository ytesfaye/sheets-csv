resource "google_cloudfunctions_function" "function" {
  name        = var.function_name
  description = "scheduled function to keep gcp routes up to date"
  project     = var.project_id
  region      = var.region
  runtime     = "python37"

  available_memory_mb           = 256
  source_archive_bucket         = var.bucket_name
  source_archive_object         = var.object_name
  timeout                       = 60
  entry_point                   = var.entry_point
  #vpc_connector                 = var.connector_name
  #vpc_connector_egress_settings = "ALL_TRAFFIC"
  service_account_email         = var.service_account_email
  labels = {
    function_purpose = var.function_name
  }

  environment_variables = var.environment_variables

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = var.pubsub_topic_id
  }
}
