library(tidycensus)
library(tmap)
library(tidyverse)
library(sf)

######################################################
# get data
######################################################

##because I can't figure out how to use group_by for sf objects, I'm creating
##separate objects for each of the ACS variables

###define function for getting the various variables

get_acs5 <- function(x){
  get_acs(geography = "tract",
          variables = x,
          state = "55",
          county = "Dane",
          geometry = TRUE)
}

##helper for identifying the relevant variables
variables <- load_variables(2018, "acs5/subject", cache = TRUE)

# bike commute mode share
bike_share <- get_acs5("S0801_C01_011")

# percent households without vehicle available
veh_avail <- get_acs5("S2504_C02_027")

# median household income
med_inc <- get_acs5("S1901_C02_012")

# Aldermanic districts
# shapefile https://opendata.arcgis.com/datasets/81039877861c40a1857b2e7634951e04_10.zip
download.file("https://opendata.arcgis.com/datasets/81039877861c40a1857b2e7634951e04_10.zip", "data/ald_dist.zip")
unzip("data/ald_dist.zip", exdir = "data")
ald_dist <- read_sf("data/4c9bfcdf-5c27-4997-9add-388fb5313aac202043-1-1k9c67z.t0l9.shp") %>% 
  mutate(district = as.factor(ALD_DIST))


######################################################
# create map
######################################################


tmap_mode("view")

tm_shape(bike_share) +
  tm_polygons("estimate", title = "% bike to work", alpha = 0.5, style = "jenks") +
  tm_shape(veh_avail) +
  tm_polygons("estimate", title = "% household w/o vehicle", alpha = 0.5, style = "jenks") +
  tm_shape(med_inc) +
  tm_polygons("estimate", title = "Median income", alpha = 0.5, style = "jenks") +
  tm_shape(ald_dist) +
  tm_polygons("district") +
  tm_text("district")
