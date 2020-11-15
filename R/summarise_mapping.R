
# Visualise mapping -------------------------------------------------------

summarise_mapping <- function(with_map, for_trust){
  
  for_trust <- tolower(for_trust)
  
  ## Table summary of mapping
  tb <- with_map %>%
    dplyr::filter(trust_code == for_trust) %>%
    dplyr::mutate(p = 100*p) %>%
    dplyr::arrange(source, -p)
  
  with_map <- with_map %>%
    dplyr::filter(trust_code == for_trust,
                  !is.na(p)) %>%
    dplyr::group_by(ltla_code, p) %>%
    dplyr::summarise(.groups = "drop") %>%
    dplyr::mutate(p = 100*p)
  
  ## Visual summary of mapping
  g <- with_shp %>%
    dplyr::left_join(with_map, by = "ltla_code") %>%
    ggplot() +
    geom_sf(aes(fill = p), lwd = 0.3, col = "grey20") +
    scale_fill_distiller(palette = "OrRd", direction = 1, na.value = "grey85", limits = c(0, NA)) +
    labs(fill = "% of Trust\nhospitalisations") +
    theme_void() +
    theme(legend.position = "bottom", legend.justification = "left")
  
  return(list(table = tb, plot = g))
  
}
