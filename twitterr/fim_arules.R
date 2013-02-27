# TODO: Add comment
# 
# Author: yia
###############################################################################
FIM.PRUNE_HIGHER_THAN_OBAMA <- TRUE
USE_SOURCE_TRICK <- TRUE

FIM.label <- "FIM"
FIM.DEBUG <-  FALSE
FIM.TRACE <- FALSE

FIM.argv <- commandArgs(trailingOnly = TRUE)
FIM.compgramlenm<-as.integer(FIM.argv[1]) #4

FIM.gramColName <- "ngram" #"compgram"
FIM.lenColName <- "ngramlen" #"compgramlen"
FIM.occsTableName <-   "bak_alloccs" #"occurrences" 

FIM.epoch <- '1hr'
FIM.support <- 5
FIM.windowLenSec <- 60*60*24

FIM.fislenm <- 5


if(FIM.DEBUG){
  FIM.db <- "sample-0.01"
  FIM.gramColName <- "compgram"
  FIM.lenColName <- "compgramlen"
  FIM.occsTableName <-   "occurrences" 
  FIM.days <- c(130104)
  FIM.compgramlenm <- 2  
  FIM.dataRoot <- "~/r_output_debug/"
  FIM.nCores<-2
  
} else {
  FIM.db <- "full"
  FIM.dataRoot <- "~/r_output/"
  FIM.nCores<-24
  FIM.days <- unique(c( 120925,  120926,  120930,  121008,  121013,  121016,  121026,  121027,  121028,  121029,  121030,  121103,  121104,  121105,  121106,  121108,  121110,  121116,  121119,  121120,  121122,  121123,  121125,  121205,  121206,  121210,  121214,  121215,  121231,  130103,  130104)) #missing data: 120914,121222,  121223,
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


occurrencesToTransactions <- function(day, compgramlenm, queryTimeUx, windowLenSec=FIM.windowLenSec, epoch=FIM.epoch,db=FIM.db, support=FIM.support, dataRoot=FIM.dataRoot){
  

  
  ############ 
  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
  try(stop(paste(Sys.time(), FIM.label, "for day:", day, " - Connected to DB", db)))
  
  
  
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
  dateSQL <- paste(dateSQL,sprintf('and timemillis >= (%d * 1000::INT8) and timemillis < (%d * 1000::INT8)',sec0Window,queryEpochEndUx))
  
  # DISTINCT because the fim algorithms in arules work with binary occurrence (that's ok I guess.. for query expansion)
  sqlTemplate <- sprintf("select DISTINCT ON (id,%%s) CAST(%%s as text) as compgram,CAST(id as varchar),floor(timemillis/%d)*%d as epochstartux, %%s as compgramlen,pos 
        from %%s where %s  and %%s<=%d  ",
    MILLIS_IN_EPOCH[[paste("X",epoch,sep="")]],SEC_IN_EPOCH[[paste("X",epoch,sep="")]],dateSQL,compgramlenm)
  
  compgramsSql <- sprintf(sqlTemplate,FIM.gramColName,FIM.gramColName, FIM.lenColName, FIM.occsTableName, FIM.lenColName)
#  compgramsSql <- paste(compgramsSql,"order by",FIM.lenColName,"desc")
  unigramSql <- sprintf(sqlTemplate,"ngram","ngram","ngramlen","ngrams1","ngramlen")
  sql <- sprintf("(%s) UNION ALL (%s) %s",compgramsSql, unigramSql, "") # No need for ordering unless we will get rid f overlap: "order by compgramlen desc")
  
  try(stop(paste(Sys.time(), FIM.label, "for day:", day, " - Fetching day's occurrences using sql:\n", sql)))
  
  occsRs <- dbSendQuery(con,sql)
  occsDf <- fetch(occsRs,n=-1)
  
  try(dbClearResult(occsRs))
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
  
  FIM.outDir <- paste(FIM.dataRoot,"fim",sep="/");
  if(!file.exists(FIM.outDir)){
    dir.create(FIM.outDir,recursive = T)
  }  

  fimForEpoch <- function(epcg) {
    
    epochstartux<-epcg$epochstartux[1]
    
    
    
    try(stop(paste(Sys.time(),FIM.label, "for day:", day, " - FIM for epoch:",epochstartux, "num occs before pruning:",nrow(epcg))))
    
    if(FIM.PRUNE_HIGHER_THAN_OBAMA){
     
      ########Read the compgram vocabulary
      #day alread set
      FLO.epochstartux <- epochstartux
      FLO.day <- day
      source("fim_less-than-obama.R", local = TRUE, echo = TRUE)
      #FLO.compgramsDf should appear in the current environment after sourcing
    
      # Note that FLO.compgramDf is for one epoch only
      midFreq <- merge(epcg,FLO.compgramsDf,by="compgram",sort=F, suffixes=c("","FLO"))
    
#      cntFLO <- array(FLO.compgramsDf$cnt)
#      names(cntFLO) <-FLO.compgramsDf$compgram
#      
#      midFreq <- a_ply(epcg,1,function(occ) {
#            if(is.na(cntFLO[occ$compgram])) 
#                return(NULL)
#            else
#               return(occ)
#            } ,.expand = FALSE)
      
      rm(FLO.compgramsDf)
    } else {
      # renaming will cost us a copy in case we don't want to do anything, right? NO:
      # From http://cran.r-project.org/doc/manuals/R-ints.html
      # The named field is set and accessed by the SET_NAMED and NAMED macros, and take values 0, 1 and 2. R has a ‘call by value’ illusion, so an assignment like
      #     b <- a
      #appears to make a copy of a and refer to it as b. However, if neither a nor b are subsequently altered there is no need to copy. What really happens is that a new symbol b is bound to the same value as a and the named field on the value object is set (in this case to 2). When an object is about to be altered, the named field is consulted. A value of 2 means that the object must be duplicated before being changed. (Note that this does not say that it is necessary to duplicate, only that it should be duplicated whether necessary or not.)
      midFreq <- epcg
    }
    
    try(stop(paste(Sys.time(),FIM.label, "for day:", day, " - FIM for epoch:",epochstartux, "num occs after pruning:",nrow(midFreq))))
    
    # trans4 <- as(split(a_df3[,"item"], a_df3[,"TID"]), "transactions") 
    epochTrans <- as(split(midFreq$compgram, midFreq$id), "transactions") 
    
    try(stop(paste(Sys.time(),FIM.label, "for day:", day, " - num transactions:",length(epochTrans))))
    
    epochFIS <- eclat(epochTrans,parameter = list(supp = support/length(epochTrans),minlen=2, maxlen=FIM.fislenm))
    epochFile<-paste(FIM.outDir,"/fis_",day,"-",epochstartux,".csv",sep="")
    write(epochFIS,file=epochFile,sep="\t",
        col.names=NA) #TODO: colnames
    
    try(stop(paste(Sys.time(),FIM.label, "for day:", day, " - Interest for epoch:", epochstartux, "num FIS:",length(epochFIS))))
    
    interest=interestMeasure(epochFIS, c("lift","allConfidence","crossSupportRatio"),transactions = epochTrans)
    quality(epochFIS) <- cbind(quality(epochFIS), interest)
#  # inspect(head(sort(dayFIS,by="crossSupportRatio")))
    write(epochFIS,file=epochFile,sep="\t",
        col.names=NA) #TODO: colnames
    try(stop(paste(Sys.time(),FIM.label, "for day:", day, " - Done for epoch:", epochstartux, "file:",epochFile)))
  }
#  debug(fimForEpoch)
  
  d_ply(idata.frame(nonovOcc),c("epochstartux"),fimForEpoch,.parallel=TRUE)
}


if(USE_SOURCE_TRICK){
#options(warn=2)
options(show.error.locations=5)
options(error = quote(dump.frames(paste("~/r_logs/fim-arules_",format(Sys.time(),format="%y%m%d%H%M%S"),".dump",sep=""), TRUE)))

for(day in FIM.days) {
  tryCatch({
  FIME.outDir <- paste(FIM.dataRoot,"fim",day,sep="/");
  if(!file.exists(FIME.outDir)){
    dir.create(FIME.outDir,recursive = T)
  }
  FIMW.day <- day
  source("fim_forwindow.R",local = TRUE,echo = TRUE)
  #FIMW.nonovOcc will appear in envinronment
  
  
  d_ply(idata.frame(FIMW.nonovOcc),c("epochstartux"),function(FIME.compgramOccs){
        FLO.epochstartux <- FIME.compgramOccs$epochstartux[1]
      	FLO.day <- day
	
        source("fim_doepoch.R",local = TRUE,echo = TRUE)
        try(rm(FIMW.epochFIS)) 
  
        rm(FIME.compgramOccs)
        return(NULL) #just in case
      },.parallel=TRUE)
  
  try(rm(FIMW.nonovOcc))
  },error=function(e) print(paste(Sys.time(),FIM.label,"Error for day",day,e,sep=" - ")), finally=print(paste(Sys.time(),FIM.label,"Day done:",day,sep=" - ")))
}
}
