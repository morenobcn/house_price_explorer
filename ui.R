library(DT)
library(shiny)
library(shinydashboard)

#shiny dashboard has different panels, header sidebar and body 
shinyUI(dashboardPage(skin = "black", 
    dashboardHeader(title = "London House Prices Stats Explorer", titleWidth = 550),
    dashboardSidebar(width = 350,
        
        #this is the logo and name of the company, imgae will be round
        #sidebarUserPanel("JLL - Nacho Moreno",
                         #image = "https://jll.box.com/shared/static/mk08h1r6t4e3w8didvjxrzofy74jf260.png"),
        
        #we add the two menus called Map and data to 
        br(),
        sidebarMenu(
            menuItem("Data Explorer", tabName = "boxplot", icon = icon("home")),
            menuItem("Map Visualization", tabName = "map", icon = icon("map")),
            menuItem("Summary Data", tabName = "data", icon = icon("database"))
            
        ),
        
        
        br(),
       
        
       #this selects the sd we will use to filter our dataset
        selectizeInput("selected_mad",
                       "Select MAD factor",
                       mad_options),
       
       
       #Adding the range slider for the quartiles
       sliderInput("slider_quantiles", "Select quantiles", min = 0.1, 
                   max = 1, step=.1, value = c(0, 1)),
       
        #Multi select for boroughs
        selectizeInput("selected_boroughs",
                       "Select Borough",
                       choices = boroughs_names, multiple = TRUE, selected=c('BROMLEY','WALTHAM FOREST', 'CAMDEN')),
        
       
       selectInput("download_files", "Download dataset",
                    choices = c("Filtered dataset", "Summary data")),
       
      downloadButton('downloadData', 'Download')
      
       
       #HTML('<font size=2>   The MAD factor is used to filter the data based on the Median Absolute Deviation (MAD). Higher value will discard lesser outliers </font size=2>
            #<br/> <font size=2> The percentile will segment the market. Selecting 0.8 to 1, will show the Top 20% of the properties.</font size=2>')
       
       
       
       
       
            ),
    #this is in teh main body so we have divided the body in two halfs
    dashboardBody(
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css") #We ahve changed the CSS to apply some changes
             
            
        ),
        tabItems(
            tabItem(tabName = "boxplot",
                    #these are the different cards with the data in teh first row of the body
                    fluidRow(infoBoxOutput("meanBox"),
                             infoBoxOutput("medianBox"),
                             infoBoxOutput("countBox")),
                    #this row adds the map and the histogram so the actual info
                    fluidRow(box(plotlyOutput("boxplot")),
                             box(plotlyOutput("ggplot_histogram")))), 
                    
                    
            #we add here the table
            tabItem(tabName = "map",
                    fluidRow(box(leafletOutput("map", height = 600), title= 'Median House Prices by Borough', width = 12))), #width = 12 , means whole page
            tabItem(tabName = "data",
                    fluidRow(box(DT::dataTableOutput("data"), width = 12)))#usign the DT package, defaul size added too
        )
    )
))