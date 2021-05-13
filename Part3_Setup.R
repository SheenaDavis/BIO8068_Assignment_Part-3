#Files and set up for shiny app 
#the accompannying files have been removed to save disk space this script is just to show the way 
#in which files were downloaded and stored.
#### Part 1
#Cumbria map showing elevation, settlements and rivers & lakes.

options("rgdal_show_exportToProj4_warnings"="none")

# Import raster elevation data Ordnance Survey projection
elevation <- raster("www/elevation.tif")
plot(elevation)

# default colours are the wrong way round, 
# use the terrain.colors option to set low elevation to green, high to brown, 
# with 30 colour categories
plot(elevation, col=terrain.colors(30))

#convert to lat long
#project raster over map of cumbria
ll_crs <- CRS("+init=epsg:4326")  # 4326 is the code for latitude longitude
elevation_ll <- projectRaster(elevation, crs=ll_crs)
mapview(elevation_ll)

# elevation500m is a coarser defined version of the elevation map that allows the script to run faster
elevation500m <- aggregate(elevation, fact=10) # fact=10 is the number of cells aggregated together
#change projection to lat&long
elevation500m_ll <- projectRaster(elevation500m, crs = ll_crs)

#Save elevation as an RDS files
#elevation
saveRDS(elevation500m_ll, file = "www/elevation.rds")
elevation500m_ll<-readRDS("www/elevation.rds")
mapview(elevation500m_ll)

#Add DTM-derived information to site data

#Settlments
settlements <-st_read("www/cumbria_settlements.shp")
print(settlements)

plot(elevation)
plot(settlements["NAME"], add=TRUE)

settlements_ll <- st_transform(settlements, 4326)#convert to lat-long
mapview(settlements_ll)

#Save settlements as an RDS file
saveRDS(settlements_ll, file = "www/settlements1.rds")
settlements_ll<-readRDS("www/settlements1.rds")
mapview(settlements_ll)

#used to create popup
settlement_info <- paste("Name", settlements_ll$NAME)#this was not used in the final app

#rivers
rivers<-st_read("www/spatial/cumbria_rivers.shp")
rivers_ll <- st_transform(rivers, 4326)
mapview(rivers_ll)

#Save rivers as RDS file 
saveRDS(rivers_ll, file = "www/rivers1.rds")
rivers_ll<-readRDS("www/rivers1.rds")
mapview(rivers_ll)

#lakes
lakes<-st_read("www/spatial/cumbria_lakes.shp")
lakes_ll <- st_transform(lakes, 4326)
mapview(lakes_ll)

#save lakes as RDS file
saveRDS(lakes_ll, file = "www/lakes1.rds")
lakes_ll<-readRDS("WWW/lakes1.rds")
mapview(lakes_ll)

#to combined with bird maps and displayed in the app
cumbria_map <- leaflet() %>% 
  addTiles(group = "OSM (default)") %>% 
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
  addRasterImage(elevation500m_ll,col=terrain.colors(30), group = "Elevation") %>% 
  addFeatures(settlements_ll, group = "Settlements",
              popup = settlement_info) %>%
  addFeatures(lakes_ll, group = "Lakes") %>%
  addFeatures(rivers_ll, group = "Rivers") %>%
  
  addLayersControl(
    baseGroups = c("OSM (default)", "Satellite"), 
    overlayGroups = c("Elevation", "Settlements", "Lakes", "Rivers" ),
    options = layersControlOptions(collapsed = FALSE)
  )

cumbria_map

##Part 2 
#Bird images

#Three bird species - Robin, Great tit, redwing 
#images

source("download_images.R") #source script for image download functions
gb_ll <- readRDS("gb_simple (1).RDS") #sets the bounds to Great Britain

Robin_recs <-  get_inat_obs(taxon_name  = "Erithacus rubecula",
                            bounds = gb_ll,
                            quality = "research",
                            # month=6,   # Month can be set.
                            # year=2018, # Year can be set.
                            maxresults = 10)

download_images(spp_recs = Robin_recs, spp_folder = "robin")

great_recs <-  get_inat_obs(taxon_name  = "Parus major",
                            bounds = gb_ll,
                            quality = "research",
                            # month=6,   # Month can be set.
                            # year=2018, # Year can be set.
                            maxresults = 10)

download_images(spp_recs = great_recs, spp_folder = "great_tit")

red_recs <-  get_inat_obs(taxon_name  = "Turdus iliacus",
                          bounds = gb_ll,
                          quality = "research",
                          # month=6,   # Month can be set.
                          # year=2018, # Year can be set.
                          maxresults = 10)

download_images(spp_recs = red_recs, spp_folder = "redwing")


#from the downloads three images were selected for the app and stored in the www folder.
#file paths are as follows:
#www/great_tit.jpg
#www/redwing.jpg
#www/robin.jpg
#These images could be read in and saved as follows:

greattit_image <- base64enc::dataURI(file="www/great_tit.jpg", mime="image/jpg")
redwing_image <- base64enc::dataURI(file="www/redwing.jpg", mime="image/jpg")
robin_image <- base64enc::dataURI(file="www/robin.jpg", mime="image/jpg")

#Part 3
#three species of bird counts within Cumbria in 2019
#species data downloaded from NBN Atlas 
# read in .csv files 
robin <- read.csv("www/Robin.csv")
great_tit <-read.csv("www/Great_tit.csv")
redwing <- read.csv("www/turdus19.csv")

#2019 distributions of 3 bird species in Cumbria - to be included in app
bird_dist <- leaflet() %>% 
  addTiles(group="OSM") %>%
  addProviderTiles("Esri.WorldImagery", group= "satellite") %>% 
  ## add markers
  addCircleMarkers(robin$Longitude..WGS84., robin$Latitude..WGS84.,  
                   radius = 2, fillOpacity = 0.5, opacity = 0.5, col="red", group="Robin") %>% 
  addCircleMarkers(great_tit$Longitude..WGS84., great_tit$Latitude..WGS84.,  
                   radius = 2, fillOpacity = 0.5, opacity = 0.5, col="blue", group="Great tit") %>% 
  addCircleMarkers(redwing$Longitude..WGS84., redwing$Latitude..WGS84.,  
                   radius = 2, fillOpacity = 0.5, opacity = 0.5, col="green", group="Redwing") %>% 
  
  
  addLayersControl(baseGroups = c("OSM","satellite"),
                   overlayGroups = c("Robin","Great tit","Redwing") , #change to c("Robin","Great tit")
                   options = layersControlOptions(collapsed = FALSE))
bird_dist

#Part 4 
#Data to be used to create graphs showing changes in bird count numbers over time 
#Read in data of the three birds showing counts per year from 2016-2019 downloaded from NBN website 

robin_records <- read.csv("www/Robin2016_2019.csv")
greattit_records <- read.csv("www/greattit_16_19.csv")
redwing_records <- read.csv("www/turdus16_19.csv")
