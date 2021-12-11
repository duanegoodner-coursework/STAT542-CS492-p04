
load_ratings <- function(data_env) {
  with(data_env, {
    data_url = "https://liangfgithub.github.io/MovieData/"
    ratings = read.csv(paste0(data_url, 'ratings.dat?raw=true'), 
                       sep = ':',
                       colClasses = c('integer', 'NULL'), 
                       header = FALSE)
    colnames(ratings) = c('UserID', 'MovieID', 'Rating', 'Timestamp')
    ratings$Timestamp = NULL
  })
}

