# TODO: Add comment
# 
# Author: yia
###############################################################################

FIM.label <- "FIM"
FIM.DEBUG <- TRUE
FIM.TRACE <- TRUE

FIM.argv <- commandArgs(trailingOnly = TRUE)
FIM.compgramlenm<-as.integer(FIM.argv[1])

FIM.gramColName <- "compgram" #"ngram" #"compgram"
FIM.lenColName <- "compgramlen" # "ngramlen" #"compgramlen"
FIM.occsTableName <-  "occurrences"  # "bak_alloccs"

FIM.epoch <- '1hr'
FIM.support <- 5
FIM.windowLenSec <- 60*60*1

FIM.fislenm <- 15
FIM.compgramlenm <- 2

if(FIM.DEBUG){
  FIM.db <- "sample-0.01"
  FIM.dataRoot <- "~/r_output_debug/"
  FIM.nCores<-2
  
} else {
  FIM.db <- "full"
  FIM.dataRoot <- "~/r_output/"
  FIM.nCores<-24
  
}

if(FIM.TRACE){
  compgramlenm <- FIM.compgramlenm
  
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


#occurrencesToTransactions <- function(day, compgramlenm, queryTimeUx, windowLenSec=FIM.windowLenSec, epoch=FIM.epoch,db=FIM.db, support=FIM.support, dataRoot=FIM.dataRoot){
  
  
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
  
  if (!exists("day") || is.null(day)) { 
    if(exists("queryTimeUx") && !is.null(queryTimeUx)){
      day <- as.POSIXct(queryTimeUx,origin="1970-01-01",tz="UTC")
      day <- as.integer(format(day, format="%y%m%d", tz="Pacific/Honolulu")) #, usetz=TRUE)
    } else {
      stop("Must specify either query time or at least the day")
    }             
  } 
  
  sec0CurrDay <-  as.numeric(as.POSIXct(strptime(paste(day,"0000",sep=""),
              "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01"))
  
  
  if(!exists("queryTimeUx") || is.null(queryTimeUx)){
    queryTimeUx <- sec0CurrDay + 60*60*24 - 1
  }
  
  queryEpochEndUx <- floor(queryTimeUx/SEC_IN_EPOCH[[paste("X",epoch,sep="")]]) * SEC_IN_EPOCH[[paste("X",epoch,sep="")]]
  
  sec0Window <- queryEpochEndUx - windowLenSec
  historyDays <- ceiling((sec0CurrDay - sec0Window)/(3600*24))  
  
  if(historyDays>0){
    sec0historyDays <- sec0CurrDay - ((60*60*24) * (1:historyDays))
    historyDays <- as.POSIXct(sec0historyDays,origin="1970-01-01",tz="UTC")
    historyDays <- format(historyDays, format="%y%m%d", tz="Pacific/Honolulu") #, usetz=TRUE)
    historyDays <- c(day,historyDays)
  } else {
    historyDays <- c(day)  
  }
  dateSQL <- paste(paste("date",historyDays,sep="="),collapse=" or ")
  
  # DISTINCT because the fim algorithms in arules work with binary occurrence (that's ok I guess.. for query expansion)
  sqlTemplate <- sprintf("select DISTINCT ON (id,%%s) CAST(%%s as text) as compgram,CAST(id as varchar),floor(timemillis/%d)*%d as epochstartux, %%s as compgramlen,pos 
        from %%s where %s and %%s<=%d and timemillis >= (%d * 1000::INT8) and timemillis < (%d * 1000::INT8) ",
    MILLIS_IN_EPOCH[[paste("X",epoch,sep="")]],SEC_IN_EPOCH[[paste("X",epoch,sep="")]],dateSQL,compgramlenm,sec0Window,queryEpochEndUx)
  
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
  
# FIXME : I dunno why I can't get this done :( 
nonovOcc <- occsDf
#  ############# Remove overlapping occurrences
#  epochCutSec <- seq(from=sec0Window,to=queryEpochEndUx,by=SEC_IN_EPOCH[[paste("X",epoch,sep="")]])  
#  epochCutMillis <- epochCutSec * 1000
#  
##  epochMillis <- data.frame(start=epochCutMillis[1:24],end=epochCutMillis[2:25])
## WRONG: allOcc <- adply(allOcc,1,transform, epochNum=which(((timemillis >= epochMillis$start) & (timemillis < epochMillis$end))),.expand = TRUE)
## Right, but is it actually better in terms of performance.. 48 comparisons for each time stamp instad of 2 + 24 ands
## isntead of 1.. so after all I was chasing a mirage.. so stupid of me to waste such time "enhancing"
##allOcc <- adply(allOcc,1,function(occ){return(data.frame(epochN=which(((occ$timemillis >= epochMillis$start) & (occ$timemillis < epochMillis$end)))))},.expand = TRUE)
#  
#  nullCombine <- function(a,b) NULL
#  foreach(epochMillisStart=epochCutMillis[1:(length(epochCutMillis)-1)],epochMillisEnd=epochCutMillis[2:length(epochCutMillis)],
#          .inorder=FALSE, .combine='rbind', .multicombine=TRUE,.maxcombine=FIM.nCores) %dopar%
##  fixEpoch <- function(epochOccs)    
#      {
#        
#        # The millis version should require the least calculations when comparing timemillise
#        epochOccs <- occsDf[((occsDf$timemillis >= epochMillisStart) & (occsDf$timemillis < epochMillisEnd)), ]
#        
#        docLenById <- array(epochOccs$tweetlen)
#        rownames(docLenById) <- epochOccs$id
#        occupiedEnv <- initOccupiedEnv(docLenById)
#        rm(docLenById)
#        
#        uniquecompgrams <- unique(epochOccs$compgram)
#        
#        try(stop(paste(Sys.time(),FIM.label, "for day:", day, " - Removing complete overlap from epoch:", epochMillisStart,"-",epochMillisEnd, "num occs:",nrow(epochOccs), "unique compgrams: ", length(uniquecompgrams))))
#        
#        for(compgram in uniquecompgrams){
#          compgramOccs <- epochOccs[which(epochOccs$compgram == compgram),]
#          
#          selOccs <- adply(compgramOccs,1,
#              selectOccurrences,ngramlen2 = FIM.compgramlenm,occupiedEnv = occupiedEnv,allowOverlap = TRUE,
#              .expand=F)
#          selOccs$X1 <- NULL
#          
#          try(stop(paste(Sys.time()," - Writing file:", epochFile, "selected occs:",nrow(selOccs))))
#          
#          write.table(selOccs, file = epochFile, append = TRUE, quote = FALSE, sep = "\t",
#              eol = "\n", na = "NA", dec = ".", row.names = FALSE,
#              col.names = FALSE, # qmethod = c("escape", "double"),
#              fileEncoding = "UTF-8")
#          
#        }
#        
#        rm(occupiedEnv)
#      }
# 
#  
#  # TODO read the files written out by the parallel job and go on
#  
  
  ############# Do the FIM for the whole day
#  dayTrans <- as(split(nonovOcc[,"compgram"],nonovOcc[,"id"]),"transactions")
#  dayFIS <- eclat(dayTrans, parameter = list(supp = support/length(dayTrans), minlen=2, maxlen = FIM.fislenm))
#  interest=interestMeasure(dayFIS, c("lift","allConfidence","crossSupportRatio"),transactions = dayTrans)
#  quality(dayFIS) <- cbind(quality(dayFIS),
#      interest)
#  # inspect(head(sort(dayFIS,by="crossSupportRatio")))
#  write()
#  ############# Do the FIM for epochs
#  
  outDir <- paste(FIM.dataRoot,"fim",sep="/");
  if(!file.exists(outDir)){
    dir.create(outDir,recursive = T)
  }
  
  fimForEpoch <- function(epcg) {
    
    require(arules)
    
    try(stop(paste(Sys.time(),FIM.label, "for day:", day, " - FIM for epoch:", epcg$epochstartux[1], "num occs:",nrow(epcg))))
    # trans4 <- as(split(a_df3[,"item"], a_df3[,"TID"]), "transactions") 
    epochTrans <- as(split(epcg$compgram, epcg$id), "transactions") 
    
    try(stop(paste(Sys.time(),FIM.label, "for day:", day, " - num transactions:",length(epochTrans))))
    
    epochFIS <- eclat(epochTrans,parameter = list(supp = support/length(epochTrans),minlen=2, maxlen=FIM.fislenm))
    epochFile<-paste(outDir,"/fis_",day,"-",epcg$epochstartux[1],".csv",sep="")
    write(epochFIS,file=epochFile,sep="\t",
        col.names=NA) #TODO: colnames
    
    try(stop(paste(Sys.time(),FIM.label, "for day:", day, " - Interest for epoch:", epcg$epochstartux[1], "num FIS:",length(epochFIS))))
    
    interest=interestMeasure(epochFIS, c("lift","allConfidence","crossSupportRatio"),transactions = epochTrans)
    quality(epochFIS) <- cbind(quality(epochFIS), interest)
#  # inspect(head(sort(dayFIS,by="crossSupportRatio")))
    write(epochFIS,file=epochFile,sep="\t",
        col.names=NA) #TODO: colnames
    try(stop(paste(Sys.time(),FIM.label, "for day:", day, " - Interest for epoch:", epcg$epochstartux[1], "file:",length(epochFIS))))
  }
  debug(fimForEpoch)
  
  d_ply(nonovOcc,c("epochstartux"),fimForEpoch,.parallel=TRUE)
#}
