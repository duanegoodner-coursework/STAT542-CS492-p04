## ui.R
library(shiny)
library(shinydashboard)
library(recommenderlab)
library(data.table)
library(ShinyRatingInput)
library(shinyjs)

source('functions/ui_helpers.R')

shinyUI(
    dashboardPage(
      
          skin = "blue",
          dashboardHeader(title = "Movie Recommenders"),
          
          dashboardSidebar(
            sidebarMenu(
              menuItem("Genre-based", tabName = "genre", icon = icon("book")),
              menuItem("Collaborative Filtering", tabName = "cf", icon = icon("th"))
            )
          ),

          dashboardBody(
            # tags$head(
            #   tags$link(rel = "styleSheet", type = "text/css", href = "movies.css")
            # ),
            includeCSS("css/movies.css"),
            tabItems(
              tabItem(tabName = "genre",
                fluidRow(
                  box(width = 12,
                      height = 250,
                      title = "Select your favorite genre",
                      status = "info", solidHeader = TRUE, collapsible = FALSE,
                      div(class = "choosegenre",
                          # uiOutput('genres')
                          awesomeRadio(inputId = "genreradio", label = "choose genre",
                                       choices = c("one", "two", "three"),
                                       inline = TRUE)
                      )
                  )
                )
              ),
              tabItem(tabName = "cf",
                fluidRow(
                  box(width = 12,
                      title = "Step 1: Rate as many movies as possible",
                      status = "info", solidHeader = TRUE, collapsible = TRUE,
                      div(class = "rateitems",
                          uiOutput('ratings')
                      )
                  )
                ),
                fluidRow(
                  useShinyjs(),
                  box(
                    width = 12, status = "info", solidHeader = TRUE,
                    title = "Step 2: Discover movies you might like",
                    br(),
                    withBusyIndicatorUI(
                      actionButton("btn", "Click here to get your recommendations", class = "btn-warning")
                    ),
                    br(),
                    tableOutput("results")
                  )
                )
              )
            )
          )
    )
) 