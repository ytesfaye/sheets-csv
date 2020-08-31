variable "region" {
  type    = string
  default = "us-central1"
}

variable "project_id" {
  type    = string
  default = "ic-iaprep-mgmt-project-a4d4"
}

variable "prefix" {
  type    = string
  default = "dev"
}

variable "labels" {
  type = map(string)
  default = {
    environment = "development"
  }
  description = "Map of labels for project"
}

variable "cf_bucket_name" {
  type    = string
  default = "dashboard-update"
}

variable "cf_service_account_name" {
  type    = string
  default = "sa-dashboard-updater"
}

variable "cf_service_account_roles" {
  type    = set(string)
  default = ["roles/bigquery.admin"]
}

variable "cf_subnet_ip" {
  type    = string
  default = "10.132.0.0/28"
}

variable "sheet_information" {
  type = object({
    sheet_id = string
    data_set = string
    sheets   = list(map(string))
  })
  default = {
    sheet_id = "my_private_sheet123456789"
    data_set = "myproject.data_set"
    sheets = [
      {
        name  = "dc_cogent"
        range = "Cogent Dashboard!F1:J25"
      },
      {
        name  = "dc_markham"
        range = "Markham Dashboard!F1:J25"
      }
    ]
  }
}

variable "app_location" {
  type    = string
  default = "us-central"
}

/************************
bigquery variables 
**************************/
variable "dataset_id" {
  default     = "mck_dc_workloads"
  description = "dashboard dataset id"
}

variable "dataset_description" {
  default     = "This is mckesson databoard dataset"
  description = "description of the dataset"
}

variable "location" {
  default     = "US"
  description = "dataset location"
}

variable "mck_views" {
  type        = map(string)
  description = "list of views needs to created"
  default = {
    mck_dc_dashboard     = <<EOF
  SELECT DC, 
  SUM(Planned_InFlight_Migration) AS Planned_InFlight_Migration,
  SUM(Sunset_in_Place) AS Sunset_in_Place , 
  SUM( Migrate_to_Azure) AS Migrate_to_Azure ,
  SUM( Modernization) AS Modernization,
  SUM( Migrate_to_GCP) AS Migrate_to_GCP,
  SUM(UnAccessed) AS UnAccessed,
  Date
  FROM (
        SELECT  DISTINCT CASE WHEN Source = 'UNIPRIX2' OR Source = 'UNIPRIX1' THEN 'UNIPRIX' ELSE Source END As DC, 
        COUNTIF( Has_separate_project_or_effort = 'TRUE') AS Planned_InFlight_Migration,
        COUNTIF(Sunset_in_Place = 'TRUE') AS Sunset_in_Place, 
        COUNTIF(Migrate_to_Azure = 'TRUE') AS Migrate_to_Azure,  
        COUNTIF(Modernization = 'TRUE') AS Modernization,
        COUNTIF(Migrate_to_GCP = 'TRUE') AS Migrate_to_GCP,
        COUNTIF(Unassessed = 'TRUE') AS UnAccessed,
        PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date 
        FROM `ic-iaprep-mgmt-project-a4d4.mck_dc_workloads.dc_all_*`
        GROUP BY Source, _TABLE_SUFFIX 
        ) 
  GROUP BY DC, Date
EOF
    mck_dc_all_workloads = <<EOF
SELECT  'Cogent' as dc, Unconfirmed_App, Application, Disposition, CAST(Server_Count AS INT64) AS Server_Count , CAST(Desktop_Count AS INT64) AS Desktop_Count ,PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date FROM `ic-iaprep-mgmt-project-a4d4.mck_dc_workloads.dc_cogent_*` union all 
SELECT  'Markham' as dc,Unconfirmed_App, Application, Disposition, CAST(Server_Count AS INT64) AS Server_Count , CAST(Desktop_Count AS INT64) AS Desktop_Count ,PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date FROM `ic-iaprep-mgmt-project-a4d4.mck_dc_workloads.dc_markham_*` union all 
SELECT  'Unipri' as dc, Unconfirmed_App, Application, Disposition, CAST(Server_Count AS INT64) AS Server_Count , CAST(Desktop_Count AS INT64) AS Desktop_Count ,PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date FROM `ic-iaprep-mgmt-project-a4d4.mck_dc_workloads.dc_uniprix_*` union all 
SELECT  'Viscount' as dc, Unconfirmed_App, Application, Disposition, CAST(Server_Count AS INT64) AS Server_Count , CAST(Desktop_Count AS INT64) AS Desktop_Count ,PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date FROM `ic-iaprep-mgmt-project-a4d4.mck_dc_workloads.dc_viscount_*`
EOF
  }
}

/******************
alerts variables
*******************/

variable "log_name" {
  type    = string
  default = "cloud-function-log-metrics"
}

variable "log_filter" {
  type    = string
  default = "resource.type=\"cloud_function\" resource.labels.function_name=\"dashboard_update\" resource.labels.region=\"us-central1\" textPayload:\"crash\" OR \"failed\""
}

variable "display_name" {
  type    = string
  default = "alert-cloud-function-error"
}

variable "duration" {
  type    = string
  default = "60s"
}

variable "comparison" {
  type    = string
  default = "COMPARISON_GT"
}

variable "threshold_value" {
  type    = string
  default = "0.001"
}

variable "notification_email_list" {
  type = map(string)
  default = {
    ashwani-sharma = "ashwani.sharma@mavewave.com"
    travis-mcvey =  "travis.mcvey@mavenwave.com"
  }
}
