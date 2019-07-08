#### This is the SERVER.R FILE, which defines all of the back end logic #####


library(shiny)
library(leaflet)
library(dplyr)
library(DT)
library(shinydashboard)
library(plotly)
library(lubridate)
library(leaflet.extras)
library(ggplot2)

#Pull All Data from googledocs, and break it into smaller tables for use in the app.
SpaCreekData <- read.csv("https://docs.google.com/spreadsheets/d/1CWJqvI_0efGqMNV3spKc1rWQhlLQZljGfKcHKxoVkc4/gviz/tq?tqx=out:csv&sheet=2019_ALL_DATA")
SpaCreekData$Date <- parse_date_time(SpaCreekData$Date, "mdy")
SpaCreekLatest <-  SpaCreekData %>% filter(Date==max(Date))
SpaCreekLatest$WaterHealth <- ifelse(SpaCreekLatest$Ent_cfu_.100ml > 104, "Unhealthy", "Healthy") %>% as.factor()
SpaCreekLatest$WaterHealth[is.na(SpaCreekLatest$Ent_cfu_.100ml)] <- "Not Yet Reported"
SpaCreekLatest <- SpaCreekLatest[SpaCreekLatest$Layer == 'S',]
SpaCreekHistoric <- SpaCreekData[SpaCreekData$Layer == 'S',]
HealthTable <- table(SpaCreekLatest$WaterHealth)
DateReported <- as.character(SpaCreekLatest$Date[1:1])


#Create variables for Mapbox integration
tcu_map <- "https://api.mapbox.com/styles/v1/gamaly/cjmhaei90a3xh2sp6lfqftcqg/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZ2FtYWx5IiwiYSI6ImNpZmswdTM3bGN2eXFzNG03OTd6YWZhNmEifQ.srtQMx2-zlTgvAT90pAOTw"
map_attr <- "© <a href='https://www.mapbox.com/map-feedback/'>Mapbox</a>"


shinyServer(function(input, output) {
    
    pal <- colorFactor(c("darkgreen", "darkred"), domain = c("Healthy", "Unhealthy"))
    
    output$map <- renderLeaflet({
        leaflet(data = SpaCreekLatest) %>% addTiles(urlTemplate = tcu_map, attribution = map_attr) %>% addCircleMarkers(~X, ~Y, popup = paste("Name: ", SpaCreekLatest$Name, "<br>", "Date: ", SpaCreekLatest$Date, "<br>", "Ent Cfu: ", SpaCreekLatest$Ent_cfu_.100ml, "<br>", SpaCreekLatest$WaterHealth), color = ~pal(WaterHealth)) %>% addFullscreenControl()
        
        
    })
    
    output$dateBox <- renderValueBox({
        valueBox(
            paste0(DateReported), "Last Date Reported", icon = icon("calendar"),
            color = "aqua")
    })
    
    output$unhealthyBox <- renderValueBox({
        valueBox(
            print(HealthTable[2]), "Unhealthy Sites", icon = icon("exclamation-circle"),
            color = "red")
    })
    output$healthyBox <- renderValueBox({
        valueBox(
            print(HealthTable[1]), "Healthy Sites", icon = icon("swimmer"),
            color = "green")
    })
    
    
    
    output$LatestDT <- renderDataTable(
        SpaCreekLatest,
        rownames = FALSE,
        options = list(
            columnDefs = list(list(
                visible = FALSE, targets = c(0, 1, 3, 4:16, 18:24)
            )) )
        
    )
    
    output$historicBoxPlots <- renderPlotly(plot_ly(SpaCreekHistoric, x = ~Date, y = ~Ent_cfu_.100ml, type = 'box') %>% layout(
        yaxis = list(type = "log", title = "Ent Cfu (100ml) - Log"))) 
    
    output$historicEntTime <- renderPlotly(
        plot_ly(
            SpaCreekHistoric,
            x = ~ Date,
            y = ~ Ent_cfu_.100ml,
            color = ~ Name
        ) %>% add_lines() %>%
            layout(
                title = "Enterococchi Test Results Over Time",
                yaxis = list(fixedrange = TRUE),
                xaxis = list(fixedrange = TRUE),
                showlegend = FALSE
            ) %>% config(displayModeBar = F)
    )
    
    output$historicSecchiTime <- renderPlotly(
        plot_ly(
            SpaCreekHistoric,
            x = ~ Date,
            y = ~ Secchi_cm,
            color = ~ Name
        ) %>% add_lines() %>% layout(
            title = "Secchi Depth Test Results Over Time",
            yaxis = list(fixedrange = TRUE),
            xaxis = list(fixedrange = TRUE),
            showlegend = FALSE
        ) %>% config(displayModeBar = F)
    ) 

    output$Ent_distributionBoxPlotLog <- renderPlotly(plot_ly(
        SpaCreekHistoric,
        x = ~Ent_cfu_.100ml,
        type = "box",
        color = ~ Name
    ) %>% layout(
        xaxis = list(type = "log", title = "Enterococchi Cfu (100ml) - Log Scale", fixedrange=TRUE),
        yaxis=list(fixedrange=TRUE),
        showlegend = FALSE,
        title = "Distribution of Enterocochi Results by Location"
    ) %>% config(displayModeBar = F))
    
    output$Secchi_distributionBoxPlotLog <- renderPlotly(plot_ly(
        SpaCreekHistoric,
        x = ~Secchi_cm,
        type = "box",
        color = ~ Name
    ) %>% layout(
        xaxis = list(title = "Secchi Depth (cm)", fixedrange=TRUE),
        yaxis=list(fixedrange=TRUE),
        showlegend = FALSE,
        title = "Distribution of Secchi Depth Results by Location"
    ) %>% config(displayModeBar = F))
    
        
    output$RainfallAndEntCfu <- renderPlot(ggplot(data = SpaCreekHistoric, aes(x = Ent_cfu_.100ml, y = Inches_Rain)) +
                                               geom_point() + geom_smooth() + ggtitle("Scatterplot of Rainfall & Ent Cfu")  +
                                               xlab("Ent Cfu (100ml)") + ylab("Rain (Inches)") +
                                               scale_x_log10() + scale_y_log10())
    
    Rain_Ent_Corrtest <- lm(`Ent_cfu_.100ml` ~ `Inches_Rain` , data = SpaCreekHistoric)
    output$corrtestRainfallEnt <- renderPrint(summary(Rain_Ent_Corrtest))
    
})
