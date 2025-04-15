from pathlib import Path

import pandas as pd
import requests

data_folder = Path("data")

# HDX API endpoint for organization list
url = "https://data.humdata.org/api/3/action/organization_list"

response = requests.get(url)
org_list = response.json().get("result")

orgs = pd.DataFrame(org_list, columns=["organization"])
orgs.to_csv(data_folder / "output" / "hdx_organizations.csv", index=False)
