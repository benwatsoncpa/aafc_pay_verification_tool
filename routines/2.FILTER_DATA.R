# Filter the act and sft data to match the Bad Unforcasted Report -------------

  # 2.1 Filter all document dates that are 2018-06-26 (issue with sandbox) ----
    
    act <- act[doc_date!=as.Date("2018-06-26")]
    
  # 2.2 Filters applied to both sft and act -----------------------------------
    frcst_grp_filter <- c(1:9,11,13:16)
    frcst_grp_filter <- paste(ifelse(nchar(frcst_grp_filter)==1,"B0","B"),frcst_grp_filter,sep='')
    frcst_grp_filter <- c(frcst_grp_filter,"A01","A03","A06","A10","A12","A13","A15","A16","A20","A25")
    
  # 2.3 SFT Filter ------------------------------------------------------------
    sft_fund_filter <- c(100:299,309,939,960,968)
    sft_fund_filter <- sft_fund_filter[!sft_fund_filter %in% c(103)]
    
    sft <- sft[fund %in% sft_fund_filter]
    sft <- sft[forecast.group.code %in% frcst_grp_filter]
    
  # 2.4 Actuals Filter --------------------------------------------------------
    
    # 2.4.1 Actuals Fund Filter -----------------------------------------------
    act_fund_filter <- c(100:299,309,939,960,968)
    act_fund_filter <- act_fund_filter[!act_fund_filter %in% c(103,109)]
    act_fund_filter <- paste("0",act_fund_filter,sep='')
    
    # 2.4.2 Filter Actuals ----------------------------------------------------
    act <- act[fund %in% act_fund_filter]
    act <- act[frcst_grp %in% frcst_grp_filter]
    
  # 2.5 Tidy Up ---------------------------------------------------------------
    rm(list=setdiff(ls(),keep_objects))
    