"""
# https://drmkc.jrc.ec.europa.eu/inform-index/INFORM-Risk/Results-and-data
# Download: https://drmkc.jrc.ec.europa.eu/inform-index/Portals/0/InfoRM/2025/INFORM_Risk_2025_v070.xlsx
"""

from pathlib import Path

import pandas as pd

from src.utils import download_file

data_folder = Path("data")
xlsx_file = data_folder / "input" / "INFORM_Risk_2025_v070.xlsx"

if not (xlsx_file).exists():
    download_file(
        url="https://drmkc.jrc.ec.europa.eu/inform-index/Portals/0/InfoRM/2025/INFORM_Risk_2025_v070.xlsx",
        dest_folder=data_folder / "input",
    )

####

raw = pd.read_excel(
    xlsx_file,
    sheet_name="Indicator Source",
    header=1,  # skip first row
)

# drop superflous rows Survey Year and Unit of Measurament
df = raw.drop(index=[0, 1])

# drop columns
df = df.drop(columns=["COUNTRY", "ISO3"])

# reshape to long format, only keep indicator and unique sources
sources = (
    df.melt(var_name="indicator", value_name="sources")
    .groupby("indicator", sort=False, as_index=False)["sources"]
    .apply(lambda x: x.dropna().unique().tolist())
)

### Export

sources.to_csv(
    data_folder / "output" / "INFORM_Risk_sources.tsv", index=False, sep="\t"
)


### Descriptives

# count occurrences of each source
# NOTE: keep combined sources (modeled indicators)
source_counts = sources.explode("sources")["sources"].value_counts()
source_counts

source_counts_df = source_counts.reset_index()
source_counts_df.to_csv(
    data_folder / "output" / "INFORM_Risk_sources_counts.tsv", index=False, sep="\t"
)
