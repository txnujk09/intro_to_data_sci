library(readr)
library(dplyr)
library(ggplot2)

#Load dataset containing NEET values merged with continent labels and HDI
df <- readr::read_csv("youth_continents_hdi_2000_2020.csv")

europe <- df %>%
#subset Europe and compute yearly average NEET for the continent
  filter(Continent == "Europe") %>%
  group_by(Year) %>%
  summarise(
    mean_neet = mean(share_neet, na.rm = TRUE),
    .groups = "drop"
  )

# Plot Europe's average NEET trend over 2000–2020
ggplot(europe, aes(x = Year, y = mean_neet)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.3) +
  labs(
    title = "Europe: Youth NEET (%)",
    x = "Year",
    y = "% of youth NEET"
  ) +
  theme_minimal()
