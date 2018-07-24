## London house prices stats explorer tool

Land registry (https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads)published data for each transaction that is registered in England & Wales. This data has been used extensively for many analysis, from price evolution in time to assess the price difference in different areas. This dataset is publicly availble under the governtment licence. Data dates back to 1995 and there is a record for each transaction.

The main variables we find in each dataset are the location of the transaction (with full postcode), the type of asset (Other, DEtached, ...) and also the price. Unfortunately there is no qualitative or quantitative information of each asset (an area would be very usefull indeed).

The main issue working with this dataset and in particular when working with transactional data (Residential, Offices, ...) is that the distribution is usually really skewed. For this reason we have creayted  tool with two main objectives:

  * Define the best Median Absolute deviation factor to filter our dataset and discard outliers.
  * Filter the resulting dataset to segment de market data so users can focus in a given upper or lower percentile of the sample. 

### hi



The main objective of the tool is to clean the data we can download from the land registry 

Link : https://natxomoreno.shinyapps.io/London_House_Prices_Stat_Explorer/
