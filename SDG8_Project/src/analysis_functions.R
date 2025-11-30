compute_gdp_growth <- function(df) {
  df %>%
    group_by(country) %>%
    arrange(year, .by_group = TRUE) %>%
    mutate(gdp_growth = 100 * (gdp_pc - lag(gdp_pc)) / lag(gdp_pc)) %>%
    ungroup()
}

compute_neet_changes <- function(df) {
  df %>%
    filter(year %in% c(2010, 2020)) %>%
    select(country, year, neet_rate) %>%
    distinct() %>%
    pivot_wider(
      names_from = year,
      names_prefix = "y",
      values_from = neet_rate
    ) %>%
    mutate(neet_change = y2020 - y2010)
}

merge_all_data <- function(gdp, neet, continents, ldc) {
  gdp %>%
    left_join(neet, by = c("country", "year")) %>%
    left_join(continents, by = "country") %>%
    left_join(ldc, by = "country") %>%
    mutate(is_ldc = if_else(is.na(is_ldc), FALSE, is_ldc))
}
