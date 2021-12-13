load_ratings <- function() {
  data_url <- "https://liangfgithub.github.io/MovieData/"
  
  # import ratings data
  # use colClasses = 'NULL' to skip columns
  ratings <- read.csv(paste0(data_url, 'ratings.dat?raw=true'), 
                      sep = ':',
                      colClasses = c('integer', 'NULL'), 
                      header = FALSE)
  colnames(ratings) <- c('UserID', 'MovieID', 'Rating', 'Timestamp')
  
  return(ratings)
}