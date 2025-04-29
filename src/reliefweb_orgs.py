"""
# ReliefWeb API
Docs: https://apidoc.reliefweb.int/

Scheme: "https://"
Host: "api.reliefweb.int"
Path: "/v1/" <content type> [ "/" <content id> ] "?appname=" <your-app-name>


## Quotas
In order to ensure optimum performance for everyone, the API is restricted in two ways:

The maximum number of entries returned per call is 1000.
The maximum number of calls allowed per day is 1000.

## Organizations
https://reliefweb.int/organizations
"""

from pathlib import Path

import pandas as pd
import requests

# App identifier
APP_NAME = "crafd"

# API endpoint
API_URL = "https://api.reliefweb.int/v1/sources"

# Request parameters
PARAMS = {
    # "appname": APP_NAME,
    "limit": 100,  # 1000 is max
    # "fields[include][]": ["name", "shortname"],
    "fields[include][]": "*",  # select all vars
    "sort[]": "name:asc",
}

# API request
response = requests.get(API_URL, params=PARAMS)
if response.status_code != 200:
    raise Exception(f"Request failed with status: {response.status_code}")

# Extract data
res = response.json()
data = res.get("data", [])

len(data)

# Create DataFrame and normalize the 'fields' column
df = pd.json_normalize(data)
# df = df.rename(columns={"fields.name": "name", "fields.shortname": "shortname"})


len(df.columns)

if not df["id"].is_unique:
    raise Exception("IDs are not unique in the dataset")


#### paginate

# FIXME: what is the true max of all orgs?
# while True:
#     next_link = res.get("links", {}).get("next", {}).get("href")
#     if not next_link:
#         break
#     response = requests.get(next_link)
#     if response.status_code != 200:
#         raise Exception(f"Request failed with status: {response.status_code}")
#     res = response.json()
#     data.extend(res.get("data", []))


# Save CSV
data_folder = Path("data")
output_path = data_folder / "output" / "reliefweb_orgs.csv"
df.to_csv(output_path, index=False)
