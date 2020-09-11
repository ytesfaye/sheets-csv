resource "google_project_iam_custom_role" "router-updater-custom-role" {
  role_id     = "router_updater"
  project     = var.project_id
  title       = "router-updater"
  description = "Ability to update routes for the project"
  permissions = var.router_updater_permissions
}

resource "google_project_iam_binding" "router-updater-role-membership" {
  project = var.project_id
  role    = google_project_iam_custom_role.router-updater-custom-role.id
  members = ["serviceAccount:${var.service_account_email}"]
}