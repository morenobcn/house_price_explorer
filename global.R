library(dplyr)
library(readr)
library(leaflet)
library(PerformanceAnalytics)
library(ggplot2)
library(plotly)
library(sp)
library(leaflet)
library(tidyverse)
library(rgdal)

#we read the data and parse some columns (after intial inspection) as the data types we are interested.



house_prices <- read_csv('./www/transactions_2017_18.csv',
                         col_types = cols(
                           'Price' = col_double(),
                           'Date of Transfer' = col_date("%d/%m/%Y"),
                           'Property Type' = col_factor(c('D', 'S', 'T', 'F', 'O'))
                         ))

#We set up an initial filter based on hte price and Property Type, 'O' = other contains office buildings I believe
house_prices <- house_prices %>%
  filter((between(Price,50000,5000000))) %>%
  filter('Property Type' != 'O')

#First we calculate the Median and mean by borough and save it to a variable since we will need this to filyer our data
boroughs_mad <- house_prices %>%
  group_by(Borough) %>%
  summarise(MAD = mad(Price), Median = median(Price), Mean = mean(Price), Max = max(Price), Min = min(Price), Skew = skewness(Price))

#Max and min of the dataset for the silder
price_max_min <- house_prices %>%
  summarise(Max = max(Price), Min = min(Price))

#Vector with the different Boroughs (we just get the first column)
boroughs_names <- boroughs_mad[,1]

#Vector with the different choices of SD for the calculations
mad_options <- c(1.5,2,2.5,3,3.5,4)


#Open the shapefile and save it in a dataframe
boroughs_sp <- readOGR('./www','London_Boroughs')

