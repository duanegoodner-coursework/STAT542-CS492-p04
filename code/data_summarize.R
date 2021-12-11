
raw_data$summaries <- new.env(parent = raw_data)


with(raw_data, {
  
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
    
    return(genre_mat)
  }
  
  # probably better way to do this. tired now so just mimicing HW example
  build_genre_cumsum_df <- function(genre_matrix) {
    genre_cumsum_df <- data.frame(Year = movies$Year, genre_matrix) %>%
      group_by(Year) %>%
      summarise_all(sum)
  
    genre_cumsum_df[, -1] <- apply(genre_cumsum_df[, -1], 2, cumsum)

    genre_cumsum_df[, -1] <- genre_cumsum_df[, -1] /
      sum(genre_cumsum_df[nrow(genre_cumsum_df), -1])
    
    return(genre_cumsum_df)
  }
})


with(raw_data$summaries, {
  # all ratings
  ratings_dist <- new.env(parent = raw_data$summaries)
  with(ratings_dist, {
    df <- data.frame(Rating = 1:5, 
                      freq = as.vector(table(ratings$Rating)/nrow(ratings)))
    
    plot <- ggplot(data = df, aes(x = Rating, y = freq)) +
      geom_bar(stat = "identity", fill = 'steelblue', width = 0.6) +
      geom_text(aes(label = round(freq, digits = 2)),
                vjust = 1.6, color = "white", size = 3.5) +
      theme_minimal()
  })
  
  # ratings per user
  users_with_num_ratings <- new.env(parent = raw_data$summaries)
  with(users_with_num_ratings, {
    df <- ratings %>%
      group_by(UserID) %>%
      summarize(ratings_per_user = n()) %>%
      full_join(users, by = "UserID")
    hist_num_ratings_per_user <- ggplot(data = df, aes(ratings_per_user)) +
      geom_bar(fill = "steelblue") + coord_cartesian(c(20, 500))
  })
  
  # num_ratings per movie
  movies_with_num_ratings <- new.env(parent = raw_data$summaries)
  with(movies_with_num_ratings, {
    df <- ratings %>%
      group_by(MovieID) %>%
      summarize(ratings_per_movie = n(), ave_ratings = mean(Rating)) %>%
      inner_join(movies, by = 'MovieID') %>%
      arrange(desc = ratings_per_movie)
    
    plot <- ggplot(df, aes(ratings_per_movie)) +
      geom_bar(fill = "steelblue", width = 1) + coord_cartesian(c(1,1500))
    
  })
  
  
  # top rated among moviews with 1000+ ratings
  top_rated_among_high_num_ratings <- new.env(parent = raw_data$summaries)
  with(top_rated_among_high_num_ratings, {
    image_url <- "https://liangfgithub.github.io/MovieImages/"
    dt <- ratings %>% group_by(MovieID) %>%
      summarize(ratings_per_movie = n(),
                ave_ratings = round(mean(Rating), digits = 3)) %>%
      inner_join(movies, by = 'MovieID') %>%
      filter(ratings_per_movie > 1000) %>%
      top_n(10, ave_ratings) %>%
      mutate(Image = paste0('<img src="', 
                            image_url, 
                            MovieID, 
                            '.jpg?raw=true"></img>')) %>%
      select('Image', 'Title', 'ave_ratings') %>%
      arrange(desc(-ave_ratings)) %>%
      datatable(class = "nowrap hover row-border",
                escape = FALSE,
                options = list(dom = 't',
                               scrollX = TRUE, autowidth = TRUE))
      
      
  })
  
  
  # genre info
  genre <- new.env(parent = raw_data$summaries)
  with(genre, {
    genre_matrix <- build_genre_matrix()
    genre_frequency_plot <- data.frame(Genres = colnames(genre_matrix),
                       Freq = colMeans(genre_matrix))  %>%
      ggplot(aes(reorder(Genres, Freq), Freq, fill = Freq)) +
      geom_bar(stat = "identity") + 
      geom_text(aes(label = round(Freq, dig=2)), 
                position = position_stack(vjust = 0.5), 
                color="white", size=3) + 
      coord_flip() + 
      scale_colour_brewer(palette="Set1") + 
      labs(y = 'Frequency', x = 'Genre')
    
    frac_of_reviews_df <- data.frame(MovieID = movies$MovieID, genre_matrix) %>%
      right_join(ratings, by = "MovieID") %>%
      select(-c("UserID", "MovieID", "Rating", "Timestamp")) %>%
      set_names(colnames(genre_matrix))
    
    frac_of_reviews_plot <-
      data.frame(Genres = names(frac_of_reviews_df),
                 Popularity = as.vector(colMeans(frac_of_reviews_df))) %>%
      ggplot(aes(reorder(Genres, Popularity), Popularity, fill = Popularity)) + 
      geom_bar(stat = "identity") + 
      geom_text(aes(label = round(Popularity, dig=3)), 
                position = position_stack(vjust = 0.5), 
                color="white", size=3) + 
      coord_flip() + 
      labs(y = 'Popularity', x = 'Genre')
    
    cumsum_df <- build_genre_cumsum_df(genre_matrix)
    
    cumsum_plot <- cumsum_df %>%
      reshape2::melt(id.vars = "Year") %>%
      ggplot(aes(Year, value, group = variable)) +
      geom_area(aes(fill = variable)) + 
      geom_line(aes(group = variable), position = "stack")
  })
})
