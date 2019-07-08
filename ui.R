#### This is the UI.R FILE, which defines the user interface #####

library(shiny)
library(leaflet)
library(dplyr)
library(DT)
library(shinydashboard)
library(plotly)
library(lubridate)
library(leaflet.extras)
library(ggplot2)

#install.packages(c("shiny", "leaflet", "dplyr", "DT", "shinydashboard", "plotly", "lubridate", "leaflet.extras", "ggplot2"))


shinyUI(dashboardPage(
    dashboardHeader(title="Water Test Results"),
    dashboardSidebar(collapsed = TRUE, width = 200,
                     sidebarMenu(
                         menuItem(
                             "Most Recent Data",
                             tabName = "MostRecent",
                             icon = icon("dashboard")
                         ),
                         menuItem(
                             "Water Runnoff Impact",
                             tabName = "RunnoffAnalysis",
                             icon = icon("chart-line")
                         ),
                         menuItem(
                             "Historic Data",
                             tabName = "Historic",
                             icon = icon("chart-line")
                         )
                     )),
    dashboardBody( tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),

        tabItems(
            # First tab content
            tabItem(
                tabName = "MostRecent",
                h1("Spa Creek & Back Creek Water Quality", align = "center"),
                p(textOutput("latestdate"), align = "center"),
                
                hr(),
                fluidRow(
                    column(4,
                           valueBoxOutput("dateBox", width = NULL)),
                    column(4,
                           valueBoxOutput("healthyBox", width = NULL)),
                    column(4,
                           valueBoxOutput("unhealthyBox", width = NULL))
                ),
                fluidRow(
                    column(12,
                           leafletOutput("map")
                           
                           
                    )),
                
                fluidRow(
                    box(
                        title = "Results",
                        width = 12,
                        status = "primary",
                        solidHeader = TRUE,
                        DTOutput('LatestDT')
                    )
                )
                
            ),
            
            ## Historic Data
            tabItem(
                tabName = "RunnoffAnalysis",
                h1("Understanding Water Runnoff"),
                p("Water quality levels as measured by Enterococci tests show a strong correlation with with rainfall in inches"),
                fluidRow(
                    column(6,
                           box(
                               plotOutput("RainfallAndEntCfu"), width = NULL)),
                    column(6,
                           box(
                               verbatimTextOutput("corrtestRainfallEnt"), width = NULL,  title = "linear model output"))),
                fluidRow(
                    box(
                        title = "Distribution of Samples by Date",
                        width = 12,
                        status = "primary",
                        solidHeader = TRUE,
                        plotlyOutput("historicBoxPlots")
                    ))
                
                
                
            ),
            tabItem(
                tabName = "Historic",
                fluidRow(
                        box(width = 12, title = "Enterococchi Test Results", status = "primary", solidHeader = TRUE, collapsible = TRUE,
                            column(width = 6, 
                            plotlyOutput("historicEntTime")),
                            column(width = 6, 
                            plotlyOutput("Ent_distributionBoxPlotLog"))
                    )),
                fluidRow(
                    box(width = 12, title = "Secchi Disk Test Results", status = "primary", solidHeader = TRUE, collapsible = TRUE,
                        column(width = 6, 
                               plotlyOutput("historicSecchiTime")),
                        column(width = 6, 
                               plotlyOutput("Secchi_distributionBoxPlotLog"))
                    ))
            )
            
        ))
)
)
