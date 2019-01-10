# Import and Clean SFT_EXTRACT ------------------------------------------------

dir <- "\\\\onottaafccifs.agr.gc.ca\\bw_data_dump\\"

meta <- fread(paste(dir,"S_SFT_EXTRACT_FORECAST.csv",sep=''),skip=5)

source("./functions/fix_names.R")
source("./functions/fix_class.R")

sft <- fread(paste(dir,"SFT_EXTRACT_FORECAST.csv",sep=''),
            col.names=fix_names(meta$FIELDNAME),
            colClasses = fix_class(meta$TYPE))

rm(dir)


# Remove Zero Variance and other useless Columns ------------------------------

source("./functions/zerovar.R")

sft <- sft[,-zerovar(sft),with=FALSE]
sft <- select(sft,-starts_with("sft_amt"),-manager)

# Fix data class types --------------------------------------------------------

  # Fix numeric class types ---------------------------------------------------

num_fields <- c("b003s_ccgl_acc",
                   "ac_doc_no",
                   "fiscyear",
                   "gl_account",
                   "actn_code",
                   "act_fte",
                   "class_lv",
                   "doc_fy_ad",
                   "doc_fy_or",
                   "doc_no_or",
                   "doc_no_ad",
                   "empl_pos",
                   "empl_stat",
                   "forecast",
                   "frcst_adj",
                   "frcst_lv",
                   "frcst_typ",
                   "line_numb",
                   "net_amnt",
                   "pri_numb",
                   "t_frc_ad",
                   "split_per",
                   "frcst_tye",
                   "unfrcsted",
                   "adj_fyf",
                   "asgn_week",
                   "schd_week",
                   "ovrwr_pay",
                   "min_prate",
                   "max_prate",
                   "payrate",
                   "allw_rate",
                   "rempl_pos",
                   "bpc_fte",
                   "fiscper",
                   "fiscper3")

sft[, (num_fields) := lapply(.SD, as.numeric), .SDcols = num_fields]

  # Fix date class types ------------------------------------------------------

  date_fields <- c("ed_end_dt",
                   "ed_frm_dt",
                   "endda",
                   "enddaproj",
                   "endda_hr",
                   "from_date",
                   "incr_date",
                   "startdate",
                   "to_date",
                   "datefrom",
                   "evnt_bega",
                   "evnt_enda")

  sft[, (date_fields) := lapply(.SD, function(x) as.Date(x,"%Y%m%d")), .SDcols = date_fields]
  
  # Special Cases -------------------------------------------------------------
  
  special_fields <- c("b003s_sftcosct","coorder","costcenter")
  
  sft[,b003s_sftcosct:=ifelse(nchar(b003s_sftcosct)<7,b003s_sftcosct,substr(b003s_sftcosct,5,10))]
  sft[,coorder:=as.numeric(ifelse(nchar(coorder)<12,coorder,substr(coorder,7,12)))]
  sft[,costcenter:=ifelse(nchar(costcenter)<7,costcenter,substr(costcenter,5,10))]
  
  
  # Remove fields that are duplicate or not useful -----------------------------
  
  sft <- sft %>%
    select(-b003s_ccgl_acc,
           -b003s_sftcosct,
           -loc_currcy,
           -wbs_elemt,
           -doc_fy_ad,
           -doc_fy_or,
           -doc_no_ad,
           -doc_no_or,
           -fi_extrac,
           -line_numb,
           -bpc_vers1,
           -bpc_fte,
           -fiscper,
           -fiscper3) %>%
    data.table()
  
  # Remove all actuals data ---------------------------------------------------
  
  source("./functions/zerovar.R")
  sft <- sft[is.na(ac_doc_no) & doc_cat!="FT"]
  sft <- sft[,-zerovar(sft),with=FALSE]
  
  # Remove t_frc_ad (duplicate with net_amnt)
  sft <- select(sft,-t_frc_ad) %>%
    data.table()
  
  # Select Columns ------------------------------------------------------------
  
  sft <- sft %>%
    select(fiscyear,
           pri_numb,
           costcenter,
           func_area,
           fund,
           gl_account,
           class_cod,
           class_grp,
           class_lv,
           zone_code,
           actn_code,
           exc_frcst,
           empl_pos,
           empl_stat,
           empl_type,
           frcst_grp,
           frcst_lv,
           frcst_typ,
           bil_bonus,
           over_flag,
           perf_flag,
           pln_frcst,
           recov,
           rec_type,
           sched_cod,
           split_per,
           startdate,
           endda,
           incr_date,
           from_date,
           to_date,
           datefrom,
           evnt_bega,
           evnt_enda,
           enddaproj,
           endda_hr,
           min_prate,
           max_prate,
           payrate,
           allw_rate,
           ovrwr_pay,
           asgn_week,
           schd_week,
           forecast,
           act_fte,
           frcst_adj,
           frcst_tye,
           adj_fyf,
           unfrcsted,
           net_amnt) %>%
    data.table()
  
  
  
  # Tidy Up -------------------------------------------------------------------
  
  keep_objects <- c("keep_objects","sft")
  rm(list=setdiff(ls(),keep_objects))
  

  
  
  






