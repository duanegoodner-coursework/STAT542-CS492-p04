top_rated_popular_of_genre <- function(genre) {
  df <- genre_matrix[
    which(genre_matrix[[genre]] == 1), ] %>%
    inner_join(ratings, by = 'MovieID') %>%
    group_by(MovieID) %>%
    summarize(ratings_per_movie = n(), ave_rating = mean(Rating)) %>%
    inner_join(movies, by = 'MovieID')
  
  num_ratings_cutoff <- summary(df$ratings_per_movie)["3rd Qu."]
  
  df <- df[which(df$ratings_per_movie > num_ratings_cutoff), ] %>%
    arrange(desc(ave_rating)) %>%
    head(n = 10)
  
  return(df)
}
environment(top_rated_popular_of_genre) <- system_01


combined_with_other_genre <- function(genre) {
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
    head(n = 10)
    
  
  return(df)
}
environment(combined_with_other_genre) <- system_01



