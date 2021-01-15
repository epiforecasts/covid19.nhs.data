library(knitr)
library(here)

knit(here("data-raw", "create_public_mapping.Rmd"),
     here("vignettes", "create_public_mapping.Rmd"))
