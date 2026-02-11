from pathlib import Path
import requests

data_folder = Path("data")

output_folder = data_folder / "input"

url = "https://www3.compareyourcountry.org/states-of-fragility/countries/0/#"


def download_file(url, output_folder):
    response = requests.get(url)
    response.raise_for_status()
    file_path = output_folder / "states_of_fragility.html"
    with open(file_path, "wb") as file:
        file.write(response.content)
    return file_path


download_file(url, data_folder)


# https://www3.compareyourcountry.org/api/secret/dataDownloadSheets


# https://www3.compareyourcountry.org/states-of-fragility/about/0/
# https://github.com/hdesaioecd/oecd-sof-2022-public