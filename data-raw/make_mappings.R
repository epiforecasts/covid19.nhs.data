
pacman::p_load(
  here,
  rio,
  magrittr,
  janitor,
  dplyr,
  stringr,
  
  usethis
)

pacman::p_load_gh(
  "epiforecasts/hospitalcatchment.utils"
)



# HES mapping (until September 2020) --------------------------------------

# Load raw data

## Site-Trust lookup
site_trust_lookup <- import(file = here("data-raw", "raw", "england_trusts", "trust_list.csv")) %>%
  select(trust_code = V1,
         stp_code = V4) %>%
  distinct()

# Trust mergers
trust_mergers <- hospitalcatchment.utils::download_nhs_mergers() %>%
  filter(!(org_code_old == "RW6" & org_code == "R0A"))

## LTLA-UTLA lookup
ltla_utla_lookup <- import(file = here("data-raw", "raw", "england_ltla", "ltla_utla_list.csv")) %>%
  select(ltla_code = LTLA19CD,
         utla_code = UTLA19CD)

## NHS site-LTLA mapping
nhs_mapping_raw <- import(file = here("data-raw", "trust-ltla-mapping", "mapping_raw.csv")) %>%
  clean_names() %>%
  rename(site_code = der_provider_site_code,
         ltla_code = der_postcode_dist_unitary_auth,
         n = spells)


# Make LTLA-Trust mapping (private)
ltla_trust_hes_private <- nhs_mapping_raw %>%
  mutate(trust_code = str_sub(site_code, 1, 3)) %>%
  # Trust changes (mergers)
  left_join(trust_mergers %>%
              filter(date_effective < as.Date("2020-10-01")),
            by = c("trust_code" = "org_code_old")) %>%
  mutate(trust_code = ifelse(!is.na(org_code), org_code, trust_code)) %>%
  #
  group_by(ltla_code, trust_code) %>%
  summarise(n = sum(n, na.rm = TRUE),
            .groups = "drop")

# Make LTLA-Trust mapping (public)
ltla_trust_hes <- ltla_trust_hes_private %>%
  # Drop pairs where there are fewer than 10 admissions
  filter(n >= 10) %>%
  # Get % LTLA to Trust
  group_by(ltla_code) %>%
  mutate(p_geo = n/sum(n)) %>%
  ungroup() %>%
  # Get % Trust from LTLA
  group_by(trust_code) %>%
  mutate(p_trust = n/sum(n)) %>%
  ungroup() %>%
  arrange(ltla_code, trust_code) %>%
  rename(geo_code = ltla_code) %>%
  mutate(source = "HES",
         level = "ltla")

# Make UTLA-Trust mapping (public)
utla_trust_hes <- ltla_trust_hes_private %>%
  left_join(ltla_utla_lookup, by = "ltla_code") %>%
  group_by(utla_code, trust_code) %>%
  summarise(n = sum(n),
            .groups = "drop") %>%
  # Drop pairs where there are fewer than 10 admissions
  filter(n >= 10) %>%
  # Get % LTLA to Trust
  group_by(utla_code) %>%
  mutate(p_geo = n/sum(n)) %>%
  ungroup() %>%
  # Get % Trust from LTLA
  group_by(trust_code) %>%
  mutate(p_trust = n/sum(n)) %>%
  ungroup() %>%
  arrange(utla_code, trust_code)  %>%
  rename(geo_code = utla_code) %>%
  mutate(source = "HES",
         level = "utla")




# Linked COVID-19 cases-admissions ----------------------------------------

# Load and link case and admissions data
dat_pil <- import(file = here("data-raw",
                              "trust-ltla-mapping",
                              "english_pillars_raw.rds")) %>%
  select(finalid, age_pil = age, sex_pil = sex,
         utla_code, ltla_code,
         home_cat = cat,
         date_onset = onsetdate,
         date_specimen_pil = date_specimen,
         date_report = lab_report_date) %>%
  mutate(date_onset = lubridate::dmy(date_onset))

dat_adm <- import(file = here("data-raw",
                              "trust-ltla-mapping",
                              "english_hospitals_raw.rds")) %>%
  select(finalid = final_id, age_adm = agegrp, sex_adm = sex,
         date_specimen_adm = specimen_date,
         trust_code = provider_code, trust_type, hospital_in, hospital_out) %>%
  left_join(trust_mergers, by = c("trust_code" = "org_code_old")) %>% 
  mutate(trust_code = ifelse(!is.na(org_code) & hospital_in >= date_effective,
                             org_code,
                             trust_code)) %>%
  select(-c(org_code, date_effective))


# Combine
dat <- dat_pil %>%
  left_join(dat_adm, by = "finalid") %>%
  distinct()


# Clean data (first admission, subject to admission delay constraints)
dat_clean <- dat %>%
  filter(substr(trust_code, 1, 1) == "R") %>%
  filter(!is.na(ltla_code),
         hospital_out > date_specimen_adm,
         hospital_in <= date_specimen_adm + 28) %>%
  filter(home_cat %in% c("Residential dwelling (including houses, flats, sheltered accommodation)")) %>%
  filter(date_specimen_adm >= as.Date("2020-06-01"),
         date_specimen_adm < as.Date("2021-06-01")) %>%
  group_by(finalid) %>%
  filter(hospital_in == pmin(hospital_in)) %>%
  ungroup()


# Make LTLA-Trust mapping (private)
ltla_trust_link_private <- dat_clean %>%
  group_by(ltla_code, trust_code) %>%
  summarise(n = n(),
            .groups = "drop")

# Make LTLA-Trust mapping (public)
ltla_trust_link <- ltla_trust_link_private %>%
  # Drop pairs where there are fewer than 10 admissions
  filter(n >= 10) %>%
  # Get % LTLA to Trust
  group_by(ltla_code) %>%
  mutate(p_geo = n/sum(n)) %>%
  ungroup() %>%
  # Get % Trust from LTLA
  group_by(trust_code) %>%
  mutate(p_trust = n/sum(n)) %>%
  ungroup() %>%
  arrange(ltla_code, trust_code) %>%
  rename(geo_code = ltla_code) %>%
  mutate(source = "Link",
         level = "ltla")

# Make UTLA-Trust mapping (public)
utla_trust_link <- ltla_trust_link_private %>%
  left_join(ltla_utla_lookup, by = "ltla_code") %>%
  group_by(utla_code, trust_code) %>%
  summarise(n = sum(n),
            .groups = "drop") %>%
  # Drop pairs where there are fewer than 10 admissions
  filter(n >= 10) %>%
  # Get % LTLA to Trust
  group_by(utla_code) %>%
  mutate(p_geo = n/sum(n)) %>%
  ungroup() %>%
  # Get % Trust from LTLA
  group_by(trust_code) %>%
  mutate(p_trust = n/sum(n)) %>%
  ungroup() %>%
  arrange(utla_code, trust_code) %>%
  rename(geo_code = utla_code) %>%
  mutate(source = "Link",
         level = "utla")



# Combine all mappings ----------------------------------------------------

mappings <- ltla_trust_hes %>%
  bind_rows(utla_trust_hes) %>%
  bind_rows(ltla_trust_link) %>%
  bind_rows(utla_trust_link)

usethis::use_data(mappings, internal = TRUE, overwrite = TRUE)
