# This script formats all actual pay records to bi-weekly pay amounts ---------

  # 3.1 Import biweekly pay periods starting in FY 2013 (April 1, 2012) -------
  biweekly_periods <- fread("./clean data/biweekly_periods.csv")
  
  # 3.2 Format biweekly_period dates and set keys -----------------------------
  biweekly_periods[,ed_frm_dt:=as.Date(ed_frm_dt)]  
  biweekly_periods[,ed_end_dt:=as.Date(ed_end_dt)]
  setkey(biweekly_periods,fiscyear,ed_frm_dt,ed_end_dt)
  
  # 3.3 Select all distinct pri_numb/fiscal year combinations -----------------
  act_biweekly <- act %>%
    filter(!is.na(ed_frm_dt) & actual !=0) %>%
    select(fiscyear,pri_numb) %>%
    distinct() %>%
    data.table()
  
  setkey(act_biweekly,fiscyear)
  
  # 3.4 Merge act_biweekly and biweekly_periods -------------------------------
  act_biweekly <- merge(act_biweekly,
                        biweekly_periods,
                        by=c("fiscyear"),
                        allow.cartesian=T)
  
  # 3.5 Create act_details: act_biweekly only it includes all fields ----------
  act_details <- act[!is.na(ed_frm_dt) & actual !=0]
  
  # 3.6 Add fiscal year to act_details based on ed_frm_dt ---------------------
  source("./functions/sap_fiscal_year.R")
  act_details[,fiscyear:=sap_fiscal_year(ed_frm_dt)]
  
  # 3.7 Merge act_biweekly with act_details -----------------------------------
  setkey(act_biweekly,pri_numb,fiscyear)
  setkey(act_details,pri_numb,fiscyear)
  
  act_biweekly <- merge(act_biweekly,act_details,allow.cartesian=T)
  
  # 3.8 Run prorate_overlap function to calculate amounts / pay period --------
  for (i in 1:10){gc(reset=T)}
  
  source("./functions/prorate_overlap.R")
  create.calendar("Canada",weekdays=c("saturday", "sunday"))
  
  act_biweekly[,actuals_adj:=prorate_overlap(ed_frm_dt.y,
                                             ed_end_dt.y,
                                             ed_frm_dt.x,
                                             ed_end_dt.x,
                                             actual)]
  
  
  
  # 3.9 Remove all periods where the actuals are nil --------------------------
  act_biweekly <- act_biweekly[actuals_adj!=0]
  
  # 3.10 Tidy up workspace ----------------------------------------------------
  for (i in 1:10){gc(reset=T)}
  keep_objects <- c(keep_objects,"act_biweekly")
  rm(list=setdiff(ls(),keep_objects))
  
  
  
  
  
  
  