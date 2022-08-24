#' Get Hospital Admissions
#'
#' @description Downloads hospital admissions by Hospital trust using
#' `download_trust_data` and then optionally aggregates to either LTLA or UTLA
#' level. This can be done either with the built in mapping or a user supplied mapping.
#' 
#' @param keep_vars Character string, defaulting to "new_adm" (first-time COVID-19 hospital admissions). Defines which variables to keep from the raw data. Other supported options are: "all_adm" (for all COVID-19 hospital admissions), and "all_bed" (for all COVID-19 beds occupied). Multiple values allowed.
#' @param level Character string, defaulting to "trust". Defines the level of aggregation
#' at which to return the data. Other supported options are "utla" for UTLA level admissions
#' or "ltla" for LTLA level admissions.
#' @inheritParams download_trust_data 
#' @inheritParams get_names
#' 
#' @importFrom dplyr filter select left_join group_by mutate summarise pull rename
#' @importFrom tidyr pivot_wider
#' @importFrom tibble tibble
#' 
#' @return A data.frame of daily admissions and/or bed occupancy data, reported at the Trust, LTLA or UTLA level. Note that new admissions ("new_adm") are called "admissions" in the data.frame to be consistent with a previous version of this function.
#' @export
get_admissions <- function(keep_vars = "new_adm",
                           level = "trust",
                           release_date = Sys.Date(),
                           mapping,
                           geo_names) {
  
  # Check variables to keep
  keep_vars <- match.arg(keep_vars, several.ok = TRUE,
                         choices = c("all_adm", "new_adm", "all_bed"))
  keep_vars_tb <- tibble(
    var = c("all_adm", "new_adm", "all_bed"),
    var_name = c("Hosp ads & diag", "New hosp cases", "All beds COVID")
  )
  keep_names <- tibble(var = keep_vars) %>%
    left_join(keep_vars_tb, by = "var") %>%
    pull(var_name)
  
  # Check spatial level
  level <- match.arg(level,
                     choices = c("utla", "ltla", "trust"))
  
  # Check mapping
  if (missing(mapping)) {
    if (level %in% "utla") {
      mapping <- covid19.nhs.data::trust_utla_mapping
    } else if (level %in% "ltla") {
      mapping <- covid19.nhs.data::trust_ltla_mapping
    }
  }
  
  # Download Trust-level admissions data
  raw_adm_trust <- download_trust_data(release_date = release_date)
  
  out <- raw_adm_trust %>%
    filter(data %in% keep_names) %>%
    select(trust_code = org_code, date, var_name = data, value) %>% 
    left_join(covid19.nhs.data::trust_names, by = "trust_code") %>% 
    left_join(keep_vars_tb, by = "var_name") %>%
    select(trust_code, trust_name, date, data = var, value)
  
  if (level %in% c("utla", "ltla")) {
    if (missing(geo_names)) {
      if (level %in% c("utla")) {
        geo_names <- covid19.nhs.data::utla_names
      }else if (level %in% "ltla") {
        geo_names <- covid19.nhs.data::ltla_names
      }else{
        geo_names <- NULL
      }
    }
    if (!is.null(geo_names)) {
      mapping <- mapping %>% 
        left_join(geo_names, by = "geo_code")
    }else{
      mapping <- mapping %>% 
        mutate(geo_name = NA)
    }
    
    out <- out %>%
      left_join(mapping, by = "trust_code") %>%
      mutate(value = value * p_trust) %>%
      group_by(geo_code, geo_name, date, data) %>%
      summarise(value = round(sum(value, na.rm = TRUE)),
                .groups = "drop")
    
  }
  
  out <- out %>%
    pivot_wider(names_from = data, values_from = value)
  # Make consistent with previous version of function
  if("new_adm" %in% keep_vars) {
    out <- out %>%
      rename(admissions = new_adm)
  }
  
  return(out)
  
}
