# Create filtered summary tables of act_biweekly and sft_biweekly -------------

  # 4.8 Summarise act_biweekly by pri and biweekly pay periods ----------------
  act_biweekly_summary <- act_biweekly %>%
    rename(ed_frm_dt=ed_frm_dt.x,
           ed_end_dt=ed_end_dt.x) %>%
    group_by(pri_numb,ed_frm_dt,ed_end_dt,frcst_grp) %>%
    summarise(actuals=sum(actuals_adj)) %>%
    data.table()
  
  # 4.9 ummarise sft_biweekly by pri and biweekly pay periods -----------------
  sft_biweekly_summary <- sft_biweekly %>%
    mutate(actuals_adj=ifelse(exclude.from.forecast=="X",0,actuals_adj)) %>%
    rename(frcst_grp=forecast.group.code) %>%
    group_by(pri_numb,ed_frm_dt,ed_end_dt,frcst_grp) %>%
    summarise(forecast=sum(actuals_adj)) %>%
    data.table()
  
  # 4.10 Set data table keys --------------------------------------------------
  setkey(sft_biweekly_summary,pri_numb,ed_frm_dt,ed_end_dt,frcst_grp)
  setkey(act_biweekly_summary,pri_numb,ed_frm_dt,ed_end_dt,frcst_grp)
  
  # 4.11 Merge with act_biweekly_summary and sft_biweekly_summary -------------
  biweekly_frcst_grp <- merge(act_biweekly_summary,
                              sft_biweekly_summary,
                              all=T)
  
  # 4.11 Merge with forecast group names --------------------------------------
  dir <- "\\\\onottaafccifs.agr.gc.ca\\bw_data_dump\\"
  frcst_grp_names <- fread(paste(dir,"forecast.group.codes.csv",sep=''))
  setkey(frcst_grp_names,frcst_grp)
  biweekly_frcst_grp <- merge(biweekly_frcst_grp,frcst_grp_names,all.x=T,by="frcst_grp")
  
  # 4.12 Fix NAs in biweekly_summary ------------------------------------------
  biweekly_frcst_grp[is.na(forecast),forecast:=0]
  biweekly_frcst_grp[is.na(actuals),actuals:=0]
  
  # 4.13 Create new variable diff----------------------------------------------
  biweekly_frcst_grp[,diff:=actuals-forecast]
  biweekly_frcst_grp[,diff:=round(diff,2)]
  
  # 4.14 Modify frcst_grp_name field and remove columns -----------------------
  
  special_paste <- function(x,y,diff){
    diff <- ifelse(diff<0,paste("(",abs(diff),")",sep=""),diff)
    paste(x," ",y," = ",diff,sep="")
  }
  
  biweekly_frcst_grp[,frcst_grp_text := special_paste(frcst_grp,frcst_grp_desc,diff)]
  
  biweekly_frcst_grp <- biweekly_frcst_grp %>%
    select(-actuals,-forecast) %>%
    data.table()
  
  # 4.15 Filter to only include differences <> 0 ------------------------------
  biweekly_frcst_grp <- biweekly_frcst_grp[diff!=0]
  
  # 4.16 Collapse frcst_grp_text by data.table keys ---------------------------
  
  biweekly_frcst_grp_merge <- biweekly_frcst_grp %>%
    group_by(pri_numb,ed_frm_dt,ed_end_dt) %>%
    summarise(frcst_grp_text=paste(frcst_grp_text,collapse = "; ")) %>%
    data.table()
  
  setkey(biweekly_frcst_grp_merge,pri_numb,ed_frm_dt,ed_end_dt)
  
  # 4.17 Merge with biweekly_summary ------------------------------------------
  
  biweekly_summary <- merge(biweekly_summary,biweekly_frcst_grp_merge,all.x=T)
  biweekly_summary[is.na(frcst_grp_text),frcst_grp_text:=""]
  
  # 4.18 Tidy up --------------------------------------------------------------
  keep_objects <- c(keep_objects,c("biweekly_frcst_grp"))
  rm(list=setdiff(ls(),keep_objects))


