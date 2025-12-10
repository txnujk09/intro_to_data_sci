library(readr)
library(dplyr)
library(ggplot2)

# Load merged dataset containing NEET rates, HDI values, and continent labels
df <- read_csv("youth_continents_hdi_2000_2020.csv")

df <- df %>%
# Create HDI tiers and broader HDI groups for comparing NEET outcomes
  mutate(
    HDI_tier = case_when(
      HDI >= 0.800                    ~ "Very High",
      HDI >= 0.700 & HDI < 0.800      ~ "High",
      HDI >= 0.550 & HDI < 0.700      ~ "Medium",
      HDI < 0.550                     ~ "Low",
      TRUE                            ~ NA_character_
    ),
    HDI_group2 = case_when(
      HDI_tier %in% c("Very High", "High")   ~ "High & Very High HDI",
      HDI_tier %in% c("Medium", "Low")       ~ "Medium & Low HDI",
      TRUE                                   ~ NA_character_
    )
  ) %>%
  filter(!is.na(HDI_group2))   #remove rows without valid HDI grouping

# Compute annual average NEET for Asia by HDI group
asia <- df %>%
  filter(Continent == "Asia") %>%
  group_by(Year, HDI_group2) %>%
  summarise(
    mean_neet = mean(share_neet, na.rm = TRUE),
    .groups = "drop"
  )

# Plot NEET trends over time for Asian HDI groups
ggplot(asia, aes(x = Year, y = mean_neet, colour = HDI_group2)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.3) +
  labs(
    title = "Asia: Youth NEET (%) by HDI group",
    subtitle = "High & Very High vs Medium & Low HDI",
    x = "Year",
    y = "% of youth NEET",
    colour = "HDI group"
  ) +
  theme_minimal()
