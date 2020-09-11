locals {
  lower_case_labels = { for key in keys(var.labels) : lower(key) => lower(var.labels[key]) }
  wait-time         = 60
}
