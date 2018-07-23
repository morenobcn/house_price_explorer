library(DT)
library(shiny)
library(shinydashboard)

#shiny dashboard has different panels, header sidebar and body 
shinyUI(dashboardPage(skin = "black", 
    dashboardHeader(title = "London House Prices Stats Explorer (2017-18)", titleWidth = 600),
    dashboardSidebar(width = 350,
        
        #this is the logo and name of the company, imgae will be round
        #sidebarUserPanel('Nacho Moreno',image = "https://jll.box.com/shared/static/mk08h1r6t4e3w8didvjxrzofy74jf260.png"),
        
        #we add the menus called Boxplot, map and data to the sidebar 
        br(),
        sidebarMenu(
            menuItem("Data Explorer", tabName = "boxplot", icon = icon("home")),
            menuItem("Map Visualization", tabName = "map", icon = icon("map")),
            menuItem("Summary Data", tabName = "data", icon = icon("database"))
            
        ),
        
        #adding a bit of blank space
        br(),
       
        
       #this selects the MAD we will use to filter our dataset
        selectizeInput("selected_mad",
                       "Select MAD factor*",
                       mad_options),
       
       
       #Adding the range slider for the quartiles
       sliderInput("slider_quantiles", "Select percentile**", min = 0.0, 
                   max = 1, step=.1, value = c(0, 1)),
       
        #Multi select for boroughs
        selectizeInput("selected_boroughs",
                       "Select Borough",
                       choices = boroughs_names, multiple = TRUE, selected=c('BROMLEY','WALTHAM FOREST', 'CAMDEN')),
        
       #Selection for the file to donwload
       selectInput("download_files", "Download dataset",
                    choices = c("Filtered dataset", "Summary data")),
       
       #Adding the button
       downloadButton('downloadData', 'Download')
      
       
      ),
    
    #this is in the main body
    dashboardBody(
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css") #We ahve changed the CSS to apply some changes
             
            
        ),
        tabItems(
            tabItem(tabName = "boxplot",
                    #Each row is evenly distributed depdending on the number of rows, no need to add the width
                    #these are the different cards with the data in teh first row of the body
                    fluidRow(infoBoxOutput("meanBox"),
                             infoBoxOutput("medianBox"),
                             infoBoxOutput("countBox")),
                    #this row adds the map and the histogram so the actual info
                    fluidRow(box(plotlyOutput("boxplot")),
                             box(plotlyOutput("ggplot_histogram"))),
                    fluidRow(box(textOutput("text"), width = 12)) #width 12 is the max of the page
                    ), 
            
            #we add here the map and data tabs
            tabItem(tabName = "map",
                    fluidRow(box(leafletOutput("map", height = 600), title= 'Median House Prices by Borough', width = 12))),
            tabItem(tabName = "data",
                    fluidRow(box(DT::dataTableOutput("data"), width = 12)))#usign the DT package, defaul size added too
        )
    )
))