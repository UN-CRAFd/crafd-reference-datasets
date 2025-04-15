from pathlib import Path

import pandas as pd
import requests
from bs4 import BeautifulSoup

data_folder = Path("data")

## Get HTML

url = "https://unstats.un.org/sdgs/dataContacts/"
html_file = data_folder / "input" / "sdg_data_contacts.html"

if not html_file.exists():
    response = requests.get(url)
    html_file.parent.mkdir(parents=True, exist_ok=True)
    with open(html_file, "w", encoding="utf-8") as file:
        file.write(response.text)

with open(html_file, "r", encoding="utf-8") as file:
    soup = BeautifulSoup(file, "html.parser")

#### Scraping

div_content = soup.find("div", class_="col-md-8")
panels = div_content.find_all("div", class_="panel-heading panelSDGs-contacts")

data = []

for panel in panels:
    heading_tag = panel.find("h4")
    heading = heading_tag.get_text(strip=True) if heading_tag else None

    content = []
    sibling = panel.find_next_sibling()

    while sibling:
        sibling_classes = sibling.get("class", [])
        if (
            "panel-heading" in sibling_classes
            and "panelSDGs-contacts" in sibling_classes
        ):
            break

        if sibling.name == "div" and "panel-body" in sibling_classes:
            content.append(sibling)  # Keep raw tag

        sibling = sibling.find_next_sibling()

    if heading and content:
        data.append({"indicator": heading, "panel-body": content})


## Post-Process

df = pd.DataFrame(data)


# NOTE: only looks for one per group
def extract_agency(panel_bodies):
    for body in panel_bodies:
        h5_tags = body.find_all("h5")
        for tag in h5_tags:
            if tag.text.strip().startswith("Agency:"):
                return tag.text.strip().replace("Agency:", "").strip()
    return None


# NOTE: only looks for one per group
def extract_website(panel_bodies):
    for body in panel_bodies:
        h5_tags = body.find_all("h5")
        for tag in h5_tags:
            if tag.text.strip().startswith("Website:"):
                link = tag.find("a")
                if link:
                    return link.get("href")
    return None


df["agency"] = df["panel-body"].apply(extract_agency)
df["website"] = df["panel-body"].apply(extract_website)

df.fillna("N/A", inplace=True)
df.drop(columns=["panel-body"], inplace=True)

## Export

df.to_csv(data_folder / "output" / "sdg_indicators_custodian_agencies.csv", index=False)
