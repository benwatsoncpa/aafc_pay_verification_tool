adj_start_date <- function(date,fiscal.year,type){
  x <- pmax(date,as.Date(paste(fiscal.year-1,4,1,sep="-")))
  return(x)
}