library(tidyverse)

# TODO

# FTS Funding -------------------------------------------------------------

# "https://fts.unocha.org/download/1496708/download"

fts_raw <- readxl::read_xlsx(
  here::here(
    "data",
    "external",
    "FTS",
    "FTS_Total_reported_funding_by_affected_location_2025_b5022d9d-cd47-47fb-ac96-faff77f49b3c_as_on_2025-05-07.xlsx"
  ),
  sheet = "Export data",
  n_max = 144
)


fts_dat <- fts_raw |>
  janitor::clean_names()

countries_to_exclude <- c(
  "Global",
  "Not specified",
  "Region - Middle East and Northern Africa",
  "Region - Europe",
  "Region - Latin America and the Caribbean",
  "Region - Southern and Eastern Africa",
  "Region - Asia and the Pacific",
  "Region - West and Central Africa",
  "Multiple Countries (shared)"
)


fts_dat <- fts_dat |>
  filter(!(country %in% countries_to_exclude))

fts_dat <- fts_dat |>
  mutate(
    country_clean = country |>
      str_replace("Anguilla \\(United Kingdom\\)", "Anguilla") |>
      str_replace("Aruba \\(Netherlands\\)", "Aruba") |>
      str_replace("Curaçao \\(Netherlands\\)", "Curacao"),
    .after = country
  ) |>
  mutate(
    country_un_code = countrycode::countrycode(
      country_clean,
      "country.name",
      "un"
    ),
    country_un_name = countrycode::countrycode(
      country_clean,
      "country.name",
      "un.name.en"
    ),
    country_iso3c = countrycode::countrycode(
      country_clean,
      "country.name",
      "iso3c"
    ),
    country_iso2c = countrycode::countrycode(
      country_clean,
      "country.name",
      "iso2c"
    )
  )


glimpse()
