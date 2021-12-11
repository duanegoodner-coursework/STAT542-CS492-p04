data("Jester5k")
Jester5k

set.seed(1234)
r <- sample(Jester5k, 1000)

rowCounts(r[1,])
as(r[1,], "list")
rowMeans(r[1,])

hist(getRatings(r), breaks = 100)
hist(getRatings(normalize(r)), breaks = 100)
hist(getRatings(normalize(r, method="Z-score")), breaks=100)

hist(rowCounts(r), breaks=50)
hist(colMeans(r), breaks=20)

recommenderRegistry$get_entries(dataType = "realRatingMatrix")

r <- Recommender(Jester5k[1:1000], method = "POPULAR")
names(getModel(r))

recom <- predict(r, Jester5k[1001:1002], n = 5)
as(recom, "list")

recom3 <- bestN(recom, n = 3)
as(recom3, "list")


recom <- predict(r, Jester5k[1001:1002], type = "ratings")
as(recom, "matrix")[, 1:10]

recom <- predict(r, Jester5k[1001:1002], type = "ratingMatrix")
as(recom, "matrix")[, 1:10]

e <- evaluationScheme(Jester5k[1:1000], method = "split", train = 0.9,
                      given = 15, goodRating = 5)

r1 <- Recommender(getData(e, "train"), "UBCF")
r2 <- Recommender(getData(e, "train"), "IBCF")

p1 <- predict(r1, getData(e, "known"), type="ratings")
p2 <- predict(r2, getData(e, "known"), type="ratings")

error <- rbind(
  UBCF = calcPredictionAccuracy(p1, getData(e, "unknown")),
  IBCF = calcPredictionAccuracy(p2, getData(e, "unknown"))
)

scheme <- evaluationScheme(Jester5k[1:1000], method="cross", k=4, given=3,
                           goodRating=5)


results <- evaluate(scheme, method="POPULAR", type = "topNList",
                    n=c(1,3,5,10,15,20))


getConfusionMatrix(results)[[1]]

plot(results, annotate=TRUE)
plot(results, "prec/rec", annotate=TRUE)





set.seed(2016)

scheme <- evaluationScheme(Jester5k[1:1000], method="split", train = .9,
                           k=1, given=-5, goodRating=5)

algorithms <- list(
  "random items" = list(name="RANDOM", param=NULL),
  "popular items" = list(name="POPULAR", param=NULL),
  "user-based CF" = list(name="UBCF", param=list(nn=50)),
  "item-based CF" = list(name="IBCF", param=list(k=50)),
  "SVD approximation" = list(name="SVD", param=list(k = 49))
  )

results <- evaluate(scheme, algorithms, type = "topNList",
                    n=c(1, 3, 5, 10, 15, 20))
plot(results, annotate=c(1,3), legend="bottomright")
plot(results, "prec/rec", annotate=3, legend="topleft")


results <- evaluate(scheme, algorithms, type = "ratings")
plot(results, ylim = c(0,100))

