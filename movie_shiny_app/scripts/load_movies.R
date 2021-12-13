load_movies <- function() {
  data_url <- "https://liangfgithub.github.io/MovieData/"
  
  # read in movie data
  movies <- readLines(paste0(data_url, 'movies.dat?raw=true'))
  movies <- strsplit(movies, split = "::", fixed = TRUE, useBytes = TRUE)
  movies <- matrix(unlist(movies), ncol = 3, byrow = TRUE)
  movies <- data.frame(movies, stringsAsFactors = FALSE)
  colnames(movies) <- c('MovieID', 'Title', 'Genres')
  movies$MovieID <- as.integer(movies$MovieID)
  
  # convert accented characters
  movies$Title <- iconv(movies$Title, "latin1", "UTF-8")
  
  return(movies)
}