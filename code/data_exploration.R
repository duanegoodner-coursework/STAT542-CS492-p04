source('code/utilities.R')




ensure_packages(c("dplyr", "ggplot2", "recommenderlab", "DT", "data.table",
                  "reshape2"))

myurl = "https://liangfgithub.github.io/MovieData/"

# import ratings data
# use colClasses = 'NULL' to skip columns
ratings = read.csv(paste0(myurl, 'ratings.dat?raw=true'), 
                   sep = ':',
                   colClasses = c('integer', 'NULL'), 
                   header = FALSE)
colnames(ratings) = c('UserID', 'MovieID', 'Rating', 'Timestamp')


# import movies data
movies = readLines(paste0(myurl, 'movies.dat?raw=true'))
movies = strsplit(movies, split = "::", fixed = TRUE, useBytes = TRUE)
movies = matrix(unlist(movies), ncol = 3, byrow = TRUE)
movies = data.frame(movies, stringsAsFactors = FALSE)
colnames(movies) = c('MovieID', 'Title', 'Genres')
movies$MovieID = as.integer(movies$MovieID)

# convert accented characters
movies$Title[73]
movies$Title = iconv(movies$Title, "latin1", "UTF-8")
movies$Title[73]

# extract year
movies$Year = as.numeric(unlist(
  lapply(movies$Title, function(x) substr(x, nchar(x)-4, nchar(x)-1))))


# import user data
users = read.csv(paste0(myurl, 'users.dat?raw=true'),
                 sep = ':', header = FALSE)
users = users[, -c(2,4,6,8)] # skip columns
colnames(users) = c('UserID', 'Gender', 'Age', 'Occupation', 'Zip-code')


tmp = data.frame(Rating = 1:5, 
                 freq = as.vector(table(ratings$Rating)/nrow(ratings)))
ggplot(data = tmp, aes(x = Rating, y = freq)) +
  geom_bar(stat="identity", fill = 'steelblue', width = 0.6) + 
  geom_text(aes(label=round(freq, dig=2)), 
            vjust=1.6, color="white", size=3.5) +
  theme_minimal()


tmp = ratings %>% 
  group_by(UserID) %>% 
  summarize(ratings_per_user = n()) 
summary(tmp$ratings_per_user)
stem(tmp$ratings_per_user)
sum(tmp$ratings_per_user > 500)
sort(tmp$ratings_per_user[tmp$ratings_per_user>1300])


tmp %>%
  ggplot(aes(ratings_per_user)) +
  geom_bar(fill = "steelblue") + coord_cartesian(c(20, 500))


tmp = tmp %>% full_join(users, by = 'UserID')

tmp = ratings %>% 
  group_by(MovieID) %>% 
  summarize(ratings_per_movie = n(), ave_ratings = mean(Rating)) %>%
  inner_join(movies, by = 'MovieID')
summary(tmp$ratings_per_movie)


tmp %>% 
  filter(ratings_per_movie > 2000) %>%
  arrange(desc = ratings_per_movie) %>%
  select(c("Title", "ratings_per_movie")) %>%
  print(n = 31)


tmp %>% ggplot(aes(ratings_per_movie)) + 
  geom_bar(fill = "steelblue", width = 1) + coord_cartesian(c(1,1500))


small_image_url = "https://liangfgithub.github.io/MovieImages/"
ratings %>% 
  group_by(MovieID) %>% 
  summarize(ratings_per_movie = n(), 
            ave_ratings = round(mean(Rating), dig=3)) %>%
  inner_join(movies, by = 'MovieID') %>%
  filter(ratings_per_movie > 1000) %>%
  top_n(10, ave_ratings) %>%
  mutate(Image = paste0('<img src="', 
                        small_image_url, 
                        MovieID, 
                        '.jpg?raw=true"></img>')) %>%
  select('Image', 'Title', 'ave_ratings') %>%
  arrange(desc(-ave_ratings)) %>%
  datatable(class = "nowrap hover row-border", 
            escape = FALSE, 
            options = list(dom = 't',
                           scrollX = TRUE, autoWidth = TRUE))


genres = as.data.frame(movies$Genres, stringsAsFactors=FALSE)
tmp = as.data.frame(tstrsplit(genres[,1], '[|]',
                              type.convert=TRUE),
                    stringsAsFactors=FALSE)

genre_list = c("Action", "Adventure", "Animation", 
               "Children's", "Comedy", "Crime",
               "Documentary", "Drama", "Fantasy",
               "Film-Noir", "Horror", "Musical", 
               "Mystery", "Romance", "Sci-Fi", 
               "Thriller", "War", "Western")
m = length(genre_list)
genre_matrix = matrix(0, nrow(movies), length(genre_list))
for(i in 1:nrow(tmp)){
  genre_matrix[i,genre_list %in% tmp[i,]]=1
}
colnames(genre_matrix) = genre_list
remove("tmp", "genres")

data.frame(Genres = genre_list, 
           Freq = as.vector(colMeans(genre_matrix))) %>% 
  ggplot(aes(reorder(Genres, Freq), Freq, fill = Freq)) + 
  geom_bar(stat = "identity") + 
  geom_text(aes(label = round(Freq, dig=2)), 
            position = position_stack(vjust = 0.5), 
            color="white", size=3) + 
  coord_flip() + 
  scale_colour_brewer(palette="Set1") + 
  labs(y = 'Frequency', x = 'Genre')


tmp = ratings %>% 
  left_join(data.frame(MovieID = movies$MovieID, genre_matrix), 
            by = "MovieID") %>%
  select(-c("UserID", "MovieID", "Rating", "Timestamp"))
data.frame(Genres = genre_list, 
           Popularity = as.vector(colMeans(tmp))) %>% 
  ggplot(aes(reorder(Genres, Popularity), Popularity, fill = Popularity)) + 
  geom_bar(stat = "identity") + 
  geom_text(aes(label = round(Popularity, dig=3)), 
            position = position_stack(vjust = 0.5), 
            color="white", size=3) + 
  coord_flip() + 
  labs(y = 'Popularity', x = 'Genre')

# range(movies$Year) % 1919 to 2000
tmp = data.frame(Year = movies$Year, genre_matrix) %>%
  group_by(Year) %>%
  summarise_all(sum)
tmp[,-1] = apply(tmp[, -1], 2, cumsum)
tmp[,-1] = tmp[,-1]/sum(tmp[nrow(tmp), -1])
print(round(tmp[nrow(tmp),-1], dig=3))


tmp = reshape2::melt(tmp, id.vars="Year") 
tmp %>%
  ggplot(aes(Year, value, group = variable)) +
  geom_area(aes(fill = variable)) + 
  geom_line(aes(group = variable), position = "stack")

