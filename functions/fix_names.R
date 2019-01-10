fix_names <- function(x){
  x <- gsub("\\/","",x)
  x <- gsub("BIC","",x)
  x <- gsub(" ",".",x)
  x <- tolower(x)
  return(x)
}