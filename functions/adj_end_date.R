adj_end_date <- function(date,fiscal.year,type){
  x <- pmin(date,as.Date(paste(fiscal.year,3,31,sep="-")))
  return(x)
}