# 6.0 Preprocess data for Pay Verification Tool Shiny App ---------------------
  
  # 6.1 Create string specifying where the App is located ---------------------
  dir <- "O:/FINANCE/FPAD/25 - Salary Liability Analysis/Payroll Verification Tool Shiny/Payroll_Verification_Tool/"
  
  # 6.2 Create a sorted list of unique PRIs -----------------------------------
  pris <- sort(unique(biweekly_summary$pri_numb))
  
  # 6.3 Delete existing files in the shiny app directory ----------------------
  file.remove(paste(dir,"pris.csv",sep=''))
  file.remove(paste(dir,"from.dates.csv",sep=''))
  file.remove(paste(dir,"end.dates.csv",sep=''))
  file.remove(paste(dir,"files/",pris,".csv",sep=''))
  
  # 6.4 Write new files to the directories ------------------------------------
  fwrite(data.frame(pri_numb=sort(unique(biweekly_summary$pri_numb))),paste(dir,"pris.csv",sep=''))
  fwrite(data.frame(ed_frm_dt=sort(unique(biweekly_summary$ed_frm_dt))),paste(dir,"from.dates.csv",sep=''))
  fwrite(data.frame(ed_end_dt=sort(unique(biweekly_summary$ed_end_dt))),paste(dir,"end.dates.csv",sep=''))
  
  for (i in 1:length(pris)){
    print(paste(i,Sys.time(),sep="  :  "))
    fwrite(biweekly_summary[pri_numb==pris[i]],paste(dir,"files/",pris[i],".csv",sep=''))
  }
  
  


