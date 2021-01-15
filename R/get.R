#' Link Mapping to Trust and UTLA Names
#'
#' @param raw_map data.frame
#'
#' @return A data.frame containing a UTLA to trust level admissions map combined 
#' meaningful names.
#' @export
#' @importFrom dplyr left_join select
#' @examples
get_names <- function(raw_map){
  out <- raw_map %>%
    left_join(trust_names, by = "trust_code") %>%
    left_join(utla_names, by = "utla_code") %>%
    select(trust_code, trust_name, utla_code, utla_name, p_trust, p_utla)
  return(out)
}
