# TODO: Add comment
# 
# Author: yia
###############################################################################
#The following two are currently mutually exclusive
FIM.NORETWEET <- TRUE
FIM.PRUNE_HIGHER_THAN_OBAMA <- FALSE

USE_SOURCE_TRICK <- TRUE

FIM.label <- "HFP"
FIM.DEBUG <- T # FALSE
FIM.TRACE <- FALSE


FIM.argv <- commandArgs(trailingOnly = TRUE)
FIME.miningFuncName <- FIM.argv[1]
# for now we only do the  hgram_occ_DAY_2 tables
#FIM.compgramlenm<-as.integer(FIM.argv[1]) #4
source("yaboulna_utils.R")
annotPrint(FIM.label,"Command line arguments read: FIME.miningFuncName=",FIME.miningFuncName)

FIM.gramColName <- "ngram" #"compgram"
FIM.lenColName <- "ngramlen" #"compgramlen"
FIM.occsTableName <-   "bak_alloccs" #"occurrences" 

FIM.epoch <- '1hr'
FIM.support <- 5
FIM.windowLenSec <- 60*60*24

FIM.fislenm <- 10


if(FIM.DEBUG){
  FIM.db <- "sample-0.01"
  FIM.gramColName <- "compgram"
  FIM.lenColName <- "compgramlen"
  FIM.occsTableName <-   "occurrences" 
  FIM.days <- c(121106)
  FIM.compgramlenm <- 2  
  FIM.dataRoot <- "~/r_output_debug/"
  FIM.nCores<-1
  
} else {
  FIM.db <- "full"
  FIM.dataRoot <- "~/r_output/"
  FIM.nCores<-1 # each epoch needs lots of memory.. I've seen 60 GB being consumed by one epoch!
  FIM.days <- unique(c(121106)) #, 121105, 121104, 121103, 120925,  120926,  120930,  121008,  121013,  121016,  121026,  121027,  121028,  121029,  121030,
          #121108,  121110,  121116,  121119,  121120,  121122,  121123,  121125,  121205,  121206,  121210,  121214,  121215,  121231,  130103,  130104)) #missing data: 120914,121222,  121223,
}

if(FIM.TRACE){
  compgramlenm <- 2 #FIM.compgramlenm
  
  epoch=FIM.epoch
  db=FIM.db
  support=FIM.support
  dataRoot=FIM.dataRoot
#    historyDays=0
#  queryTimeUx=1352206800
  day=121106
  windowLenSec=FIM.windowLenSec
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


if(USE_SOURCE_TRICK){
#options(warn=2)
options(show.error.locations=5)
options(error = quote(dump.frames(paste("~/r_logs/fim-arules_",format(Sys.time(),format="%y%m%d%H%M%S"),".dump",sep=""), TRUE)))

for(day in FIM.days) {
  tryCatch({
  
        baseDirName <- ifelse(FIM.NORETWEET,"fim_hgrams-2_no-retweets_apriori","fim_hgrams-2")
        FIME.outDir <- paste(FIM.dataRoot,baseDirName,FIME.miningFuncName,day,sep="/");
        if(!file.exists(FIME.outDir)){
          dir.create(FIME.outDir,recursive = T)
        }
        
  FIMW.day <- day
  FIMW.drv <- dbDriver("PostgreSQL")
  FIMW.con <- dbConnect(FIMW.drv, dbname=FIM.db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
  try(stop(paste(Sys.time(), FIM.label, "for day:", FIMW.day, " - Connected to DB", FIM.db)))
  
  if(FIM.NORETWEET){
    sql <- sprintf("select string_agg(ngram,'|') as noretweet,floor(timemillis/3600000)*3600 as epochstartux from hgram_occ_%s_2 group by id,timemillis having string_agg(ngram,'|') !~ '(^|[\\|\\,])rt([\\|\\,]|$)'; ", FIMW.day )
  
  } else {
    sql <- sprintf("select DISTINCT ON (id,ngram) CAST(ngram as text) as compgram,CAST(id as varchar),floor(timemillis/3600000)*3600 as epochstartux, ngramlen as compgramlen,pos 
            from  hgram_occ_%s_2",FIMW.day);  
  } 
  
  try(stop(paste(Sys.time(), FIM.label, "for day:", FIMW.day, " - Fetching day's occurrences using sql:\n", sql)))
  
  occsRs <- dbSendQuery(FIMW.con,sql)
  FIMW.nonovOcc <- fetch(occsRs,n=-1)
  
  try(dbClearResult(occsRs))
  try(stop(paste(Sys.time(), FIM.label, "for day:", FIMW.day, " - Fetched day's occurrences. nrow:", nrow(FIMW.nonovOcc))))
  
  
  ########### 
# dbDisconnect(FIMW.con, ...) closes the connection. Eg.
  try(dbDisconnect(FIMW.con))
# dbUnloadDriver(FIMW.drv,...) frees all the resources used by the driver. Eg.
  try(dbUnloadDriver(FIMW.drv))
  
  d_ply(idata.frame(FIMW.nonovOcc),c("epochstartux"),function(FIME.compgramOccs){
#        FIME.epochstartux <- FIME.compgramOccs$epochstartux[1]
      	FIME.day <- day
if(FIME.compgramOccs[1,"epochstartux"] < 1352203200) return(NULL)	
        source("fim_doepoch.R",local = TRUE,echo = TRUE)
        try(rm(FIME.epochFIS)) 
  
        rm(FIME.compgramOccs)
#        return(NULL) #just in case
      },.parallel=TRUE)
  
  try(rm(FIMW.nonovOcc))
  },error=function(e) print(paste(Sys.time(),FIM.label,"Error for day",day,e,sep=" - ")), 
  finally=print(paste(Sys.time(),FIM.label,"Day done:",day,sep=" - ")))
}
}
