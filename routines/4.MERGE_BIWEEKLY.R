# Create summary tables of act_biweekly and sft_biweekly ----------------------

  # 4.1 Summarise act_biweekly by pri and dates -------------------------------
  act_biweekly_summary <- act_biweekly %>%
    rename(ed_frm_dt=ed_frm_dt.x,
           ed_end_dt=ed_end_dt.x) %>%
    group_by(pri_numb,ed_frm_dt,ed_end_dt) %>%
    summarise(actuals=sum(actuals_adj)) %>%
    data.table()
  
  # 4.2 Summarise sft_biweekly by pri and dates -------------------------------
  sft_biweekly_summary <- sft_biweekly %>%
    mutate(actuals_adj=ifelse(exclude.from.forecast=="X",0,actuals_adj)) %>%
    group_by(pri_numb,ed_frm_dt,ed_end_dt) %>%
    summarise(forecast=sum(actuals_adj)) %>%
    data.table()
  
  # 4.3 Merge with act_biweekly_summary and sft_biweekly_summary --------------
  biweekly_summary <- merge(act_biweekly_summary,
                             sft_biweekly_summary,
                             all=T,
                             by=c("pri_numb",
                                  "ed_frm_dt",
                                  "ed_end_dt"))
  
  # 4.4 Fix NAs in biweekly_summary -------------------------------------------
  biweekly_summary[is.na(forecast),forecast:=0]
  biweekly_summary[is.na(actuals),actuals:=0]
  
  # 4.5 Create new variables diff and cumulative diff -------------------------
  biweekly_summary[,diff:=round(actuals-forecast,2)]
  biweekly_summary[!is.na(diff),cumulative:=cumsum(diff),by=pri_numb]
  
  # 4.6 Select only distinct records ------------------------------------------
  biweekly_summary <- biweekly_summary %>%
    distinct() %>%
    data.table()
  
  # 4.7 Tidy up ---------------------------------------------------------------
  keep_objects <- c(keep_objects,c("biweekly_summary"))
  rm(list=setdiff(ls(),keep_objects))
