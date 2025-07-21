#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(plotly)
library(httr)
library(jsonlite)
library(RColorBrewer)

hdb <- readRDS('hdb_locs.rds')
flask_url <- "http://flask:5000/"
#flask_url <- "http://127.0.0.1:5000/"

get_pred <- function(town, storey) {
  out <- GET(flask_url, path="prediction", 
             query=list(town=town, storey=storey), 
             verbose())
  as.numeric(content(out))
}

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("HDB resale transactions"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            dateRangeInput("dates_in", 
                           "Select start and end dates",
                           start='2017-01-01',
                           end='2022-02-28'),
            selectInput("choose_flat",
                        "Select flat types", 
                        choices=c("1 ROOM", "2 ROOM", "3 ROOM", "4 ROOM", "5 ROOM",
                                  "EXECUTIVE", "MULTI-GENERATION"),
                        multiple=TRUE)
        ),

        # Show a plot of the generated distribution
        mainPanel(
          tabsetPanel(
            tabPanel("Time series",
                     plotOutput("timePlot")
            ),
            tabPanel("Time series (plotly)",
                     plotlyOutput("timePlot2")
            ),
          )
        )
    ),
    
    hr(),  
    h2("Batch Predictions"),
    
    fluidRow(
      column(5, "Input file should contain two columns:", 
             strong("town (character)"), "and" ,
             strong("storey (numeric)."),
             "There should also be a header row."
             ),
      column(4, fileInput("file1", "Upload csv file", accept=".csv")),
      column(3, downloadButton("download", "Download"))
    ),
    fluidRow(
      column(12, tableOutput("data_display"), align="center")
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    sub_df <- reactive({filter(hdb, between(date, input$dates_in[1], 
                                            input$dates_in[2]), 
                               flat_type %in% input$choose_flat)
      })
    
  output$timePlot <- renderPlot({
    sub_df2 <- group_by(sub_df(), date, flat_type) %>% 
      summarise(mean_ppsqm = mean(ppsqm), .groups="drop") 
    ggplot(sub_df2, aes(x=date, y=mean_ppsqm, col=flat_type)) + geom_point() + 
      geom_line() + 
      labs(title="Mean price per sq. metres", y="SGD", x="Month", col="Flat type")
  })
  output$timePlot2 <- renderPlotly({
    sub_df2 <- group_by(sub_df(), date, flat_type) %>% 
      summarise(mean_ppsqm = mean(ppsqm), .groups="drop") 
    p <- ggplot(sub_df2, aes(x=date, y=mean_ppsqm, col=flat_type)) + geom_point() + 
      geom_line() + 
      labs(title="Mean price per sq. metres", y="SGD", x="Month", col="Flat type")
    ggplotly(p)
  })
  
  output$data_display <- renderTable({
    head(output_data(), n=5)
  })
  
  input_data <- reactive({
    file <- input$file1
    ext <- tools::file_ext(file$datapath)
    req(file)
    shiny::validate(need(ext == "csv", "Please upload a csv file"))
    read.csv(file$datapath, header=TRUE)
  })
  
  output_data <- reactive({
    tmp_out <- mapply(get_pred, town=input_data()$town, 
                      storey=input_data()$storey)
    # check status code
    # handle errors
    #predictions <- content(tmp_out) %>% unlist %>% as.numeric()
    cbind(input_data(), predictions=unname(tmp_out))
  })
  
  output$download <- downloadHandler(
    filename = function() {
      paste("predictions-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(output_data(), file, row.names = FALSE)
    }
  )
  
}

# Run the application 
shinyApp(ui = ui, server = server)
