ensure_packages <- function(package_names) {
  tmp <- setdiff(package_names, rownames(installed.packages()))
  if (length(tmp) > 0) install.packages(tmp)
  lapply(package_names, require, character.only = TRUE)
}


