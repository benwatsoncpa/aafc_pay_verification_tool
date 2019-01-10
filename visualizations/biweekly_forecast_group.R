#
# This script visualizes the biweekly_forecast group data ---------------------

source("./functions/sap_fiscal_year.R")

# Graph avg over/under payments by forecast group and fiscal year ------------

vis <- biweekly_frcst_grp %>%
  filter(ed_frm_dt<as.Date("2018-01-25")) %>%
  mutate(fiscyear=sap_fiscal_year(ed_frm_dt)) %>%
  mutate(type=ifelse(diff<0,"Underpayment","Overpayment")) %>%
  group_by(fiscyear,frcst_grp_desc,type) %>%
  summarise(diff=mean(diff)) %>%
  group_by(frcst_grp_desc) %>%
  mutate(abs.diff=mean(abs(diff))) %>%
  filter(diff!=0) %>%
  data.table()

ggplot(vis,aes(reorder(frcst_grp_desc,abs.diff),diff,fill=as.factor(type)))+
  geom_bar(stat="identity")+
  coord_flip()+
  facet_wrap(~fiscyear)

# conclusion: Not much insight here

# Correlation Heat Map the Forecast Group Differences -------------------------

source("./functions/fix_names.R")

vis <- biweekly_frcst_grp %>%
  mutate(frcst_grp_desc=fix_names(frcst_grp_desc)) %>%
  select(pri_numb,ed_frm_dt,ed_end_dt,frcst_grp_desc,diff) %>%
  spread(frcst_grp_desc,diff,fill=0) %>%
  select(-pri_numb,-ed_frm_dt,-ed_end_dt) %>%
  data.table() 
  
vis <- melt(round(cor(vis),2))

ggplot(data = vis, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile()+
  theme(axis.text.x=element_text(angle=90))

# conclusion: Not much insight here

# Cluster analysis of forecast group diffs ------------------------------------

vis <- biweekly_frcst_grp %>%
  mutate(frcst_grp_desc=fix_names(frcst_grp_desc)) %>%
  select(pri_numb,ed_frm_dt,ed_end_dt,frcst_grp_desc,diff) %>%
  spread(frcst_grp_desc,diff,fill=0) %>%
  select(-pri_numb,-ed_frm_dt,-ed_end_dt) %>%
  data.table() %>%
  scale(center=T,scale = T)

# Determine number of clusters
wss <- (nrow(vis)-1)*sum(apply(vis,2,var))
for (i in 2:100) wss[i] <- sum(kmeans(vis, centers=i)$withinss)
plot(1:100, wss, type="b", xlab="Number of Clusters",ylab="Within groups sum of squares")

# K-Means Cluster Analysis
fit <- kmeans(mydata, 5) # 5 cluster solution
# get cluster means 
aggregate(mydata,by=list(fit$cluster),FUN=mean)
# append cluster assignment
mydata <- data.frame(mydata, fit$cluster)

# Cluster analysis of forecast group diffs by pri/fiscal year -----------------

vis <- biweekly_frcst_grp %>%
  mutate(fiscyear=sap_fiscal_year(ed_frm_dt)) %>%
  mutate(frcst_grp_desc=fix_names(frcst_grp_desc)) %>%
  select(pri_numb,fiscyear,ed_frm_dt,ed_end_dt,frcst_grp_desc,diff) %>%
  spread(frcst_grp_desc,diff,fill=0) %>%
  group_by(pri_numb,fiscyear) %>%
  summarise_at(vars(-ed_frm_dt,-ed_end_dt,-pri_numb,-fiscyear),funs(sum)) %>%
  data.table() %>%
  select(-pri_numb,-fiscyear) %>%
  scale(center=T,scale = T) %>%
  data.table()

# Determine number of clusters
wss <- (nrow(vis)-1)*sum(apply(vis,2,var))
for (i in 2:30) wss[i] <- sum(kmeans(vis, centers=i,iter.max=100)$withinss)
plot(1:30, wss, type="b", xlab="Number of Clusters",ylab="Within groups sum of squares")

pairs(sample_n(vis,2000),lower.panel=panel.smooth,upper.panel=histogram)

# K-Means Cluster Analysis
fit <- kmeans(mydata, 5) # 5 cluster solution
# get cluster means 
aggregate(mydata,by=list(fit$cluster),FUN=mean)
# append cluster assignment
mydata <- data.frame(mydata, fit$cluster)


# vis errors by action

vis <- biweekly_summary %>%
  mutate(type=ifelse(diff<0,"Underpayment","OverPayment")) %>%
  group_by(action,type) %>%
  summarise(diff=mean(diff)) %>%
  data.table()

ggplot(vis,aes(reorder(action,-diff),diff,fill=type)) +
  geom_bar(stat="identity")+
  geom_label(aes())
  coord_flip()




