from pathlib import Path

import requests


def download_file(url: str, dest_folder: str | Path) -> Path:
    dest_folder = Path(dest_folder)
    dest_folder.mkdir(parents=True, exist_ok=True)

    filename = Path(url).name
    filepath = dest_folder / filename

    response = requests.get(url)
    response.raise_for_status()
    filepath.write_bytes(response.content)

    return filepath
