from pathlib import Path

import pandas as pd
import requests
from bs4 import BeautifulSoup

data_folder = Path("data")

url = "https://www.un.org/en/about-us/un-system"

# add headers to avoid 403 ERROR
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}
response = requests.get(url, headers=headers)

with open(data_folder / "input" / "un_system.html", "w", encoding="utf-8") as file:
    file.write(response.text)

#############################################################

# TODO: add external processing here


#############################################################

df = pd.read_csv(data_folder / "output" / "un_system.csv")
