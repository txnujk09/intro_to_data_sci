library(readr)
library(dplyr)
library(ggplot2)

# Load the merged dataset (NEET + continents + HDI)
df <- readr::read_csv("youth_continents_hdi_2000_2020.csv")

south_america <- df %>%
# subset South America and compute yearly average NEET for the continent
  filter(Continent == "South America") %>%
  group_by(Year) %>%
  summarise(
    mean_neet = mean(share_neet, na.rm = TRUE),
    .groups = "drop"
  )

# Plot South America's average NEET trend over 2000–2020
ggplot(south_america, aes(x = Year, y = mean_neet)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.3) +
  labs(
    title = "South America: Youth NEET (%)",
    x = "Year",
    y = "% of youth NEET"
  ) +
  theme_minimal()
