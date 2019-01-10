zerovar <- function(dat) {
  out <- lapply(dat, function(x) length(unique(x)))
  want <- which(!out > 1)
  unlist(want)
}