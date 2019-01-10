# This script formats all forecast pay records to bi-weekly pay amounts -------

  # 3.11 Import biweekly pay periods starting in FY 2013 (April 1, 2012) ------
  biweekly_periods <- fread("./clean data/biweekly_periods.csv")
  
  # 3.12 Format biweekly_period dates and set keys ----------------------------
  biweekly_periods[,ed_frm_dt:=as.Date(ed_frm_dt)]  
  biweekly_periods[,ed_end_dt:=as.Date(ed_end_dt)]
  setkey(biweekly_periods,fiscyear,ed_frm_dt,ed_end_dt)
  
  # 3.13 Select all distinct pri_numb/fiscal year combinations ----------------
  sft_biweekly <- sft %>%
    select(fiscyear,pri_numb) %>%
    distinct() %>%
    data.table()
  
  # 3.14 Merge sft_biweekly with biweekly_periods -----------------------------
  setkey(biweekly_periods,fiscyear)
  setkey(sft_biweekly,fiscyear)
  
  sft_biweekly <- merge(sft_biweekly,biweekly_periods,all=T,allow.cartesian=T)
  
  # 3.15 Merge sft_biweekly with sft
  setkey(sft_biweekly,fiscyear,pri_numb)
  setkey(sft,fiscyear,pri_numb)
  
  sft_biweekly <- merge(sft_biweekly,sft,allow.cartesian=T)
  
  # 3.16 Adjust effective from date and effective to date to within FY --------
  source("./functions/adj_start_date.R")
  sft_biweekly[,effective.from.date:=adj_start_date(effective.from.date,fiscyear)]
  
  source("./functions/adj_end_date.R")
  sft_biweekly[,effective.to.date:=adj_end_date(effective.to.date,fiscyear)]
  
  # 3.17 Calculate actuals_adj and filter to <> 0 -----------------------------
  source("./functions/prorate_overlap.R")
  sft_biweekly[,actuals_adj:=prorate_overlap(effective.from.date,
                                             effective.to.date,
                                             ed_frm_dt,
                                             ed_end_dt,
                                             gross.full.year.forecast)]
  
  sft_biweekly <- sft_biweekly[actuals_adj!=0]
  
  # 3.18 Tidy Up --------------------------------------------------------------
  keep_objects <- c(keep_objects,"sft_biweekly")
  rm(list=setdiff(ls(),keep_objects))