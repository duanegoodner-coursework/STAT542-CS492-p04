

get_user_ratings = function(value_list) {
  dat = data.table(MovieID = sapply(strsplit(names(value_list), "_"), 
                                    function(x) ifelse(length(x) > 1, x[[2]], NA)),
                   Rating = unlist(as.character(value_list)))
  dat = dat[!is.null(Rating) & !is.na(MovieID)]
  dat[Rating == " ", Rating := 0]
  dat[, ':=' (MovieID = as.numeric(MovieID), Rating = as.numeric(Rating))]
  dat = dat[Rating > 0]
}


get_user_top_n_ids <- function(user_ratings) {
  
  if (nrow(user_ratings) < 2) {
    top_n_result <- popular_recommender@model$topN
    user_top_n_ids <-
      as.integer(top_n_result@itemLabels[top_n_result@items[[1]][1:10]])
  } else {
    new_user_data <- data.table(
      i = rep(max(model_data$i) + 1, nrow(user_ratings)),
      j = user_ratings$MovieID,
      x = user_ratings$Rating)
    
    full_data <- rbind(model_data, new_user_data)
    full_data_sparse <- sparseMatrix(i = as.integer(as.factor(full_data$i)),
                                     j = as.integer(as.factor(full_data$j)),
                                     x = full_data$x)
    full_data_rrm <- as(full_data_sparse, "realRatingMatrix")
    
    top_n_result <-
      predict(svd_recommender, full_data_rrm[new_user_id], type = "topNList", n = 10)
    
    user_top_n_ids <- top_n_result@itemLabels[top_n_result@items[[1]]]
  }
  
  return(user_top_n_ids)
}

get_top_rated_popular_of_genre_ids <- function(genre, num_movies = 5) {
  df <- genre_matrix[
    which(genre_matrix[[genre]] == 1), ] %>%
    inner_join(ratings, by = 'MovieID') %>%
    group_by(MovieID) %>%
    summarize(ratings_per_movie = n(), ave_rating = mean(Rating)) %>%
    inner_join(movies, by = 'MovieID')
  
  num_ratings_cutoff <- summary(df$ratings_per_movie)["3rd Qu."]
  
  df <- df[which(df$ratings_per_movie > num_ratings_cutoff), ] %>%
    arrange(desc(ave_rating)) %>%
    head(num_movies)
  
  return(df$MovieID)
}


