
# Load England shapefile --------------------------------------------------

get_england_shp <- function(){
  
  out <- sf::read_sf(here::here("data", "raw", "uk_ltla_shp", "ltla_uk.shp")) %>%
    sf::st_transform(27700) %>%
    sf::st_simplify(dTolerance = 100) %>%
    dplyr::filter(str_starts(lad19cd, "E")) %>%
    dplyr::rename(ltla_code = lad19cd,
                  ltla_name = lad19nm) %>%
    dplyr::mutate_if(is.character, tolower)
  
}
