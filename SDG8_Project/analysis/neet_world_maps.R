## Purpose: Create world maps of youth NEET rates (2015–2020) for SDG 8.6
## Inputs: data/youth-not-in-education-employment-training.csv, data/continents-according-to-our-world-in-data.csv
## Outputs: PNG maps saved to analysis/figures/neet_map_<year>.png

library(tidyverse)
library(sf)
library(rnaturalearth)

# File paths (relative to project root)
neet_path <- "../data/youth-not-in-education-employment-training.csv"
continents_path <- "../data/continents-according-to-our-world-in-data.csv"

# Years to plot
years_to_plot <- 2015:2020

# Load and clean NEET data (long format already)
neet_clean <- readr::read_csv(neet_path, show_col_types = FALSE) %>%
  rename(
    country = Entity,
    code = Code,
    year = Year,
    neet_rate = `Share of youth not in education, employment or training, total (% of youth population)`
  ) %>%
  mutate(
    year = as.numeric(year),
    neet_rate = as.numeric(neet_rate)
  ) %>%
  select(country, code, year, neet_rate) %>%
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
  select(country, continent) %>%
  distinct(country, .keep_all = TRUE) %>%
  drop_na(continent)

# Merge NEET data with continents
neet_map_data <- neet_clean %>%
  left_join(continents_clean, by = "country") %>%
  filter(year %in% years_to_plot)

# Country geometries
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") %>%
  select(iso_a3, geometry)

# Output directory
out_dir <- "figures"
dir.create(out_dir, showWarnings = FALSE)

plot_neet_map <- function(target_year) {
  # Join NEET data to shapes for the target year
  df_year <- world %>%
    left_join(
      neet_map_data %>% filter(year == target_year),
      by = c("iso_a3" = "code")
    )

  # OWID-like beige-to-red palette
  palette_colors <- c("#fef6e4", "#f9d9a9", "#f7a26d", "#e25b42", "#b2171e")
  palette_values <- scales::rescale(c(0, 10, 25, 40, 60))

  p <- ggplot(df_year) +
    geom_sf(aes(fill = neet_rate), color = "grey80", size = 0.1) +
    scale_fill_gradientn(
      colours = palette_colors,
      values = palette_values,
      limits = c(0, 60),
      oob = scales::squish,
      na.value = "grey90",
      name = "NEET (%)"
    ) +
    labs(
      title = paste0("Youth Not in Education, Employment or Training (", target_year, ")"),
      subtitle = "Share of youth population",
      caption = "Source: ILO / World Bank NEET data"
    ) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      plot.title = element_text(face = "bold")
    )

  out_file <- file.path(out_dir, paste0("neet_map_", target_year, ".png"))
  ggsave(out_file, p, width = 12, height = 6, dpi = 300)
  message("Saved: ", out_file)
}

invisible(lapply(years_to_plot, plot_neet_map))
