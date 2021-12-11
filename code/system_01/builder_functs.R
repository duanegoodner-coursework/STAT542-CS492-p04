

build_genre_matrix <- function() {
  genres_str_list <- movies$Genres %>%
    lapply(strsplit, split = "[|]") %>%
    unlist(recursive = FALSE)
  
  genre_names <- unlist(genres_str_list) %>%
    unique()
  
  genre_mat <- lapply(genres_str_list, \(x) {
    x %>%
      factor(levels = genre_names) %>%
      class2ind() %>% colSums
  }) %>%
    bind_rows()
  
  system_01$genre_matrix <- data.frame(MovieID = movies$MovieID,
                                          genre_mat, check.names = FALSE)
}
environment(build_genre_matrix) <- system_01
