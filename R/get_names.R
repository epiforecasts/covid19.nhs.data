#' Link Mapping to Trust and Geography Names
#'
#' @param mapping data.frame containing trust_code, p_trust, geo_code and p_geo. 
#' Defaults to `trust_utla_mapping` if not supplied.
#' @param geo_names A dataframe containing `geo_code` and `geo_name`. Used to 
#' assign meaningful to geographies.
#' @return A data.frame containing a UTLA to trust level admissions map combined
#' meaningful names.
#' @export
#' @importFrom dplyr left_join select
get_names <- function(mapping, geo_names) {
  if (missing(geo_names)) {
    geo_names <- utla_names
  }
  out <- mapping %>%
    left_join(trust_names, by = "trust_code") %>%
    left_join(geo_names, by = "geo_code") %>%
    select(trust_code, trust_name, geo_code, geo_name, p_trust, p_geo)
  return(out)
}
