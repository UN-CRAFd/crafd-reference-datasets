from pathlib import Path

import pandas as pd

input_path = Path("data") / "external" / "UNSD — Methodology.csv"
# Prevent "NA" (Namibia's ISO code) from being interpreted as NaN
df = pd.read_csv(input_path, sep=";", keep_default_na=False, na_values=[""])


df = df.rename(
    columns={
        "Global Code": "global_code",
        "Global Name": "global_name",
        "Region Code": "region_code",
        "Region Name": "region_name",
        "Sub-region Code": "sub_region_code",
        "Sub-region Name": "sub_region_name",
        "Intermediate Region Code": "intermediate_region_code",
        "Intermediate Region Name": "intermediate_region_name",
        "Country or Area": "country_or_area",
        "M49 Code": "m49_code",
        "ISO-alpha2 Code": "iso_alpha2",
        "ISO-alpha3 Code": "iso_alpha3",
        "Least Developed Countries (LDC)": "is_ldc",
        "Land Locked Developing Countries (LLDC)": "is_lldc",
        "Small Island Developing States (SIDS)": "is_sids",
    }
)

# Replace empty strings with None (will become NULL in PostgreSQL)
df = df.replace("", None)

# Convert boolean columns from 'x' markers to proper booleans
boolean_cols = ["is_ldc", "is_lldc", "is_sids"]
for col in boolean_cols:
    df[col] = df[col].notna()

# Convert code columns to integers (where appropriate)
code_cols = [
    "global_code",
    "region_code",
    "sub_region_code",
    "intermediate_region_code",
    "m49_code",
]
for col in code_cols:
    df[col] = pd.to_numeric(df[col], errors="coerce").astype("Int64")

# Ensure string columns are proper strings (strip whitespace)
string_cols = [
    "global_name",
    "region_name",
    "sub_region_name",
    "intermediate_region_name",
    "country_or_area",
    "iso_alpha2",
    "iso_alpha3",
]
for col in string_cols:
    df[col] = df[col].str.strip() if df[col].dtype == "object" else df[col]

# Convert categorical columns to category dtype for better performance and memory usage
categorical_cols = [
    "global_name",
    "region_name",
    "sub_region_name",
    "intermediate_region_name",
]
for col in categorical_cols:
    if df[col].notna().any():  # Only if column has values
        df[col] = df[col].astype("category")


# Save cleaned dataset
output_path = Path("data") / "output" / "unsd_m49_countries.csv"
df.to_csv(output_path, index=False)

print(f"\n✓ Cleaned dataset saved to {output_path}")
print("\nData types:")
print(df.dtypes)


# Export to public directory for API
public_path = Path("public")
public_path.mkdir(parents=True, exist_ok=True)

# Export as CSV
csv_export_path = public_path / "unsd_m49_countries.csv"
df.to_csv(csv_export_path, index=False)
print(f"✓ Exported to {csv_export_path}")

# Export as JSON
json_export_path = public_path / "unsd_m49_countries.json"
df.to_json(json_export_path, orient="records", indent=2)
print(f"✓ Exported to {json_export_path}")


# ISO 3166-1 Alpha-2 (-> Primary Key)

# ISO 3166-1 Numeric
# Three-digit numeric codes [language neutrality]
