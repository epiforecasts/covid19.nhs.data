library(readr)
library(dplyr)
library(here)
library(stringr)
library(usethis)

# File (NHS Trusts; etr) from https://digital.nhs.uk/services/organisation-data-service/data-downloads/other-nhs-organisations
trust_names <- read_csv(file = here("data-raw", "raw", "england_trusts", "trust_list.csv"), col_names = FALSE) %>%
  select(trust_code = X1, trust_name = X2) %>%
  mutate(trust_name = str_replace(str_to_title(trust_name), "Nhs", "NHS"))

use_data(trust_names, overwrite = TRUE)
