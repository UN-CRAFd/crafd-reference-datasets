library(tidyverse)

# TODO


# Read Data ---------------------------------------------------------------

# Country Data
dat <- readRDS("data/output/")


# Gender Inequality Index (GII) ----------------------------------------------

# see https://hdr.undp.org/data-center/thematic-composite-indices/gender-inequality-index#/indicies/GII

raw_gii <- readxl::read_xlsx(
  here::here("data", "external", "HDR23-24_Statistical_Annex_GII_Table.xlsx"),
  sheet = "Table 5",
  range = "A9:C204",
  col_names = c("HDI_rank", "country", "GII_value"),
  na = ".."
)

gii_df <- raw_gii |>
  filter(!is.na(HDI_rank)) |>
  select(-HDI_rank) |>
  arrange(GII_value) |>
  rownames_to_column("GII_worldwide_rank")

# standardize country names
gii_df <- gii_df |>
  mutate(
    country_iso3c = countrycode::countrycode(country, "country.name", "iso3c"),
    country_iso2c = countrycode::countrycode(country, "country.name", "iso2c"),
    country_un_code = countrycode::countrycode(country, "country.name", "un"),
  )

# check if any countries could not be matched
gii_df$country_iso3c |>
  is.na() |>
  sum()


gii_final <- gii_df |> select(country_iso3c, GII_value, GII_worldwide_rank)


# Global South Indicator ------------------------------------------------------

global_south <- read_csv(
  here::here("data", "external", "global-south-countries-2024.csv"),
  col_names = c("country", "is_global_south"),
  skip = 1
)


global_south <- global_south |>
  filter(country != "Micronesia") |>
  mutate(
    country_iso3c = countrycode::countrycode(country, "country.name", "iso3c")
  ) |>
  select(-country)


# Fragile Countries -------------------------------------------------------

#### OECD ####

oecd_fragility <- readxl::read_xlsx(
  here::here("data", "external", "List of fragile contexts (2022).xlsx")
)
oecd_fragility <- oecd_fragility |>
  janitor::clean_names() |>
  select(country_iso3c = iso3c, oecd_fragility_level = fragility_level)


#### World Bank 2025 ####

conflict <- tibble(
  country = c(
    "Afghanistan",
    "Burkina Faso",
    "Cameroon",
    "Central African Republic",
    "Congo, Democratic Republic of",
    "Ethiopia",
    "Haiti",
    "Iraq",
    "Lebanon",
    "Mali",
    "Mozambique",
    "Myanmar",
    "Niger",
    "Nigeria",
    "Somalia",
    "South Sudan",
    "Sudan",
    "Syrian Arab Republic",
    "Ukraine",
    "West Bank and Gaza (territory)",
    "Yemen, Republic of"
  ),
  worldbank_fragility_level = "Conflict"
)
institutional_social_fragility <- tibble(
  country = c(
    "Burundi",
    "Chad",
    "Comoros",
    "Congo, Republic of",
    "Eritrea",
    "Guinea-Bissau",
    "Kiribati",
    "Kosovo",
    "Libya",
    "Marshall Islands",
    "Micronesia, Federated States of",
    "Papua New Guinea",
    "São Tomé and Príncipe",
    "Solomon Islands",
    "Timor-Leste",
    "Tuvalu",
    "Venezuela, RB",
    "Zimbabwe"
  ),
  worldbank_fragility_level = "Institutional and Social Fragility"
)

# merge both lists together
worldbank_fragility <- bind_rows(conflict, institutional_social_fragility) |>
  mutate(worldbank_is_fragile = TRUE)

## check for duplicates
# worldbank_fragility$country |> duplicated() |> sum()

worldbank_fragility <- worldbank_fragility |>
  filter(country != "Kosovo") |> # not included in ISO standard
  mutate(
    country_iso3c = countrycode::countrycode(country, "country.name", "iso3c")
  ) |>
  select(-country)


#### US Depart. of State List 2024 ####

us_fragility <- tibble(
  country = c(
    "Haiti",
    "Libya",
    "Mozambique",
    "Papua New Guinea",
    "Benin",
    "Côte d’Ivoire",
    "Ghana",
    "Guinea",
    "Togo"
  ),
  us_designated_fragile = TRUE
)

us_fragility <- us_fragility |>
  mutate(
    country_iso3c = countrycode::countrycode(country, "country.name", "iso3c")
  ) |>
  select(-country)


# Join Data ---------------------------------------------------------------

dat_full <- dat |>
  left_join(gii_final, by = "country_iso3c") |>
  left_join(global_south, by = "country_iso3c") |>
  left_join(oecd_fragility, by = "country_iso3c") |>
  left_join(worldbank_fragility, by = "country_iso3c") |>
  left_join(us_fragility, by = "country_iso3c")

# explicit NAs
dat_full <- dat_full |>
  mutate(
    oecd_fragility_level = oecd_fragility_level |>
      replace_na("Not fragile or Missing"),
    worldbank_fragility_level = worldbank_fragility_level |>
      replace_na("Not listed"),
    worldbank_is_fragile = worldbank_is_fragile |> replace_na(FALSE),
    us_designated_fragile = us_designated_fragile |> replace_na(FALSE)
  )


# Export Data -------------------------------------------------------------

dat_full |>
  # select(GII_value, GII_worldwide_rank) |>
  clipr::write_clip()

saveRDS(dat_full, here::here("data", "output", "country_indicators.rds"))
