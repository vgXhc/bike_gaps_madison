library(tidycensus)
library(tmap)
library(tidyverse)
library(sf)
library(leaflet)
library(shiny)

options(tigris_use_cache = TRUE)


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
# variables <- load_variables(2018, "acs5/subject", cache = TRUE)

# bike commute mode share
bike_share <- get_acs5("S0801_C01_011")

# percent households without vehicle available
veh_avail <- get_acs5("S2504_C02_027")

# median household income
med_inc <- get_acs5("S1901_C02_012")



# Aldermanic districts
# shapefile https://opendata.arcgis.com/datasets/81039877861c40a1857b2e7634951e04_10.zip
#download.file("https://opendata.arcgis.com/datasets/81039877861c40a1857b2e7634951e04_10.zip", "data/ald_dist.zip")
#unzip("data/ald_dist.zip", exdir = "data")
ald_dist <- read_sf(file.path(".","data", "4c9bfcdf-5c27-4997-9add-388fb5313aac202043-1-1k9c67z.t0l9.shp")) %>% 
    st_make_valid() %>% #one polygon has some kind of error
    mutate(district = as.factor(ALD_DIST))

# low-stress bike network data

traffic_stress <- read_sf(file.path(".", "data", "LTS", "Merge_FeatureToLine_Clean.shp")) 
low_stress <- traffic_stress %>% 
    filter(LTS_F <= 2) %>% 
    mutate(LTS_F = as_factor(LTS_F))

# overall road network data
# this will allow filtering for roads that would easily be dieted
# download.file("https://opendata.arcgis.com/datasets/55a0bff60c3b475893c6f483dd53cd40_1.csv")
# unzip("data/Street_Centerlines_and_Pavement_Data-shp.zip", exdir = "data")
roads <- read_sf("data/ab6ebe0a-d838-4e18-b4a2-7cc420e06232202044-1-1wweqis.8fsc.shp")

multi_lane <- roads %>% 
    filter(lanes > 2 | (lanes > 1 & oneway == 2))

tm_shape(multi_lane) +
    tm_lines()

# RoadsCurrent <- st_read("data/Transportation.gdb.zip", layer = "RoadsCurrent")
# 
# RoadsCurrent <- RoadsCurrent %>% 
#     filter(RdStatus == "Constructed" & civilMunicipality == "City of Madison")
# 
# tm_shape(RoadsCurrent) +
#     tm_lines(col = "LTS_Appr")
######################################################
# create map
######################################################

tmap_mode("view")

t_map <- tm_shape(bike_share) +
    tm_polygons("estimate", title = "% bike to work", alpha = 0.5, style = "jenks") +
    tm_shape(veh_avail) +
    tm_polygons("estimate", title = "% household w/o vehicle", alpha = 0.5, style = "jenks") +
    tm_shape(med_inc) +
    tm_polygons("estimate", title = "Median income", alpha = 0.5, style = "jenks") +
    tm_shape(ald_dist) +
    tm_polygons("district") +
    tm_text("district")



# Define UI for application that draws a histogram
ui <- fluidPage(
    sidebarLayout(position = "right",
                  sidebarPanel(
                      selectInput("layer", 
                                  label = "Choose a variable to display",
                                  choices = c("Bike mode share", 
                                              "Households without vehicle",
                                              "Median income"),
                                  selected = "Bike mode share"),
                      ),
                  mainPanel(
                      leafletOutput("my_tmap")
                  )
    )

    
    
)


server <- function(input, output, session) {
    

    output$my_tmap <- renderLeaflet({
        x <- switch(input$layer,
                    "Bike mode share" = bike_share,
                    "Households without vehicle" = veh_avail,
                    "Median income" = med_inc)
        tmap_leaflet(tm_shape(x) +
                         tm_polygons("estimate", title = input$layer, style = "jenks")+
                         tm_shape(low_stress) +
                         tm_lines("LTS_F"))
    })
    
    # When map is clicked, show a popup with coordinates
    observe({
        event <- input$my_tmap_shape_click
        if (is.null(event))
            return()
        
        isolate({
            leafletProxy("my_tmap") %>% 
                clearPopups() %>% 
                addPopups(lng = event$lng,
                          lat = event$lat, 
                          popup = paste0(event$lat, event$lng))
        })
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
