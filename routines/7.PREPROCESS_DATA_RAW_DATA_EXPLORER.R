# 7.0 Preprocess data for Raw Data Explorer ------------------------a----------

  # 7.1 Create string specifying where the App is located ---------------------
  dir <- "O:/FINANCE/FPAD/25 - Salary Liability Analysis/Raw Data Explorer/Raw_Data_Explorer/"
  
  # 7.2 Create a sorted list of unique PRIs -----------------------------------
  pris <- sort(unique(biweekly_summary$pri_numb))
  
  # 7.3 Delete existing files in the shiny app directory ----------------------
  file.remove(paste(dir,"pris.csv",sep=''))
  file.remove(paste(dir,"files/",pris,".csv",sep=''))
  
  # 7.4 Create act_explore and sft_explore: cleaned up versions of act/sft ----
  act_explore <- act %>%
    select(fiscyear,pri_numb,ac_doc_no,ac_doc_typ,pstng_date,doc_date,
           gl_account,class_cod,ed_frm_dt,ed_end_dt,empl_stat,costcenter,func_area,fund,
           ent_de_cd,frcst_grp,actual) %>%
    data.table()
  
  setkey(act_explore,pri_numb)
  
  sft_explore <- sft %>%
    mutate(pay.rate=ifelse(pay.rate==0,overwrite.pay.rate,pay.rate)) %>%
    mutate(percent.of.week=round(assigned.work.week/scheduled.work.week,2)) %>%
    select(fiscyear,pri_numb,first.name,last.name,action.description,
           forecast.group.description,classification,cost.center,fund,percent.of.week,
           effective.from.date,effective.to.date,pay.rate,gross.full.year.forecast) %>%
    data.table()
  
  setkey(sft_explore,pri_numb)
  
  # 7.4 Write new files to the directories ------------------------------------
  fwrite(data.frame(pri_numb=sort(unique(biweekly_summary$pri_numb))),paste(dir,"pris.csv",sep=''))
  
  for (i in 1:length(pris)){
    print(paste(i,Sys.time(),sep="  :  "))
    fwrite(act_explore[pri_numb==pris[i]],paste(dir,"files/",pris[i],".actual.csv",sep=''))
  }
  
  for (i in 1:length(pris)){
    print(paste(i,Sys.time(),sep="  :  "))
    fwrite(sft_explore[pri_numb==pris[i]],paste(dir,"files/",pris[i],".forecast.csv",sep=''))
  }
  
  for (i in 1:length(pris)){
    print(paste(i,Sys.time(),sep="  :  "))
    fwrite(biweekly_summary[pri_numb==pris[i]],paste(dir,"files/",pris[i],".biweekly.csv",sep=''))
  }