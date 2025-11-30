# Load required packages
library(tidyverse)

# File paths (relative to project root)
gdp_path <- "data/gdp-per-capita-worldbank.csv"
neet_path <- "data/youth-not-in-education-employment-training.csv"
continents_path <- "data/continents-according-to-our-world-in-data.csv"
ldc_path <- "data/ldc_list.csv"

# Read raw datasets
gdp_raw <- read_csv(gdp_path, show_col_types = FALSE)
neet_raw <- read_csv(neet_path, show_col_types = FALSE)
continents_raw <- read_csv(continents_path, show_col_types = FALSE)
ldc_raw <- read_csv(ldc_path, show_col_types = FALSE)

# Clean GDP dataset (already long format)
gdp_clean <- gdp_raw %>%
  rename(
    country = Entity,
    code = Code,
    year = Year,
    gdp_pc = `GDP per capita, PPP (constant 2017 international $)`
  ) %>%
  mutate(
    year = as.numeric(year),
    gdp_pc = as.numeric(gdp_pc)
  ) %>%
  select(country, code, year, gdp_pc) %>%
  drop_na(country)

# Clean NEET dataset (already long format)
neet_clean <- neet_raw %>%
  rename(
    country = Entity,
    code = Code,
    year = Year,
    neet_rate = `Share of youth not in education, employment or training, total (% of youth population)`
  ) %>%
  mutate(
    year = as.numeric(year),
    neet_rate = as.numeric(neet_rate)
  ) %>%
  select(country, code, year, neet_rate) %>%
  drop_na(country)

# Clean continents dataset
continents_clean <- continents_raw %>%
  rename(
    country = Entity,
    code = Code,
    year = Year,
    continent = Continent
  ) %>%
  mutate(
    country = str_trim(country),
    continent = str_trim(continent)
  ) %>%
  select(country, code, continent) %>%
  distinct(country, .keep_all = TRUE) %>% # keep one continent per country
  drop_na(continent)

# Clean LDC dataset
ldc_clean <- ldc_raw %>%
  rename_with(~ str_replace_all(., "[^A-Za-z0-9]", "_")) %>%
  mutate(across(everything(), ~ na_if(., ""))) %>%
  rename(country = 1) %>%
  mutate(country = str_trim(country)) %>%
  select(country) %>%
  distinct() %>%
  mutate(is_ldc = TRUE)

# Save cleaned datasets as RDS
write_rds(continents_clean, "data/continents_clean.rds")
write_rds(gdp_clean, "data/gdp_clean.rds")
write_rds(neet_clean, "data/neet_clean.rds")
write_rds(ldc_clean, "data/ldc_clean.rds")

# Print samples of cleaned datasets
cat("GDP clean head:\n")
print(head(gdp_clean))

cat("\nNEET clean head:\n")
print(head(neet_clean))

cat("\nContinents clean head:\n")
print(head(continents_clean))

cat("\nLDC clean head:\n")
print(head(ldc_clean))
