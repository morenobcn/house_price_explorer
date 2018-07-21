library(DT)
library(shiny)
library(googleVis)

shinyServer(function(input, output, session){
    
    ##Functions to save the data and avoid repeat code, we wil call the functions as house_prices_mad(), its reactive so will be aware
    ##of changes in the user selection
  
    #we calculate the house_prices_sd based on the selection of Median standar deviation of the user
    #note the input$selected_sd will contain users choice
    
    #Then we use this calculation as input to filter the data
    #We used a for loop to filter data per each borough and based on the SD and mean jsut claculated as.double(boroughs_sd[i,3])
    #### house_prices_mad is the main dataset we will use for the boxplot and map ####
  
    borough_data <- reactive({
      
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
      
    summary_borough <- house_prices_mad %>%
        group_by(Borough) %>%
        summarise(Median = median(Price), Mean = mean(Price), Max = max(Price), Min = min(Price), Count = n())
      
    })
    
    datasetInput <- reactive({
      # Fetch the appropriate data object, depending on the value
      # of input$dataset.
      switch(input$download_files,
             "Filtered dataset" = borough_data(),
             "Summary data" = summary_data())
    })
    
    
    #Boxplot
    output$boxplot <-renderPlotly({
      
    #GGplot boxplot with the data
      ggplot(borough_data(),aes(x=Borough, y =Price)) +
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
    
    # show statistics using infoBox, wow quite useful!!
    #we use the IDs from the 
    output$meanBox <- renderInfoBox({
      
      #With the tables ready we calculate the metrics we willbe displaying
      mean_value <- borough_data() %>%
        summarise((format(as.integer(mean(Price)),big.mark=",")))
        
      
      infoBox(
          paste("Mean House price"),
          mean_value, icon = icon("home"), color="black")
    
       })
    output$medianBox <- renderInfoBox({
      
      #Median to display
      median_value <- borough_data() %>%
        summarise(format(as.integer(median(Price)),big.mark=","))
        
      
      infoBox(
        paste("Median House price"), median_value, icon = icon("home"), color="black")
    })
    
    #in this one the code is slightly different
    output$countBox <- renderInfoBox({
      
      #Count to display
      count <- borough_data() %>%
        summarise(format(as.integer(n()),big.mark=","))
      
      
      infoBox(
        paste("Total count of properties"), count, icon = icon("home"), color="black")
    })

  #Show the map using leaflet
  output$map <- renderLeaflet({
    
    ####Here we can't use the reactive fucntion cos would only show the selected boroughs and we want to show all!!
    
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
    
    #Create a dataset with the output by borough so we can map this data, we only do this once
    summary_borough <- house_prices_mad %>%
      group_by(Borough) %>%
      summarise(Median = median(Price), Mean = mean(Price), Max = max(Price), Min = min(Price), Count = n())
    
    ###### WE WORK ON THE MAP#########
    
    
    #We merge with our data now
    boroughs_to_map <- merge(boroughs_sp, summary_borough, by.x = 'name', by.y = 'Borough')
    
    #lets begin with the map
    
    #create the palette
    palette <- colorQuantile(c("#F8CDA9",  "#F6B784", "#F19447", "#ED700A"),boroughs_to_map$Median, n=4)
    
    #Custom labels
    labels <- sprintf(
      "<strong>%s</strong><br/>%s (pounds)",
      boroughs_to_map$name, format(round(boroughs_to_map$Median, digits=0), big.mark = ",")
    ) %>% 
      lapply(htmltools::HTML)
    
    #plot the map
    boroughs_to_map %>%
      leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      addProviderTiles(providers$CartoDB.DarkMatterNoLabels)  %>%
      addPolygons(weight = 1,
                           color = 'Black',
                           opacity = 0.7,
                           fillColor = ~palette(Median),
                           fillOpacity = 0.8,
                           label = labels,
                           popup = ~paste('<strong>', name,'</strong>', '<br/>', 'Median: ', format(round(Median, digits=0), big.mark = ","), '<br/>', 'Mean: ', format(round(Mean, digits=0),big.mark = ",")),
                           highlight = highlightOptions( weight = 3, color = "E30613",fillOpacity = 1,bringToFront = TRUE)) %>%
      leaflet::addLegend("bottomright", 
                         colors =c("#F8CDA9",  "#F6B784", "#F19447", "#ED700A"),
                         labels= c("Lower Quartile", "","","Top Quartile"),
                         #value = ~Median, 
                         title = 'Median House Price (pounds)') 
    
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



