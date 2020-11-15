# Mapping local authorities to NHS Acute Trusts in England


## Summary

This repo provides a many-to-many mapping between lower-tier local authority districts to NHS Acute Trusts in England, as defined by hospital locations and hospital admissions during the COVID-19 pandemic. This mapping can be used to match LTLA-level data, such as testing data, to hospital admissions and other related data that is typically provided at the Trust level.

The mapping contains the following variables:

* `trust_code`: the three-digit organisation code for NHS Trusts.
* `ltla_code`: the nine-digit identifier (LTLA19CD) for lower-tier local authorities in England.
* `source`: the source of the mapping, one of `hospital_postcode`, `patient_postcode` (either CHESS or CO-CIN) or `utla_final_match`; details below.
* `p`: the proportion of patients in a given Trust whose home address is in the given LTLA. This column is `NA` for `source = hospital_postcode` or `source = utla_final_match`.


## Quick start

Load the quick-start functions with `source("R/quick_start.R")`:

```r
source("R/quick_start.R")
```

Load the raw mapping with `get_mapping()`:

``` r
get_mapping()
```

Add Trust names and local authority names to the raw mapping with `get_names()`:

``` r
get_names(raw_map = get_mapping())
```

Summarise the mapping for a given Trust (as defined by the Trust organisation code) with `summarise_mapping()`:

```r
summarise_mapping(with_map = get_mapping(), for_trust = "r0a")
```
Please note that this mapping will not reflect Trust-LTLA pairs where `source == "hospital_postcode"` or `source == "utla_final_match"`.



## Methods

We aimed to create a COVID-19-specific mapping between NHS Acute Trusts and lower-tier local authority districts (LTLAs) where all Trusts are mapped to at least one LTLA and all LTLAs are mapped to at least one Trust.

### Data

We used three main sources of data to create this mapping:

* A list of NHS hospitals, the hospitals' postcodes, and the codes and names of the Trust to which each hospital belongs.
* CHESS (COVID-19 Hospitalisation in England Surveillance System) linelist. 
* CO-CIN (COVID-19 Clinical Information Network) linelist.

The CHESS linelist contains patients' outcodes (the first half of a UK postcode) and the CO-CIN linelist contains patients' full postcodes. Both the CHESS and CO-CIN linelists contain information about where patients were admitted from (e.g. home, care home, hospital transfer, ...). We used only patients who were admitted to hospital from home.

### Matching LTLAs to NHS Trusts

We use the R library [postcodeioR](https://cran.r-project.org/web/packages/PostcodesioR/index.html) to look up hospital or patient postcodes and return the corresponding LTLA code. All Trusts are mapped to at least one LTLA via their hospital postcodes, and can be mapped to additional LTLAs via patient postcodes from the CHESS and/or CO-CIN linelists.

To preserve anonymity of patients, we remove any Trust-LTLA mapping made via patient postcodes where the number of matches is fewer than 5; this also serves the purpose of excluding patients who may have been admitted to hospital whilst away from their home address. We do not report the absolute number of patients per Trust-LTLA pair, but instead report the proportion (`p`).

If, after mapping all available hospital and patient postcodes to their LTLAs, there are some LTLAs that have not yet been mapped to any Trusts, then these LTLAs are matched to NHS Trusts that have been mapped to other LTLAs in the same upper-tier local authority (UTLA).




