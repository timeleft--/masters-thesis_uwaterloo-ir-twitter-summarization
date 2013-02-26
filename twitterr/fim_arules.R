# TODO: Add comment
# 
# Author: yia
###############################################################################

FIM.label <- "FIM"
FIM.DEBUG <- TRUE
FIM.TRACE <- FALSE

FIM.argv <- commandArgs(trailingOnly = TRUE)
FIM.compgramlenm<-as.integer(FIM.argv[1])

FIM.gramColName <- "ngram" #"compgram"
FIM.lenColName <- "ngramlen" #"compgramlen"
FIM.occsTableName <- "bak_alloccs"  # "occurrences"

FIM.epoch <- '1hr'
FIM.support <- 5

FIM.fislenm <- 15

if(FIM.DEBUG){
  FIM.db <- "full"#"sample-0.01"
  FIM.dataRoot <- "~/r_output_debug/"
  if(FIM.TRACE){
    compgramlenm <- 4
    
    epoch=FIM.epoch
    db=FIM.db
    support=FIM.support
    dataRoot=FIM.dataRoot
    windowDays=0
    querytime=1352206800
  }
} else {
  FIM.db <- "full"
  FIM.dataRoot <- "~/r_output/"

}

########################################################


require(arules)

require(RPostgreSQL)

source("compgrams_utils.R")

########################################################

source("compgrams_utils.R")

########################################################


occurrencesToTransactions <- function(day, compgramlenm, querytime, windowDays=2, epoch=FIM.epoch,db=FIM.db, support=FIM.support, dataRoot=FIM.dataRoot){
  
  ############ 
  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
  try(stop(paste(Sys.time(), FIM.label, "for day:", day, " - Connected to DB", db)))
  
  
  ########Read the compgram vocabulary
#  if(compgramlenm==1){
#    sql <- printf("select distinct ngramarr[1] as compgram
#            from cnt_%s%d where date=%d and cnt > %d order by cnt desc;", epoch1, ngramlen1, day, support)
#  } else {
#    # compgrams with no enough "support were not originally stored, but that was for item support not itemset  
#    sql <- sprintf("select distinct ngramarr as compgram
#            from compcnt_%s%d_%d where cnt > %d order by cnt desc;",epoch1, ngramlen1, day, support)
#  }
#  
#  try(stop(paste(Sys.time(), FIM.label, "for day:", day, " - Fetching day's compgrams using sql:\n", sql)))
#  
#  compgramRs <- dbSendQuery(con,sql)
#  compgramDf <- fetch(compgramRs,n=-1)
#  try(dbClearResult(compgramRs))
#  
#  try(stop(paste(Sys.time(), FIM.label, "for day:", day, " - Fetched day's compgrams. nrow:", nrow(compgramDf))))
#  
#  if(compgramlenm!=1){
#    compgramDf <- within(compgramDf, {compgram=stripEndChars(compgram)})
#  }
  
  ########### Read the occurrences
  
  SEC_IN_EPOCH <- c(X5min=(60*5), X1hr=(60*60), X1day=(24*60*60)) 
  MILLIS_IN_EPOCH <- SEC_IN_EPOCH * 1000
  
  sec0CurrDay <-  as.numeric(as.POSIXct(strptime(paste(day,"0000",sep=""),
                            "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01"))
  if(is.null(querytime)){
    querytime <- sec0CurrDay + 60*60*24 - 1
  }              
              
  if(windowDays>0){
    sec0WindowDays <- sec0CurrDay - ((60*60*24) * (1:windowDays))
    windowDays <- as.POSIXct(sec0WindowDays,origin="1970-01-01",tz="UTC")
    windowDays <- format(windowDays, format="%y%m%d", tz="Pacific/Honolulu") #, usetz=TRUE)
    windowDays <- c(day,windowDays)
  } else {
    windowDays <- c(day)  
  }
  dateSQL <- paste(paste("date",windowDays,sep="="),collapse=" or ")
  
  # DISTINCT because the fim algorithms in arules work with binary occurrence (that's ok I guess.. for query expansion)
  sqlTemplate <- sprintf("select DISTINCT ON (id,%%s) %%s as compgram,CAST(id as varchar),floor(timemillis/%d)*%d as epochstartux, %%s as compgramlen,pos 
        from %%s where %s and %%s<=%d and timemillis <= (%d * 1000::INT8) ",
    MILLIS_IN_EPOCH[[paste("X",epoch,sep="")]],SEC_IN_EPOCH[[paste("X",epoch,sep="")]],dateSQL,compgramlenm,querytime)
  
  compgramsSql <- sprintf(sqlTemplate,FIM.gramColName,FIM.gramColName, FIM.lenColName, FIM.occsTableName, FIM.lenColName)
#  compgramsSql <- paste(compgramsSql,"order by",FIM.lenColName,"desc")
  unigramSql <- sprintf(sqlTemplate,"ngram","ngram","ngramlen","ngrams1","ngramlen")
  sql <- sprintf("(%s) UNION ALL (%s) %s",compgramsSql, unigramSql, "order by compgramlen desc")
  
  try(stop(paste(Sys.time(), FIM.label, "for day:", day, " - Fetching day's occurrences using sql:\n", sql)))
  
  occsRs <- dbSendQuery(con,sql)
  occsDf <- fetch(occsRs,n=-1)
  
  try(dbClearResult(occRs))
  try(stop(paste(Sys.time(), FIM.label, "for day:", day, " - Fetched day's occurrences. nrow:", nrow(occsDf))))
  
  
  ########### 
  # dbDisconnect(con, ...) closes the connection. Eg.
  try(dbDisconnect(con))
  # dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
  try(dbUnloadDriver(drv))
  
  ############# Remove overlapping occurrences
  
 
  FIM.docLenById <- array(occsDf$tweetlen)
  rownames(FIM.docLenById) <- occsDf$id
  occupiedEnv <- initOccupiedEnv(FIM.docLenById)
  rm(FIM.docLenById)
  
  
  nonovOcc <- adply(idata.frame(occsDf),1,ngramSelect, .expand=F)
  nonovOcc$X1 <- NULL
  
  
  ############# Do the FIM for the whole day
  dayTrans <- as(split(nonovOcc[,"compgram"],nonovOcc[,"id"]),"transactions")
  dayFIS <- eclat(dayTrans, parameter = list(supp = support/length(dayTrans), minlen=2, maxlen = FIM.fislenm))
  interest=interestMeasure(dayFIS, c("lift","allConfidence","crossSupportRatio"),transactions = dayTrans)
  quality(dayFIS) <- cbind(quality(dayFIS),
      interest)
  # inspect(head(sort(dayFIS,by="crossSupportRatio")))

  ############# Do the FIM for epochs
  
  fimForEpoch <- function(epcg) {
    epochstart <- epcg$epochstartux[1]
    epochOccs <- occsDf[which(epochOccs$epochstartux == epochstart)]
    
    # trans4 <- as(split(a_df3[,"item"], a_df3[,"TID"]), "transactions") 
    epochTrans <- as(split(epcg[,"compgram"], epcg[,"id"]), "transactions") 
  }
  debug(fimForEpoch)
  
  d_ply(nonovOcc,c("epochstartux"),fimForEpoch)
}
