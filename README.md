## London house prices stats explorer tool

Follow this link to access the hosted Shiny Application: https://natxomoreno.shinyapps.io/London_House_Prices_Stat_Explorer/

### Project background

Land registry (https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads) published data for each transaction that is registered in England & Wales. This data has been used extensively for many analysis, from price evolution in time to assess the price difference in different areas. This dataset is publicly availble under the governtment licence. Data dates back to 1995 and there is a record for each transaction.

The main variables we find in each dataset are the location of the transaction (with full postcode), the type of asset (Other, DEtached, ...) and also the price. Unfortunately there is no qualitative or quantitative information of each asset (an area would be very usefull indeed).

The main issue working with this dataset and in particular when working with transactional data (Residential, Offices, ...) is that the distribution is usually really skewed. For this reason we have creayted  tool with two main objectives:

  * Define the best Median Absolute deviation factor to filter our dataset and discard outliers.
  * Filter the resulting dataset to segment de market data so users can focus in a given upper or lower percentile of the sample. 

### Cleanse the data and discard outliers

Is a common practice to filter big datasets setting a minimum and maximum value arbitrarily. This method although effective introduces an important bias in our sample since we don't take into consideration that each geographical area is different. Also given the fact Thats why within teh Shiny App we have created the method o

### Market segmentation






