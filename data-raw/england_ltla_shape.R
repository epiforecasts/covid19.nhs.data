pacman::p_load(
  sf,
  here,
  dplyr,
  stringr,
  usethis
)

england_ltla_shape <- sf::read_sf(here::here("data-raw", "raw", "uk_ltla_shp", "ltla_uk.shp")) %>%
  sf::st_transform(27700) %>%
  sf::st_simplify(dTolerance = 100) %>%
  dplyr::filter(str_starts(LAD20CD, "E")) %>%
  dplyr::rename(
    geo_code = LAD20CD,
    geo_name = LAD20NM
  )

# Replace non-ASCII character (degree symbol) with corresponding ASCII code
st_crs(england_ltla_shape)$wkt <- gsub(pattern = "°",
                                       replacement = "\\\u00b0",
                                       x = st_crs(england_ltla_shape)$wkt)

usethis::use_data(england_ltla_shape, overwrite = TRUE)
