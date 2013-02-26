# TODO: Add comment
# 
# Author: yaboulna
###############################################################################


FLO.label <- "FLO"
FLO.DEBUG <- FALSE
FLO.TRACE <- TRUE

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
FLO.support <- 5
FLO.windowLenSec <- 60*60*72

FLO.fislenm <- 15


if(FLO.DEBUG){
  FLO.db <- "full" #"sample-0.01"
  FLO.dataRoot <- "~/r_output_debug/"
  FLO.nCores<-2
  
} else {
  FLO.db <- "full"
  FLO.dataRoot <- "~/r_output/"
  FLO.nCores<-24
  
}

if(FLO.TRACE){
  compgramlenm <- FLO.compgramlenm
  
  epoch=FLO.epoch
  db=FLO.db
  support=FLO.support
  dataRoot=FLO.dataRoot
  epochstartux=1352206800
  day=121106
  
  windowLenSec=FLO.windowLenSec
}


########################################################

require(plyr)

require(foreach)

require(doMC)

registerDoMC(cores=FIM.nCores)

require(RPostgreSQL)

require(arules)

########################################################

source("compgrams_utils.R")

########################################################
SEC_IN_EPOCH <- c(X5min=(60*5), X1hr=(60*60), X1day=(24*60*60)) 
MILLIS_IN_EPOCH <- SEC_IN_EPOCH * 1000

########################################################

FLO.drv <- dbDriver("PostgreSQL")
FLO.con <- dbConnect(FLO.drv, dbname=FLO.db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
try(stop(paste(Sys.time(), FLO.label, "Connected to DB", FLO.db)))

#######################################################

sqlTemplate <- sprintf('(select %%s as compgramlen, CAST (%%s as text) as compgram, date, %%s as epochstartux, cnt  from %%s_%s%%d where date=%d and cnt <= %d and %%s=(%d * %%d::INT8) and %%s=%%d )',
    FLO.epoch,day,FLO.threshold,epochstartux)

sqlLen <- c()
for(len in 1:2){
  sqlLen <- c(sqlLen, sprintf(sqlTemplate,"ngramlen","ngramarr","(epochstartmillis/1000)","cnt",len,"epochstartmillis",1000,"ngramlen",len))
}
#sqlUnigram <- sprintf('(select ngramlen as compgramlen, CAST (ngramarr as text) as compgram, date, (epochstartmillis/1000) as epochstartux, cnt  from cnt_%s1 where date=%d and cnt <= %d)', 
#sqlLen <- c(sqlUnigram)

for(len in 3:FLO.compgramlenm) {
  sqlLen <- c(sqlLen, sprintf(sqlTemplate,FLO.lenColName, FLO.gramColName, FLO.timeSelect, FLO.cntTablePrefix,len, FLO.timeSelect,FLO.uxTimeToColTimeMultiplier,FLO.lenColName,len))
}

sqlUnion <- paste(sqlLen, collapse="\nUNION ALL\n")

try(stop(paste(Sys.time(),FLO.label,"Fetching epoch's compgrams less than Obama using sql:\n",sqlUnion)))

compgramsRs <- dbSendQuery(FLO.con,sqlUnion)

compgramsDf <- fetch(compgramsRs, n=-1)

try(stop(paste(Sys.time(),FLO.label,"Fetching epoch's compgrams less than Obama. Numrows:",nrow(compgramsDf))))

try(dbClearResult(compgramsRs))


