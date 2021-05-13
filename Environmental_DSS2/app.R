#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
#install.packages("shiny")
#install.packages("rsconnect")
#call relevant libraries
setwd("~/BIO8068_prac/BIO8068_Assignment_Part-3")
library(shiny)
library(raster)
library(leafem)
library(leaflet)
library(ggplot2)
library(rsconnect)

#read in data

elevation_ll<-readRDS("www/elevation.rds")
settlements<-readRDS("www/settlements1.rds")
lakes<-readRDS("www/lakes1.rds")
rivers<-readRDS("www/rivers.rds")
robin <- read.csv("www/robin.csv")
great_tit <-read.csv("www/great_tit.csv")
redwing <- read.csv("www/turdus19.csv")
robin_records <- read.csv("www/Robin2016_2019.csv")
greattit_records <- read.csv("www/greattit_16_19.csv")
redwing_records <- read.csv("www/turdus16_19.csv")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Cumbria: The Rural Environment"),
    
    # Sidebar ----
    sidebarLayout(
        sidebarPanel(titlePanel("Garden bird species in Cumbria"),
                     p("The rural environment of Cumbria supports a rich diversity of bird species, many of which are common visitors in gardens
                       and have grown to rely on gardens as a source of food, paticularly during the winter months.
                       The following 3 birds have been recorded in gardens during the last RSPB garden birdwatch."),
                     
                     p(strong("The European Robin"),"is a common garden visitor, which is easily identified by it's orange breast.
                       It is an insectivorous bird."),
                     
                     img(src=robin_image,height="60%", width="60%"),
                     
                     p(strong("The Great Tit"),"is the largest of the UK tit species and are well adapted to gardens although they are commonly found in woodlands. 
                       They have a black head and neck and contrasting white cheeks,while their plumage is an olive colour on top and a pale yellow underneath. "),
                     
                     img(src=greattit_image,height="60%", width="60%"),
                     
                     p(strong("The Redwing."),"is the smallest true thrush in the UK, it is the least common garden visitor of these three birds
                       prefering hedgerows and grassy fields, however it is known to seek food in gardens during the winter months. It is easily identified 
                       y its orange-red patches below the wing."),
                     
                     img(src=redwing_image,height="60%", width="60%"),
                     
                     
        ),
        

        # Show a map of bird count distribution and spatial features of Cumbria
        mainPanel( p("The rural environment of Cumbria boasts rich diversity, both in terms of species and landscapes.
                     This interactive webpage shows a map of the elevation denoting Cumbria's hilly landscape, rivers, lakes and settlements.
                     Additionally the map shows the 2019 counts of three bird species; the European Robin, the Great Tit and the Redwing.
                     Finally the histograms shown on this webpage give an indication of the changes in populations of these species using count data
                     from the years 2016 to 2019"),
                   leafletOutput(outputId = "map"),
                   p("Below are histograms showing European Robin, Great Tit and Redwing counts over time. 
                     These histograms were generated using a citizen science database called the National Biodiversity Network (NBN)."),
                   plotOutput(outputId = "robin_plot"),
                   plotOutput(outputId = "greattit_plot"),
                   plotOutput(outputId = "redwing_plot"),
                   p("Looking at these histograms; there have been large increases in the number of birds observed in 2019,
                     which could indicate a rise in their populations or an increased participation in citizen science in 2019.")
        
                  )
    )
    
)

# Define server logic 
server <- function(input, output){

    output$map <- renderLeaflet({
        leaflet() %>%
            addTiles(group = "OSM (default)") %>% 
            addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>%
            addRasterImage(elevation_ll,col=terrain.colors(30), group = "Elevation") %>%
            addCircleMarkers(robin$Longitude..WGS84., robin$Latitude..WGS84.,  
                             radius = 2, fillOpacity = 0.5, opacity = 0.5, col="red", group="Robin")%>% 
            addCircleMarkers(great_tit$Longitude..WGS84., great_tit$Latitude..WGS84.,  
                             radius = 2, fillOpacity = 0.5, opacity = 0.5, col="blue", group="Great Tit") %>% 
            addCircleMarkers(redwing$Longitude..WGS84., redwing$Latitude..WGS84.,  
                             radius = 2, fillOpacity = 0.5, opacity = 0.5, col="green", group="Redwing")  %>% 
            
            addFeatures(settlements, group = "Settlements") %>%
            addFeatures(lakes, group = "Lakes") %>%
            addFeatures(rivers, group = "Rivers") %>%
            
            addLayersControl(
                baseGroups = c("OSM", "Satellite"), 
                overlayGroups = c( "Robin", "Great Tit","Redwing" ,"Elevation", "Settlements","Rivers", "Lakes"),
                options = layersControlOptions(collapsed = FALSE)
                )
    }
  )
                
observeEvent(input$map, {
    click<-input$map
    text<-paste("Lattitude ", click$lat, "Longtitude ", click$lng)
    print(text)
    
})

output$robin_plot <- renderPlot( ggplot(robin_records_per_yr, aes(x = Start.date.year, y=count_per_year)) + geom_line() + xlab("Years") + ylab("Robins Observed"))

output$greattit_plot <- renderPlot( ggplot(greattit_records_per_yr, aes(x = Start.date.year, y=count_per_year)) + geom_line() + xlab("Years") + ylab("Great Tits observed"))

output$redwing_plot <- renderPlot( ggplot(redwing_records_per_yr, aes(x = Start.date.year, y=count_per_year)) + geom_line() + xlab("Years") + ylab("Redwings observed"))

}
 







# Run the application 
shinyApp(ui = ui, server = server)
