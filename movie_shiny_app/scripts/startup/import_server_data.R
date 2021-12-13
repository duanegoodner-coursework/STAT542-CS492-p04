source('scripts/load_movies.R')
source('scripts/load_ratings.R')

import_server_data <- function() {
  
  movies <<- load_movies()
  small_image_url <<-  "https://liangfgithub.github.io/MovieImages/"
  movies$image_url <<-  sapply(movies$MovieID, 
                            function(x) paste0(small_image_url, x, '.jpg?raw=true'))
  
  ratings <<- load_ratings()
  
  genre_matrix <<- readRDS('server_data/genre_matrix.RDS')
  
  r_rrm <<- readRDS('server_data/r_rrm.RDS')
  svd_recommender <<- readRDS('server_data/svd_recommender.RDS')
  popular_recommender <<- readRDS('server_data/popular_recommender.RDS')
  
  model_data <<- data.table(summary(as(r_rrm, "dgCMatrix")))
  new_user_id <<- max(model_data$i + 1)
}

import_server_data()




