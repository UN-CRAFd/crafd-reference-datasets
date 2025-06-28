"""
Extract Participating Organizations from MPTFO
https://mptf.undp.org/partners/organizations

https://mptf.undp.org/mptf_rest_api/
see analyze-all-data.js in page source
"""

import json
from pathlib import Path

import pandas as pd
import requests

# Constants
API_URL = (
    "https://mptf.undp.org/mptf_rest_api/getAnalyzeAllProjects/"
    ",implementing_agent_group_description,FUCOUNT,BUDGET,NET_FUNDED,"
    "EXPENDITURE,delivery_rate,/fromYear:2016,toYear:2025,--budget:DESC"
)
HEADERS = {
    "drupal-page-url": "/partners/organizations",
    "Referer": "https://mptf.undp.org/partners/organizations",
}

# Fetch and parse response
response = requests.get(API_URL, headers=HEADERS)
# The API returns a JSON-encoded string
payload = json.loads(response.json())

# Normalize to DataFrame
data = payload.get("data", [])
df = pd.DataFrame(data)

# Save CSV
data_folder = Path("data")
output_path = data_folder / "output" / "mptf_participating_orgs.csv"
df.to_csv(output_path, index=False)

# --------------------------------------------------------

org_names = df[["ORGANIZATION", "implementing_agent_group_description"]]
