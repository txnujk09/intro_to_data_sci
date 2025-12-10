## Purpose: Create world maps of GDP per capita growth for SDG 8.1 (2015–2020) with 7% benchmark coloring.
## Inputs: data/gdp-per-capita-worldbank.csv, data/continents-according-to-our-world-in-data.csv
## Outputs: PNG maps saved to analysis/figures/gdp_growth_map_<year>.png

library(tidyverse)
library(sf)
library(rnaturalearth)

# File paths (relative to project root)
gdp_path <- "../data/gdp-per-capita-worldbank.csv"
continents_path <- "../data/continents-according-to-our-world-in-data.csv"

# Read and clean GDP data (long format already)
gdp_clean <- read_csv(gdp_path, show_col_types = FALSE) %>%
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

# Read continent lookup and keep one continent per country
continents_clean <- read_csv(continents_path, show_col_types = FALSE) %>%
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

# Compute year-over-year GDP per capita growth per country
gdp_growth <- gdp_clean %>%
  group_by(country) %>%
  arrange(year, .by_group = TRUE) %>%
  mutate(gdp_growth = 100 * (gdp_pc - lag(gdp_pc)) / lag(gdp_pc)) %>%
  ungroup() %>%
  left_join(continents_clean %>% select(country, continent), by = "country")

# Years to plot
years_to_plot <- 2015:2020

# Country geometries (ISO A3 codes align with gdp_clean$code)
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") %>%
  select(iso_a3, geometry)

# Prep growth data for join
growth_map_data <- gdp_growth %>%
  filter(year %in% years_to_plot) %>%
  select(code, country, continent, year, gdp_growth)

# Output directory for maps (relative to this script)
out_dir <- "figures"
dir.create(out_dir, showWarnings = FALSE)

plot_growth_map <- function(target_year) {
  # Join growth data to shapes for the target year
  df_year <- world %>%
    left_join(
      growth_map_data %>% filter(year == target_year),
      by = c("iso_a3" = "code")
    )

  # Map with symmetric red/green scale around 0, squishing beyond +/-7%
  p <- ggplot(df_year) +
    geom_sf(aes(fill = gdp_growth), color = "grey80", size = 0.1) +
    scale_fill_gradient2(
      low = "darkred",
      mid = "white",
      high = "darkgreen",
      midpoint = 0,
      limits = c(-7, 7),
      oob = scales::squish,
      name = "GDP Growth (%)"
    ) +
    labs(
      title = paste0("GDP Growth Rates by Country (", target_year, ")"),
      subtitle = "Dark red: growth <= -7%   |   Dark green: growth >= +7%",
      caption = "Source: World Bank GDP per capita (PPP, constant 2017); year-over-year growth"
    ) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      plot.title = element_text(face = "bold")
    )

  out_file <- file.path(out_dir, paste0("gdp_growth_map_", target_year, ".png"))
  ggsave(out_file, p, width = 12, height = 6, dpi = 300)
  message("Saved: ", out_file)
}

invisible(lapply(years_to_plot, plot_growth_map))
