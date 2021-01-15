#' Link Mapping to Trust and UTLA Names
#'
#' @param mapping data.frame containing trust_code, p_trust, utla_code and p_utla. 
#' Defaults to `trust_utla_mapping` if not supplied.
#' @return A data.frame containing a UTLA to trust level admissions map combined
#' meaningful names.
#' @export
#' @importFrom dplyr left_join select
get_names <- function(mapping) {
  out <- mapping %>%
    left_join(trust_names, by = "trust_code") %>%
    left_join(utla_names, by = "utla_code") %>%
    select(trust_code, trust_name, utla_code, utla_name, p_trust, p_utla)
  return(out)
}
