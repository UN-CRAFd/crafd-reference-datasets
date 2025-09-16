## Standard country or area codes for statistical use (M49) ##

# This is the online version of the United Nations publication
# "Standard Country or Area Codes for Statistical Use" originally
# published as Series M, No. 49 and now commonly referred to as the M49 standard.
# The print version of the standard was issued last in 1999 and previously
# in 1996 , 1982 , 1975 and 1970 .
#
# M49 is prepared by the Statistics Division of the United Nations
# Secretariat primarily for use in its publications and databases.

# https://unstats.un.org/unsd/methodology/m49/

# The names of countries or areas refer to their short form used in day-to-day
# operations of the United Nations and not necessarily to their official
# name as used in formal documents.
# These names are based on the United Nations Terminology Database (UNTERM)

## three-digit alphabetical codes assigned by the International Organization for Standardization (ISO).1
# International Standard ISO 3166-1, Codes for the representation of names of countries and
# their subdivisions--Part 1: Country codes, ISO 3166-1: 2006 (E/F),
# International Organization on Standardization (Geneva, 2006).
# The latest version is available online at http://www.iso.org/iso/home/standards/country_codes.htm.

## Geographic Regions ##
# The list of geographic regions presents the composition of geographical regions
# used by the Statistics Division in its publications and databases.
# Each country or area is shown in one region only.
# These geographic regions are based on continental regions;
# which are further subdivided into sub-regions and intermediary regions
# drawn as to obtain greater homogeneity in sizes of population,
# demographic circumstances and accuracy of demographic statistics.

library(tidyverse)

# Read --------------------------------------------------------------------

unds_raw <- read_delim("data/external/UNSD — Methodology.csv", delim = ";")

unds <- unds_raw |> janitor::clean_names()
unds <- unds |>
  select(
    country = country_or_area,
    everything(),
    -global_code,
    -global_name
  )

# names(unds)

# Wrangle -----------------------------------------------------------------

unds <- unds |>
  mutate(
    is_LDC = case_when(
      least_developed_countries_ldc == "x" ~ TRUE,
      .default = FALSE
    ),
    is_LLDC = case_when(
      land_locked_developing_countries_lldc == "x" ~ TRUE,
      .default = FALSE
    ),
    is_SIDS = case_when(
      small_island_developing_states_sids == "x" ~ TRUE,
      .default = FALSE
    )
  ) |>
  select(
    -least_developed_countries_ldc,
    -land_locked_developing_countries_lldc,
    -small_island_developing_states_sids
  )


# G77 ---------------------------------------------------------------------

# http://www.fc-ssc.org/en/partnership_program/south_south_countries
# https://www.g77.org/doc/members.html

g77 <- read_csv("data/external/g77_list.csv", skip = 1)

# add iso codes
g77 <- g77 |>
  mutate(
    iso_alpha3_code = countrycode::countrycode(country, "country.name", "iso3c")
  )

# add indicator variable
unds <- unds |>
  mutate(
    is_G77 = if_else(iso_alpha3_code %in% g77$iso_alpha3_code, TRUE, FALSE)
  )

# EU Members -----------------------------------------------------------------

# https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Glossary:European_Union_(EU)

EU_countries <- tibble(
  country = c(
    "Austria",
    "Belgium",
    "Bulgaria",
    "Croatia",
    "Cyprus",
    "Czechia",
    "Denmark",
    "Estonia",
    "Finland",
    "France",
    "Germany",
    "Greece",
    "Hungary",
    "Ireland",
    "Italy",
    "Latvia",
    "Lithuania",
    "Luxembourg",
    "Malta",
    "Netherlands",
    "Poland",
    "Portugal",
    "Romania",
    "Slovakia",
    "Slovenia",
    "Spain",
    "Sweden"
  )
)


# add iso codes
EU_countries <- EU_countries |>
  mutate(
    iso_alpha3_code = countrycode::countrycode(country, "country.name", "iso3c")
  )

# add indicator variable
unds <- unds |>
  mutate(
    is_EU = if_else(
      iso_alpha3_code %in% EU_countries$iso_alpha3_code,
      TRUE,
      FALSE
    )
  )

# G20 -------------------------------------------------------------------------

# https://en.wikipedia.org/wiki/G20#Members

g20 <- tibble(
  country = c(
    "United States",
    "United Kingdom",
    "Turkey",
    "South Korea",
    "South Africa",
    "Saudi Arabia",
    "Russia",
    "Mexico",
    "Japan",
    "Italy",
    "Indonesia",
    "India",
    "Germany",
    "France",
    "European Union",
    "China",
    "Canada",
    "Brazil",
    "Australia",
    "Argentina",
    "African Union"
  )
)


# add iso codes
g20 <- g20 |>
  filter(!country %in% c("African Union", "European Union")) |>
  mutate(
    iso_alpha3_code = countrycode::countrycode(country, "country.name", "iso3c")
  )

