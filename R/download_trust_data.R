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
  
  ## Define temporary download location
  tmp <- file.path(tempdir(), "nhs.xlsx")

  ## Current data (defined by release date)
  nhs_url <- paste0(
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

  if (!url.exists(nhs_url)) {

    ## Try last week data
    release_date <- release_date - 7
    nhs_url <- paste0(
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
  
  ## Download data
  download.file(nhs_url, destfile = tmp, mode = "wb")
  sheet_names <- setdiff(excel_sheets(tmp), c("Adult G&A Beds Unoccupied Non", "Adult CC Beds Unoccupied Non"))

  ## Reshape data
  out_current <- map_df(.x = sheet_names, .f = ~ {
    dat <- suppressMessages(read_excel(tmp,
      sheet = .x,
      range = cell_limits(c(15, 1), c(522, NA))
    )) %>%
      tibble()

    colnames(dat) <- c(
      colnames(dat)[1:4],
      as.character(seq.Date(
        from = as.Date("2022-04-01"),
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
  
  ## "Weekly Admissions and Beds from 1 October 2021 up to 31 March 2022 (XLSX, 2.6MB)"
  nhs_url_3 <- paste0(
    "https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2022/05",
    "/Weekly-covid-admissions-and-beds-publication-",
    "220512_211001to220331-1.xlsx"
  )
  
  download.file(nhs_url_3, destfile = tmp, mode = "wb")
  sheet_names <- setdiff(excel_sheets(tmp), c("Adult G&A Beds Unoccupied Non",
                                              "Adult CC Beds Unoccupied Non",
                                              "Data quality notes"))
  
  out_3 <- map_df(.x = sheet_names, .f = ~ {
    dat <- suppressMessages(read_excel(tmp,
                                       sheet = .x,
                                       range = cell_limits(c(15, 1), c(522, NA))
    )) %>%
      tibble()
    
    colnames(dat) <- c(
      colnames(dat)[1:4],
      as.character(seq.Date(
        from = as.Date("2021-10-01"),
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
  
  ## "Weekly Admissions and Beds from 7 April up to 30 September 2021 (XLSX, 1.1MB)"
  nhs_url_2 <- paste0(
    "https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2021/12",
    "/Weekly-covid-admissions-and-beds-publication-",
    "211209-210407-210930.xlsx"
  )
  
  download.file(nhs_url_2, destfile = tmp, mode = "wb")
  sheet_names <- setdiff(excel_sheets(tmp), c("Adult G&A Beds Unoccupied Non", "Adult CC Beds Unoccupied Non"))
  
  out_2 <- map_df(.x = sheet_names, .f = ~ {
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
  
  
  ## "Weekly Admissions and Beds up to 6 April 2021 (XLSX, 4.0MB)"
  nhs_url_1 <- paste0(
    "https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2021/04",
    "/Weekly-covid-admissions-and-beds-publication-",
    "210429-up-to-210406.xlsx"
  )
  
  download.file(nhs_url_1, destfile = tmp, mode = "wb")
  sheet_names <- setdiff(excel_sheets(tmp), c("Adult G&A Beds Unoccupied Non", "Adult CC Beds Unoccupied Non"))
  
  out_1 <- map_df(.x = sheet_names, .f = ~ {
    dat <- suppressMessages(read_excel(tmp,
                                       sheet = .x,
                                       range = cell_limits(c(15, 1), c(522, NA))
    )) %>%
      tibble()
    
    colnames(dat) <- c(
      colnames(dat)[1:4],
      as.character(seq.Date(
        from = as.Date(
          ifelse((grepl("G&A", .x) | grepl("CC", .x)),
                 "2020-11-17",
                 "2020-08-01")
        ),
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
  
  ## Combine three files, filter by release date
  out <- out_current %>%
    bind_rows(out_3) %>%
    bind_rows(out_2) %>%
    bind_rows(out_1) %>%
    filter(date <= release_date) %>%
    arrange(data, nhs_region, org_code, date)

  return(out)
}
