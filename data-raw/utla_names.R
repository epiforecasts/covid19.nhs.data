library(readr)
library(dplyr)
library(here)
library(usethis)

## File from https://geoportal.statistics.gov.uk/datasets/3e4f4af826d343349c13fb7f0aa2a307_0
utla_names <- read_csv(file = here("data-raw", "raw", "england_ltla", "ltla_utla_list.csv"), col_names = TRUE) %>%
  select(geo_code = UTLA19CD, geo_name = UTLA19NM) %>%
  unique()

use_data(utla_names, overwrite = TRUE)
