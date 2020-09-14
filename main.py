"""This script imports a google sheet and inputs
it into BigQuery"""
from __future__ import print_function
import base64
import sys
import os.path
#import csv
import pandas as pd
import logging
import json
from datetime import date
from googleapiclient.discovery import build
from google.oauth2 import service_account
from google.cloud import bigquery

# If modifying these scopes, delete the file token.pickle.
scopes = ['https://www.googleapis.com/auth/spreadsheets.readonly']

class SheetService:
    """
      Main Sheet class to handle all sheet operations.
    """
    def __init__(self, sheet_version='v4', credentials=None):
        """ Initialize the class for the api versions etc..

        Args:
            compute_version_id: The compute api version to use. Defaults to v1
            resource_version_id: The cloud resource manager version to use. Defaults to v1
            max_results: The max number of results to fetch in each call to the API. Defaults to 500
        """
        if credentials:
            self.sheet_client = build('sheets', sheet_version,
              credentials=credentials, cache_discovery=False)
            self.bq_client = bigquery.Client()
        else:
            self.sheet_client = build('sheets',
              sheet_version, cache_discovery=False)
            self.bq_client = bigquery.Client()
        self.sheets = self.sheet_client.spreadsheets()
        self.logger = logging.getLogger(__name__)
        self.errors = []
        self.columns = []
        self.values = []


    def _set_values(self, sheet_id, sheet_range):
        """ Calls the Sheet API to get the actual results of the sheets

        Args:
            sheet_id: The google sheet id we want to grab
            sheet_range: the range of which we require.
        """
        try:
            result = self.sheets.values().get(spreadsheetId=sheet_id,
                                    range=sheet_range).execute()
            self.columns = result.get('values',[]).pop(0)
            for i in range(0,len(self.columns)):
                self.columns[i] = self.columns[i].replace(' ','_')

            self.values = result.get('values', [])
        except Exception as ex:
            message = "An exception occured attempting to \
              open sheet {} on range {} with message {}".format(sheet_id,sheet_range, ex)
            self.logger.error(message)
            sys.exit()

    def load_into_bq(self,table_id,date_append=True):
        """ Uploads the presumably CSV file to the given gcs bucket
        appends current date for a new table to keep historical information
        """
        if date_append:
            table_id = "{}_{}".format(table_id, date.today().strftime("%Y%m%d"))
        
        dataFrame = pd.DataFrame(data=self.values,columns=self.columns)

        print("Starting on table: {}".format(table_id))
        job_config = bigquery.LoadJobConfig(
            autodetect=True,
            write_disposition="WRITE_TRUNCATE")
        job = self.bq_client.load_table_from_dataframe(dataFrame,
            table_id, job_config=job_config)

        job.result()
        destination_table = self.bq_client.get_table(table_id)  # Make an API request.
        print("Loaded {} rows.".format(destination_table.num_rows))

    def workflow(self, sheet_id, sheet_range, csv_name, table_id):
        """ Runs the full workflow of gathering the sheet and data

        Args:
            sheet_id: The google sheet id we want to grab
            sheet_range: the range of which we require.
        """
        logging.info("workflow starting for sheet_id: %s, range: %s, \
                      csv_name: %s, table_id: %s", sheet_id,
                      sheet_range, csv_name, table_id)
        self._set_values(sheet_id=sheet_id, sheet_range=sheet_range)
        self.load_into_bq(table_id=table_id)

def wrapper(sample_data,credentials=None):
    """To make local testing mirror a Cloud function as much as possible
    have both call the same wrapper.
    """
    for cur_sheet in sample_data["sheets"]:
        logging.info("Initializing sheet service for cur_sheet: {}".format(cur_sheet))
        sheet_service = SheetService(sheet_version='v4', credentials=credentials)
        logging.info("SheetService initialized, begining workflow".format(cur_sheet))
        sheet_service.workflow(sample_data["sheet_id"],
          sheet_range=cur_sheet["range"],
          csv_name=cur_sheet["name"]+".csv",
          table_id="{}.{}".format(sample_data["data_set"],cur_sheet["name"]))

        if not sheet_service.values:
            print('No data found.')
        else:
            print("sucessfully completed current sheet: {}".format(cur_sheet))

def sheet_pubsub(event, context):
    """Background Cloud Function to be triggered by Pub/Sub.
    Args:
          event (dict):  The dictionary with data specific to this type of
          event. The `data` field contains the PubsubMessage message. The
          `attributes` field will contain custom attributes if there are any.
          context (google.cloud.functions.Context): The Cloud Functions event
          metadata. The `event_id` field contains the Pub/Sub message ID. The
          `timestamp` field contains the publish time.
    """

    print("""This Function was triggered by messageId {} published at {}
    """.format(context.event_id, context.timestamp))

    if 'data' in event:
        # Grab and decode the payload
        payload = base64.b64decode(event['data']).decode('utf-8')
        sheet_info = json.loads(payload)
        print("Sheet info: {}".format(sheet_info))
        wrapper(sample_data=sheet_info)
    else:
        print("No data found in event. Exiting.")

def main():
    """If Main is executed you are doing this locally and will need the json file
      if being executed via the cloud function we should have the permissions within the
      service account executing the function.
    """
    # The ID and range of a sample spreadsheet.
    sample_data = {
        "sheet_id" : "1oRULNbJj5sG7HsVvA4ySD5w3LOX_P_-g5nvazkk2z58",
        "data_set" : "ic-iaprep-mgmt-project-a4d4.mck_dc_workloads",
        "sheets" : [
                {"name": "dc_cogent", "range": "Cogent Dashboard!F1:J25"},
                {"name": "dc_markham", "range": "Markham Dashboard!F1:J25"},
        ]
    }
    logging.info("Executing via main, looking for a credentials file")
    if os.path.exists('credentials.json'):
        secret_file = os.path.join(os.getcwd(), 'credentials.json')
        credentials = service_account.Credentials.from_service_account_file(
          secret_file, scopes=scopes)
        wrapper(sample_data=sample_data, credentials=credentials)

    else:
        logging.error("No credential file found, running in Google?")
        wrapper(sample_data=sample_data)

if __name__ == '__main__':
    main()
    sys.exit()
