# Import and Clean SFT_EXTRACT_ACTUAL -----------------------------------------

dir <- "\\\\onottaafccifs.agr.gc.ca\\bw_data_dump\\"

meta <- fread(paste(dir,"S_SFT_EXTRACT_FCST_SSHOT.csv",sep=''),skip=5)

source("./functions/fix_names.R")
source("./functions/fix_class.R")

fsnap <- fread(paste(dir,"SFT_EXTRACT_FCST_SSHOT.csv",sep=''),
             col.names=fix_names(meta$FIELDNAME),
             colClasses = fix_class(meta$TYPE))

# Remove Zero Variance and other useless Columns ------------------------------

source("./functions/zerovar.R")
fsnap <- fsnap[,-zerovar(fsnap),with=FALSE]

# Fix data class types --------------------------------------------------------

# Fix numeric class types ---------------------------------------------------

num__fields <- c()

# fsnap[, (num_fields) := lapply(.SD, as.numeric), .SDcols = num__fields]

# Fix date class types ------------------------------------------------------

date_fields <- c()

# fsnap[, (date_fields) := lapply(.SD, function(x) as.Date(x,"%Y%m%d")), .SDcols = date_fields]

# Special Cases -------------------------------------------------------------

special_fields <- c()

# Tidy Up -------------------------------------------------------------------

keep_objects <- c(keep_objects,"fsnap")
rm(list=setdiff(ls(),keep_objects))