variable "region" {
  type        = string
  default     = "northamerica-northeast1"
  description = "Region to deploy the resources to."
}

variable "project_id" {
  type        = string
  default     = "mig-dashboard-dev-e918"
  description = "Project to deploy the resources to."
}

variable "prefix" {
  type        = string
  default     = "dev"
  description = "Prefix that resources will be created with."
}

variable "labels" {
  type = map(string)
  default = {
    environment = "development"
  }
  description = "Map of labels for project"
}

variable "function_mem_amount" {
  type        = number
  default     = 512
  description = "Amount of memory to allocate to the cloud function."
}

variable "cf_bucket_name" {
  type        = string
  default     = "mck-dashboard-update"
  description = "Bucket that the cloud function Archive.zip will be uploaded to."
}

variable "pubsub_topic" {
  type        = string
  default     = "mck-dashboard-update"
  description = "Topic that is created for the cloud scheduler and function to interact"
}

variable "cf_service_account_email" {
  type        = string
  default     = "mig-dashboard-dev-e918-1@mig-dashboard-dev-e918.iam.gserviceaccount.com"
  description = "Service account for the cloud function to 'runas'"
}


variable "sheet_information" {
  type = object({
    sheet_id = string
    data_set = string
    sheets   = list(map(string))
  })
  default = {
    sheet_id = "1oRULNbJj5sG7HsVvA4ySD5w3LOX_P_-g5nvazkk2z58"
    data_set = "mig-dashboard-dev-e918.mck_dashboard_data"
    sheets = [
      {
        name  = "dc_cogent"
        range = "Cogent Dashboard!F1:J25"
      },
      {
        name  = "dc_markham"
        range = "Markham Dashboard!F1:J25"
      },
      {
        name  = "dc_uniprix"
        range = "Uniprix Dashboard!F1:J60"
      },
      {
        name  = "dc_viscount"
        range = "Viscount Dashboard!F1:J15"
      },
      {
        name  = "dc_tracker"
        range = "DataCenter Tracker!A1:K7"
      },
      {
        name  = "dc_all"
        range = "Master Server Inventory!A1:BZ1000"
      }
    ]
  }
  description = "The Google Sheet ID, bigquery dataset to upload the sheet id to, and then specific sheets and ranges to read from."
}

/************************
bigquery variables 
**************************/
variable "dataset_id" {
  type        = string
  default     = "mck_dashboard_data"
  description = "dashboard dataset id"
}

variable "dataset_description" {
  type        = string
  default     = "This is mckesson databoard dataset"
  description = "description of the dataset"
}

variable "location" {
  type        = string
  default     = "US"
  description = "dataset location"
}

