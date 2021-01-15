

utla_uk_shape <- sf::read_sf(here::here("data-raw", "raw", "uk_utla_shp", "utla_uk.shp")) %>%
  sf::st_transform(27700) %>%
  sf::st_simplify(dTolerance = 100) %>%
  dplyr::filter(str_starts(ctyua19cd, "E")) %>%
  dplyr::rename(utla_code = ctyua19cd,
                utla_name = ctyua19nm)

usethis::use_data(utla_uk_shape, overwrite = TRUE)
