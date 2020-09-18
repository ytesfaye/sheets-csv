# Cloud Function module

This module is utilized to create the actual function that performs the transfer of data from Sheets into Big Query.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| google | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_name | Bucket name containing the Zip of the source code. | `string` | n/a | yes |
| entry\_point | The specific entry function that serves as the entry point. | `string` | n/a | yes |
| environment\_variables | Environment variables for the function | `map(string)` | `{}` | no |
| function\_name | Name of the Cloud Function | `string` | n/a | yes |
| object\_name | Zip name within the bucket with the source code. | `string` | n/a | yes |
| project\_id | GCP Project id to deploy the function to. | `string` | n/a | yes |
| pubsub\_topic\_id | Name of the pub/sub to trigger the function. | `string` | n/a | yes |
| region | Region to deploy the function to. | `string` | n/a | yes |
| service\_account\_email | Service Account email the function will run as. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| service\_account | n/a |
| url | n/a |
