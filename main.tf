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

resource "google_pubsub_topic" "dashboard_topic" {
  name    = var.pubsub_topic
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
  function_name         = var.function_name
  function_mem_amount   = var.function_mem_amount
  environment_variables = {}
}

module "cloud_scheduler" {
  source          = "./modules/scheduler"
  name            = "mck-dashboard-scheduler-001"
  project_id      = var.project_id
  region          = var.region
  pubsub_topic_id = google_pubsub_topic.dashboard_topic.id
  pub_message     = jsonencode(var.sheet_information)
  description     = "Scheduler to keep the dashboard up-to-date."
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
  region                  = var.region
  function_name           = var.function_name
  workspace_id            = var.project_id
  notification_email_list = var.notification_email_list
  display_name            = var.display_name
  duration                = var.duration
  comparison              = var.comparison
  threshold_value         = var.threshold_value
}

module "cloud_physics_scheduler" {
  source          = "./modules/scheduler"
  name            = "mck-cloud-physics-data-001"
  project_id      = var.project_id
  region          = var.region
  pubsub_topic_id = google_pubsub_topic.dashboard_topic.id
  pub_message     = jsonencode(var.cloud_physics_sheet_info)
  description     = "Scheduler to import cloud physics data to BQ."
}

module "cloud_physics_scheduler" {
  source          = "./modules/scheduler"
  name            = "mck-smart-sheet-data-001"
  project_id      = var.project_id
  region          = var.region
  pubsub_topic_id = google_pubsub_topic.dashboard_topic.id
  pub_message     = jsonencode(var.smart_sheet_info)
  description     = "Scheduler to import smart sheet data to BQ."
}