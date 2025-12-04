library(readr)
library(dplyr)
library(ggplot2)

# Load the merged dataset (NEET + continents + HDI)
df <- readr::read_csv("youth_continents_hdi_2000_2020.csv")

asia <- df %>%
  filter(Continent == "Asia") %>%
  group_by(Year) %>%
  summarise(
    mean_neet = mean(share_neet, na.rm = TRUE),
    .groups = "drop"
  )

ggplot(asia, aes(x = Year, y = mean_neet)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.3) +
  labs(
    title = "Asia: Youth NEET (%)",
    x = "Year",
    y = "% of youth NEET"
  ) +
  theme_minimal()


