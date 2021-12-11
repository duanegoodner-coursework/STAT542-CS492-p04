source('code/utilities.R')
ensure_packages(c("dplyr", "ggplot2", "recommenderlab", "DT", "data.table",
                  "reshape2", "stringr", "purrr", "caret", "envnames"))

system_01 <- new.env()

source('code/system_01/import_data.R')
source('code/system_01/builder_functs.R')
source('code/system_01/query_functs.R')

import_data(system_01)
build_genre_matrix()

animation_pop_highly_rated <- top_rated_popular_of_genre("Animation")
animation_combined_with_other <- combined_with_other_genre("Animation")
