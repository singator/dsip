#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)
library(tidyverse)

lm1 <- readRDS("lm1.rds")
hdb4 <- readRDS("hdb4.rds") %>% as_tibble()

#* @apiTitle HDB predictions with R API
#* @apiDescription Similar functions to the Python API in class

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg = "") {
    list(msg = paste0("The message is: '", msg, "'"))
}

#* Predict the ppsqm for a new flat to be sold.
#* 
#* @param town The town to predict
#* @param storey The storey of the flat.
#* @get /prediction
function(town = "QUEENSTOWN", storey=1) {
    new_df <- data.frame(town=town, storey=as.numeric(storey))
    pred <- predict.lm(lm1, new_df)
    list(pred = pred)
}

#* Plot a boxplot
#* @serializer png
#* @get /plot
function() {
    print(ggplot(hdb4) + geom_boxplot(aes(x=as.factor(storey), y=ppsqm), alpha=0.4))
}
