#' Load local authority to Trust mappings
#' 
#' @description Load LTLA- or UTLA-Trust mappings from two data sources: HES (Hospital Episodes Statistics) until September 2020, and linked COVID-19 cases and admissions June 2020 - May 2021. Replaces previous datasets trust_ltla_mapping and trust_utla_mapping (the HES mappings).
#' 
#' @param scale Character string defining the geographical scale. Supported options are "ltla" (lower-tier local authority) and "utla" (upper-tier local authority).
#' @param source Character string defining the souce of the mapping. supported options are "link" (linked COVID-19 cases and admissions) and "hes" (Hospital Episodes Statistics, originally the only mapping available).
#' @importFrom dplyr filter select
#' 
#' @return A data.frame with the following columns: `geo_code` (9-digit LTLA or UTLA ID); `trust_code`; `n` (the number of reported admissions); `p_geo` (the proportion of all admissions from a LTLA/UTLA that go to a given Trust); `p_trust` (the proportion of all admissions to a Trust that come from a given LTLA/UTLA); `source` ("HES" or "Link"); and `level` ("ltla" or "utla").
#' @export
#' 
load_mapping <- function(scale, source) {
  
  # Checks for geographical scale
  if(missing(scale)) {
    message("Parameter missing - specify geographical scale.")
  } else {
    scale <- match.arg(scale, choices = c("ltla", "utla"))
  }
  
  # Checks for data source
  if(missing(source)) {
    message("Parameter missing - specify mapping source.")
  } else {
    
    source <- tolower(source)
    source <- match.arg(source, choices = c("hes", "link"))
    
    if(source == "hes") {
      source <- "HES"
    } else if (source == "link") {
      source <- "Link"
    }
    
  }
  
  # Return mapping
  out <- covid19.nhs.data::mappings %>%
    filter(map_source == source,
           map_level == scale) %>%
    select(-c(map_source, map_level))
  
  return(out)
  
}