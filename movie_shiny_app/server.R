library(data.table)
library(recommenderlab)
library(Matrix)
library(caret)

# source('scripts/import_data.R')
source('functions/server_helpers.R')


import_shiny_app_data()

shinyServer(function(input, output, session) {
  
  genre_names <- colnames(genre_matrix)[-1]
  
  # show genre options
  # output$genres <- renderUI({
  #   num_rows <- 3
  #   num_cols <- 6
  # 
  #   lapply(1:num_rows, function(row_num) {
  #     list(fluidRow(lapply(1:num_cols, function(col_num) {
  #       list(box(width = 2,
  #                div(
  #                  style = "text-align:center",
  #                  strong(genre_names[(row_num - 1) * num_cols + col_num])
  #                )))
  #     })))
  #   })
  # })
  
  # show the books to be rated
  output$ratings <- renderUI({
    num_rows <- 20
    num_movies <- 6 # movies per row
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        list(box(width = 2,
                 div(
                   style = "text-align:center",
                   img(src = movies$image_url[(i - 1) * num_movies + j],
                       height = 150)
                   ),
                 div(
                   style = "text-align:center",
                   strong(movies$Title[(i - 1) * num_movies + j])
                   ),
                 div(style = "text-align:center; font-size: 150%; color: #f0ad4e;",
                     ratingInput(paste0("select_", movies$MovieID[(i - 1) * num_movies + j]),
                                 label = "", dataStop = 5)
                   )
                 )
           ) #00c0ef
      })))
    })
  })
  
  # Calculate recommendations when the sbumbutton is clicked
  df <- eventReactive(input$btn, {
    withBusyIndicatorServer("btn", { # showing the busy indicator
      # hide the rating container
      useShinyjs()
      jsCode <- "document.querySelector('[data-widget=collapse]').click();"
      runjs(jsCode)
      
      # get the user's rating data
      value_list <- reactiveValuesToList(input)
      
      # new_user_ratings <- readRDS('test_data/user_ratings_dat.RDS')
      new_user_ratings <- get_user_ratings(value_list)
      
      # calculate ids of movies in user's top_n list
      user_top_n_ids <- get_user_top_n_ids(new_user_ratings)
      
      # extract entries from movies corresponding to recommended moive IDs
      recom_movies <- subset(movies, MovieID %in% user_top_n_ids)
      
      return(recom_movies)
      
    }) # still busy
    
  }) # clicked on button
  
  
  # display the recommendations
  output$results <- renderUI({
    num_rows <- 2
    num_movies <- 5
    recom_result <- df()
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        box(width = 2, status = "success", solidHeader = TRUE, title = paste0("Rank ", (i - 1) * num_movies + j),
            
            div(style = "text-align:center", 
                a(img(src = recom_result$image_url[(i - 1) * num_movies + j], height = 150))
            ),
            div(style="text-align:center; font-size: 100%", 
                strong(recom_result$Title[(i - 1) * num_movies + j])
            )
            
        )        
      }))) # columns
    }) # rows
    
  }) # renderUI function
  
}) # server function