# Cloud Schedule module

This module supports the schedule portion of the Architecture. The payload for the Sheets ID, the Big Query dataset to upload the data into, as well as, the specific sheets and their ranges to use.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| google | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| description | The description for the Cloud Scheduler job. | `string` | `"Job to initiate function Dashboard update"` | no |
| name | Name of the Cloud Scheduler job. | `string` | n/a | yes |
| project\_id | Project to deploy the resources to. | `string` | n/a | yes |
| pub\_message | Message to publish to the pubsub topic. | `string` | n/a | yes |
| pubsub\_topic\_id | Topic that is created for the cloud scheduler and function to interact | `string` | n/a | yes |
| region | Region to deploy the scheduler into. | `string` | n/a | yes |

## Outputs

No output.
