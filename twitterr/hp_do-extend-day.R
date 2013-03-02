HPD.DEBUG <- TRUE
HPD.TRACE <- TRUE

if(HPD.DEBUG){
  HPD.nCores <- 2
  HPD.days <- c(121105)
  HPD.db <- "sample-0.01"
  HPD.dataRoot <- "/home/yaboulna/r_march_debug/"
} else {
  HPD.nCores <- 24
  HPD.days <- c(121105)
  HPD.db<-"full"
  HPD.dataRoot <- "/home/yaboulna/r_march/"
}
HPD.secsInEpoch <- 3600 # could be window

if(HPD.TRACE){
  day <- 121105
  epochstartux <-  1352109600 + (3600 * 10)
  len1 <- 1
  
  HPD.dataRoot <- "~/r_march_debug/" #avoid /home/yaboulna(ga)
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

###################################
nullCombine <- function(a,b) NULL

for(len1 in c(1:4)){
  HPD.lenDir <- paste(HPD.dataRoot,"/ngram_occ_",len1,"-",len1 + 1, sep="")
  
  for(day in HPD.days){
    HPD.label <- paste("HPD",len1,day)
    
    HPD.dayDir <- paste(HPD.lenDir,day, sep="/")
    
    tryCatch({
       
        sec0CurrDay <-  as.numeric(as.POSIXct(strptime(paste(day,"0000",sep=""),
                    "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01"))
        
        foreach(epochstartux=seq(sec0CurrDay,sec0CurrDay+(3600*23),by=HPD.secsInEpoch),
                .inorder = FALSE, .combine = 'nullCombine') %dopar% 
            {
              FTX.day <- day
              FTX.epochstartux <-epochstartux
              FTX.len1 <- len1  
              FTX.dayDir <- HPD.dayDir
              
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
    cmd <- sprintf("cat %s/*.csv > %s.csv", HPD.dayDir, HPD.dayDir)
    annotPrint(HPD.label,cmd)
    execCmd(cmd)
    
    psql <- sptintf("psql -p 5433 -d %s -c \"%%s\"",HPD.db)
    
    sql <- sprintf("CREATE TABLE hgram_%d_%d_staging () inherits hgram_%d", len,day,len)
    cmd <- sprintf(psql,sql)
    annotPrint(HPD.label,cmd)
    execCmd(cmd)
    
    
    sql <- sprintf("COPY hgram_%d_%d_staging FROM '%s.csv'",len,day,len,HPD.dayDir)
    cmd <- sprintf(psq,sql)
    annotPrint(HPD.label,cmd)
    execCmd(cmd)
    
    sql <- sprintf("CREATE TABLE hgram_occ_%d_%d AS SELECT DISTINCT (ON id,pos) * FROM hgram_%d_%d_staging",len,day,len)
    cmd <- sprintf(psq,sql)
    annotPrint(HPD.label,cmd)
    execCmd(cmd)
    
    sql <- sprintf("CREATE TABLE hgram_cnt_%d_%d AS SELECT floor(timemillis/(%d * 1000::INT8))*(%d * 1000::INT8) as epochstartux, ngram, count(*) as cnt 
from hgram_occ_%d_%d group by ngram",len,day,HPD.secsInEpoch,HPD.secsInEpoch)
cmd <- sprintf(psq,sql)
annotPrint(HPD.label,cmd)
execCmd(cmd)

    sql <- sprintf("CREATE TABLE hgram_vol_%d_%d AS SELECT epochstartux,sum(cnt) as totalcnt from hgram_cnt_%d_%d group by epochstartux",
        len,day,len,day)
    cmd <- sprintf(psq,sql)
    annotPrint(HPD.label,cmd)
    execCmd(cmd)
  }
}
