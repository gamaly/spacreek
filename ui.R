
library(shiny)
library(leaflet)
library(dplyr)
library(DT)
library(shinydashboard)
library(plotly)
library(lubridate)
library(leaflet.extras)
library(ggplot2)



# Define UI for application that draws a histogram
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
                         #menuItem("About", tabName = "About", icon = icon("info-circle"))
                     )),
    dashboardBody(
        tags$head(tags$style(HTML('
                                /* logo */
                                .skin-blue .main-header .logo {
                                background-color: #3B769B;
                                }

                                /* logo when hovered */
                                .skin-blue .main-header .logo:hover {
                                color: #F9FAF5;

                                }

                                /* navbar (rest of the header) */
                                .skin-blue .main-header .navbar {
                                background-color: #3B769B;
                                }

                                /* main sidebar */
                                .skin-blue .main-sidebar {
                                background-color: #3B769B;
                                }

                                /* active selected tab in the sidebarmenu */
                                .skin-blue .main-sidebar .sidebar .sidebar-menu .active a{
                                color: #D1BA86;
                                }

                                /* other links in the sidebarmenu */
                                .skin-blue .main-sidebar .sidebar .sidebar-menu a{
                                background-color: #3B769B;
                                color: #F9FAF5;
                                }

                                /* other links in the sidebarmenu when hovered */
                                .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{
                                color: #D1BA86;
                                }
                                /* toggle button when hovered  */
                                .skin-blue .main-header .navbar .sidebar-toggle:hover{
                                color: #F9FAF5;
                                }

                                /* body */
                                .content-wrapper, .right-side {
                                background-color: #ddd3bb;
                                }

                                '))),
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
