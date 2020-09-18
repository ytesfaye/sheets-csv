# Big Query Module

A module for the migration dashboard to setup and confiure Big Query to enable the cloud function to update the values, as well as, create the views.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| google | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dataset\_description | description of the dataset | `string` | n/a | yes |
| dataset\_id | dashboard dataset id | `string` | n/a | yes |
| location | dataset location | `string` | n/a | yes |
| mck\_views | list of views needs to created | `map(string)` | n/a | yes |
| project\_id | Project to deploy the resources to. | `string` | n/a | yes |

## Outputs

No output.
