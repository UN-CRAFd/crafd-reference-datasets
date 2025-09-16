# UNSDG Expenditure --------------------------------------------------------

library(tidyverse)

unds <- read_csv(here::here(
  "data",
  "output",
  "full_country_list_with_stats.csv"
))

colnames(unds)

unsdg_expenditures <- read_csv(
  here::here("data", "external", "unsdg_expenditures.csv")
)



unsdg_expenditures <- unsdg_expenditures |> janitor::clean_names()


unsdg_expenditures <- unsdg_expenditures |>
  left_join(unds, by = join_by("iso3" == "iso_alpha3_code"))


unsdg_expenditures |> write_csv("data/output/unsdg_country_spending.csv")
