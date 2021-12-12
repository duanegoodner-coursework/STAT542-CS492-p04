top_rated_popular_of_genre <- function(genre, num_movies = 5) {
  df <- genre_matrix[
    which(genre_matrix[[genre]] == 1), ] %>%
    inner_join(ratings, by = 'MovieID') %>%
    group_by(MovieID) %>%
    summarize(ratings_per_movie = n(), ave_rating = mean(Rating)) %>%
    inner_join(movies, by = 'MovieID')
  
  num_ratings_cutoff <- summary(df$ratings_per_movie)["3rd Qu."]
  
  df <- df[which(df$ratings_per_movie > num_ratings_cutoff), ] %>%
    arrange(desc(ave_rating)) %>%
    head(num_movies)
  
  return(df[, c('Title', 'Genres', 'Year', 'ratings_per_movie', 'ave_rating', 'MovieID')])
}
environment(top_rated_popular_of_genre) <- system_01


most_other_genres_high_rate_popular <- function(genre, num_movies = 5) {
  genre_names <- names(genre_matrix)[which(names(genre_matrix) != "MovieID")]
  
  df <- genre_matrix[
    which(genre_matrix[[genre]] == 1), ] %>%
    inner_join(ratings, by = 'MovieID') %>%
    group_by(MovieID) %>%
    summarize(ratings_per_movie = n(), ave_rating = mean(Rating)) %>%
    inner_join(movies, by = 'MovieID')
  
  num_ratings_cutoff <- median(df$ratings_per_movie)
  ave_rating_cutoff <- median(df$ave_rating)
  
  df <- df[which(df$ratings_per_movie > num_ratings_cutoff &
                   df$ave_rating > ave_rating_cutoff), ] %>%
    left_join(genre_matrix, by = 'MovieID')
  
  df <- arrange(df, desc(rowSums(df[, genre_names]))) %>%
    head(num_movies)
    
  
  return(df[, c('Title', 'Genres', 'Year', 'ratings_per_movie', 'ave_rating', 'MovieID')])
}
environment(most_other_genres_high_rate_popular) <- system_01



