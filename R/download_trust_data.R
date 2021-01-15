#' Download UK Hospital Trust Admissions Data
#'
#' @description Downloads UK hospital admissions data by Trust. Data is released 
#' each Thursday. See here for details: 
#' https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-hospital-activity/
#' @param release_date Date, release date of data to download. Will automatically find 
#' the Thursday prior to the date specified.
#'
#' @return A data.frame of hospital admissions by trust.
#' @export
#' @importFrom lubridate floor_date year month 
#' @importFrom RCurl url.exists
#' @importFrom readxl excel_sheets cell_limits
#' @importFrom purrr map_df
#' @importFrom tibble tibble
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr mutate rename filter select bind_rows
download_trust_data <- function(release_date = Sys.Date()){
  
  ## Revert to the last Thursday 
  release_date <- floor_date(release_date, unit = "week", week_start = 4)
  
  nhs_url <- paste0("https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/",
                    year(release_date), "/",
                    ifelse(month(release_date)<10, 
                           paste0(0,month(release_date)),
                           month(release_date)),
                    "/Weekly-covid-admissions-and-beds-publication-",
                    gsub("-", "", as.character(format.Date(release_date, format = "%y-%m-%d"))),
                    ".xlsx")
  
  if(!RCurl::url.exists(nhs_url)){
    
    ## Try last week data
    release_date <- release_date - 7
    nhs_url <- paste0("https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/",
                      year(release_date), "/",
                      ifelse(month(release_date)<10, 
                             paste0(0,month(release_date)),
                             month(release_date)),
                      "/Weekly-covid-admissions-and-beds-publication-",
                      gsub("-", "", as.character(format.Date(release_date, format = "%y-%m-%d"))),
                      ".xlsx")
    
  }
  
  tmp <- file.path(tempdir(), "nhs.xlsx")
  download.file(nhs_url, destfile = tmp, mode = "wb")
  
  sheet_names <- excel_sheets(tmp)
  
  out <- map_df(.x = sheet_names, .f = ~{
    
    dat <- suppressMessages(read_excel(tmp,
                                       sheet = .x,
                                       range = cell_limits(c(15, 1), c(520, NA)))
    ) %>%
      tibble()
    
    colnames(dat) <- c(colnames(dat)[1:4], 
                       as.character(seq.Date(from = as.Date("2020-08-01"), 
                                             by = "day", length = ncol(dat)-4)))
    
    out <- dat %>%
      pivot_longer(cols = -colnames(dat)[1:4], names_to = "date", values_to = "value") %>%
      rename(type1_acute = `Type 1 Acute?`,
             nhs_region = `NHS England Region`,
             org_code = Code,
             org_name = Name) %>%
      mutate(type1_acute = ifelse(type1_acute == "Yes", TRUE, FALSE),
             org_code = ifelse(org_code != "-", org_code, NA),
             date = as.Date(date),
             data = .x) %>%
      filter(!is.na(org_code)) %>%
      select(data, nhs_region, type1_acute, org_code, org_name, date, value)
    return(out)
  }) %>%
    bind_rows()
  
  return(out)
}

