resource "google_bigquery_dataset" "mck_dataset" {
  project     = var.project_id
  dataset_id  = var.dataset_id
  description = var.dataset_description
  location    = var.location
}

resource "google_bigquery_table" "mck_dashboard_views" {
  for_each   = var.mck_views
  project    = var.project_id
  dataset_id = google_bigquery_dataset.mck_dataset.dataset_id
  table_id   = each.key

  view {
    query          = each.value
    use_legacy_sql = false
  }
}