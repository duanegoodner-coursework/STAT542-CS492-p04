data_url <- "https://liangfgithub.github.io/MovieData/"

# read in ratings data
# ratings = read.csv(paste0(data_url, 'ratings.dat?raw=true'),
#                    sep = ':',
#                    colClasses = c('integer', 'NULL'),
#                    header = FALSE)
# colnames(ratings) = c('UserID', 'MovieID', 'Rating', 'Timestamp')
# ratings$Timestamp = NULL


# read in movie data
movies <- readLines(paste0(data_url, 'movies.dat?raw=true'))
movies <- strsplit(movies, split = "::", fixed = TRUE, useBytes = TRUE)
movies <- matrix(unlist(movies), ncol = 3, byrow = TRUE)
movies <- data.frame(movies, stringsAsFactors = FALSE)
colnames(movies) <- c('MovieID', 'Title', 'Genres')
movies$MovieID <- as.integer(movies$MovieID)

# convert accented characters
movies$Title <- iconv(movies$Title, "latin1", "UTF-8")

small_image_url = "https://liangfgithub.github.io/MovieImages/"
movies$image_url = sapply(movies$MovieID, 
                          function(x) paste0(small_image_url, x, '.jpg?raw=true'))

r_rrm <- readRDS('recommenders/r_rrm.RDS')
svd_recommender <- readRDS('recommenders/svd_recommender.RDS')
ibcf_recommender <- readRDS('recommenders/ibcf_recommender.RDS')
popular_recommender <- readRDS('recommenders/popular_recommender.RDS')
model_data <- data.table(summary(as(r_rrm, "dgCMatrix")))
new_user_id <- max(model_data$i + 1)