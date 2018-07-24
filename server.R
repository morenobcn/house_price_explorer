library(DT)
library(shiny)
library(googleVis)

shinyServer(function(input, output, session){
    
    ##Functions to save the data and avoid repeat code, we wil call the functions as borough_data() and summary_data(), its reactive so will be aware
    ##of changes in the user selection
  
    borough_data <- reactive({
      
      
      #we calculate the house_prices_sd based on the selection of Median standar deviation the user has chosen for each borough, thus the for loop
      #note the input$selected_sd will contain users choice
      
      #Then we use this calculation as input to filter the data
      #We used a for loop to filter data per each borough and based on the SD and mean just claculated as.double(boroughs_sd[i,3])
      
      i = 1
      house_prices_mad <- as_tibble()
      for (i in 1:nrow(boroughs_mad)){
        filtered_mad <- house_prices %>%
          filter(Borough == as.character(boroughs_mad[i,1])) %>%
          filter(between(Price,((as.double(input$selected_mad)*as.double(boroughs_mad[i,2]))-as.double(boroughs_mad[i,3])),((as.double(input$selected_mad)*as.double(boroughs_mad[i,2]))+as.double(boroughs_mad[i,3])))) %>%
          filter(between(Price, (quantile(Price, c(input$slider_quantiles[1]))),(quantile(Price, c(input$slider_quantiles[2])))))
        i = i +1
        house_prices_mad <- bind_rows(house_prices_mad,filtered_mad)  
      }
      
      #Filter the data by the selected borough for representations
      borough_data <- house_prices_mad %>%
        filter(Borough %in% input$selected_boroughs)
      
    })
    
    #I repeat part of the code here to avoid issues
    summary_data <- reactive({
      
      i = 1
      house_prices_mad <- as_tibble()
      for (i in 1:nrow(boroughs_mad)){
        filtered_mad <- house_prices %>%
          filter(Borough == as.character(boroughs_mad[i,1])) %>%
          filter(between(Price,((as.double(input$selected_mad)*as.double(boroughs_mad[i,2]))-as.double(boroughs_mad[i,3])),((as.double(input$selected_mad)*as.double(boroughs_mad[i,2]))+as.double(boroughs_mad[i,3])))) %>%
          filter(between(Price, (quantile(Price, c(input$slider_quantiles[1]))),(quantile(Price, c(input$slider_quantiles[2])))))
        i = i +1
        house_prices_mad <- bind_rows(house_prices_mad,filtered_mad)  
      }
      
    #different from previosur eactive, here we will summarise by borough
      summary_borough <- house_prices_mad %>%
        group_by(Borough) %>%
        summarise(Median = median(Price), Mean = mean(Price), Max = max(Price), Min = min(Price), Count = n())
      
    })
    
    #this is the reactive function for the download, we let the user choose which file to download
    datasetInput <- reactive({
      # Fetch the appropriate data object, depending on the value
      # of input$dataset.
      switch(input$download_files,
             "Filtered dataset" = borough_data(),
             "Summary data" = summary_data())
    })
    
    
    #Boxplot
    output$boxplot <-renderPlotly({ #since we are using renderploty we dont even need to use the function ggplotly()
      
    #GGplot boxplot with the data
      ggplot(borough_data(),aes(x=Borough, y =Price)) + #note that we use the reactive expression with all the data
          geom_boxplot(fill='#E30613', color="darkred", outlier.size = 0.5) +
          theme_minimal() +
          labs(title='House prices spread by Borough', y='Count of properties', x='Borough', caption='Data from Land Registry')
      })
    
    #GGPlot histogram with the mean
    output$ggplot_histogram <-renderPlotly({ 
      
    ggplot(borough_data(), aes(x=Price)) + 
        geom_histogram(binwidth=25000,fill='#E30613') +
        geom_vline(xintercept= mean(borough_data()$Price),colour='grey20',size=0.5,linetype=2) +
        theme_minimal() +
        labs(title='House prices distribution (with mean)', y='Count of properties', x='House Prices', caption='Data from Land Registry')
   })
    
    # show statistics using infoBox
    #we use the IDs from the UI for each of the infoboxes
    output$meanBox <- renderInfoBox({
      
      #With the tables ready we calculate the metrics we willbe displaying
      mean_value <- borough_data() %>%
        summarise((format(as.integer(mean(Price)),big.mark=",")))
        
      
      infoBox(
          paste("Mean House price"),
          mean_value, icon = icon("home"), color="black")
    
       })
    
    #Median to display
    output$medianBox <- renderInfoBox({
      
    
        median_value <- borough_data() %>%
        summarise(format(as.integer(median(Price)),big.mark=","))
        
      
      infoBox(
        paste("Median House price"), median_value, icon = icon("home"), color="black")
    })
    
    #Countbox to display
    output$countBox <- renderInfoBox({
      
      #Count to display
      count <- borough_data() %>%
        summarise(format(as.integer(n()),big.mark=","))
      
      
      infoBox(
        paste("Total count of properties"), count, icon = icon("home"), color="black")
    })
    
  #Disclaimer text at the bottom of the page
    
  output$text <- renderText({
    HTML('* The MAD factor is used to filter the data based on the Median Absolute Deviation (MAD). Selecting higher values will mean the dataset will include higher nad lower value outliers. **The percentile will segment the market. 
Selecting 0.8 to 1, will show the Top 20% of the properties, selecting 0.1 to 0.2 will show the low end 20% of the market. Dataset: Land Registry. Values 2017 to June 2018.')
    })

  #Show the map using leaflet
  output$map <- renderLeaflet({
    
    #We merge the shapefile with the boroughs data from the summary_data() reactive expression
    boroughs_to_map <- merge(boroughs_sp, summary_data(), by.x = 'name', by.y = 'Borough')
    
    #create a manual JLL the palette
    palette <- colorQuantile(c("#F8CDA9",  "#F6B784", "#F19447", "#ED700A"),boroughs_to_map$Median, n=4)
    
    #Custom labels for the hover over
    labels <- sprintf(
      "<strong>%s</strong><br/>%s",
      boroughs_to_map$name, format(round(boroughs_to_map$Median, digits=0), big.mark = ",")
    ) %>% 
      lapply(htmltools::HTML)
    
    #plot the map
    boroughs_to_map %>%
      leaflet(options = leafletOptions(preferCanvas = TRUE)) %>% #not sure what the prefer canvas does
      addProviderTiles(providers$CartoDB.DarkMatterNoLabels)  %>% #this is the basemap
      addPolygons(weight = 1,
                           color = 'Black',
                           opacity = 0.7,
                           fillColor = ~palette(Median), #what variable we will be using for the cloropeth
                           fillOpacity = 0.8,
                           label = labels, #using the previous variable
                           popup = ~paste('<strong>', name,'</strong>', '<br/>', 'Median: ', format(round(Median, digits=0), big.mark = ","), '<br/>', 'Mean: ', format(round(Mean, digits=0),big.mark = ",")),
                           highlight = highlightOptions( weight = 3, color = "E30613",fillOpacity = 1,bringToFront = TRUE)) %>%
      #the previous highlight option is the polygon hover over highlighting
      #there are some conflicts so we need to use this notation to call addlegend
      leaflet::addLegend("bottomright", 
                         colors =c("#F8CDA9",  "#F6B784", "#F19447", "#ED700A"),
                         labels= c("Lower Quartile", "","","Top Quartile"),
                         #value = ~Median, 
                         title = 'Median House Price (pounds sterling)') 
    
  })
    
    # show data using DataTable
    output$data <- DT::renderDataTable({
      
      
      
      datatable(summary_data(), rownames=FALSE, 
                options = list(
                  pageLength = 33,
                  order = list(list(1, 'desc')))) %>% 
        formatStyle(input$selected, background="skyblue", fontWeight='bold') #we highlight the selected column
    })
    
    
    ###########Download the data
    output$downloadData <- downloadHandler(
      
      # This function returns a string which tells the client
      # browser what name to use when saving the file.
      filename = function() {
        paste(input$download_files,c('csv') ,sep = ".")
      },
      
      # This function should write data to a file given to it by
      # the argument 'file'.
      content = function(file) {
        
        
        # Write to a file specified by the 'file' argument
        write.table(datasetInput(), file, sep = ',',
                    row.names = FALSE)
      }
    )
    
    
    })



