# TODO: Add comment
# 
# Author: yaboulna
###############################################################################


SEC_IN_EPOCH <- c(X5min=(60*5), X1hr=(60*60), X1day=(24*60*60)) 
MILLIS_IN_EPOCH <- SEC_IN_EPOCH * 1000


#occurrencesToTransactions <- function(day, compgramlenm, queryTimeUx, windowLenSec=FIM.windowLenSec, epoch=FIM.epoch,db=FIM.db, support=FIM.support, dataRoot=FIM.dataRoot){


############ 

FIMW.drv <- dbDriver("PostgreSQL")
FIMW.con <- dbConnect(FIMW.drv, dbname=FIM.db, user="yaboulna", password="5#afraPG",
    host="hops.cs.uwaterloo.ca", port="5433")

try(stop(paste(Sys.time(), FIM.label, "for day:", FIMW.day, " - Connected to DB", FIM.db)))



########### Read the occurrences

if (!exists("FIMW.day") || is.null(FIMW.day)) { 
  if(exists("queryTimeUx") && !is.null(queryTimeUx)){
    FIMW.day <- as.POSIXct(queryTimeUx,origin="1970-01-01",tz="UTC")
    FIMW.day <- as.integer(format(FIMW.day, format="%y%m%d", tz="Pacific/Honolulu")) #, usetz=TRUE)
  } else {
    stop("Must specify either query time or at least the FIMW.day")
  }             
} 

sec0CurrDay <-  as.numeric(as.POSIXct(strptime(paste(FIMW.day,"0000",sep=""),
            "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01"))


if(!exists("queryTimeUx") || is.null(queryTimeUx)){
  queryTimeUx <- sec0CurrDay + 60*60*24 - 1
}

queryEpochEndUx <- floor(queryTimeUx/SEC_IN_EPOCH[[paste("X",FIM.epoch,sep="")]]) * SEC_IN_EPOCH[[paste("X",FIM.epoch,sep="")]]

sec0Window <- queryEpochEndUx - FIM.windowLenSec
historyDays <- ceiling((sec0CurrDay - sec0Window)/(3600*24))  

if(historyDays>0){
  sec0historyDays <- sec0CurrDay - ((60*60*24) * (1:historyDays))
  historyDays <- as.POSIXct(sec0historyDays,origin="1970-01-01",tz="UTC")
  historyDays <- format(historyDays, format="%y%m%d", tz="Pacific/Honolulu") #, usetz=TRUE)
  historyDays <- c(FIMW.day,historyDays)
} else {
  historyDays <- c(FIMW.day)  
}
dateSQL <- paste(paste("date",historyDays,sep="="),collapse=" or ")
dateSQL <- paste(dateSQL,sprintf('and timemillis >= (%d * 1000::INT8) and timemillis < (%d * 1000::INT8)',sec0Window,queryEpochEndUx))

# DISTINCT because the fim algorithms in arules work with binary occurrence (that's ok I guess.. for query expansion)
sqlTemplate <- sprintf("select DISTINCT ON (id,%%s) CAST(%%s as text) as compgram,CAST(id as varchar),floor(timemillis/%d)*%d as epochstartux, %%s as compgramlen,pos 
        from %%s where %s  and %%s<=%d  ",
    MILLIS_IN_EPOCH[[paste("X",FIM.epoch,sep="")]],SEC_IN_EPOCH[[paste("X",FIM.epoch,sep="")]],dateSQL,FIM.compgramlenm)

compgramsSql <- sprintf(sqlTemplate,FIM.gramColName,FIM.gramColName, FIM.lenColName, FIM.occsTableName, FIM.lenColName)
#  compgramsSql <- paste(compgramsSql,"order by",FIM.lenColName,"desc")
unigramSql <- sprintf(sqlTemplate,"ngram","ngram","ngramlen","ngrams1","ngramlen")
sql <- sprintf("(%s) UNION ALL (%s) %s",compgramsSql, unigramSql, "") # No need for ordering unless we will get rid f overlap: "order by compgramlen desc")

try(stop(paste(Sys.time(), FIM.label, "for day:", FIMW.day, " - Fetching day's occurrences using sql:\n", sql)))

occsRs <- dbSendQuery(FIMW.con,sql)
occsDf <- fetch(occsRs,n=-1)

try(dbClearResult(occsRs))
try(stop(paste(Sys.time(), FIM.label, "for day:", FIMW.day, " - Fetched day's occurrences. nrow:", nrow(occsDf))))


########### 
# dbDisconnect(FIMW.con, ...) closes the connection. Eg.
try(dbDisconnect(FIMW.con))
# dbUnloadDriver(FIMW.drv,...) frees all the resources used by the driver. Eg.
try(dbUnloadDriver(FIMW.drv))

# FIXME : I dunno why I can't get this done :( 
FIMW.nonovOcc <- occsDf
#  ############# Remove overlapping occurrences
#  epochCutSec <- seq(from=sec0Window,to=queryEpochEndUx,by=SEC_IN_EPOCH[[paste("X",FIM.epoch,sep="")]])  
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
#        try(stop(paste(Sys.time(),FIM.label, "for day:", FIMW.day, " - Removing complete overlap from FIM.epoch:", epochMillisStart,"-",epochMillisEnd, "num occs:",nrow(epochOccs), "unique compgrams: ", length(uniquecompgrams))))
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
#  dayFIS <- eclat(dayTrans, parameter = list(supp = FIM.support/length(dayTrans), minlen=2, maxlen = FIM.fislenm))
#  interest=interestMeasure(dayFIS, c("lift","allConfidence","crossSupportRatio"),transactions = dayTrans)
#  quality(dayFIS) <- cbind(quality(dayFIS),
#      interest)
#  # inspect(head(sort(dayFIS,by="crossSupportRatio")))
#  write()
#  ############# Do the FIM for epochs
#  

