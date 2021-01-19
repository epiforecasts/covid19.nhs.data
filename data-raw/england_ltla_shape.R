library(sf)
library(dplyr)
library(usethis)
library(here)
library(stringr)

england_ltla_shape <- sf::read_sf(here::here("data-raw", "raw", "uk_ltla_shp", "ltla_uk.shp")) %>%
  sf::st_transform(27700) %>%
  sf::st_simplify(dTolerance = 100) %>%
  dplyr::filter(str_starts(LAD20CD, "E")) %>%
  dplyr::rename(
    geo_code = LAD20CD,
    geo_name = LAD20NM
  )

usethis::use_data(england_ltla_shape, overwrite = TRUE)
