# Import and clean the actuals ------------------------------------------------

  # 1.7 Read from FTP Directory -----------------------------------------------
  dir <- "\\\\onottaafccifs.agr.gc.ca\\bw_data_dump\\"
  meta <- fread(paste(dir,"S_SFT_EXTRACT_ACTUAL.csv",sep=''),skip=5)
  
  source("./functions/fix_names.R")
  source("./functions/fix_class.R")
  
  act <- fread(paste(dir,"SFT_EXTRACT_ACTUAL.csv",sep=''),
               col.names=fix_names(meta$FIELDNAME),
               colClasses = fix_class(meta$TYPE))
  
  sum(grepl("-",act$actual))
  nrow(act)
  
  # 1.8 Fix negative dollar amounts -------------------------------------------
  
  fix_negative_string <- function(x) {
    x <- ifelse(grepl("-",x),paste("-",gsub("-","",x),sep=""),x)
    return(x)
    }
  
  act[,actual:=fix_negative_string(actual)]
  act[,act_adj:=fix_negative_string(act_adj)]
  act[,act_extr:=fix_negative_string(act_extr)]
  act[,act_net:=fix_negative_string(act_net)]
  act[,net_recov:=fix_negative_string(net_recov)]
  act[,net_amnt:=fix_negative_string(net_amnt)]
  
  # 1.9 Remove Zero Variance and other useless Columns ------------------------
  source("./functions/zerovar.R")
  act <- act[,-zerovar(act),with=FALSE]
  
  # 1.10 Fix data class types -------------------------------------------------
  
    # 1.10.1 Fix numeric class types ------------------------------------------
    
    num_fields <- c("b003s_ccgl_acc",
                    "ac_doc_no",
                    "fiscyear",
                    "gl_account",
                    "class_lv",
                    "doc_fy_ad",
                    "doc_fy_or",
                    "doc_no_ad",
                    "doc_no_or",
                    "empl_stat",
                    "frcst_lv",
                    "frcst_typ",
                    "net_amnt",
                    "fiscper",
                    "fiscper3",
                    "pri_numb",
                    "actual",
                    "act_adj",
                    "act_extr",
                    "act_net",
                    "net_recov")
    
    act[, (num_fields) := lapply(.SD, as.numeric), .SDcols = num_fields]
    
    # 1.10.2 Fix date class types ---------------------------------------------
    
    date_fields <- c("ed_end_dt",
                     "ed_frm_dt",
                     "pstng_date",
                     "doc_date")
    
    act[, (date_fields) := lapply(.SD, function(x) as.Date(x,"%Y%m%d")), .SDcols = date_fields]
    
    # 1.10.3 Special Cases ----------------------------------------------------
    
    special_fields <- c("b003s_sftcosct","coorder","costcenter")
    
    act[,b003s_sftcosct:=ifelse(nchar(b003s_sftcosct)<7,b003s_sftcosct,substr(b003s_sftcosct,5,10))]
    act[,coorder:=as.numeric(ifelse(nchar(coorder)<12,coorder,substr(coorder,7,12)))]
    act[,costcenter:=ifelse(nchar(costcenter)<7,costcenter,substr(costcenter,5,10))]
  
  # 1.11 Select the fields that we want to retain -----------------------------
  
  act <- act %>%
      select(fiscyear,
             pri_numb,
             ac_doc_no,
             ac_doc_typ,
             pstng_date,
             doc_date,
             costcenter,
             func_area,
             fund,
             gl_account,
             class_cod,
             ed_end_dt,
             ed_frm_dt,
             empl_stat,
             empl_type,
             ent_de_cd,
             frcst_grp,
             frcst_lv,
             frcst_typ,
             actual,
             act_adj,
             act_extr,
             act_net,
             net_amnt,
             net_recov) %>%
      data.table()
    
  # 1.12 Replace NA with 0 for numeric fields ---------------------------------
  
  act[is.na(actual),actual:=0]
  act[is.na(act_net),act_net:=0]
  act[is.na(act_adj),act_adj:=0]
  act[is.na(act_extr),act_extr:=0]
  act[is.na(net_amnt),net_amnt:=0]
  act[is.na(net_recov),net_recov:=0]
  
  # 1.13 Tidy Up --------------------------------------------------------------
  keep_objects <- c(keep_objects,"act")
  rm(list=setdiff(ls(),keep_objects))