# add indicator variable
unds <- unds |>
  mutate(
    is_G20 = if_else(iso_alpha3_code %in% g20$iso_alpha3_code, TRUE, FALSE)
  )

# African Union -------------------------------------------------------------------------

# https://au.int/en/member_states/countryprofiles2
# N = 55

AU_members <- read_tsv("data/external/AU_members.csv")
AU_members <- AU_members |> select(country = `Member State`)

# add iso codes
AU_members <- AU_members |>
  mutate(
    country = country |>
      str_replace("Sahrawi Arab Democratic Republic", "Western Sahara"),
    iso_alpha3_code = countrycode::countrycode(country, "country.name", "iso3c")
  )

# add indicator variable
unds <- unds |>
  mutate(
    is_AU = if_else(
      iso_alpha3_code %in% AU_members$iso_alpha3_code,
      TRUE,
      FALSE
    )
  )

# P5 -------------------------------------------------------------------------

# https://main.un.org/securitycouncil/en/content/current-members

p5_countries <- tibble(
  country = c(
    "China",
    "France",
    "Russian Federation",
    "United Kingdom",
    "United States"
  )
)

# add iso codes
p5_countries <- p5_countries |>
  mutate(
    iso_alpha3_code = countrycode::countrycode(country, "country.name", "iso3c")
  )

# add indicator variable
unds <- unds |>
  mutate(
    is_P5 = if_else(
      iso_alpha3_code %in% p5_countries$iso_alpha3_code,
      TRUE,
      FALSE
    )
  )

# UN Members -------------------------------------------------------------------------

# https://ourworldindata.org/grapher/united-nations-membership-status
# Retrieved from https://www.un.org/en/about-us/member-states

UN_members <- read_csv(
  "data/external/united-nations-membership-status.csv",
  skip = 1
)
UN_members <- UN_members |> janitor::clean_names()

UN_members <- UN_members |>
  filter(year == 2022) |>
  filter(united_nations_membership_status == "Member") |>
  select(country = entity, iso_alpha3_code = code)


# add indicator variable
unds <- unds |>
  mutate(
    is_UN_member = if_else(
      iso_alpha3_code %in% UN_members$iso_alpha3_code,
      TRUE,
      FALSE
    )
  )


# OECD Members ---------------------------------------------------------------

# https://www.oecd.org/en/about/members-partners.html
# N = 38 member countries

OECD_members <- read_csv("data/external/OECD_members.csv")

OECD_members <- OECD_members |>
  mutate(
    iso_alpha3_code = countrycode::countrycode(country, "country.name", "iso3c")
  )


# add indicator variable
unds <- unds |>
  mutate(
    is_OECD = if_else(
      iso_alpha3_code %in% OECD_members$iso_alpha3_code,
      TRUE,
      FALSE
    )
  )


# World Bank Income Groups ---------------------------------------------------

# The World Bank classifies economies for analytical purposes into four income groups:
# low, lower-middle, upper-middle, and high income

# subject to change, status of 2024

# https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups
# Download: https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups

world_bank_raw <- readxl::read_excel(
  here::here("data", "external", "WorldBank_CLASS_2025_07_02.xlsx"),
  sheet = "List of economies"
)
world_bank <- world_bank_raw |> janitor::clean_names()

world_bank <- world_bank |>
  # other aggregates afterwards
  head(n = 218) |>
  select(
    iso_alpha3_code = code,
    world_bank_income_group = income_group,
    world_bank_lending_category = lending_category
  )


unds <- unds |> left_join(world_bank, by = "iso_alpha3_code")


# UN Political Regional Groups --------------------------------------------

# https://www.un.org/dgacm/en/content/regional-groups
# https://www.un.org/en/model-united-nations/groups-member-states

regional_groups <- read_csv("data/external/UN_regional_groups.csv", skip = 3)

regional_groups <- regional_groups |>
  mutate(
    iso_alpha3_code = countrycode::countrycode(country, "country.name", "iso3c")
  ) |>
  rename(
    UN_regional_group = regional_group
  ) |> select(-country)


unds <- unds |> left_join(regional_groups, by = "iso_alpha3_code")


# OECD States of Fragility ------------------------------------------------

raw_oecd_fragility <- readxl::read_xlsx(
  here::here("data", "external", "OECD_States of Fragility_2025.xlsx"),
  sheet = "Economic Fragility",
  skip = 2
)

fragile_countries <- tibble(country = colnames(raw_oecd_fragility[-1]))

oecd_fragility <- fragile_countries |>
  as_tibble() |>
  mutate(
    iso_alpha3_code = countrycode::countrycode(
      country,
      "country.name",
      "iso3c"
    ),
    oecd_fragile_state = TRUE
  ) |>
  select(-country)

unds <- unds |> left_join(oecd_fragility, by = "iso_alpha3_code")


# Export ------------------------------------------------------------------

# View(unds)

# Export to CSV
output_path <- here::here("data", "output", "full_country_list_with_stats.csv")
unds |> write_csv(output_path)
