
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
ibcf_recommender <- Recommender(r_rrm, "IBCF")
popular_recommender <- Recommender(r_rrm, "POPULAR")

saveRDS(svd_recommender, file = "recommenders/svd_recommender.RDS")
saveRDS(ibcf_recommender, file = "recommenders/ibcf_recommender.RDS")
saveRDS(popular_recommender, file = "recommenders/popular_recommender.RDS")
saveRDS(r_rrm, "recommenders/r_rrm.RDS")

