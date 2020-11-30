
# Load LTLA-Trust mapping -------------------------------------------------

get_mapping <- function(simplify = FALSE, p_min = 0.01){
  
  out <- readRDS(file = here::here("data", "trust-ltla-mapping", "trust_ltla_mapping_public.rds"))
  
  if(simplify){
    
    out <- out %>%
      dplyr::filter(p > p_min) %>%
      dplyr::group_by(trust_code, ltla_code) %>%
      dplyr::summarise()
    
  }
  
  return(out)
  
}



# Get Trust and LTLA names ------------------------------------------------

get_names <- function(raw_map){
  
  ## File from https://digital.nhs.uk/services/organisation-data-service/data-downloads/other-nhs-organisations
  trust_names <- readr::read_csv(file = here::here("data", "raw", "england_trusts", "england_trusts.csv"),
                                 col_names = FALSE) %>%
    dplyr::select(trust_code = X1, trust_name = X2) %>%
    dplyr::mutate(trust_code = tolower(trust_code),
                  trust_name = stringr::str_replace(stringr::str_to_title(trust_name), "Nhs", "NHS"))
  
  ## File from https://geoportal.statistics.gov.uk/datasets/3e4f4af826d343349c13fb7f0aa2a307_0
  ltla_names <- readr::read_csv(file = here::here("data", "raw", "england_ltla", "ltla_utla_list.csv"),
                                col_names = TRUE) %>%
    dplyr::select(ltla_code = LTLA19CD, ltla_name = LTLA19NM, utla_code = UTLA19CD, utla_name = UTLA19NM) %>%
    dplyr::mutate(ltla_code = tolower(ltla_code),
                  utla_code = tolower(utla_code))
  
  out <- raw_map %>%
    dplyr::left_join(trust_names, by = "trust_code") %>%
    dplyr::left_join(ltla_names, by = "ltla_code")
  
  return(out)
  
}



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




# Visualise mapping -------------------------------------------------------

summarise_mapping <- function(with_map, with_shp = get_england_shp(), for_trust){
  
  for_trust <- tolower(for_trust)
  
  ## Pull Trust name
  get_names(raw_map = get_mapping()) %>%
    dplyr::filter(trust_code == for_trust) %>%
    pull(trust_name) %>%
    unique() -> plot_title
  
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
    labs(title = plot_title,
         fill = "% of Trust\nhospitalisations") +
    theme_void() +
    theme(legend.position = "bottom", legend.justification = "left")
  
  return(list(summary_table = tb, summary_plot = g))
  
}

