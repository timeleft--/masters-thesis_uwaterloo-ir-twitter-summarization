# TODO: Add comment
# 
# Author: yia
###############################################################################
FSO.ngramlen2=2
FSO.days <- c(130104)
FSO.root <- paste("~/r_output/occ_yuleq_fix_",FSO.ngramlen2,"/",sep="")
#day<-130104
source("compgrams_utils.R")
require(plyr)
FSO.db<-"full"

FSO.drv <- dbDriver("PostgreSQL")
FSO.con <- dbConnect(FSO.drv, dbname=FSO.db, user="yaboulna", password="5#afraPG",
    host="hops.cs.uwaterloo.ca", port="5433")


for(day in FSO.days){
  if(!file.exists(FSO.root)){
    dir.create(FSO.root,recursive=TRUE)
  }
#  alloccFile <- paste(FSO.root,day,".csv",sep="")
  seloccFile <-  paste(FSO.root,"sel_",day,".csv",sep="")
  try(file.rename(seloccFile,paste(seloccFile,"_fix_sel-occ_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="") ))
  selStaging <- paste(seloccFile,"staging",sep=".")
  file.create(selStaging)
  
#  allOcc <- read.table(alloccFile, header = FALSE, quote = "", comment.char="", 
#      sep = "\t", na = "NA", dec = ".", row.names = NULL, fill=TRUE,
#      col.names = c("id","timemillis","date","ngram","ngramlen","tweetlen","pos"), #,"yq","dl","cnt"),
#      colClasses = c("character","numeric","integer","character","integer","integer","integer"), #,"NULL","NULL","NULL"),
#      fileEncoding = "UTF-8-MAC")
  require(RPostgreSQL)

  
  allOccRs <- dbSendQuery(FSO.con,"select * from debug_allocc2_130104")
  allOcc <- fetch(allOccRs, n=-1)
  
  try(stop(paste(Sys.time()," - Fetched all occs. Num Rows: ", nrow(allOcc))))
  
  try(dbClearResult(allOccRs))
  
  
#  docLenById <- array(allOcc$tweetlen, row.names=allOcc$id)
  docLenById <- array(allOcc$tweetlen)
  rownames(docLenById) <- allOcc$id
  occupiedEnv <- initOccupiedEnv(docLenById)
  rm(docLenById)
  
  sec0CurrDay <-  as.numeric(as.POSIXct(strptime(paste(day,"0000",sep=""),
              "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01")) 
  epochCuts <- sec0CurrDay + (c(0:24) * 3600)  
  allOcc$epoch <- cut(allOcc$timemillis/1000,breaks=epochCuts)
  
  fixEpoch <- function(epochOccs){
    uniqueNgrams <- unique(epochOccs$ngram)
    
    try(stop(paste(Sys.time()," - Fixing epoch:", epochOccs$epoch, "num occs:",nrow(epochOccs), "unique Ngrams: ", length(uniqueNgrams))))
    
    for(ngram in uniqueNgrams){
      ngramOccs <- epochOccs[which(epochOccs$ngram == ngram),]
      
      selOccs <- adply(ngramOccs,1,
          selectOccurrences,ngramlen2 = FSO.ngramlen2,occupiedEnv = occupiedEnv,allowOverlap = FALSE,
          colsToReturn=c("ngram","id","timemillis","date","ngramlen","tweetlen","pos"),
          .expand=F)
      selOccs$X1 <- NULL
      
      
      write.table(selOccs, file = selStaging, append = TRUE, quote = FALSE, sep = "\t",
          eol = "\n", na = "NA", dec = ".", row.names = FALSE,
          col.names = FALSE, # qmethod = c("escape", "double"),
          fileEncoding = "UTF-8")
    }
  }
# debug(fixEpoch)
  
  d_ply(allOcc,c("epoch"),fixEpoch)
  
  file.rename(selStaging,seloccFile)
  
  rm(occupiedEnv)
  
  
}


# dbDisFSO.connect(FSO.con, ...) closes the FSO.connection. Eg.
try(dbDisconnect(FSO.con))
# dbUnloadDriver(FSO.drv,...) frees all the resources used by the driver. Eg.
try(dbUnloadDriver(FSO.drv))
