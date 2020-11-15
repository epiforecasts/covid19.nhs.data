
# Load LTLA-Trust mapping -------------------------------------------------

get_mapping <- function(simplify = FALSE, p_min = 0.01){
  
  out <- readRDS(file = here::here("data", "trust_ltla_mapping_public.rds"))
  
  if(simplify){
    
    out <- out %>%
      dplyr::filter(p > p_min) %>%
      dplyr::group_by(trust_code, ltla_code) %>%
      dplyr::summarise()
    
  }
  
  return(out)
  
}
