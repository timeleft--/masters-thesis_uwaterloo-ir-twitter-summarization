
HPD.DEBUG <- FALSE
HPD.TRACE <- FALSE

if(HPD.DEBUG){
	HPD.nCores <- 1
	HPD.days <- c(130104)
#  , 121101, 121102, 121103, 121104, 121105, 121106, 121107, 121108, 121109, 121110, 121111, 121112, 121113, 121114, 121115, 
#      120917, 120918, 120919, 120920, 120921, 120922, 120923, 120924, 120925, 120926, 120927, 120928, 120929, 120930, 
#      121001, 121002, 121003, 121004, 121005, 121006, 121007, 121008, 121009, 121010, 121011, 121012, 121013, 121014, 121015, 121016,
#      121017, 121018, 121019, 121020, 121021, 121022, 121023, 121024, 121025, 121026, 121027, 121028, 121029, 121030, 121031, 
#      121116, 121117, 121118, 121119, 121120, 121121, 121122, 121123, 121124, 121125, 121126, 121127, 121128, 121129, 121130, 
#      121201, 121202, 121203, 121204, 121205, 121206, 121207, 121208, 121209, 121210, 121211, 121212, 121213, 121214, 121215, 
#      121216, 121217, 121218, 121219, 121220, 121221, 121222, 121223, 121224, 121225, 121226, 121227, 121228, 121229, 121230, 121231, 130101, 130102, 130103)
	HPD.db<-"march"
#  HPD.dataRoot <- "/home/yaboulna/r_march_debug/"
} else {
  HPD.nCores <- 24
  HPD.days <- c(130104, 121101, 121102, 121103, 121104, 121105, 121106, 121107, 121108, 121109, 121110, 121111, 121112, 121113, 121114, 121115, 
      120917, 120918, 120919, 120920, 120921, 120922, 120923, 120924, 120925, 120926, 120927, 120928, 120929, 120930, 
      121001, 121002, 121003, 121004, 121005, 121006, 121007, 121008, 121009, 121010, 121011, 121012, 121013, 121014, 121015, 121016,
      121017, 121018, 121019, 121020, 121021, 121022, 121023, 121024, 121025, 121026, 121027, 121028, 121029, 121030, 121031, 
      121116, 121117, 121118, 121119, 121120, 121121, 121122, 121123, 121124, 121125, 121126, 121127, 121128, 121129, 121130, 
      121201, 121202, 121203, 121204, 121205, 121206, 121207, 121208, 121209, 121210, 121211, 121212, 121213, 121214, 121215, 
      121216, 121217, 121218, 121219, 121220, 121221, 121222, 121223, 121224, 121225, 121226, 121227, 121228, 121229, 121230, 121231, 130101, 130102, 130103)
  HPD.db<-"march"
#  HPD.dataRoot <- "/home/yaboulna/r_march/"
}

HPD.epoch <- '1hr'
HPD.secsInEpoch <- 3600 # could be window

