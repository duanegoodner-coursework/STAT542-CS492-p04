source('code/utilities.R')
ensure_packages(c("dplyr", "caret", "recommenderlab"))

system_01 <- new.env()

source('code/system_01/import_data.R')
source('code/system_01/builder_functs.R')
source('code/system_01/query_functs.R')

import_data(system_01)
build_genre_matrix()

with(system_01, {
  top_rated_popular <- colnames(genre_matrix[-1]) %>%
    lapply(top_rated_popular_of_genre) %>%
    setNames(colnames(genre_matrix[-1]))
  
  most_other_genres_top_rated_popular <- colnames(genre_matrix[-1]) %>%
    lapply(most_other_genres_high_rate_popular) %>%
    setNames(colnames(genre_matrix[-1]))
  
})
