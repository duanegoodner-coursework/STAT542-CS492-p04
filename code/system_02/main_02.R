source('code/utilities.R')
ensure_packages(c("recommenderlab", "Matrix"))

source('code/system_02/load_ratings.R')

system_02 <- new.env()
load_ratings(system_02)

source('code/system_02/analysis_functs.R')

set.seed(8219)

with(system_02, {
  r_rrm <- build_rrm(ratings)
  algos <- list(
    "SVD" = list(name="SVD", param=list(k = 50)),
    "UBCF" = list(name="UBCF", param=list(nn = 50))
  )
  
  eval_schemes <- vector(mode = "list", length = 10)
  
  for (scheme_num in 1:length(eval_schemes)) {
    eval_schemes[[scheme_num]] <- evaluationScheme(r_rrm, method = "split",
                                                   train = 0.9, given = 10)
  }
  
  eval_results <- lapply(eval_schemes, test_algos, algo_list = algos)
  
})

with(system_02, {
  rmse_box_plot(eval_results)
})
