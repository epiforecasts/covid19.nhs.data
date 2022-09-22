#' Link Mapping to Trust and Geography Names
#'
#' @param mapping A data.frame containing geo_code, trust_code, p_geo and p_trust.
#' @param geo_names A data.frame containing `geo_code` and `geo_name`. Used to 
#' assign meaningful to geographies.
#' @return A data.frame containing a UTLA to trust level admissions map combined
#' meaningful names.
#' @export
#' @importFrom dplyr left_join select
get_names <- function(mapping, geo_names) {
  
  if (missing(mapping)) {
    stop("Missing mapping - please specify a LTLA- or UTLA-Trust mapping.")
  } else {
    # Geography names checks
    if (missing(geo_names)) {
      stop("Missing geo_names - please specify appropriate geography names.")
    }
  }
  
  out <- mapping %>%
    left_join(covid19.nhs.data::trust_names, by = "trust_code") %>%
    left_join(geo_names, by = "geo_code") %>%
    select(trust_code, trust_name, geo_code, geo_name, p_trust, p_geo)
  
  return(out)
  
}
