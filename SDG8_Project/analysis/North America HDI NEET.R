## Purpose: Plot North American youth NEET trends split by HDI group (supplemental context for SDG 8.6)
## Inputs: youth_continents_hdi_2000_2020.csv (NEET + continent + HDI merged dataset)
## Outputs: ggplot showing average NEET% by HDI grouping over time (viewed interactively or saved via ggsave)

library(readr)
library(dplyr)
library(ggplot2)

# Load merged NEET + continent + HDI dataset (produced from provided CSVs + HDI file).
df <- read_csv("youth_continents_hdi_2000_2020.csv")

# If the NEET column name differs, rename to share_neet using the line below.
# df <- df %>%
#   rename(share_neet = `Share of youth not in education, employment or training, total (% of youth population)`)

# Derive HDI tiers and a 2-bucket HDI grouping, then drop rows lacking HDI.
df <- df %>%
  mutate(
    HDI_tier = case_when(
      HDI >= 0.800               ~ "Very High",
      HDI >= 0.700 & HDI < 0.800 ~ "High",
      HDI >= 0.550 & HDI < 0.700 ~ "Medium",
      HDI < 0.550                ~ "Low",
      TRUE                       ~ NA_character_
    ),
    HDI_group2 = case_when(
      HDI_tier %in% c("Very High", "High") ~ "High & Very High HDI",
      HDI_tier %in% c("Medium", "Low")     ~ "Medium & Low HDI",
      TRUE                                 ~ NA_character_
    )
  ) %>%
  filter(!is.na(HDI_group2))

# Filter to North America and compute mean NEET by year and HDI group.
north_america <- df %>%
  filter(Continent == "North America") %>%
  group_by(Year, HDI_group2) %>%
  summarise(
    mean_neet = mean(share_neet, na.rm = TRUE),
    .groups = "drop"
  )

# Plot NEET trends by HDI grouping (use ggsave(...) to write to file if needed).
ggplot(north_america, aes(x = Year, y = mean_neet, colour = HDI_group2)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.3) +
  labs(
    title = "North America: Youth NEET (%) by HDI group",
    subtitle = "High & Very High vs Medium & Low HDI",
    x = "Year",
    y = "% of youth NEET",
    colour = "HDI group"
  ) +
  theme_minimal()
