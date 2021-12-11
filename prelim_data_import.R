






raw_data <- new.env()


with(raw_data, {
  data_url <- "https://liangfgithub.github.io/MovieData/"
  
  # import ratings data
  # use colClasses = 'NULL' to skip columns
  ratings <- read.csv(paste0(data_url, 'ratings.dat?raw=true'), 
                      sep = ':',
                      colClasses = c('integer', 'NULL'), 
                      header = FALSE)
  colnames(ratings) <- c('UserID', 'MovieID', 'Rating', 'Timestamp')
  
  
  # import movies data
  movies <- readLines(paste0(data_url, 'movies.dat?raw=true'))
  movies <- strsplit(movies, split = "::", fixed = TRUE, useBytes = TRUE)
  movies <- matrix(unlist(movies), ncol = 3, byrow = TRUE)
  movies <- data.frame(movies, stringsAsFactors = FALSE)
  colnames(movies) <- c('MovieID', 'Title', 'Genres')
  movies$MovieID <- as.integer(movies$MovieID)
  
  # convert accented characters
  movies$Title[73]
  movies$Title <- iconv(movies$Title, "latin1", "UTF-8")
  movies$Title[73]
  
  # extract year
  movies$Year <- as.numeric(unlist(
    lapply(movies$Title, function(x) substr(x, nchar(x) - 4, nchar(x) - 1))))
  
  
  # import user data
  users <- read.csv(paste0(data_url, 'users.dat?raw=true'),
                    sep = ':', header = FALSE)
  users <- users[, -c(2,4,6,8)] # skip columns
  colnames(users) <- c('UserID', 'Gender', 'Age', 'Occupation', 'Zip-code')
})


