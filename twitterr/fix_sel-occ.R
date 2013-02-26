# TODO: Add comment
# 
# Author: yia
###############################################################################
AUTO_REMOVE_STAGING <- FALSE
READ_ALLOCCS_FROM_FILE <- FALSE
FSO.ngramlen2=2
FSO.days <- c(130104)
FSO.root <- paste("~/r_output/occ_yuleq_full_",FSO.ngramlen2,"/",sep="")
#day<-130104
FSO.db<-"full"
FSO.nCores<-24
########################################################

source("compgrams_utils.R")

require(plyr)

require(foreach)

require(doMC)

registerDoMC(cores=FSO.nCores)

require(RPostgreSQL)

###########################

FSO.drv <- dbDriver("PostgreSQL")
FSO.con <- dbConnect(FSO.drv, dbname=FSO.db, user="yaboulna", password="5#afraPG",
    host="hops.cs.uwaterloo.ca", port="5433")
if(!file.exists(FSO.root)){
  dir.create(FSO.root,recursive=TRUE)
}

for(day in FSO.days){
  
  seloccFile <-  paste(FSO.root,"sel_",day,".csv",sep="")
  try(file.rename(seloccFile,paste(seloccFile,"_fix_sel-occ_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="") ))
  selStaging <- paste(seloccFile,"staging",sep=".")
  file.create(selStaging)

  if(READ_ALLOCCS_FROM_FILE){
    alloccFile <- paste(FSO.root,day,".csv",sep="")
    allOcc <- read.table(alloccFile, header = FALSE, quote = "", comment.char="", 
        sep = "\t", na = "NA", dec = ".", row.names = NULL, fill=TRUE,
        col.names = c("id","timemillis","date","ngram","ngramlen","tweetlen","pos"), #,"yq","dl","cnt"),
        colClasses = c("character","numeric","integer","character","integer","integer","integer"), #,"NULL","NULL","NULL"),
        fileEncoding = "UTF-8-MAC")
  } else {
    allOccRs <- dbSendQuery(FSO.con,"select * from debug_allocc2_130104")
    allOcc <- fetch(allOccRs, n=-1)
    
    try(dbClearResult(allOccRs))
  }  
  
  try(stop(paste(Sys.time()," - Read all occs. Num Rows: ", nrow(allOcc))))
  
  
  # Divide by epochs beacuse the ngrams are ordered in descending order of desirability per epoch
  # since this is how the all occurrences file was written out.. 
  sec0CurrDay <-  as.numeric(as.POSIXct(strptime(paste(day,"0000",sep=""),
              "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01")) 
  epochCutSec <- (sec0CurrDay + (c(0:24) * 3600))   
  
#  allOcc$epoch <- cut(allOcc$timemillis/1000,breaks=epochCutSec-1) #-1 because the intervals are closed to the right (0,1]
# 
 
#  docLenById <- array(allOcc$tweetlen, row.names=allOcc$id)
#  docLenById <- array(allOcc$tweetlen)
#  rownames(docLenById) <- allOcc$id
#  occupiedEnv <- initOccupiedEnv(docLenById)
#  rm(docLenById)
  
#  fixEpoch <- function(epochOccs){
#    uniqueNgrams <- unique(epochOccs$ngram)
#    
#    try(stop(paste(Sys.time()," - Fixing epoch:", epochOccs$epoch, "num occs:",nrow(epochOccs), "unique Ngrams: ", length(uniqueNgrams))))
#    
#    for(ngram in uniqueNgrams){
#      ngramOccs <- epochOccs[which(epochOccs$ngram == ngram),]
#      
#      selOccs <- adply(ngramOccs,1,
#          selectOccurrences,ngramlen2 = FSO.ngramlen2,occupiedEnv = occupiedEnv,allowOverlap = FALSE,
#          colsToReturn=c("ngram","id","timemillis","date","ngramlen","tweetlen","pos"),
#          .expand=F)
#      selOccs$X1 <- NULL
#      
#      
#      write.table(selOccs, file = selStaging, append = TRUE, quote = FALSE, sep = "\t",
#          eol = "\n", na = "NA", dec = ".", row.names = FALSE,
#          col.names = FALSE, # qmethod = c("escape", "double"),
#          fileEncoding = "UTF-8")
#    }
#  }
## debug(fixEpoch)
#  
#  d_ply(allOcc,c("epoch"),fixEpoch)
#file.rename(selStaging,seloccFile)


########## Parallel alternative

  epochCutMillis <- epochCutSec * 1000
  nullCombine <- function(a,b) NULL
  foreach(epochMillisStart=epochCutMillis[1:24],epochMillisEnd=epochCutMillis[2:25],
          .inorder=FALSE, .combine='nullCombine') %dopar%
      {
        
        # The millis version is ugly when it comes to naming files
        epochFile <- paste(seloccFile,"_",(epochMillisEnd/1000),".staging",sep="")
        file.create(epochFile)
        
        try(stop(paste(Sys.time()," - Num Rows in allOcc: ", nrow(allOcc))))
        
        # The millis version should require the least calculations when comparing timemillise
        epochOccs <- allOcc[((allOcc$timemillis >= epochMillisStart) && (allOcc$timemillis < epochMillisEnd)), ]
        
        docLenById <- array(epochOccs$tweetlen)
        rownames(docLenById) <- epochOccs$id
        occupiedEnv <- initOccupiedEnv(docLenById)
        rm(docLenById)
        
        uniqueNgrams <- unique(epochOccs$ngram)
    
        try(stop(paste(Sys.time()," - Fixing epoch:", epochMillisStart,"-",epochMillisEnd, "num occs:",nrow(epochOccs), "unique Ngrams: ", length(uniqueNgrams))))
        
        for(ngram in uniqueNgrams){
          ngramOccs <- epochOccs[which(epochOccs$ngram == ngram),]
          
          selOccs <- adply(ngramOccs,1,
              selectOccurrences,ngramlen2 = FSO.ngramlen2,occupiedEnv = occupiedEnv,allowOverlap = FALSE,
              colsToReturn=c("ngram","id","timemillis","date","ngramlen","tweetlen","pos"),
              .expand=F)
          selOccs$X1 <- NULL
          
          try(stop(paste(Sys.time()," - Writing file:", epochFile, "selected occs:",nrow(selOccs))))
          
          write.table(selOccs, file = epochFile, append = TRUE, quote = FALSE, sep = "\t",
              eol = "\n", na = "NA", dec = ".", row.names = FALSE,
              col.names = FALSE, # qmethod = c("escape", "double"),
              fileEncoding = "UTF-8")
        
        }
        
        rm(occupiedEnv)
      }
#  spillMerge <- function(toWrite) {
#  requires .inorder=FALSE,.multicombine=TRUE,.maxcombine=1 and I don't know if =1 makes any sense  
#  }


  epochFiles <- paste(seloccFile,"_",epochCutSec[2:25],".staging",sep="")
  
  catCmd <- paste("cat",paste(epochFiles,collapse=" "),">",seloccFile)
  try(stop(paste(Sys.time()," - Concatinating files using command:", catCmd)))
  
  system(catCmd,intern = FALSE)
  
  if(AUTO_REMOVE_STAGING){
    rmCmd <- paste("rm",paste(epochFiles,collapse=" "))
    try(stop(paste(Sys.time()," - Removing files using command:", rmCmd)))
    system(rmCmd,intern = FALSE)
  }
}


# dbDisFSO.connect(FSO.con, ...) closes the FSO.connection. Eg.
try(dbDisconnect(FSO.con))
# dbUnloadDriver(FSO.drv,...) frees all the resources used by the driver. Eg.
try(dbUnloadDriver(FSO.drv))
