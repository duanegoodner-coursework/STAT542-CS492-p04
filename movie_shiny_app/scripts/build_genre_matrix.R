source('scripts/load_movies.R')

build_genre_matrix_for_server <- function() {
  
  movies <- load_movies()
  
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
  
  genre_matrix <- data.frame(MovieID = movies$MovieID,
                             genre_mat, check.names = FALSE)
  
  saveRDS(genre_matrix, "recommenders/genre_matrix.RDS")
}

build_genre_matrix_for_server()