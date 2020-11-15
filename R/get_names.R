
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
