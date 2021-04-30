#' Download English Hospital Trust Admissions Data
#'
#' @description Downloads English hospital admissions data by Trust. Data is released
#' each Thursday. See here for details:
#' https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-hospital-activity/
#' @param release_date Date, release date of data to download. Will automatically find
#' the Thursday prior to the date specified.
#'
#' @return A data.frame of hospital admissions by trust.
#' @export
#' @importFrom lubridate floor_date year month as_date
#' @importFrom RCurl url.exists
#' @importFrom readxl excel_sheets cell_limits read_excel
#' @importFrom purrr map_df
#' @importFrom tibble tibble
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr mutate rename filter select bind_rows
#' @importFrom utils download.file
download_trust_data <- function(release_date = Sys.Date()) {

  ## Revert to the last Thursday
  release_date <- as_date(release_date)
  release_date <- floor_date(release_date, unit = "week", week_start = 4)
  
  # Data until 06 April 2021 (inclusive)
  nhs_past_url <- paste0(
    "https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/",
    year(release_date), "/",
    ifelse(month(release_date) < 10,
           paste0(0, month(release_date)),
           month(release_date)
    ),
    "/Weekly-covid-admissions-and-beds-publication-",
    gsub("-", "", as.character(format.Date(release_date, format = "%y-%m-%d"))),
    "-up-to-210406",
    ".xlsx"
  )

  # Data from 07 April 2021 (inclusive)
  nhs_current_url <- paste0(
    "https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/",
    year(release_date), "/",
    ifelse(month(release_date) < 10,
      paste0(0, month(release_date)),
      month(release_date)
    ),
    "/Weekly-covid-admissions-and-beds-publication-",
    gsub("-", "", as.character(format.Date(release_date, format = "%y-%m-%d"))),
    ".xlsx"
  )

  if (!url.exists(nhs_current_url)) {

    ## Try last week data
    release_date <- release_date - 7
    nhs_current_url <- paste0(
      "https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/",
      year(release_date), "/",
      ifelse(month(release_date) < 10,
        paste0(0, month(release_date)),
        month(release_date)
      ),
      "/Weekly-covid-admissions-and-beds-publication-",
      gsub("-", "", as.character(format.Date(release_date, format = "%y-%m-%d"))),
      ".xlsx"
    )
  }

  tmp <- file.path(tempdir(), "nhs.xlsx")
  
  # Download past data 
  download.file(nhs_past_url, destfile = tmp, mode = "wb")
  sheet_names <- setdiff(excel_sheets(tmp), c("Adult G&A Beds Unoccupied Non", "Adult CC Beds Unoccupied Non"))

  out_past <- map_df(.x = sheet_names, .f = ~ {
    dat <- suppressMessages(read_excel(tmp,
      sheet = .x,
      range = cell_limits(c(15, 1), c(522, NA))
    )) %>%
      tibble()

    colnames(dat) <- c(
      colnames(dat)[1:4],
      as.character(seq.Date(
        from = as.Date(ifelse((grepl("G&A", .x) | grepl("CC", .x)), "2020-11-17", "2020-08-01")),
        by = "day", length = ncol(dat) - 4
      ))
    )

    out <- dat %>%
      pivot_longer(cols = -colnames(dat)[1:4], names_to = "date", values_to = "value") %>%
      rename(
        type1_acute = `Type 1 Acute?`,
        nhs_region = `NHS England Region`,
        org_code = Code,
        org_name = Name
      ) %>%
      mutate(
        type1_acute = ifelse(type1_acute == "Yes", TRUE, FALSE),
        org_code = ifelse(org_code != "-", org_code, NA),
        date = as.Date(date),
        data = .x
      ) %>%
      filter(!is.na(org_code)) %>%
      select(data, nhs_region, type1_acute, org_code, org_name, date, value)
    return(out)
  }) %>%
    bind_rows()
  
  # Download recent data
  download.file(nhs_current_url, destfile = tmp, mode = "wb")
  sheet_names <- setdiff(excel_sheets(tmp), c("Adult G&A Beds Unoccupied Non", "Adult CC Beds Unoccupied Non"))
  
  out_recent <- map_df(.x = sheet_names, .f = ~ {
    dat <- suppressMessages(read_excel(tmp,
                                       sheet = .x,
                                       range = cell_limits(c(15, 1), c(522, NA))
    )) %>%
      tibble()
    
    colnames(dat) <- c(
      colnames(dat)[1:4],
      as.character(seq.Date(
        from = as.Date("2021-04-07"),
        by = "day", length = ncol(dat) - 4
      ))
    )
    
    out <- dat %>%
      pivot_longer(cols = -colnames(dat)[1:4], names_to = "date", values_to = "value") %>%
      rename(
        type1_acute = `Type 1 Acute?`,
        nhs_region = `NHS England Region`,
        org_code = Code,
        org_name = Name
      ) %>%
      mutate(
        type1_acute = ifelse(type1_acute == "Yes", TRUE, FALSE),
        org_code = ifelse(org_code != "-", org_code, NA),
        date = as.Date(date),
        data = .x
      ) %>%
      filter(!is.na(org_code)) %>%
      select(data, nhs_region, type1_acute, org_code, org_name, date, value)
    return(out)
  }) %>%
    bind_rows()
  
  out <- out_past %>%
    bind_rows(out_recent)

  return(out)
}
