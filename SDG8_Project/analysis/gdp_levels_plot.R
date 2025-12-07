# GDP Per Capita Levels by Continent - Line Plot

library(tidyverse)

# Create figures directory if it doesn't exist
dir.create("figures", showWarnings = FALSE)

# Load data and merge with continents
gdp_clean <- readr::read_rds("../data/gdp_clean.rds")
continents_clean <- readr::read_rds("../data/continents_clean.rds")

gdp_all <- gdp_clean %>%
  left_join(continents_clean %>% select(country, continent), by = "country") %>%
  rename(gdp_per_capita = gdp_pc) %>%
  filter(!is.na(continent))

# Generate the plot
gdp_levels_plot <- gdp_all %>%
  # Plot individual country lines (thin, grey, transparent)
  ggplot(aes(x = year, y = gdp_per_capita)) +
  geom_line(aes(group = country), color = "grey", alpha = 0.2, linewidth = 0.3) +
  # Add continent mean lines (thicker, colored)
  geom_line(
    aes(x = year, y = gdp_per_capita, color = continent, group = continent),
    data = gdp_all %>%
      group_by(continent, year) %>%
      summarise(gdp_per_capita = mean(gdp_per_capita, na.rm = TRUE), .groups = "drop"),
    linewidth = 1.2
  ) +
  labs(
    title = "GDP Per Capita Levels by Continent",
    x = "Year",
    y = "GDP Per Capita (USD)",
    color = "Continent"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "bottom"
  )

# Save the figure
ggsave(
  "figures/gdp_levels_continent.png",
  plot = gdp_levels_plot,
  width = 12,
  height = 7,
  dpi = 300
)

message("Plot saved successfully to: figures/gdp_levels_continent.png")
