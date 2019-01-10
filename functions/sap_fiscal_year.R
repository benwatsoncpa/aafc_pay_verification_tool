sap_fiscal_year <- function(x){
    month <- as.numeric(format(x,"%m"))
    fy <- as.numeric(format(x,"%Y"))
    fy <- ifelse(month<4,fy,fy+1)
    return(fy)
  }