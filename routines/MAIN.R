# Pre-process the SAP/SFT data so that it can be loaded into the Pay 
# Verification Tool (an interactive data visualization tool for identifying
# overpayments and underpayments)

# Author: Ben Watson, CPA, CMA (ben.watson@canada.ca)
# Project built under R Version: 3.5.1

# Reset workspace, memory and load libraries ----------------------------------

rm(list=ls())
for (i in 1:50){gc(reset=T)}

library(data.table)
library(tm)
library(memisc)
library(tidyverse)
library(bizdays)
library(scales)
library(zoo)

# 1.0 Import and clean data from FTP directory --------------------------------
source("./routines/1.IMPORT_SFT_CLASSIFICATION_DETAILS.R",echo=F)
source("./routines/1.IMPORT_SFT_EXTRACT_ACTUAL.R",echo=F)

# 2.0 Add filters to data -----------------------------------------------------
source("./routines/2.FILTER_DATA.R",echo=F)

# 3.0 Calculate biweekly pay amounts for both forecast/actuals ----------------
source("./routines/3.SPLIT_ACTUALS_BIWEEKLY.R",echo=F)
source("./routines/3.SPLIT_SFT_BIWEEKLY.R",echo=F)

# 4.0 Merge the biweekly forecast and actuals ---------------------------------
source("./routines/4.MERGE_BIWEEKLY.R")
source("./routines/4.MERGE_BIWEEKLY_FORECAST_GROUP.R")

# 5.0 Create sft features -----------------------------------------------------
source("./routines/5.CREATE_SFT_FEATURES.R")

# Write tables to disk --------------------------------------------------------
fwrite(act_biweekly,"./clean data/act_biweekly.csv")
fwrite(sft_biweekly,"./clean data/sft_biweekly.csv")
fwrite(biweekly_summary,"./clean data/biweekly_summary.csv")
fwrite(biweekly_frcst_grp,"./clean data/biweekly_frcst_grp.csv")

# 6.0 Preprocess data for shiny app -------------------------------------------
source("./routines/6.PREPROCESS_DATA_PAY_VERIFICATION_TOOL.R")

# 7.0 Preprocess data for Raw Data Explorer -----------------------------------
source("./routines/7.PREPROCESS_DATA_RAW_DATA_EXPLORER.R")

# Visualization of Employees with Pay Errors ----------------------------------

source("./functions/sap_fiscal_year.R")

rm.cases <- biweekly_summary %>%
  filter(action!="External Secondment - In") %>%
  filter(action!="Transfer In (External)") %>%
  filter(action!="Transfer Out (External)") %>%
  select(pri_numb) %>%
  distinct() %>%
  data.table()

vis <- biweekly_summary %>%
  filter(pri_numb %in% rm.cases$pri_numb) %>%
  filter(ed_frm_dt <=as.Date("2018-01-25")) %>%
  mutate(Error.1000=round(diff,-3)!=0,
         Error.100=round(diff,-2)!=0,
         Error.10=round(diff,-1)!=0) %>%
  group_by(ed_frm_dt) %>%
  summarise(Error.1000=mean(Error.1000),
            Error.100=mean(Error.100),
            Error.10=mean(Error.10)) %>%
  gather(variable,value,-ed_frm_dt) %>%
  mutate(variable=as.factor(gsub("\\."," > $ ",variable))) %>%
  data.table()

ggplot(vis,aes(ed_frm_dt,value,col=variable))+
  geom_point()+geom_line()+
  labs(title="Percent of Paychecks outside Error Tolerance",
       x="Pay Check Date",y="Percent of Pay Checks",
       col="Tolerance")+
  scale_y_continuous(labels=percent)



  
  
  
  


  


