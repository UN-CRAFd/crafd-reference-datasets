library(tidyverse)
library(rnaturalearth)
library(sf)

# Countries ---------------------------------------------------------------

# UNSD standard country names
unds <- read_delim("data/external/UNSD — Methodology.csv", delim = ";")
unds <- unds |> janitor::clean_names()

countries <- unds |>
  select(country_UN = country_or_area, iso_alpha2_code, iso_alpha3_code) |>
  arrange(country_UN)


# write_csv(countries, file = "data/output/UNSD_iso_countries.csv")

# Cities ------------------------------------------------------------------

# Download the cities dataset using rnaturalearth package
cities_raw <- ne_download(
  scale = "medium",
  type = "populated_places",
  category = "cultural",
  returnclass = "sf"
)
cities_raw <- cities_raw |>
  janitor::clean_names() |>
  st_set_geometry(NULL) |>
  as_tibble()

cities_dat <- cities_raw |>
  select(
    name,
    city_name_en = name_en,
    sov_a3,
    sov0name,
    adm0_a3,
    adm0name,
    featurecla,
    pop_max
  )

# cities_dat |> count(featurecla, sort = TRUE)

selected_cities <- cities_dat |>
  filter(
    featurecla %in%
      c(
        "Admin-0 capital",
        "Admin-1 capital",
        "Populated place",
        "Admin-1 region capital",
        "Admin-0 region capital"
      )
  )

# Merge -------------------------------------------------------------------

countries_cities <- selected_cities |>
  mutate(
    sov_a3_edit = sov_a3 |>
      str_replace("IS1", "ISR") |>
      str_replace("ALD", "FIN")
  ) |>
  left_join(countries, join_by(sov_a3_edit == iso_alpha3_code), keep = TRUE)

countries_cities <- countries_cities |> drop_na(country_UN)


# Formating ---------------------------------------------------------------

countries_cities <- countries_cities |>
  arrange(country_UN) |>
  mutate(
    city_country = str_glue("{city_name_en}, {country_UN}")
  )


# Export ------------------------------------------------------------------

write_csv(countries_cities_export, "data/output/countries_cities_export.csv")
