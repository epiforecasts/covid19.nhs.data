% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/download_trust_data.R
\name{download_trust_data}
\alias{download_trust_data}
\title{Download English Hospital Trust Admissions Data}
\usage{
download_trust_data(release_date = Sys.Date())
}
\arguments{
\item{release_date}{Date, release date of data to download. Will automatically find
the Thursday prior to the date specified.}
}
\value{
A data.frame of hospital admissions by trust.
}
\description{
Downloads English hospital admissions data by Trust. Data is released
each Thursday. See here for details:
https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-hospital-activity/
}
