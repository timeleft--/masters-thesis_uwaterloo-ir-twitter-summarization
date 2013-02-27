# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

FLO.more<-TRUE

FLO.label <- "FLO"
FLO.DEBUG <- FALSE
FLO.TRACE <- FALSE

FLO.argv <- commandArgs(trailingOnly = TRUE)
FLO.compgramlenm<- 4 #as.integer(FLO.argv[1]) 
#FLO.thresholdWord <- FLO.argv[2] 
FLO.threshold <- 150

FLO.cntTablePrefix <- "bak_compcnt" #we must specify where ngramlen=len to avoid the deducations in shorter ones 
FLO.gramColName <- "ngramarr" #same
FLO.lenColName <- "ngramlen" # same
FLO.timeSelect <- "epochstartux"
FLO.uxTimeToColTimeMultiplier <- 1 # put 1000 if the column stores millis

FLO.epoch <- '1hr'


if(FLO.DEBUG){
  FLO.db <- "full" #"sample-0.01"
  FLO.dataRoot <- "~/r_output_debug/"
  
} else {
  FLO.db <- "full"
  FLO.dataRoot <- "~/r_output/"
  
}

if(FLO.TRACE){
  
  
  FLO.epochstartux=1352206800
  FLO.day=121106
  
}


########################################################

require(RPostgreSQL)


########################################################


FLO.drv <- dbDriver("PostgreSQL")
FLO.con <- dbConnect(FLO.drv, dbname=FLO.db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
try(stop(paste(Sys.time(), FLO.label, "Connected to DB", FLO.db)))

#######################################################

sqlTemplate <- sprintf('(select DISTINCT ON (compgram) %%s as compgramlen, CAST (%%s as text) as compgram, date, %%s as epochstartux, cnt  from %%s_%s%%d where date=%d and cnt %s %d and %%s=(%d * %%d::INT8) and %%s=%%d )',
    FLO.epoch,FLO.day,ifelse(FLO.more,'>','<='),FLO.threshold,FLO.epochstartux)

sqlLen <- c()
for(len in 1:2){
  sqlLen <- c(sqlLen, sprintf(sqlTemplate,"ngramlen","ngramarr","(epochstartmillis/1000)","cnt",len,"epochstartmillis",1000,"ngramlen",len))
}

for(len in 3:FLO.compgramlenm) {
  sqlLen <- c(sqlLen, sprintf(sqlTemplate,FLO.lenColName, FLO.gramColName, FLO.timeSelect, FLO.cntTablePrefix,len, FLO.timeSelect,FLO.uxTimeToColTimeMultiplier,FLO.lenColName,len))
}

sqlUnion <- paste(sqlLen, collapse="\nUNION ALL\n")

try(stop(paste(Sys.time(),FLO.label,"Fetching epoch's compgrams less than Obama using sql:\n",sqlUnion)))

compgramsRs <- dbSendQuery(FLO.con,sqlUnion)

FLO.compgramsDf <- fetch(compgramsRs, n=-1)

try(stop(paste(Sys.time(),FLO.label,"Fetching epoch's compgrams less than Obama. Numrows:",nrow(FLO.compgramsDf))))

try(dbClearResult(compgramsRs))

try(dbDisconnect(FLO.con))
try(dbUnloadDriver(FLO.drv))

