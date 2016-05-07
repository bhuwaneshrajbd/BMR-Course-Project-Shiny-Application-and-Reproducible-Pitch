library(dygraphs)
library(shiny)

indiatourism <- read.csv('indiatourism.csv', stringsAsFactors = FALSE)
choices <- unique(indiatourism$Region)

shinyUI(pageWithSidebar(
        headerPanel('International Tourism - Number of Arrivals in India between the Years 2000 to 2014'),
        sidebarPanel(
                selectInput('Region', 'Choose Region', choices = choices),
                p('Total Tourist visit from select Country Region'),
                tableOutput("table_output"),
                p('Number of Tourists (Country Region Wise)'),
                plotOutput("view")
        ),
        mainPanel(
          p('Number of Tourists (Country Region Wise)'),
          plotOutput("view1")
                  
        )
))
