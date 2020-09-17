# Alert module

Part of the overall architecture to provide alerting whenever the cloud function fails.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| google | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alignment\_period | Advanced aggregration alignment period | `string` | `"60s"` | no |
| comparison | How to compare the log filters versus the threshold value | `string` | `"COMPARISON_GT"` | no |
| cross\_series\_reducer | cross serier reducer | `string` | `"REDUCE_NONE"` | no |
| display\_name | Name of the alert. | `string` | `"alert-cloud-function-error"` | no |
| document\_content | n/a | `string` | `"This is notify that alert condition ${condition.display_name} has generated this alert for the policy ${metric.display_name}."` | no |
| duration | How often to check. | `string` | `"60s"` | no |
| log\_filter | Filter for the alert to look for in the logs | `string` | `"resource.type=\"cloud_function\" resource.labels.function_name=\"dashboard_update\" resource.labels.region=\"us-central1\" textPayload:\"crash\" OR \"failed\""` | no |
| log\_name | Log for the Alerts to watch | `string` | `"cloud-function-log-metrics"` | no |
| notification\_email\_list | Map of a name to an email for notifications. | `map(string)` | {  "ashwani-sharma": "ashwani.sharma@mavenwave.com",  "travis-mcvey": "travis.mcvey@mavenwave.com"} | no |
| per\_series\_aligner | Advanced aggregration aligner | `string` | `"ALIGN_COUNT"` | no |
| project\_id | Project to deploy the resources to. | `string` | `"mig-dashboard-dev-e918"` | no |
| threshold\_value | Threshold to be compared against | `string` | `"0.001"` | no |
| workspace\_id | GCP project id | `string` | n/a | yes |

## Outputs

No output.
