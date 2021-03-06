
build_recommenders <- function() {
  data_url <- "https://liangfgithub.github.io/MovieData/"
  ratings <- read.csv(paste0(data_url, 'ratings.dat?raw=true'), 
                      sep = ':',
                      colClasses = c('integer', 'NULL'), 
                      header = FALSE)
  colnames(ratings) <- c('UserID', 'MovieID', 'Rating', 'Timestamp')
  ratings$Timestamp <- NULL
  
  
  
  user_ids <- as.factor(ratings$UserID)
  movie_ids <- as.factor(ratings$MovieID)
  r_sparse <- sparseMatrix(i = as.integer(user_ids),
                           j = as.integer(movie_ids),
                           x = ratings$Rating)
  rownames(r_sparse) <- paste0(as.character(levels(user_ids)))
  colnames(r_sparse) <- paste0(as.character(levels(movie_ids)))
  
  r_rrm <- as(r_sparse, "realRatingMatrix")
  
  svd_recommender <- Recommender(r_rrm, "SVD", param = list(k = 45))
  popular_recommender <- Recommender(r_rrm, "POPULAR")
  
  saveRDS(r_rrm, "server_data/r_rrm.RDS")
  saveRDS(svd_recommender, file = "server_data/svd_recommender.RDS")
  saveRDS(popular_recommender, file = "server_data/popular_recommender.RDS")
  
}

build_recommenders()

