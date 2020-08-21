"""This script imports a google sheet and inputs
it into BigQuery"""
from __future__ import print_function
import base64
import sys
import os.path
import logging
from googleapiclient.discovery import build
from google.oauth2 import service_account

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
            self.service = build('sheets', sheet_version, credentials=credentials)
        else:
            self.service = build('sheets', sheet_version)
        self.sheets = self.service.spreadsheets()
        self.logger = logging.getLogger(__name__)
        self.errors = []
        self.values = []

    def _get_values(self, sheet_id, sheet_range):
        """ Calls the Sheet API to get the actual results of the sheets

        Args:
            sheet_id: The google sheet id we want to grab
            sheet_range: the range of which we require.
        """
        try:
            result = self.sheets.values().get(spreadsheetId=sheet_id,
                                    range=sheet_range).execute()
            values = result.get('values', [])
            return values
        except Exception as ex:
            message = "An exception occured attempting to \
              open sheet {} on range {} with message {}".format(sheet_id,sheet_range, ex)
            self.logger.error(message)
            sys.exit()



    def workflow(self,sheet_id, sheet_range):
        """ Runs the full workflow of gathering the sheet and data

        Args:
            sheet_id: The google sheet id we want to grab
            sheet_range: the range of which we require.
        """
        self.values = self._get_values(sheet_id, sheet_range)

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
        sheet_info = base64.b64decode(event['data']).decode('utf-8')

        # Convert the payload into a dictionary
        sheet_service = SheetService()
        sheet_service.workflow(sheet_id=sheet_info["id"],sheet_range=["range"])

def main():
    """If Main is executed you are doing this locally and will need the json file
      if being executed via the cloud function we should have the permissions within the
      service account executing the function.
    """
    # The ID and range of a sample spreadsheet.
    sample_spreadsheet_id = '1oRULNbJj5sG7HsVvA4ySD5w3LOX_P_-g5nvazkk2z58'
    sample_range = 'Programs!A1:I15'
    logging.info("Executing via main, looking for a credentials file")
    if os.path.exists('credentials.json'):
        secret_file = os.path.join(os.getcwd(), 'credentials.json')
        credentials = service_account.Credentials.from_service_account_file(
          secret_file, scopes=scopes)

        sheet_service = SheetService(sheet_version='v4', credentials=credentials)
        sheet_service.workflow(sheet_id=sample_spreadsheet_id,sheet_range=sample_range)

        if not sheet_service.values:
            print('No data found.')
        else:
            print('Name, Major:')
            for row in sheet_service.values:
                # Print columns A and E, which correspond to indices 0 and 4.
                print('%s, %s' % (row[0], row[4]))
    else:
        logging.error("No credential file found, Exiting!")
        sys.exit()

if __name__ == '__main__':
    main()
    sys.exit()
