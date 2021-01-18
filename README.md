
# Trust-level COVID-19 hospitalisations in England

[![R build
status](https://github.com/epiforecasts/covid19.england.hospitalisations/workflows/R-CMD-check/badge.svg)](https://github.com/epiforecasts/covid19.england.hospitalisations/actions)
[![Codecov test
coverage](https://codecov.io/gh/epiforecasts/covid19.england.hospitalisation/branch/master/graph/badge.svg)](https://codecov.io/gh/epiforecasts/covid19.england.hospitalisation?branch=master)

This package contains a many-to-many mapping between upper-tier local
authority districts (UTLAs) and NHS Acute Trusts in England; details of
this mapping (including a summary of the methods and a quick-start
guide) can be found in
[vignettes/mapping-summary](https://github.com/epiforecasts/covid19-uk-hospitalisation-data/tree/main/vignettes/mapping-summary).

This package also has functionality to download trust-level hospital
admissions data, published weekly on the [NHS COVID-19 Hospital
Activity](https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-hospital-activity/)
webpage. Data published on date `YYYY-MM-DD` can be downloaded using the
function `get_admissions(release_date = "YYYY-MM-DD")`. This function
can also be used to return estimated admissions by UTLA and LTLA. See
`?get_admissions` for details.

## Installation

Install the stable development version of the package using
[`{drat}`](https://epiforecasts.io/drat/):

``` r
install.packages("drat")
drat:::add("epiforecasts")
install.packages("covid19.england.hospitalisations")
```

Install the unstable development version of the package with:

``` r
remotes::install_github("epiforecasts/covid19.england.hospitalisations")
```

## Quick start

Load the package.

``` r
library(covid19.england.hospitalisations)
```

Download the latest admissions mapped to lower-tier local authority
using the default mapping.

``` r
adm <- get_admissions("ltla")
```

``` r
map_admissions(adm, england_ltla_shape)
```

![](README_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->
