library(plumber)

plumb("plumber.R")$run(port=9002, host="0.0.0.0")
