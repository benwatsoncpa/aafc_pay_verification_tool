# Function to calculate how much of an amount should be applied to a date range
prorate_overlap <- function(start1,end1,start2,end2,amount){
  startmax <- pmax(start1,start2)
  endmin <- pmin(end1,end2)
  days <- ifelse(startmax>endmin,0,bizdays(startmax,endmin,"Canada")+1)
  amount_adj <- amount*days/(bizdays(start1,end1,"Canada")+1)
  amount_adj <- round(amount_adj,2)
  return(amount_adj)
}


  
