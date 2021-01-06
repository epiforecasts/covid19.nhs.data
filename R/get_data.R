
# Download data from NHS Statistics COVID-19 Hospital activity ------------

## Download and save daily Trust- and hospital-level admissions and occupancy data from:
## https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-hospital-activity/

download_trust_data <- function(release_date  = NULL){
  
  nhs_url <- paste0("https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/",
                    lubridate::year(release_date), "/",
                    ifelse(lubridate::month(release_date)<10, 
                           paste0(0,lubridate::month(release_date)),
                           lubridate::month(release_date)),
                    "/Weekly-covid-admissions-and-beds-publication-",
                    gsub("-", "", as.character(format.Date(release_date, format = "%y-%m-%d"))),
                    ".xlsx")
  
  tmp <- file.path(tempdir(), "nhs.xlsx")
  download.file(nhs_url, destfile = tmp, mode = "wb")
  
  sheet_names <- readxl::excel_sheets(tmp)
  
  out <- purrr::map_df(.x = sheet_names, .f = ~{
    
    dat <- suppressMessages(readxl::read_excel(tmp,
                                               sheet = .x,
                                               range = readxl::cell_limits(c(15, 1), c(520, NA)))
    ) %>%
      tibble::tibble()
    
    colnames(dat) <- c(colnames(dat)[1:4], as.character(seq.Date(from = as.Date("2020-08-01"), by = "day", length = ncol(dat)-4)))
    
    out <- dat %>%
      tidyr::pivot_longer(cols = -colnames(dat)[1:4], names_to = "date", values_to = "value") %>%
      dplyr::rename(type1_acute = `Type 1 Acute?`,
                    nhs_region = `NHS England Region`,
                    org_code = Code,
                    org_name = Name) %>%
      dplyr::mutate(type1_acute = ifelse(type1_acute == "Yes", TRUE, FALSE),
                    org_code = ifelse(org_code != "-", org_code, NA),
                    date = as.Date(date),
                    data = .x) %>%
      dplyr::filter(!is.na(org_code)) %>%
      dplyr::select(data, nhs_region, type1_acute, org_code, org_name, date, value)
    
    return(out)
    
  }) %>%
    dplyr::bind_rows()
  
  
  return(out)
  
}

