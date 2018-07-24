## London house prices stats explorer tool

Access the hosted Shiny Application: https://natxomoreno.shinyapps.io/London_House_Prices_Stat_Explorer/

### Project background

[Land Registry](https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads, 'Price Paid, Land Registry') publishes data for each house sale transaction that is registered in England & Wales. This data has been used extensively for many analysis, from price evolution in time to assess the price difference in different areas. This dataset is publicly available under the government licence. and dates back to 1995.

The main variables we find in each dataset are the location of the transaction (with full postcode), the type of asset (Other, Detached, ...) and the price. Unfortunately, there is no qualitative or quantitative information of each asset (an area would be very useful indeed).

The main issue working with this dataset, particularly when working with any transactional dataset (Residential, Offices, ...) is that the distribution is usually really skewed, with values of just few thousand pounds to many millions. For this reason, we have created a tool with two main objectives:

  * Filter the original dataset based on the Median Absolute Deviation times a factor and this way discard outliers.
  * Further filter the resulting dataset to segment de market data so users can focus in a given upper or lower percentile of the sample.

This exercise responds to business needs that I have found in my day to day job. 

### Cleanse the data and discard outliers

Although is common practice, would be wrong to cleanse the data only applying a minimum and max values filter to the whole dataset, mainly because two reasons:

 * The highly skewed distribution of the price range 
 * The variability of prices within each group
 
To tackle the first issue, we decided to implement the MAD (Median Absolute Deviation) instead of the standard deviation to be less dependent on the variance of the data and apply a factor below and above the median to filter the data. So, a '2' factor will discard values 2 times above or below the Median therefore the higher the factor applied will result in more extreme values to be included in the final sample. 

At the same time and to avoid geographical bias we apply this methodology **per each Borough**. That is, we calculate the median and MAD for each borough and is with this data that we apply the MAD factor filtering. In other words, a 1million pounds house in a central Borough won’t be considered an outlier but might be discarded if the house is located in one of the outer Boroughs. 

![screenshot_1](https://user-images.githubusercontent.com/36007042/43162508-40ad3e6a-8f59-11e8-9732-819506ba48d3.png)

 
### Market segmentation

Real Estate investors market their properties to very specific market segments, i.e. for the top end of the market. Having the capability to dynamically select which 'slice' of the market we are interested in is therefore a very useful tool when working with house prices. 

With the percentiles slider implemented the user can easily select the segment of the market he is interested in. For example, to analyse the top end of the market would be as easy as to select for 0.8 to 1 in the slider

![screenshot_2](https://user-images.githubusercontent.com/36007042/43162671-c1d10fd0-8f59-11e8-863a-268f425b1b5d.png)

### Download the data

Since this is a tool which objective is to implement specific criteria to filter and segment a dataset the download capability has also been implemented. We can download either the full dataset once is cleansed according to user selection or a Borough summary for convenience.

## Next steps

This application should be extended to allow the following:

* Implement de capability to upload your own CSV.
* Map each of the properties to help to visualize the data.
* Make the tool country agnostic making the code as generic as possible so we can implement the same methodology for other datasets.
