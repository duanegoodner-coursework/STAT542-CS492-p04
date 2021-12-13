## REFERENCE: Majority of the code for this app is based on the Book Recommender app at:
# https://github.com/pspachtholz/BookRecommender

## ui.R
library(shiny)
library(shinydashboard)
library(recommenderlab)
library(data.table)
library(ShinyRatingInput)
library(shinyjs)
library(shinyWidgets)

source('functions/ui_helpers.R')
source('scripts/startup/import_ui_data.R')


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
            includeCSS("css/movies.css"),
            tabItems(
              
              # genre-base recommender tab
              tabItem(tabName = "genre",
                      h3("UI and server code taken from: https://github.com/pspachtholz/BookRecommender"),
                      br(),
                fluidRow(
                  box(width = 12,
                      # height = 250,
                      title = "Select your favorite genre",
                      status = "info", solidHeader = TRUE, collapsible = FALSE,
                      div(class = "choosegenre",
                          # uiOutput('genres')
                          awesomeRadio(inputId = "genreradio", label = NULL,
                                       choices = genre_names,
                                       inline = TRUE)
                      )
                  )
                ),
                fluidRow(
                  useShinyjs(),
                  box(
                    width = 12, status = "info", solidHeader = TRUE,
                    title = "Step 2: Discover top movies from your favorite genre",
                    # br(),
                    # withBusyIndicatorUI(
                    #   actionButton("genre_btn",
                    #                "Click here to get your recommendations",
                    #                class = "btn-warning")
                    # ),
                    br(),
                    tableOutput("genre_results")
                  )
                )
              ),
              
              # collaborative filtering tab
              tabItem(tabName = "cf",
                      h3("UI and server code taken from: https://github.com/pspachtholz/BookRecommender"),
                      br(),
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
                      actionButton("btn",
                                   "Click here to get your recommendations",
                                   class = "btn-warning")
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