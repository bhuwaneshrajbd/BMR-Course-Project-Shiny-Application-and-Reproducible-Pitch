#Load Required Library
library(dygraphs)
library(ggplot2)
library(reshape2)
library(xts)
library(rsconnect)
library(shiny)

#Load data
indiatourism <- read.csv('indiatourism.csv', stringsAsFactors = FALSE)
indiatourism$NoOfVisitors <- as.numeric(indiatourism$NoOfVisitors)
indiatourism$Region <- as.factor(indiatourism$Region)
indiatourism$IncomeGroup <- factor(indiatourism$IncomeGroup
                        , levels = c("High income","Low income","Upper middle income","Others","Lower middle income")
                        , labels = c("High income","Low income","Upper middle income","Others","Lower middle income"))

#Aggregates the No of Visitors arrival in India according to their Country Region
aggregated_data <- aggregate(NoOfVisitors ~ Region, data = indiatourism, FUN = sum)
CountryRegion <- aggregated_data[order(-aggregated_data$NoOfVisitors),]
CountryRegion$Region <- factor(CountryRegion$Region, levels = CountryRegion$Region)

shinyServer(
        function(input, output) {
                datasetInput <- reactive({
                        dataset <- subset(indiatourism, Region == input$Region)
                        dataset
                })
                
                output$dygraph <- renderDygraph({
                        indiatourismData <- datasetInput()
                        indiatourism_xts <- as.xts(
                                indiatourismData[5]
                                , order.by = as.Date(paste(indiatourismData$Region,'01','01', sep = '-'), format='%Y-%M-%D')
                                )
                        
                        dygraph(data = indiatourism_xts, 
                                main = paste("Tourists Visit from ",input$Region,
                                             " to India", sep = "")) %>% 
                                dyRangeSelector()
                })
                output$view <- renderPlot({
                        ggplot(CountryRegion, aes(x = Region, y = NoOfVisitors)) + 
                                geom_bar(stat = "identity", fill = "red") + 
                                theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
                                ylab("Number of Visitors")
                })
                output$view1 <- renderPlot({
                  dataset <- datasetInput()
                  aggregated_data <- aggregate(NoOfVisitors ~ IncomeGroup, data = dataset, FUN = sum)
                  ggplot(aggregated_data, aes(x = IncomeGroup, y = NoOfVisitors)) + 
                    geom_bar(stat = "identity", fill = "red") + 
                    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
                    ylab("Number of Visitors")
                })
                output$table_output <- renderTable({
                     dataset <- datasetInput()
                     dataset <- aggregate(NoOfVisitors ~ Region, 
                                          data = dataset, FUN = sum)
                     dataset
                })
        }
)
