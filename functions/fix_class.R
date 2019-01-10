fix_class <- function(x){
  cases(
    "character"=x=="CHAR",
    "numeric"=x=="NUMC",
    "character"=x=="CUKY",
    "numeric"=x=="CURR",
    "numeric"=x=="DEC",
    "character"=x=="DATS",
    "numeric"=x=="FLTP")
  return(x)
}