import pandas as pd
from pathlib import Path

# Load the cleaned data (prevent "NA" from being interpreted as NaN)
df = pd.read_csv("data/output/unsd_m49_countries.csv", keep_default_na=False, na_values=[""])

print("=== DATA QUALITY CHECKS ===\n")

# Check for duplicates in m49_code
print(f"1. Duplicate M49 codes: {df['m49_code'].duplicated().sum()}")
if df['m49_code'].duplicated().any():
    print(df[df['m49_code'].duplicated(keep=False)][['m49_code', 'country_or_area']])

# Check for missing critical data
print(f"\n2. Missing values:")
print(df[['m49_code', 'iso_alpha2', 'iso_alpha3', 'country_or_area']].isna().sum())

# Check for rows without ISO codes (might be regions, not countries)
no_iso = df[df['iso_alpha2'].isna() | df['iso_alpha3'].isna()]
print(f"\n3. Rows without ISO codes: {len(no_iso)}")
if len(no_iso) > 0:
    print(no_iso[['country_or_area', 'm49_code', 'iso_alpha2', 'iso_alpha3']].head(10))

# Check ISO code lengths
print(f"\n4. ISO-alpha2 length issues:")
iso2_lengths = df[df['iso_alpha2'].notna()]['iso_alpha2'].str.len()
if (iso2_lengths != 2).any():
    print(f"   Non-2-char codes: {(iso2_lengths != 2).sum()}")
    print(df[df['iso_alpha2'].notna() & (df['iso_alpha2'].str.len() != 2)][['country_or_area', 'iso_alpha2']])
else:
    print("   All ISO-alpha2 codes are 2 characters ✓")

print(f"\n5. ISO-alpha3 length issues:")
iso3_lengths = df[df['iso_alpha3'].notna()]['iso_alpha3'].str.len()
if (iso3_lengths != 3).any():
    print(f"   Non-3-char codes: {(iso3_lengths != 3).sum()}")
    print(df[df['iso_alpha3'].notna() & (df['iso_alpha3'].str.len() != 3)][['country_or_area', 'iso_alpha3']])
else:
    print("   All ISO-alpha3 codes are 3 characters ✓")

# Check for duplicate ISO codes
print(f"\n6. Duplicate ISO codes:")
print(f"   iso_alpha2 duplicates: {df['iso_alpha2'].duplicated().sum()}")
print(f"   iso_alpha3 duplicates: {df['iso_alpha3'].duplicated().sum()}")

# Sample data
print(f"\n7. Sample rows:")
print(df.head(5).to_string())

print(f"\n8. Value counts for key columns:")
print(f"   Total rows: {len(df)}")
print(f"   Unique countries: {df['country_or_area'].nunique()}")
print(f"   Unique regions: {df['region_name'].nunique()}")
print(f"   Unique sub-regions: {df['sub_region_name'].nunique()}")
