pacman::p_load(
  sf,
  here,
  dplyr,
  stringr,
  usethis
)

england_utla_shape <- sf::read_sf(here::here("data-raw", "raw", "uk_utla_shp", "utla_uk.shp")) %>%
  sf::st_transform(27700) %>%
  sf::st_simplify(dTolerance = 100) %>%
  dplyr::filter(str_starts(ctyua19cd, "E")) %>%
  dplyr::rename(
    geo_code = ctyua19cd,
    geo_name = ctyua19nm
  ) %>%
  dplyr::mutate(geo_code = ifelse(geo_code == "E10000002", "E06000060", geo_code))

# Replace non-ASCII character (degree symbol) with corresponding ASCII code
st_crs(england_utla_shape)$wkt <- gsub(pattern = "°",
                                       replacement = "\\\u00b0",
                                       x = st_crs(england_utla_shape)$wkt)

usethis::use_data(england_utla_shape, overwrite = TRUE)
