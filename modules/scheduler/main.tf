resource "google_cloud_scheduler_job" "route_update_1" {
  name        = "gcp-route-update-scheduler-001"
  description = var.description
  schedule    = "0 1 * * *"
  time_zone   = "America/Los_Angeles"

  project = var.project_id
  region  = var.region

  pubsub_target {
    topic_name = var.pubsub_topic_id
    data       = base64encode(var.pub_message)
  }
}
