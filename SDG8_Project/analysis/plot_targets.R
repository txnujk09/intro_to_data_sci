# Script to generate plots for SDG8 analysis and save as PNGs

library(tidyverse)

# create output directory
out_dir <- "plots"
dir.create(out_dir, showWarnings = FALSE)

# load cleaned data
gdp_clean <- readr::read_rds("../data/gdp_clean.rds")
neet_clean <- readr::read_rds("../data/neet_clean.rds")
continents_clean <- readr::read_rds("../data/continents_clean.rds")
ldc_clean <- readr::read_rds("../data/ldc_clean.rds")

# source helper functions
source("../src/analysis_functions.R")

# merge and compute metrics
merged_df <- merge_all_data(gdp_clean, neet_clean, continents_clean, ldc_clean)

gdp_growth <- compute_gdp_growth(merged_df)
neet_changes <- compute_neet_changes(merged_df)

# Plot 1: Average GDP per Capita Growth by Continent
p1 <- gdp_growth %>%
  filter(!is.na(gdp_growth), !is.na(continent)) %>%
  group_by(continent, year) %>%
  summarise(avg_growth = mean(gdp_growth, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = year, y = avg_growth, color = continent)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Average GDP per Capita Growth by Continent",
    x = "Year",
    y = "Growth Rate (%)",
    color = "Continent"
  ) +
  theme_minimal()

p1_file <- file.path(out_dir, "gdp_growth_by_continent.png")
ggsave(p1_file, p1, width = 10, height = 6, dpi = 300)
message("Saved: ", p1_file)

# Plot 2: Share of LDCs achieving >= 7% growth
p2 <- gdp_growth %>%
  filter(is_ldc, !is.na(gdp_growth)) %>%
  group_by(year) %>%
  summarise(ldc_share_ge7 = mean(gdp_growth >= 7, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = year, y = ldc_share_ge7)) +
  geom_line(linewidth = 1, color = "#0072B2") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Share of LDCs Achieving ≥7% GDP per Capita Growth",
    x = "Year",
    y = "Share of LDCs"
  ) +
  theme_minimal()

p2_file <- file.path(out_dir, "ldc_share_ge7.png")
ggsave(p2_file, p2, width = 10, height = 6, dpi = 300)
message("Saved: ", p2_file)

# Plot 3: Average Youth NEET Rate by Continent
p3 <- merged_df %>%
  filter(!is.na(neet_rate), !is.na(continent)) %>%
  group_by(continent, year) %>%
  summarise(avg_neet = mean(neet_rate, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(x = year, y = avg_neet, color = continent)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Average Youth NEET Rate by Continent",
    x = "Year",
    y = "NEET Rate (%)",
    color = "Continent"
  ) +
  theme_minimal()

p3_file <- file.path(out_dir, "neet_by_continent.png")
ggsave(p3_file, p3, width = 10, height = 6, dpi = 300)
message("Saved: ", p3_file)

message("All plots generated in: ", normalizePath(out_dir))
