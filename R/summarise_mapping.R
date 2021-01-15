#' Summarise Trust Mapping
#'
#' @param with_map 
#' @param shapefile 
#' @param for_trust 
#' @param for_utla 
#'
#' @return
#' @export
#'
#' @examples
summarise_mapping <- function(with_map, shapefile = utla_shape, for_trust = NULL, for_utla = NULL){
  
  if (missing(shapefile) {
    shapefile <- utla_uk_shape
  }
  if(!is.null(for_trust)){
    
    for_trust <- toupper(for_trust)
    
    ## Pull Trust name
    get_names(raw_map = get_mapping()) %>%
      dplyr::filter(trust_code == for_trust) %>%
      pull(trust_name) %>%
      unique() -> plot_title
    
    ## Table summary of mapping
    tb <- get_names(raw_map = with_map %>%
                      dplyr::filter(trust_code == for_trust)) %>%
      dplyr::select(trust_code, trust_name, utla_code, utla_name, p_trust) %>%
      dplyr::arrange(-p_trust)
    
    with_map <- with_map %>%
      dplyr::filter(trust_code == for_trust) %>%
      dplyr::group_by(utla_code, p_trust) %>%
      dplyr::summarise(.groups = "drop") %>%
      dplyr::mutate(p = 100*p_trust)
    
    ## Visual summary of mapping
    g <- with_shp %>%
      dplyr::left_join(with_map, by = "utla_code") %>%
      ggplot() +
      geom_sf(aes(fill = p), lwd = 0.3, col = "grey20") +
      scale_fill_distiller(palette = "OrRd", direction = 1, na.value = "grey85", limits = c(0, NA)) +
      labs(title = plot_title,
           fill = "% of Trust\nhospitalisations") +
      theme_void() +
      theme(legend.position = "bottom", legend.justification = "left")
    
    return(list(summary_table = tb, summary_plot = g))
    
  } else if (!is.null(for_utla)){
    
    for_utla <- toupper(for_utla)
    
    ## Table summary of mapping
    tb <- get_names(raw_map = with_map %>%
                      dplyr::filter(utla_code == for_utla)) %>%
      dplyr::select(utla_code, utla_name, trust_code, trust_name, p_utla) %>%
      dplyr::arrange(-p_utla)
    
    return(list(summary_table = tb))
  }
}

