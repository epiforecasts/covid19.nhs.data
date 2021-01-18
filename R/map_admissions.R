#' Map Admissions
#'
#' @description Map NHS Hospital aggregated admissions. By default this maps the
#' latest data provided.
#' @param admissions A data.frame of admissions data as produced by `get_dadmissions`. 
#' Must contain the following variables: `geo_code`, `date`, and `admissions`
#' @param date A date variable indicating when to plot data for. 
#' @param scale_fill A `ggplot2` `scale_fill` used to define the fill colours 
#' used in the map. The default is: `scale_fill_viridis_c(option = "cividis", direction = -1)`.
#' @inheritParams summarise_mapping
#' @importFrom ggplot2 ggplot geom_sf aes scale_fill_viridis_c labs theme_void theme guides guide_colorbar
#' @importFrom dplyr filter
#' @import sf 
#' @return A map of Covid-19 admissions in England 
#' @export
map_admissions <- function(admissions, shapefile, date, scale_fill) {
  
  if (missing(date)) {
    max_date <- max(admissions$date)
  }else{
    max_date <- date
  }
  
  if (missing(scale_fill)) {
    scale_fill <- scale_fill_viridis_c(option = "cividis", direction = -1)
  }
  
  admissions <- admissions %>% 
    filter(date == max_date)
  
  g <- shapefile %>%
    left_join(admissions, by = "geo_code") %>% 
    ggplot() +
    geom_sf(aes(fill = admissions), lwd = 0.3, col = "grey20") +
    scale_fill +
    theme_void() +
    guides(fill = guide_colorbar(title = "Admissions")) +
    theme(legend.position = "bottom", legend.justification = "left")

  return(g)
}

