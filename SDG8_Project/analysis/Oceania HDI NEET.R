library(readr)
library(dplyr)
library(ggplot2)

# 0.1 Load the merged dataset
# Make sure this filename matches what you saved
df <- read_csv("youth_continents_hdi_2000_2020.csv")

# If your NEET column is not yet called 'share_neet', uncomment this:
# df <- df %>%
#   rename(share_neet = `Share of youth not in education, employment or training, total (% of youth population)`)

# 0.2 Create HDI tiers and 2-group classification
df <- df %>%
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
  filter(!is.na(HDI_group2))   # drop rows without HDI classification
oceania <- df %>%
  filter(Continent == "Oceania") %>%
  group_by(Year, HDI_group2) %>%
  summarise(
    mean_neet = mean(share_neet, na.rm = TRUE),
    .groups = "drop"
  )

ggplot(oceania, aes(x = Year, y = mean_neet, colour = HDI_group2)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.3) +
  labs(
    title = "Oceania: Youth NEET (%) by HDI group",
    subtitle = "High & Very High vs Medium & Low HDI",
    x = "Year",
    y = "% of youth NEET",
    colour = "HDI group"
  ) +
  theme_minimal()
