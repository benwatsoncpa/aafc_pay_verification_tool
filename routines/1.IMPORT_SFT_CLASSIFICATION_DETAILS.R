# Import and clean forecast with classification details -----------------------

  # 1.1 Import and combine data -----------------------------------------------
  dir <- "\\\\onottaafccifs.agr.gc.ca\\bw_data_dump\\"
  
  sft.2013 <- fread(paste(dir,"2013.csv",sep=''))
  sft.2014 <- fread(paste(dir,"2014.csv",sep=''))
  sft.2015 <- fread(paste(dir,"2015.csv",sep=''))
  sft.2016 <- fread(paste(dir,"2016.csv",sep=''))
  sft.2017 <- fread(paste(dir,"2017.csv",sep=''))
  sft.2018 <- fread(paste(dir,"2018.csv",sep=''))
  
  sft <- rbindlist(list(sft.2013,sft.2014,sft.2015,sft.2016,sft.2017,sft.2018),use.names = T,fill=T)
  
  # 1.2 Fix names -------------------------------------------------------------
  source("./functions/fix_names.R")
  names(sft) <- fix_names(names(sft))
  
  # 1.3 Remove zero variance & duplicate columns ------------------------------
  source("./functions/zerovar.R")
  sft <- sft[,-zerovar(sft),with=FALSE]
  names(sft) <- make.unique(names(sft))
  sft$personnel.number.1 <- NULL
  
  # 1.4 Remove hierarchy fields & rename fields -------------------------------
  sft <- sft %>%
    rename(fiscyear=fiscal.year,
           pri_numb=personnel.number) %>%
    data.table()
  
  # 1.5 Fix date class types --------------------------------------------------
  date_fields <- c("start.date",
                   "end.date",
                   "incremental.date",
                   "effective.from.date",
                   "effective.to.date")
  
  sft[,(date_fields):=lapply(.SD,function(x)as.Date(x,"%m/%d/%Y")),.SDcols=date_fields]
  
  # 1.6 Tidy up ---------------------------------------------------------------
  keep_objects <- c("keep_objects","sft")
  rm(list=setdiff(ls(),keep_objects))
  
  
  