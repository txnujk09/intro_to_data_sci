## Purpose: Plot GDP per capita levels by continent (SDG 8.1 context)
## Inputs: data/gdp-per-capita-worldbank.csv, data/continents-according-to-our-world-in-data.csv
## Outputs: figures/gdp_levels_continent.png (continent averages + country traces)

library(tidyverse)

# File paths (relative to project root)
gdp_path <- "../data/gdp-per-capita-worldbank.csv"
continents_path <- "../data/continents-according-to-our-world-in-data.csv"

# Ensure figures directory exists
dir.create("figures", showWarnings = FALSE)

# Load and clean GDP per capita data
gdp_clean <- readr::read_csv(gdp_path, show_col_types = FALSE) %>%
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

# Load continent lookup and keep one continent per country
continents_clean <- readr::read_csv(continents_path, show_col_types = FALSE) %>%
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
  distinct(country, .keep_all = TRUE) %>%
  drop_na(continent)

# Merge GDP with continent info
gdp_all <- gdp_clean %>%
  left_join(continents_clean %>% select(country, continent), by = "country") %>%
  rename(gdp_per_capita = gdp_pc) %>%
  filter(!is.na(continent))

# Generate the plot (country traces in grey, continent means colored)
gdp_levels_plot <- gdp_all %>%
  ggplot(aes(x = year, y = gdp_per_capita)) +
  geom_line(aes(group = country), color = "grey", alpha = 0.2, linewidth = 0.3) +
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
