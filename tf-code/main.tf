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

/******************************************
 Service Account and permissions to run 
 the function.
 *****************************************/
resource "google_service_account" "service_account" {
  account_id   = "${var.prefix}-${var.cf_service_account_name}"
  display_name = var.cf_service_account_name
  project      = var.project_id
}

resource "google_project_iam_binding" "router-updater-role-membership" {
  for_each = var.cf_service_account_roles

  project = var.project_id
  role    = each.value
  members = ["serviceAccount:${google_service_account.service_account.email}"]
}

# Configure networking requirements
module "networking" {
  source     = "./modules/networking"
  project_id = var.project_id
  region     = var.region
  subnet_ip  = var.cf_subnet_ip
}

resource "google_project_service" "project_services" {
  project = var.project_id
  service = "pubsub.googleapis.com"
}

resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.app_location
}

# ensures the api is active and ready before deploying vpc connector
resource "null_resource" "resource-to-wait-on" {
  provisioner "local-exec" {
    command = "sleep ${local.wait-time}"
  }
  depends_on = [google_project_service.project_services]
}

resource "google_pubsub_topic" "dashboard_topic" {
  name    = "dashboard-update"
  project = var.project_id

  labels = local.lower_case_labels
}

module "cloud_function" {
  source                = "./modules/function"
  project_id            = var.project_id
  bucket_name           = google_storage_bucket.bucket.name
  connector_name        = module.networking.connector_name
  object_name           = google_storage_bucket_object.archive.name
  region                = var.region
  service_account_email = google_service_account.service_account.email
  pubsub_topic_id       = google_pubsub_topic.dashboard_topic.id
  entry_point           = "sheet_pubsub"
  function_name         = "dashboard_update"
}

module "cloud_scheduler" {
  source                = "./modules/scheduler"
  target                = module.cloud_function.url
  project_id            = var.project_id
  region                = var.region
  service_account_email = google_service_account.service_account.email
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