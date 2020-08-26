output "url" {
  value = google_cloudfunctions_function.function.https_trigger_url
}

output "service_account" {
  value = google_cloudfunctions_function.function.service_account_email
}
