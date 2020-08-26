# Sheets-csv

Goal of this project is to take a google sheet, convert to CSV and upload to a gcp bucket for big query to consume.

## Prerequisite

* Google Sheets API enabled within the project
* Service account within the Project with JSON credentials
* Service account email granted permission to the Sheet in question.

## Authenticating with BigQuery

BigQuery utilizes `GOOGLE_APPLICATION_CREDENTIALS` environment variable. The Makefile is going to pass this into the container, it should be as so:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=credentials.json
make execute
```