variable "mck_views" {
  type        = map(string)
  description = "list of views needs to created"
  default = {
    mck_dc_dashboard               = <<EOF
  SELECT DC, 
  SUM(Planned_InFlight_Migration) AS Planned_InFlight_Migration,
  SUM(Sunset_in_Place) AS Sunset_in_Place , 
  SUM(Citrix) AS Citrix_Migration,
  SUM( Migrate_to_Azure) AS Migrate_to_Azure ,
  SUM( Modernization) AS Modernization,
  SUM( Migrate_to_GCP) AS Migrate_to_GCP,
  SUM(UnAccessed) AS UnAccessed,
  Date
  FROM (
        SELECT  DISTINCT CASE WHEN Source = 'UNIPRIX2' OR Source = 'UNIPRIX1' THEN 'UNIPRIX' ELSE Source END As DC, 
        COUNTIF( Has_separate_project_or_effort = 'TRUE') AS Planned_InFlight_Migration,
        COUNTIF(Sunset_in_Place = 'TRUE') AS Sunset_in_Place, 
        COUNTIF(Citrix = 'TRUE') AS Citrix,
        COUNTIF(Migrate_to_Azure = 'TRUE') AS Migrate_to_Azure,  
        COUNTIF(Modernization = 'TRUE') AS Modernization,
        COUNTIF(Migrate_to_GCP = 'TRUE') AS Migrate_to_GCP,
        COUNTIF(Unassessed = 'TRUE') AS UnAccessed,
        PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date 
        FROM `mig-dashboard-dev-e918.mck_dashboard_data.dc_all_*`
        GROUP BY Source, _TABLE_SUFFIX 
        ) 
  GROUP BY DC, Date
EOF
    mck_dc_all_workloads           = <<EOF
SELECT  'Cogent' as dc, Unconfirmed_App, Application, Disposition, CAST(Server_Count AS INT64) AS Server_Count , CAST(Desktop_Count AS INT64) AS Desktop_Count ,PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date FROM `mig-dashboard-dev-e918.mck_dashboard_data.dc_cogent_*` union all 
SELECT  'Markham' as dc,Unconfirmed_App, Application, Disposition, CAST(Server_Count AS INT64) AS Server_Count , CAST(Desktop_Count AS INT64) AS Desktop_Count ,PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date FROM `mig-dashboard-dev-e918.mck_dashboard_data.dc_markham_*` union all 
SELECT  'Unipri' as dc, Unconfirmed_App, Application, Disposition, CAST(Server_Count AS INT64) AS Server_Count , CAST(Desktop_Count AS INT64) AS Desktop_Count ,PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date FROM `mig-dashboard-dev-e918.mck_dashboard_data.dc_uniprix_*` union all 
SELECT  'Viscount' as dc, Unconfirmed_App, Application, Disposition, CAST(Server_Count AS INT64) AS Server_Count , CAST(Desktop_Count AS INT64) AS Desktop_Count ,PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date FROM `mig-dashboard-dev-e918.mck_dashboard_data.dc_viscount_*`
EOF
    mck_dc_all_workloads_details   = <<EOF
    SELECT Source, Server, OS, Normalized_OS, Power_State, Application_Lookup, Confirmed_Application, MW_Project_Name, Sunset_in_Place,
    Citrix, Modernization, Migrate_to_Azure, Migrate_to_GCP, Unassessed, Migration_Scheduled, Migration_Succeeded, In_flight_Initiative,
    Project_Owner, Tech_Owner, BAP_ID, Lean_IX_ID, Archer_ID, Host_CPU, Host_Mem,Allocated_Storage,Rationale, Server_Function_Notes, 
    Wave, Wave_Order, Environment,Destination_Project,Project_Request_ID, Data_Center, Destination, Program_Status, PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date
  ,(case 
      when Sunset_in_Place = 'TRUE' then 'Sunset'
      when Citrix = 'TRUE' then 'Citrix'
      when Modernization = 'TRUE' then 'Modernization'
      when Migrate_to_Azure = 'TRUE' then 'Azure'
      when Migrate_to_GCP = 'TRUE' then 'GCP'
      when Unassessed = 'TRUE' then 'Unassessed Server ' 
      else 'other'
    end) as disposition

    FROM `mig-dashboard-dev-e918.mck_dashboard_data.dc_all_*`
    Order by Date
EOF
    mck_dc_all_workloads_dc_rollup = <<EOF
    SELECT DISTINCT
    Source
    ,sum(case when Sunset_in_Place = "TRUE" then 1 else 0 end) AS Sunset_in_Place
    ,sum(case when Migrate_to_GCP = "TRUE" then 1 else 0 end) AS Migrate_to_GCP
    ,sum(case when Citrix = "TRUE" then 1 else 0 end) AS Migrate_to_Citrix
    ,sum(case when Migrate_to_Azure = "TRUE" then 1 else 0 end) AS Migrate_to_Azure
    ,sum(case when Modernization = "TRUE" then 1 else 0 end) AS Modernization
    ,sum(case when Unassessed = "TRUE" then 1 else 0 end) AS Unassessed
    ,date
    FROM mig-dashboard-dev-e918.mck_dashboard_data.mck_dc_all_workloads_details 
    WHERE  date = CURRENT_DATE()
    GROUP BY Source, date
EOF
    mck_cloud_physics_data = <<EOF
    SELECT Tags, Application,	VM_State,Guest_OS,Process,Local_IP, 
    Local_Port, Formatted_Local_Port,Protocol,Target_Name,Target_Application,			
    Target_IP,Target_Port	,Formatted_Target_Port,Target_Address,State,
    PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date
    FROM `ic-iaprep-mgmt-project-a4d4.mck_dc_workloads.cloud_physics_*`
    order by Date   
EOF

  }
}

/******************
alerts variables
*******************/

variable "log_name" {
  type        = string
  default     = "cloud-function-log-metrics"
  description = "Log for the Alerts to watch"
}

variable "log_filter" {
  type        = string
  default     = "resource.type=\"cloud_function\" resource.labels.function_name=\"dashboard_update\" resource.labels.region=\"us-central1\" textPayload:\"crash\" OR \"failed\""
  description = "Filter for the alert to look for in the logs"
}

variable "display_name" {
  type        = string
  default     = "alert-cloud-function-error"
  description = "Name of the alert."
}

variable "duration" {
  type        = string
  default     = "60s"
  description = "How often to check."
}

variable "comparison" {
  type        = string
  default     = "COMPARISON_GT"
  description = "How to compare the log filters versus the threshold value"
}

variable "threshold_value" {
  type        = string
  default     = "0.001"
  description = "Threshold to be compared against"
}

variable "notification_email_list" {
  type = map(string)
  default = {
    ashwani-sharma = "ashwani.sharma@mavenwave.com"
    travis-mcvey   = "travis.mcvey@mavenwave.com"
  }
  description = "Map of a name to an email for notifications."
}
