library(shiny)
library(shinydashboard)
library(data.table)
library(ShinyRatingInput)
library(shinyjs)

library(recommenderlab)
library(Matrix)

source('scripts/import_data.R')

r_rrm <- readRDS('recommenders/r_rrm.RDS')
svd_recommender <- readRDS('recommenders/svd_recommender.RDS')
popular_recommender <- readRDS('recommenders/popular_recommender.RDS')
new_user_ratings <- readRDS('test_data/user_ratings_dat.RDS')

model_data <- data.table(summary(as(r_rrm, "dgCMatrix")))

# use i, j, x to be consistent with sparse matrix
new_user_id <- max(model_data$i + 1)
new_user_data <- data.table(
  i = rep(max(model_data$i) + 1, nrow(new_user_ratings)),
  j = new_user_ratings$MovieID,
  x = new_user_ratings$Rating)

full_data <- rbind(model_data, new_user_data)
full_data_sparse <- sparseMatrix(i = as.integer(as.factor(full_data$i)),
                                 j = as.integer(as.factor(full_data$j)),
                                 x = full_data$x)
full_data_rrm <- as(full_data_sparse, "realRatingMatrix")

svd_topN <- predict(svd_recommender, full_data_rrm[new_user_id], type = "topNList", n = 10)

popular_topN <- predict(popular_recommender, full_data_rrm[new_user_id], type = "topNList", n = 10)

