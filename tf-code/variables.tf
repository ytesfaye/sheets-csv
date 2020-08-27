variable "region" {
  type    = string
  default = "us-central1"
}

variable "project_id" {
  type    = string
  default = "my-project-1"
}

variable "prefix" {
  type    = string
  default = ""
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
  SELECT main_table.DC, 
  Program.Count AS Planned_InFlight_Migration,
  SUM(Sunset_in_Place) AS Sunset_in_Place , 
  SUM( Migrate_to_Azure) AS Migrate_to_Azure ,
  SUM( Modernization) AS Modernization,
  SUM( Migrate_to_GCP) AS Migrate_to_GCP,
  main_table.Date
  FROM (
        SELECT  DISTINCT CASE WHEN Source = 'UNIPRIX2' OR Source = 'UNIPRIX1' THEN 'UNIPRIX' ELSE Source END As DC, 
        
        (countif(Sunset_in_Place = 'TRUE')) AS Sunset_in_Place, 
        countif(Migrate_to_Azure = 'TRUE') AS Migrate_to_Azure,  
        countif(Modernization = 'TRUE') AS Modernization,
        countif(Migrate_to_GCP = 'TRUE') AS Migrate_to_GCP,
        PARSE_DATE("%Y%m%d",_TABLE_SUFFIX) as Date 
        FROM `ic-iaprep-mgmt-project-a4d4.mck_dc_workloads.dc_all_*`
        GROUP BY Source, _TABLE_SUFFIX ) AS main_table
        JOIN  
        (
           SELECT  DISTINCT Upper(Data_Center) As DC, 
           countif(Data_Center = Data_Center) AS Count, 
           PARSE_DATE("%Y%m%d",_TABLE_SUFFIX) as Date 
           FROM `ic-iaprep-mgmt-project-a4d4.mck_dc_workloads.dc_program_*` 
           GROUP BY  Data_Center, _TABLE_SUFFIX
           ORDER BY Date
        ) AS Program ON main_table.DC = UPPER(Program.DC) 
        AND main_table.Date =  Program.Date 
  GROUP BY DC, Date,Planned_InFlight_Migration
EOF
    mck_dc_all_workloads = <<EOF
SELECT  'Cogent' as dc, Unconfirmed_App, Application, Disposition, CAST(Server_Count AS INT64) AS Server_Count , CAST(Desktop_Count AS INT64) AS Desktop_Count ,PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date FROM `ic-iaprep-mgmt-project-a4d4.mck_dc_workloads.dc_cogent_*` union all 
SELECT  'Markham' as dc,Unconfirmed_App, Application, Disposition, CAST(Server_Count AS INT64) AS Server_Count , CAST(Desktop_Count AS INT64) AS Desktop_Count ,PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date FROM `ic-iaprep-mgmt-project-a4d4.mck_dc_workloads.dc_markham_*` union all 
SELECT  'Unipri' as dc, Unconfirmed_App, Application, Disposition, CAST(Server_Count AS INT64) AS Server_Count , CAST(Desktop_Count AS INT64) AS Desktop_Count ,PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date FROM `ic-iaprep-mgmt-project-a4d4.mck_dc_workloads.dc_uniprix_*` union all 
SELECT  'Viscount' as dc, Unconfirmed_App, Application, Disposition, CAST(Server_Count AS INT64) AS Server_Count , CAST(Desktop_Count AS INT64) AS Desktop_Count ,PARSE_DATE('%Y%m%d',_TABLE_SUFFIX) as Date FROM `ic-iaprep-mgmt-project-a4d4.mck_dc_workloads.dc_viscount_*`
EOF
  }
}
