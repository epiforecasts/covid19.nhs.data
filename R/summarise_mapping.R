#' Summarise Trust Mapping
#'
#' @description Summarise the Trust mapping (currently only supports the UTLA mapping) both
#' graphically and in a table.
#' @param shapefile A shapefile defaults to `uk_utla_shape` if not supplied.
#' @param trust A character string indicating a trust of interest. 
#' @param utla  A character string indicating the UTLA of interest. Only used if 
#' `trust` is not specified. 
#' @inheritParams get_names
#' @importFrom dplyr filter select arrange group_by summarise mutate left_join summarise pull
#' @importFrom ggplot2 ggplot geom_sf aes scale_fill_distiller labs theme_void theme
#' @return A table and optional map summarising the admissions mapping. 
#' @export
summarise_mapping <- function(trust = NULL, utla = NULL, mapping, shapefile) {
  
  if (missing(shapefile)){
    shapefile <- uk_utla_shape
  }
  if (missing(mapping)) {
    mapping <- trust_utla_mapping
  }
  
  if(!is.null(trust)){
    
    trust <- toupper(trust)
    
    ## Pull Trust name
    plot_title <- mapping %>% 
      get_names() %>%
      filter(trust_code == trust) %>%
      pull(trust_name) %>%
      unique()
    
    ## Table summary of mapping
    tb <- mapping %>% 
      filter(trust_code == trust) %>% 
      get_names() %>%
      select(trust_code, trust_name, utla_code, utla_name, p_trust) %>%
      arrange(-p_trust)
    
    mapping <- mapping %>%
      filter(trust_code == trust) %>%
      group_by(utla_code, p_trust) %>%
      summarise(.groups = "drop") %>%
      mutate(p = 100 * p_trust)
    
    ## Visual summary of mapping
    g <- shapefile %>%
      left_join(mapping, by = "utla_code") %>%
      ggplot() +
      geom_sf(aes(fill = p), lwd = 0.3, col = "grey20") +
      scale_fill_distiller(palette = "OrRd", direction = 1, na.value = "grey85", limits = c(0, NA)) +
      labs(title = plot_title,
           fill = "% of Trust\nhospitalisations") +
      theme_void() +
      theme(legend.position = "bottom", legend.justification = "left")
    
    return(list(summary_table = tb, summary_plot = g))
  } else if (!is.null(utla)){
    
    utla <- toupper(utla)
  
    ## Table summary of mapping
    tb <- mapping %>% 
      filter(utla_code == utla) %>% 
      get_names() %>%
      select(utla_code, utla_name, trust_code, trust_name, p_utla) %>%
      arrange(-p_utla)
    
    return(list(summary_table = tb))
  }
}

