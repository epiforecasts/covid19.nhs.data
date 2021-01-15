#' Get Hospital Admissions
#'
#' @description Downloads hospital admissions by Hospital trust using
#' `download_trust_data` and then optionally aggregates to either LTLA or UTLA
#' level. This can be done either with the built in mapping or a user supplied mapping.
#' @param level Character string, defaulting to "trust". Defines the level of aggregation
#' at which to return the data. Other supported options are "utla" for UTLA level admissions
#' or "ltla" for LTLA level admissions.
#' @inheritParams download_trust_data 
#' @inheritParams get_names
#' @importFrom dplyr filter select left_join group_by mutate summarise
#' @return A data.frame of admissions by day either at trust, LTLA or UTLA levels.
#' @export
get_admissions <- function(level = "trust", release_date = Sys.Date(), mapping) {
  
  level <- match.arg(level, choices = c("utla", "ltla", "trust"))

  if (missing(mapping)) {
    if (level %in% "utla") {
      mapping <- trust_utla_mapping
    } else if (level %in% "ltla") {
      mapping <- trust_ltla_mapping
    }
  }

  # Download Trust-level admissions data
  raw_adm_trust <- download_trust_data(release_date = release_date)

  adm <- raw_adm_trust %>%
    filter(type1_acute, data == "New hosp cases") %>%
    select(trust_code = org_code, date, admissions = value)

  if (level %in% c("utla", "ltla")) {
    adm <- adm %>%
      left_join(mapping, by = "trust_code") %>%
      mutate(admissions = admissions * p_trust) %>%
      group_by(geo_code, date) %>%
      summarise(admissions = round(sum(admissions, na.rm = TRUE)))
  }
  return(adm)
}
