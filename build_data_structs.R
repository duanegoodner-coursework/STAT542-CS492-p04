
build_data_structs <- function(data_struct_env) {
  with(data_struct_env, {
    genre_matrix <- builders$genre_matrix()
    genre_cumsum_df <- builders$genre_cumsum_df(genre_matrix)
    ratings_num_and_mean <- builders$ratings_num_and_mean()
  })
}