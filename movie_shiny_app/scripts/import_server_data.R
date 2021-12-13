source('scripts/load_movies.R')

import_server_data <- function() {
  movies <<- load_movies()
  
  small_image_url <<-  "https://liangfgithub.github.io/MovieImages/"
  movies$image_url <<-  sapply(movies$MovieID, 
                            function(x) paste0(small_image_url, x, '.jpg?raw=true'))
  
  genre_matrix <<- readRDS('recommenders/genre_matrix.RDS')
  
  r_rrm <<- readRDS('recommenders/r_rrm.RDS')
  svd_recommender <<- readRDS('recommenders/svd_recommender.RDS')
  popular_recommender <<- readRDS('recommenders/popular_recommender.RDS')
  
  
  model_data <<- data.table(summary(as(r_rrm, "dgCMatrix")))
  new_user_id <<- max(model_data$i + 1)
}

import_server_data()




