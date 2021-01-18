#' Map Admissions
#'
#' @description Map NHS Hospital aggregated admissions. By default this maps the
#' latest data provided.
#' @param admissions A data.frame of admissions data as produced by `get_dadmissions`. 
#' Must contain the following variables: `geo_code`, `date`, and `admissions`
#' @inheritParams summarise_mapping
#' @importFrom ggplot2 ggplot geom_sf aes scale_fill_distiller labs theme_void theme
#' @importFrom dplyr filter
#' @import sf 
#' @return A map of Covid-19 admissions in England 
#' @export
map_admissions <- function(admissions, shapefile, date) {
  
  if (missing(date)) {
    max_date <- max(admissions$date)
  }else{
    max_date <- date
  }
  
  admissions <- admissions %>% 
    filter(date == max_date)
  
  g <- shapefile %>%
    left_join(admissions, by = "geo_code") %>% 
    ggplot() +
    geom_sf(aes(fill = admissions), lwd = 0.3, col = "grey20") +
    scale_fill_distiller(palette = "OrRd", direction = 1, na.value = "grey85", limits = c(0, NA)) +
    theme_void() +
    theme(legend.position = "bottom", legend.justification = "left")

  return(g)
}

