## London house prices stats explorer tool

Follow this link to access the hosted Shiny Application: https://natxomoreno.shinyapps.io/London_House_Prices_Stat_Explorer/

### Project background

Land registry (https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads) published data for each transaction that is registered in England & Wales. This data has been used extensively for many analysis, from price evolution in time to assess the price difference in different areas. This dataset is publicly availble under the governtment licence. Data dates back to 1995 and there is a record for each transaction.

The main variables we find in each dataset are the location of the transaction (with full postcode), the type of asset (Other, DEtached, ...) and also the price. Unfortunately there is no qualitative or quantitative information of each asset (an area would be very usefull indeed).

The main issue working with this dataset and in particular when working with transactional data (Residential, Offices, ...) is that the distribution is usually really skewed. For this reason we have creayted  tool with two main objectives:

  * Define the best Median Absolute deviation factor to filter our dataset and discard outliers.
  * Filter the resulting dataset to segment de market data so users can focus in a given upper or lower percentile of the sample. 

### Cleanse the data and discard outliers

Although is common practice, would be wrong to cleanse the data only applying a minimum and max values filter to the whole datase, mainly because the below reasons:

 1. The highly skewed distribution of the price range 
 2. The vairability of prices within each group
 
To tackle the first issue we decided to implement the MAD (Median Abosolute Deviation) instead of the standard deviation to be less dependent on the variance of the data and apply a factor below and above the median to implement the data. So a '2' factor will discard values 2 times above or below the Median. The higher the factor aplied will result in more extreme values to be included in the final smaple. 

At the same time and to avoid geographical bias we apply this methodology per each Borough. That is, we calculate the median and MAD for each borough and is with this data that we apply the MAD factor filtering. In other words, a 1million pounds house in a central Borough wont be considered an outlier but might be discarded if the hosue is located in one of the outer Boroughs. 
 
### Market segmentation

Real Estate investors market their properties to very specific segments of the market, i.e for the top end of the market. HAving the capability ot dinamically select which 'slice' of the market we are interested in analyze is then a very useful tool when analyzing the house prices. 

With the percentiles slider implemented then the user can easily select the segment of the market he is interested in. For example to analyze the top end of the market would be as easy as to select fro 0.8 to 1 in the slider

### Download the data

Since this is a tool to do an initial analysis of the data a download capability has also been implemented. We can download either the full dataset once is cleansed according to user selection or as well a Borough summary for convenience.

## Next steps

This application should be extended to allow the following:

 1. 












