% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_admissions.R
\name{get_admissions}
\alias{get_admissions}
\title{Get Hospital Admissions}
\usage{
get_admissions(level = "trust", release_date = Sys.Date(), mapping, geo_names)
}
\arguments{
\item{level}{Character string, defaulting to "trust". Defines the level of aggregation
at which to return the data. Other supported options are "utla" for UTLA level admissions
or "ltla" for LTLA level admissions.}

\item{release_date}{Date, release date of data to download. Will automatically find
the Thursday prior to the date specified.}

\item{mapping}{data.frame containing trust_code, p_trust, geo_code and p_geo.
Defaults to \code{trust_utla_mapping} if not supplied.}

\item{geo_names}{A dataframe containing \code{geo_code} and \code{geo_name}. Used to
assign meaningful to geographies.}
}
\value{
A data.frame of admissions by day either at trust, LTLA or UTLA levels.
}
\description{
Downloads hospital admissions by Hospital trust using
\code{download_trust_data} and then optionally aggregates to either LTLA or UTLA
level. This can be done either with the built in mapping or a user supplied mapping.
}
