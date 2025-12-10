## Purpose: Plot average African youth NEET rate over time (SDG 8.6)
## Inputs: youth_continents_hdi_2000_2020.csv (NEET + continent + HDI merged dataset)
## Outputs: ggplot of continent-level mean NEET% by year (viewed interactively or saved via ggsave)

library(readr)
library(dplyr)
library(ggplot2)

# Load merged NEET + continent + HDI dataset (built upstream from the provided CSVs + HDI file).
df <- readr::read_csv("youth_continents_hdi_2000_2020.csv")

# If your NEET column is named differently, standardize it to share_neet using:
# df <- df %>%
#   rename(share_neet = `Share of youth not in education, employment or training, total (% of youth population)`)

# Compute mean NEET for Africa by year.
africa <- df %>%
  filter(Continent == "Africa") %>%
  group_by(Year) %>%
  summarise(
    mean_neet = mean(share_neet, na.rm = TRUE),
    .groups = "drop"
  )

# Plot the continent-level NEET trend (use ggsave(...) to write to file if needed).
ggplot(africa, aes(x = Year, y = mean_neet)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.3) +
  labs(
    title = "Africa: Youth NEET (%)",
    x = "Year",
    y = "% of youth NEET"
  ) +
  theme_minimal()
