source('code/utilities.R')
ensure_packages(c("recommenderlab", "Matrix"))

# source('code/system_02/load_ratings.R')
# 
# system_02 <- new.env()
# load_ratings(system_02)


myurl <- "https://liangfgithub.github.io/MovieData/"
ratings <- read.csv(paste0(myurl, 'ratings.dat?raw=true'), 
                   sep = ':',
                   colClasses = c('integer', 'NULL'), 
                   header = FALSE)
colnames(ratings) <- c('UserID', 'MovieID', 'Rating', 'Timestamp')
ratings$Timestamp <- NULL


set.seed(100)

user_ids <- as.factor(ratings$UserID)
movie_ids <- as.factor(ratings$MovieID)
r_sparse <- sparseMatrix(i = as.integer(user_ids),
                         j = as.integer(movie_ids),
                         x = ratings$Rating)
rownames(r_sparse) <- paste0('u', as.character(levels(user_ids)))
colnames(r_sparse) <- paste0('m', as.character(levels(movie_ids)))

r_rrm <- as(r_sparse, "realRatingMatrix")

r_rrm_norm <- normalize(r_rrm)

eval_scheme <- evaluationScheme(r_rrm, method = "split", train = 0.9, given = 5)
eval_scheme_norm <- evaluationScheme(r_rrm_norm, method = "split", train = 0.9, given = 5)
# recommender_ubcf <- Recommender(getData(eval_scheme, "train"), "UBCF")
# recommender_ibcf <- Recommender(getData(eval_scheme, "train"), "IBCF")
recommender_svd <- Recommender(getData(eval_scheme, "train"), "SVD", param = list(k = 45))

# ubcf_pred <- predict(recommender_ubcf, getData(eval_scheme, "known"),
#                      type = "ratings")
# ibcf_pred <- predict(recommender_ibcf, getData(eval_scheme, "known"),
#                      type = "ratings")

svd_pred <- predict(recommender_svd, getData(eval_scheme, "known"),
                    type = "ratings")

svd_pred_norm <- predict(recommender_svd_normn, getData(eval_scheme, "known"),
                         type = "ratings")


error <- rbind(
  # UBCF = calcPredictionAccuracy(ubcf_pred, getData(eval_scheme, "unknown")),
  # IBCF = calcPredictionAccuracy(ibcf_pred, getData(eval_scheme, "unknown")),
  SVD = calcPredictionAccuracy(svd_pred, getData(eval_scheme, "unknown")),
  SVD_NORM = calcPredictionAccuracy(svd_pred_norm, getData(eval_scheme, "unknown"))
)


# algos <- list(
#   "random items" = list(name="RANDOM", param=NULL),
#   "popular items" = list(name="POPULAR", param=NULL),
#   "user-based CF" = list(name="UBCF", param=list(nn=50)),
#   "item-based CF" = list(name="IBCF", param=list(k=50)),
#   "SVD approximation" = list(name="SVD", param=list(k = 45))
# )
# 
# results <- evaluate(eval_scheme, algos, type = "ratings")
# 
# lapply(results, getConfusionMatrix)

