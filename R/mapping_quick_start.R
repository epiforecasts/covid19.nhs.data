
# Load UTLA-Trust mapping -------------------------------------------------

get_mapping <- function(){
  
  out <- readRDS(file = here::here("data", "trust-ltla-mapping", "trust_utla_mapping_public.rds"))
  
  return(out)
  
}



# Get Trust and UTLA names ------------------------------------------------

get_names <- function(raw_map){
  
  ## File (NHS Trusts; etr) from https://digital.nhs.uk/services/organisation-data-service/data-downloads/other-nhs-organisations
  trust_names <- readr::read_csv(file = here::here("data", "raw", "england_trusts", "trust_list.csv"),
                                 col_names = FALSE) %>%
    dplyr::select(trust_code = X1, trust_name = X2) %>%
    dplyr::mutate(trust_name = stringr::str_replace(stringr::str_to_title(trust_name), "Nhs", "NHS"))
  
  ## File from https://geoportal.statistics.gov.uk/datasets/3e4f4af826d343349c13fb7f0aa2a307_0
  utla_names <- readr::read_csv(file = here::here("data", "raw", "england_ltla", "ltla_utla_list.csv"),
                                col_names = TRUE) %>%
    dplyr::select(utla_code = UTLA19CD, utla_name = UTLA19NM) %>%
    unique()
  
  out <- raw_map %>%
    dplyr::left_join(trust_names, by = "trust_code") %>%
    dplyr::left_join(utla_names, by = "utla_code") %>%
    dplyr::select(trust_code, trust_name, utla_code, utla_name, p_trust, p_utla)
  
  return(out)
  
}



# Load England shapefile --------------------------------------------------

get_england_shp <- function(){
  
  out <- sf::read_sf(here::here("data", "raw", "uk_utla_shp", "utla_uk.shp")) %>%
    sf::st_transform(27700) %>%
    sf::st_simplify(dTolerance = 100) %>%
    dplyr::filter(str_starts(ctyua19cd, "E")) %>%
    dplyr::rename(utla_code = ctyua19cd,
                  utla_name = ctyua19nm)
  
}




# Visualise mapping -------------------------------------------------------

summarise_mapping <- function(with_map, with_shp = get_england_shp(), for_trust = NULL, for_utla = NULL){
  
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

