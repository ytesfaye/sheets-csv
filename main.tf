/******************************************
 Bucket and upload Source code
 *****************************************/
resource "google_storage_bucket" "bucket" {
  name    = "${var.prefix}-${var.cf_bucket_name}"
  project = var.project_id
}

resource "google_storage_bucket_object" "archive" {
  name   = "Archive.zip"
  bucket = google_storage_bucket.bucket.name
  source = "files/Archive.zip"
}

# Does not have permission, these apis are already enabled. 

# resource "google_project_service" "pubsub" {
#  project = var.project_id
#  service = "pubsub.googleapis.com"
#  disable_dependent_services = true
# }

# resource "google_project_service" "cloud_scheduler" {
#  project = var.project_id
#  service = "cloudscheduler.googleapis.com"
#  disable_dependent_services = true
# }


# ensures the api is active and ready before deploying vpc connector
resource "null_resource" "resource-to-wait-on" {
  provisioner "local-exec" {
    command = "sleep ${local.wait-time}"
  }
  depends_on = [google_project_service.pubsub, google_project_service.cloud_scheduler]
}

resource "google_pubsub_topic" "dashboard_topic" {
  name    = "mck-dashboard-update"
  project = var.project_id

  labels = local.lower_case_labels
}

module "cloud_function" {

  source                = "./modules/function"
  project_id            = var.project_id
  bucket_name           = google_storage_bucket.bucket.name
  object_name           = google_storage_bucket_object.archive.name
  region                = var.region
  service_account_email = var.cf_service_account_email
  pubsub_topic_id       = google_pubsub_topic.dashboard_topic.id
  entry_point           = "sheet_pubsub"
  function_name         = "dashboard_update"
  environment_variables = {}
}

module "cloud_scheduler" {
  source                = "./modules/scheduler"
  name                  = "gcp-dashboard-scheduler-001"
  target                = module.cloud_function.url
  project_id            = var.project_id
  region                = var.region
  service_account_email = var.cf_service_account_email
  pubsub_topic_id       = google_pubsub_topic.dashboard_topic.id
  pub_message           = jsonencode(var.sheet_information)
  description           = "Scheduler to keep the dashboard up-to-date."
}

module "bigquery" {
  source              = "./modules/bigquery"
  project_id          = var.project_id
  dataset_id          = var.dataset_id
  dataset_description = var.dataset_description
  location            = var.location
  mck_views           = var.mck_views
}

module "alerts" {
  source                  = "./modules/alerts"
  project_id              = var.project_id
  log_name                = var.log_name
  log_filter              = var.log_filter
  workspace_id            = var.project_id
  notification_email_list = var.notification_email_list
  display_name            = var.display_name
  duration                = var.duration
  comparison              = var.comparison
  threshold_value         = var.threshold_value
}