if(HPD.TRACE){
  day <- 130104 # 121105
  epochstartux <-   1357293600 #1352109600 + (3600 * 10)
  len1 <- 2
  
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
for(len1 in c(2:5)){
#  HPD.lenDir <- paste(HPD.dayDir,"/",len1,"-",len1 + 1, sep="")
  if(len1==1){
    HPD.volumeAdjustmentFactor <- 1
  } else {
    sql <- sprintf("select avg(CAST(v2.totalcnt as float8)/v1.totalcnt) as volRedFactor 
      from %s v1 join %s v2 on v2.epochstartux = v1.%s;", ifelse(len1==2,paste("volume_",HPD.epoch,len1-1,sep=""),paste("hgram_vol_",HPD.epoch,len1-1,sep="")),
      paste("hgram_vol_",HPD.epoch,len1,sep=""),
      ifelse(len1==2,"epochstartmillis/1000","epochstartux"))
  
    annotPrint(paste("HPD",len1,sep="_"),"Getting volume adjustment factor by sql: \n",sql)
    HPD.drv <- dbDriver("PostgreSQL")
    HPD.con <- dbConnect(HPD.drv, dbname=HPD.db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
    HPD.volumeAdjustmentFactorRs <- dbSendQuery(HPD.con,sql)
    HPD.volumeAdjustmentFactorDf <- fetch(HPD.volumeAdjustmentFactorRs,n=-1)
	
    try(dbClearResult(HPD.volumeAdjustmentFactorRs))
	try(dbDisconnect(HPD.con))
	try(dbUnloadDriver(HPD.drv))
	
    HPD.volumeAdjustmentFactor <- HPD.volumeAdjustmentFactorDf[1,1]
    
    annotPrint(paste("HPD",len1,sep="_"),"Got volume adjustment factor. Nrow: ",nrow(HPD.volumeAdjustmentFactorDf),
        ". Factor:",HPD.volumeAdjustmentFactor)
  
  }
  
  for(day in HPD.days){   
#    HPD.dayDir <- paste(HPD.dataRoot,"hgram_occ",day, sep="/")
	dayHgramTable <- paste("hgram_occ",day,sep="_")
	if(len1==1){
      execSql(sprintf("CREATE TABLE %s () INHERITS(hgram_occ)",dayHgramTable),HPD.db)
    }
    HPD.label <- paste("HPD",len1,day,sep="_")
    
    daylenHgramsTable <- paste("hgram_occ",day,len1+1, sep="_")
    execSql(sprintf("CREATE TABLE %s () INHERITS (%s)",daylenHgramsTable, dayHgramTable),HPD.db)
    
#    if(len1==1) {
#      annotPrint( HPD.label, "Skipping filtering of occurrences, this shouldn't have suffered from the locks problem")
#    } else 
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
              FTX.db <- HPD.db      
              FTX.volumeAdjustmentFactor <- HPD.volumeAdjustmentFactor 
              FTX.parentHgramsTable <- daylenHgramsTable
              
              source("hp_do-extend-epoch.R",local = TRUE,echo = TRUE)
              
              
              #FTX.extensible
              #FTX.len1OccsDf
              
              try(rm(FTX.extensible))
              try(rm(FTX.len1OccsDf))
            },
            error=function(e) print(paste(Sys.time(),HPD.label,"Error for day-epoch",day,epochstartux,e,sep=" - ")), 
            finally={
              try(dbDisconnect(FTX.con))
              try(dbUnloadDriver(FTX.drv))
              
              print(paste("HPD","Day-epoch done:",day,epochstartux,sep=" - "))
              })
            
         }
        
        
      },error=function(e) print(paste(Sys.time(),HPD.label,"Error for day",day,e,sep=" - ")), 
      finally=print(paste(HPD.label,"Day done:",day,sep=" - "))
      
      )
  
    # write to DB

# What the hell was I doing.. first there was this group by timemillis now fixed to epochstartux
# and also there is an obvious bug below.. since the length is always len1+1 even though I don't 
# have a where ngramlen= len1+1

    # TODO: use the SQL in hgramcnt_fix-uniincludedinbi.txt to delete unis included in bi, and 
    # to inherit and create more indeces are required by inheritence
    cntTableNameDay <- sprintf("hgram_cnt_%s%d_%d",HPD.epoch,len1+1,day)
    cntTableNameParent <- sprintf("hgram_cnt_%s%d",HPD.epoch,len1+1)
    sql <- sprintf("CREATE TABLE %s (date integer, epochstartux bigint, ngram text, cnt integer, ngramlen int);",cntTableNameParent)
    execSql(sql,HPD.db)
    
    sql <- sprintf("
DROP TABLE IF EXISTS %s; 
CREATE TABLE %s AS 
SELECT %d as date, CAST(floor(timemillis/(%d * 1000::INT8))*(%d) AS INT8) as epochstartux, 
ngram, CAST(count(*) AS INT4) as cnt, array_length(string_to_array(ngram,','),1) as ngramlen 
from %s group by ngram,epochstartux; 
CREATE INDEX %s_time ON %s(epochstartux);
CREATE INDEX %s_date ON %s(date);
CREATE INDEX %s_ngramlen ON %s(ngramlen);
ALTER TABLE %s inherit %s;",cntTableNameDay,cntTableNameDay,day,
HPD.secsInEpoch,HPD.secsInEpoch,daylenHgramsTable,cntTableNameDay,cntTableNameDay,cntTableNameDay,cntTableNameDay,cntTableNameDay,cntTableNameDay,cntTableNameDay,cntTableNameParent)

# TODONE add create index to above SQL
    execSql(sql,HPD.db)

    volTableNameParent <- sprintf("hgram_vol_%s%d_%d",HPD.epoch,len1+1)
    sql <- sprintf("CREATE TABLE %s (date integer, epochstartux bigint, totalcnt bigint);",volTableNameParent)
    execSql(sql,HPD.db)
    
    volTableNameDay <- sprintf("hgram_vol_%s%d_%d",HPD.epoch,len1+1,day)
    sql <- sprintf("DROP TABLE IF EXISTS %s; CREATE TABLE %s AS 
SELECT  %d as date, epochstartux,sum(cnt) as totalcnt from %s group by epochstartux;
CREATE INDEX %s_time ON %s(epochstartux);CREATE INDEX %s_date ON %s(date);
ALTER TABLE %s inherit %s;",
volTableName,volTableName,day,cntTableName,volTableName,volTableName,volTableName,volTableName,
volTableNameDay,volTableNameParent)

    execSql(sql,HPD.db)
  }
}
