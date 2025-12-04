#load the possible libraries that will be used 
library(tidyverse)
library(ggplot2)
library(dplyr)

#set the working directory to where I have stored the data
setwd("~/Desktop/IC academic/Data Science/data sets")

#extract and name the continent file as "continents"
continents <- read.csv("continents-according-to-our-world-in-data.csv",
                       stringsAsFactors = F)

#extract and name the youth not in education employment or training file as "youth"
youth <- read.csv("youth-not-in-education-employment-training.csv",
                  stringsAsFactors = F)

#from the continent data frame, select only the given columns
continents <- continents %>% select("Entity", "Code", "Continent")

#join the youth and continent data frame by country using left join
#left join allows the data in "youth" to be preserved, and "continents" will be combined to it
all <- youth %>% left_join(continents, by = "Entity")

#after join, there are 2 country code columns, using select to omit the unused columns
all <- all %>% select("Entity", "Code.x", "Year", "Continent", "Share.of.youth.not.in.education..employment.or.training..total....of.youth.population.")

#to avoid any NA data
all <- all %>% na.omit()

#our group decided to use 2000 to 2020, in which the data is most consistent
all <- all %>% filter(Year >= 2000) %>% filter(Year <= 2020)

#define a new data frame in which the countries are grouped by continent, then year
#an average for each year per each continent is calculated
by_continent <- all %>%
  group_by(Continent, Year) %>%
  summarise(continent_avg = mean(Share.of.youth.not.in.education..employment.or.training..total....of.youth.population.))

#plot a heat map for each continent over the time: 2000-2020, with x-axis being Year and y-axis being Continent
#fill the heat map by 
by_continent %>% ggplot(aes(x = Year, y = Continent, fill = continent_avg)) +
  geom_tile() + 
  scale_fill_gradient(low = "green", high = "red") +
  labs(title = "Youth not in employment, training and education per continent",
       fill = "average share of youth not in employment, training and education") +
  theme(legend.position = "bottom")