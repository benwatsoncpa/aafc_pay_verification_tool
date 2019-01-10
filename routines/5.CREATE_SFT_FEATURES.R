# Create Action Feature -------------------------------------------------------

  # 5.1 Create action feature -------------------------------------------------
  actn <- sft_biweekly %>%
    mutate(action=action.description) %>%
    select(pri_numb,ed_frm_dt,ed_end_dt,action) %>%
    distinct() %>%
    group_by(pri_numb,ed_frm_dt,ed_end_dt) %>%
    mutate(cnt=n()) %>%
    mutate(action=ifelse(cnt>1,"Transition",action)) %>%
    select(-cnt) %>%
    data.table()
    
  # 5.2 Merge action feature into with biweekly_summary -----------------------
  setkey(actn,pri_numb,ed_frm_dt,ed_end_dt)
  setkey(biweekly_summary,pri_numb,ed_frm_dt,ed_end_dt)
  biweekly_summary <- merge(biweekly_summary,actn,all.x=T)
    
  # 5.3 Create classification feature -----------------------------------------
  classification <- sft_biweekly %>%    
    select(pri_numb,ed_frm_dt,ed_end_dt,classification) %>%
    distinct() %>%
    group_by(pri_numb,ed_frm_dt,ed_end_dt) %>%
    mutate(cnt=n()) %>%
    mutate(classification=ifelse(cnt>1,"Transition",classification)) %>%
    select(-cnt) %>%
    data.table()
  
  # 5.4 Merge classification into with biweekly_summary -----------------------
  setkey(classification,pri_numb,ed_frm_dt,ed_end_dt)
  setkey(biweekly_summary,pri_numb,ed_frm_dt,ed_end_dt)
  biweekly_summary <- merge(biweekly_summary,classification,all.x=T)
  
  # 5.5 Create Employment Type feature ----------------------------------------
  emp.type <- sft_biweekly %>%
    rename(emp.type=employment.type.abbreviation) %>%
    select(pri_numb,ed_frm_dt,ed_end_dt,emp.type) %>%
    distinct() %>%
    group_by(pri_numb,ed_frm_dt,ed_end_dt) %>%
    mutate(cnt=n()) %>%
    mutate(emp.type=ifelse(cnt>1,"Transition",emp.type)) %>%
    select(-cnt) %>%
    data.table()
  
  # 5.6 Merge employment type into with biweekly_summary ----------------------
  setkey(emp.type,pri_numb,ed_frm_dt,ed_end_dt)
  setkey(biweekly_summary,pri_numb,ed_frm_dt,ed_end_dt)
  biweekly_summary <- merge(biweekly_summary,emp.type,all.x=T)
  
  
  # 5.7 Create Branch feature -------------------------------------------------
  
    # Clean up hierarchy level 1 in sft_biweekly ------------------------------
    sft_biweekly[,branch:=substr(hierarchy.level.1,17,nchar(hierarchy.level.1)-2)]
    sft_biweekly[grepl("COST CENTER",branch),branch:="AAFC"]
    sft_biweekly[grepl("repeated",branch),branch:="AAFC"]
    sft_biweekly[grepl("up assign",branch),branch:="AAFC"]
    
  branch <- sft_biweekly %>%
    select(pri_numb,ed_frm_dt,ed_end_dt,branch) %>%
    distinct() %>%
    group_by(pri_numb,ed_frm_dt,ed_end_dt) %>%
    mutate(cnt=n()) %>%
    mutate(branch=ifelse(cnt>1,"Transition",branch)) %>%
    select(-cnt) %>%
    data.table()
  
  # 5.8 Merge employment type into with biweekly_summary ----------------------
  setkey(branch,pri_numb,ed_frm_dt,ed_end_dt)
  setkey(biweekly_summary,pri_numb,ed_frm_dt,ed_end_dt)
  biweekly_summary <- merge(biweekly_summary,branch,all.x=T)
  
  # 5.9 Filter to only distinct records ---------------------------------------
  biweekly_summary <- distinct(biweekly_summary) %>%
    data.table()
  
  # 5.10 Create grouping feature -----------------------------------------------
  
  # Create table that ranks the continuous periods of employment ---------------
  period.ranks <- biweekly_summary %>%
    select(pri_numb,ed_frm_dt,ed_end_dt) %>%
    group_by(pri_numb) %>%
    arrange(ed_frm_dt) %>%
    mutate(group=1) %>%
    mutate(group=ed_frm_dt==lag(ed_end_dt)+1) %>%
    data.table()
  
  period.ranks[is.na(group),group:=FALSE]
  
  period.ranks <- period.ranks %>%
    filter(group==F) %>%
    group_by(pri_numb) %>%
    mutate(group=min_rank(ed_frm_dt)) %>%
    data.table()
  
  # Set keys and merge with biweekly_summary using a rolling join --------------
  setkey(period.ranks,pri_numb,ed_frm_dt,ed_end_dt)
  setkey(biweekly_summary,pri_numb,ed_frm_dt,ed_end_dt)
  
  biweekly_summary <- period.ranks[biweekly_summary,roll=-Inf]
  biweekly_summary$group <- na.locf(biweekly_summary$group)
  
  # 5.11 Tidy Up ---------------------------------------------------------------
  rm(list=setdiff(ls(),keep_objects))
    
    