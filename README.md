# Trust-level COVID-19 hospitalisations in England

This repo contains a many-to-many mapping between lower-tier local authority districts (LTLAs) and NHS Acute Trusts in England; details of this mapping (including a summary of the methods and a quick-start guide) can be found in [reports/trust-ltla-mapping-summary](https://github.com/epiforecasts/covid19-uk-hospitalisation-data/tree/main/reports/trust-ltla-mapping-summary).

This repo also has functionality to download trust-level hospital admissions data, published weekly on the [NHS COVID-19 Hospital Activity](https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-hospital-activity/) webpage. Data published on date `YYYY-MM-DD` can be downloaded using the function `download_trust_data(release_date = "YYYY-MM-DD")`; see [R/get_data.R](https://github.com/epiforecasts/covid19-uk-hospitalisation-data/blob/main/R/get_data.R) for details.






