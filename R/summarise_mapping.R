#' Summarise Trust Mapping
#'
#' @description Summarise the Trust mapping (currently only supports the UTLA mapping) both
#' graphically and in a table.
#' @param shapefile A shapefile defaults to `england_utla_shape` if not supplied.
#' @param trust A character string indicating a trust of interest. 
#' @param geography  A character string indicating the geography of interest. Only used if 
#' `trust` is not specified. Related to the mapping used so for `trust_utla_mapping`
#' refers to a UTLA. 
#' @inheritParams get_names
#' @importFrom dplyr filter select arrange group_by summarise mutate left_join summarise pull
#' @importFrom ggplot2 ggplot geom_sf aes scale_fill_distiller labs theme_void theme
#' @import sf 
#' @return A table and optional map summarising the admissions mapping. 
#' @export
summarise_mapping <- function(trust = NULL, geography = NULL, mapping, shapefile, geo_names) {
  
  if (is.null(trust) & is.null(geography)) { 
    stop("Either a trust or a geography must be specified")
  }
  
  if (missing(shapefile)){
    shapefile <- england_utla_shape
  }
  if (missing(mapping)) {
    mapping <- trust_utla_mapping
  }
  if (missing(geo_names)) {
    geo_names <- utla_names
  }
  
  if(!is.null(trust)){
    
    trust <- toupper(trust)
    
    ## Pull trust name
    plot_title <- mapping %>% 
      get_names(geo_names = geo_names) %>%
      filter(trust_code == trust) %>%
      pull(trust_name) %>%
      unique()
    
    ## Table summary of mapping
    tb <- mapping %>% 
      filter(trust_code == trust) %>% 
      get_names(geo_names = geo_names) %>%
      select(trust_code, trust_name, geo_code, geo_name, p_trust) %>%
      arrange(-p_trust)
    
    mapping <- mapping %>%
      filter(trust_code == trust) %>%
      group_by(geo_code, p_trust) %>%
      summarise(.groups = "drop") %>%
      mutate(p = 100 * p_trust)
    
    ## Visual summary of mapping
    g <- shapefile %>%
      left_join(mapping, by = "geo_code") %>% 
      ggplot() +
      geom_sf(aes(fill = p), lwd = 0.3, col = "grey20") +
      scale_fill_distiller(palette = "OrRd", direction = 1, na.value = "grey85", limits = c(0, NA)) +
      labs(title = plot_title,
           fill = "% of Trust\nhospitalisations") +
      theme_void() +
      theme(legend.position = "bottom", legend.justification = "left")
    
    return(list(summary_table = tb, summary_plot = g))
  } else if (!is.null(geography)){
    
    geography <- toupper(geography)
  
    ## Table summary of mapping
    tb <- mapping %>% 
      filter(geo_code == geography) %>% 
      get_names(geo_names = geo_names) %>%
      select(geo_code, geo_name, trust_code, trust_name, p_geo) %>%
      arrange(-p_geo)
    
    return(list(summary_table = tb))
  }
}

