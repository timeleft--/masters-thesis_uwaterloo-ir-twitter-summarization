
HPD.DEBUG <- FALSE
HPD.TRACE <- FALSE

if(HPD.DEBUG){
  HPD.nCores <- 1
  HPD.days <- c(121105,121106)
  HPD.db <- "sample-0.01"
#  HPD.dataRoot <- "/home/yaboulna/r_march_debug/"
} else {
  HPD.nCores <- 24
  HPD.days <- c(120917, 120918, 120919, 120920, 120921, 120922, 120923, 120924, 120925, 120926, 120927, 120928, 120929, 120930, 121001, 121002, 121003, 121004, 121005, 121006, 121007, 121008, 121009, 121010, 121011, 121012, 121013, 121014, 121015, 121016, 121017, 121018, 121019, 121020, 121021, 121022, 121023, 121024, 121025, 121026, 121027, 121028, 121029, 121030, 121031, 121101, 121102, 121103, 121104, 121105, 121106, 121107, 121108, 121109, 121110, 121111, 121112, 121113, 121114, 121115, 121116, 121117, 121118, 121119, 121120, 121121, 121122, 121123, 121124, 121125, 121126, 121127, 121128, 121129, 121130, 121201, 121202, 121203, 121204, 121205, 121206, 121207, 121208, 121209, 121210, 121211, 121212, 121213, 121214, 121215, 121216, 121217, 121218, 121219, 121220, 121221, 121222, 121223, 121224, 121225, 121226, 121227, 121228, 121229, 121230, 121231, 130101, 130102, 130103, 130104)
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

while(!require(RPostgreSQL)){
  install.packages("RPostgreSQL")
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
    
    daylenHgramsTable <- paste("hgram_occ",day,len1+1, sep="_")
    execSql(sprintf("CREATE TABLE %s () INHERITS (%s)",daylenHgramsTable, dayHgramTable),HPD.db)
    
    tryCatch({
       
        sec0CurrDay <-  as.numeric(as.POSIXct(strptime(paste(day,"0000",sep=""),
                    "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01"))
        
        foreach(epochstartux=seq(sec0CurrDay,sec0CurrDay+(3600*23),by=HPD.secsInEpoch),
                .inorder = FALSE, .combine = 'nullCombine') %dopar% 
         {
            FTX.drv <- dbDriver("PostgreSQL")
            FTX.con <- dbConnect(FTX.drv, dbname=HPD.db, user="yaboulna", password="5#afraPG",
               host="hops.cs.uwaterloo.ca", port="5433")
            
           tryCatch({
              FTX.day <- day
              FTX.epochstartux <-epochstartux
              FTX.len1 <- len1  
#              FTX.dayDir <- HPD.dayDir
                      
              
              FTX.parentHgramsTable <- daylenHgramsTable
              
              source("hp_do-extend-epoch.R",local = TRUE,echo = TRUE)
              
              
              #FTX.extensible
              #FTX.len1OccsDf
              
              try(rm(FTX.extensible))
              try(rm(FTX.len1OccsDf))
            },
            error=function(e) print(paste(Sys.time(),HPD.label,"Error for day-epoch",day,epoch,e,sep=" - ")), 
            finally={
              try(dbDisconnect(FTX.con))
              try(dbUnloadDriver(FTX.drv))
              
              print(paste("HPD","Day-epoch done:",day,epoch,sep=" - "))
              })
            
         }
        
        
      },error=function(e) print(paste(Sys.time(),HPD.label,"Error for day",day,e,sep=" - ")), 
      finally=print(paste(HPD.label,"Day done:",day,sep=" - "))
      
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
SELECT %d as ngramlen, %d as date, (epochstartux * 1000::INT8) as epochstartmillis,sum(cnt) as totalcnt from %s group by epochstartux;",
volTableName,volTableName,len1+1,day,cntTableName)

    execSql(sql,HPD.db)
  }
}
