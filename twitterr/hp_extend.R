HPD.DEBUG <- TRUE
HPD.TRACE <- TRUE

if(HPD.DEBUG){
  HPD.nCores <- 2
  HPD.days <- c(121105)
  HPD.db <- "sample-0.01"
#  HPD.dataRoot <- "/home/yaboulna/r_march_debug/"
} else {
  HPD.nCores <- 24
  HPD.days <- c(121105)
  HPD.db<-"full"
#  HPD.dataRoot <- "/home/yaboulna/r_march/"
}

HPD.epoch <- '1hr'
HPD.secsInEpoch <- 3600 # could be window

if(HPD.TRACE){
  day <- 121105
  epochstartux <-  1352109600 + (3600 * 10)
  len1 <- 1
  
#  HPD.dataRoot <- "~/r_march_debug/" #avoid /home/yaboulna(ga)
}
###################################

while(!require(foreach)){
  install.packages("foreach")
}
while(!require(doMC)){
  install.packages("doMC")
}
registerDoMC(cores=HPD.nCores)

while(!require(plyr)){
  install.packages("plyr")
}

source("yaboulna_utils.R")
##################################

createRes <- execSql("CREATE TABLE hgram_occ 
(id int8, timemillis int8, date int4, ngram text, ngramlen int2, tweetlen int2, pos int2)", HPD.db)

###################################
nullCombine <- function(a,b) NULL
for(day in HPD.days){   
#    HPD.dayDir <- paste(HPD.dataRoot,"hgram_occ",day, sep="/")
  dayHgramTable <- paste("hgram_occ",day,sep="_")
  execSql(sprintf("CREATE TABLE %s () INHERITS(hgram_occ)",dayHgramTable),HPD.db)
	for(len1 in c(1:4)){
#  HPD.lenDir <- paste(HPD.dayDir,"/",len1,"-",len1 + 1, sep="")
  
    HPD.label <- paste("HPD",len1,day,sep="_")
    
    FTX.parentHgramsTable <- paste("hgram_occ",day,len1+1, sep="_")
    execSql(sprintf("CREATE TABLE %s () INHERITS (%s)",FTX.parentHgramsTable, dayHgramTable),HPD.db)
    
    tryCatch({
       
        sec0CurrDay <-  as.numeric(as.POSIXct(strptime(paste(day,"0000",sep=""),
                    "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01"))
        
        foreach(epochstartux=seq(sec0CurrDay,sec0CurrDay+(3600*23),by=HPD.secsInEpoch),
                .inorder = FALSE, .combine = 'nullCombine') %dopar% 
            {
              FTX.day <- day
              FTX.epochstartux <-epochstartux
              FTX.len1 <- len1  
#              FTX.dayDir <- HPD.dayDir
              
              source("hp_do-extend-epoch.R")
              
              #FTX.extensible
              #FTX.len1OccsDf
              
              rm(FTX.extensible)
              rm(FTX.len1OccsDf)
            }
        
        
      },error=function(e) print(paste(Sys.time(),"HPD","Error for day",day,e,sep=" - ")), 
      finally=print(paste("HPD",FIM.label,"Day done:",day,sep=" - "))
      )
  
    # write to DB
    
    cntTableName <- sprintf("hgram_cnt_%s%d_%d",HPD.epoch,len1+1,day)
    sql <- sprintf("DROP TABLE IF EXISTS %s; CREATE TABLE %s AS 
SELECT %d as ngramlen, %d as date, CAST(floor(timemillis/(%d * 1000::INT8))*(%d * 1000::INT8) AS INT8) as epochstartux, 
ngram, CAST(count(*) AS INT4) as cnt 
from %s group by ngram,timemillis;",cntTableName,cntTableName,len1+1,day,
HPD.secsInEpoch,HPD.secsInEpoch,FTX.parentHgramsTable)

    execSql(sql,HPD.db)

    volTableName <- sprintf("hgram_vol_%s%d_%d",HPD.epoch,len1+1,day)
    sql <- sprintf("DROP TABLE IF EXISTS %s; CREATE TABLE %s AS 
SELECT %d as ngramlen, %d as date, epochstartux,sum(cnt) as totalcnt from %s group by epochstartux;",
volTableName,volTableName,len1+1,day,cntTableName)

    execSql(sql,HPD.db)
  }
}
