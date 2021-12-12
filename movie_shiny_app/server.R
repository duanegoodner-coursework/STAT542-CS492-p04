library(data.table)
library(recommenderlab)
library(Matrix)

source('scripts/import_data.R')

get_user_ratings = function(value_list) {
  dat = data.table(MovieID = sapply(strsplit(names(value_list), "_"), 
                                    function(x) ifelse(length(x) > 1, x[[2]], NA)),
                   Rating = unlist(as.character(value_list)))
  dat = dat[!is.null(Rating) & !is.na(MovieID)]
  dat[Rating == " ", Rating := 0]
  dat[, ':=' (MovieID = as.numeric(MovieID), Rating = as.numeric(Rating))]
  dat = dat[Rating > 0]
}


get_user_top_n <- function(user_ratings) {
  new_user_data <- data.table(
    i = rep(max(model_data$i) + 1, nrow(new_user_ratings)),
    j = new_user_ratings$MovieID,
    x = new_user_ratings$Rating)
  
  full_data <- rbind(model_data, new_user_data)
  full_data_sparse <- sparseMatrix(i = as.integer(as.factor(full_data$i)),
                                   j = as.integer(as.factor(full_data$j)),
                                   x = full_data$x)
  full_data_rrm <- as(full_data_sparse, "realRatingMatrix")
  
  
  if (nrow(user_ratings) == 1) {
    cur_recommender <- ibcf_recommender
  } else {
    cur_recommender <- svd_recommender
  }
  
  top_n_result <-
    predict(cur_recommender, full_data_rrm[new_user_id], type = "topNList", n = 10)
  
  return(top_n_result@itemLabels[top_n_result@items[[1]]])
}


shinyServer(function(input, output, session) {
  
  # show the books to be rated
  output$ratings <- renderUI({
    num_rows <- 20
    num_movies <- 6 # movies per row
    
    lapply(1:num_rows, function(i) {
      list(fluidRow(lapply(1:num_movies, function(j) {
        list(box(width = 2,
                 div(style = "text-align:center", img(src = movies$image_url[(i - 1) * num_movies + j], height = 150)),
                 #div(style = "text-align:center; color: #999999; font-size: 80%", books$authors[(i - 1) * num_books + j]),
                 div(style = "text-align:center", strong(movies$Title[(i - 1) * num_movies + j])),
                 div(style = "text-align:center; font-size: 150%; color: #f0ad4e;", ratingInput(paste0("select_", movies$MovieID[(i - 1) * num_movies + j]), label = "", dataStop = 5)))) #00c0ef
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
      
      if (nrow(new_user_ratings) == 0) {
        top_n_result <- popular_recommender@model$topN
        user_predicted_ids <-
          as.integer(top_n_result@itemLabels[top_n_result@items[[1]][1:10]])
      } else {
        user_predicted_ids <- get_user_top_n(new_user_ratings)
      }
      
      recom_movies <- subset(movies, MovieID %in% user_predicted_ids)
      
      recom_results <- data.table(Rank = 1:nrow(recom_movies), 
                                  MovieID = recom_movies$MovieID, 
                                  Title = recom_movies$Title)
      
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
                a(img(src = movies$image_url[recom_result$MovieID[(i - 1) * num_movies + j]], height = 150))
            ),
            div(style="text-align:center; font-size: 100%", 
                strong(movies$Title[recom_result$MovieID[(i - 1) * num_movies + j]])
            )
            
        )        
      }))) # columns
    }) # rows
    
  }) # renderUI function
  
}) # server function