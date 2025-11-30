# intro_to_data_sci
Intro to Data Science – SDG 8 Analysis
======================================

This repository contains the full coursework project for the Intro to Data Science module. 
The project investigates progress towards Sustainable Development Goal 8 (SDG 8), focusing on:

- Target 8.1 – Sustaining per-capita economic growth, with emphasis on Least Developed Countries (LDCs)
- Target 8.6 – Reducing the proportion of youth not in education, employment, or training (NEET)

All analysis is performed using R, organised in a reproducible and transparent workflow.


How to Run the Analysis
-----------------------

1. Open the project folder in RStudio or VS Code.

2. Run the cleaning pipeline:
   source("src/load_and_clean.R")

   This loads all raw CSV files, cleans them, and generates cleaned .rds files in /data.

3. Knit the R Markdown file:
   analysis/SDG8_analysis.Rmd  →  Knit → PDF

   This produces the full analysis with figures.


Methods Summary
---------------

Data sources:
- Our World in Data (continent classifications)
- World Bank GDP per capita data
- Youth NEET dataset
- UN Least Developed Countries (LDC) list

Data processing steps:
- Pivot wide → long
- Convert values to numeric
- Merge datasets by country and year
- Compute:
  * GDP per capita growth percentage
  * NEET changes (2010 → 2020)
  * Percentage of LDCs meeting 7% GDP growth target

Plots generated:
- GDP growth trends by continent
- NEET trends by continent
- LDC performance over time

All visualisations created with ggplot2.


Group Collaboration
-------------------

This repository includes contributions from all group members through commits, pushes, and synchronised work using GitHub version control.


References
----------

- World Bank Open Data
- Our World In Data
- UN SDG Global Indicators Database
- UN Least Developed Countries List


Notes
-----

All figures are generated automatically through the R Markdown workflow. 
The codebase is fully reproducible, with clear separation of cleaning, functions, and analysis.
