"""
# FTS API / Financial Tracking Service (FTS) by OCHA
https://fts.unocha.org/content/fts-public-api
-> https://api.hpc.tools/docs/v2/

Swagger/OpenAPI schema: https://api.hpc.tools/api-docs

https://fts.unocha.org/content/about-fts-using-fts-data


## HDX
https://data.humdata.org/m/organization/ocha-fts


https://fts.unocha.org/donors/memberstates

"""

# Example --- Grouped view: Germany, Government of 2025
# https://fts.unocha.org/donor-grouped/4306/flows/2025

from pathlib import Path

import pandas as pd
import requests

# Define the API endpoint
API_URL = "https://api.hpc.tools/v1/public/fts/flow"
PARAMS = {
    # Subsidiary organizations
    "filterBy[0]": "sourceOrganizationId:4306",
    "filterBy[1]": "sourceOrganizationId:2987",
    "filterBy[2]": "sourceOrganizationId:6544",
    "filterBy[3]": "sourceOrganizationId:13808",
    "year": 2025,
    "boundary": "incoming",
    "report": 4,
    "format": "json",
    "limit": 1000,
}

# Send the GET request
response = requests.get(API_URL, params=PARAMS)

# Check response and parse
if response.status_code == 200:
    data = response.json().get("data", [])
    flows = data.get("flows", [])

    # Convert to DataFrame
    df = pd.json_normalize(flows)
else:
    print(f"Error {response.status_code}: {response.text}")


# Save CSV
data_folder = Path("data")
output_path = data_folder / "output" / "fts" / "fts_api_grouped_germany.csv"
df.to_csv(output_path, index=False)


# ------------------------------------------------------

df.columns
df[["description"]]

filtered_df = df[df["description"].str.contains("data", na=False)]
filtered_df
