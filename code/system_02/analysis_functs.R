build_rrm <- function(ratings_data) {
  user_ids <- as.factor(ratings_data$UserID)
  movie_ids <- as.factor(ratings_data$MovieID)
  r_sparse <- sparseMatrix(i = as.integer(user_ids),
                           j = as.integer(movie_ids),
                           x = ratings_data$Rating)
  rownames(r_sparse) <- paste0('u', as.character(levels(user_ids)))
  colnames(r_sparse) <- paste0('m', as.character(levels(movie_ids)))
  
  r_rrm <- as(r_sparse, "realRatingMatrix")
  
  return(r_rrm)
}
environment(build_rrm) <- system_02



test_algos <- function(eval_scheme, algo_list) {

  results <- evaluate(eval_scheme, algo_list, type = "ratings")
  errors <- lapply(results, getConfusionMatrix)

  return(data.frame(unlist(errors, recursive = FALSE)))
}
environment(test_algos) <- system_02



rmse_box_plot <- function(eval_results) {
  results_df <- bind_rows(eval_results)
  boxplot(results_df[c("SVD.RMSE", "UBCF.RMSE")],
          ylab = "RMSE",
          main = "RMSE for SVD and UBCF Predictors (10 iterations each)")
}
environment(rmse_box_plot) <- system_02