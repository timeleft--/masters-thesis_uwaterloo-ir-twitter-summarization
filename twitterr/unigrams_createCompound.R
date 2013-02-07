# TODO: Add comment
# 
# Author: yia
###############################################################################

G.epoch2 <- '1hr' 
G.ngramlen2 <- 2
G.support<-5

logLabel <- "unigrams_createCompound()" #Recall()???

REMOVE_EXITING_OUTPUTS<-FALSE

DEBUG_UGC <- TRUE

if(DEBUG_UGC){
  G.days<-c(121106,121110)
  G.nCores <- 2
  G.db <- "sample-0.01"
  
  ngramlen1<-1
  epoch1<-NULL
  
}else {
  G.days<-c(121110, 130103, 121016, 121206, 121210, 120925, 121223, 121205, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116, 121106, 121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219)
  G.db<-"full"
  G.nCores <- 50 #30
}


while(!require(foreach)){
  install.packages("foreach")
}
while(!require(doMC)){
  install.packages("doMC")
}
registerDoMC(cores=G.nCores)

while(!require(plyr)){
  install.packages("plyr")
}

while(!require(RPostgreSQL)){
  install.packages("RPostgreSQL")
} 

compoundUnigramsFromNgrams <- function(day, epoch2, ngramlen2, ngramlen1=1, epoch1=NULL,support=5,db=G.db){

  
  inTable <- paste('assoc',epoch2,ngramlen2,'_',day,sep="") 
  
  outTable <- paste('compound',epoch2,ngramlen2,'_',day,sep="") 
  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  if(dbExistsTable(con,outTable)){
    if(REMOVE_EXITING_OUTPUTS){
      dbRemoveTable(con,outTable)
      try(dbDisconnect(con))
      try(dbUnloadDriver(drv))
    } else {
      try(dbDisconnect(con))
      try(dbUnloadDriver(drv))
      stop(paste("Output table",outTable,"already exist. Please remove it yourself."))
    }
  }
  
  # opposite of what happens in conttable_construct
  if(is.null(epoch1)){
    epoch1<-epoch2
  }
  if(epoch1 == '1day' || epoch2 == '1day'){
    stop("Because we calculate the day base on GMT-10 and the epochstartmillis is at GMT, using day 
            epochs will result in more than one record per unigram, which is not the expected")
    #TODO: subtract 10 hours from epochstartmillis to align both timezones.. but is this right?
  }
  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
  try(stop(paste(Sys.time(), logLabel, " for day:", day, " - Connected to DB",db)))
  
  #* 1000 as epochstartmillis
  # For lineage:  "row.names", "X1" as hod,
  sql <- sprintf('select "row.names", epochstartux , "ngramAssoc.ngram" as ngram, 
							"ngramAssoc.a1b1" as cnt
							from %s where "ngramAssoc.yuleQ" > 0 order by epochstartux asc;', inTable)

  try(stop(paste(Sys.time(), logLabel, "for day:", day, " - Fetching ngrams' association using sql: ", sql)))        
      
  ngramRs <- dbSendQuery(con,sql)
  
  ngramDf <- fetch(ngramRs, n=-1)
  
  try(stop(paste(Sys.time(), logLabel, "for day:", day, " - Fetched ngrams' association length: ", length(ngramDf))))
  #cleanup
  # dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
  try(dbClearResult(ngramRs))

  #####################
  
  sql <- sprintf("select *
          from cnt_%s%d where date=%d and cnt > %d order by epochstartmillis asc;", epoch1, ngramlen1, day, support)
  
  try(stop(paste(Sys.time(), logLabel, "for day:", day, " - Fetching unigrams' cnts using sql:", sql)))
  
  ugramRs <- dbSendQuery(con,sql)
  #epochstartmillis asc, -> I had an idea but if I can't get it right.. screw it! I wanna finish my masters!
  #Test SQL: select epochstartmillis/1000 as epochstartux, ngramarr[1] as unigram, cnt as unigramcnt from cnt_1hr1 where date=121106 and cnt > 5 order by cnt desc;
  
  ugramDf <- fetch(ugramRs, n=-1)
  
  try(stop(paste(Sys.time(), logLabel, "for day:", day, " - Fetched unigrams' num rows:", length(ugramDf))))
  #cleanup
  # dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
  try(dbClearResult(ugramRs))
  
  #########################
  # dbDisconnect(con, ...) closes the connection. Eg.
  try(dbDisconnect(con))
  # dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
  try(dbUnloadDriver(drv))
  
  ########################
  
  epochGroupFun <- function(eg) {
    
    currEpochMillis <- eg[1,"epochstartux"] * 1000
    epochUnigrams <- ugramDf[ugramDf$epochstartmillis == (currEpochMillis),]
    
    ngramFun <- function(ng){
      ugramsInNgram <- unlist(strsplit(ng[1,"ngram"],","))
      
      #TODO Pure?
    
      for(u in 1:length(ugramsInNgram)){
        ugram <- ugramsInNgram[u]
        
        ugramIx <- which(epochUnigrams$ngramarr == paste("{",ugram,"}",sep=""))
        
        epochUnigrams[ugramIx,"cnt"] <- epochUnigrams[ugramIx, "cnt"] - ng[1,"cnt"]
      }
      
      return(data.frame(ngramlen=ngramlen2,
              ngramarr=paste("{",ng[1,"ngram"],"}",sep=""), 
              date=day,epochstartmillis=currEpochMillis,
              cnt=ng[1,"cnt"],lineage=ng[1,"row.names"]))
    } 
#    debug(ngramFun)
    
    epochCompound <- adply(idata.frame(eg),1,ngramFun,.expand=F) 
    epochCompound["X1"] <- NULL
    
    res <- rbind.fill(epochUnigrams, epochCompound)
    
    return(res)
  }
#  debug(epochGroupFun)
      
  combinedDf <- ddply(idata.frame(ngramDf),c("epochstartux"), epochGroupFun)
 
  
  try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Will write combinedDf to DB")))
  dbWriteTable(con,outTable,combinedDf)
  try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Finished writing to DB")))
  try(dbDisconnect(con))
  try(dbUnloadDriver(drv))
#  return (combinedDf) 

   return(paste("Success for day",day))
}

###############################
### Driver
##############################

nullCombine <- function(a,b) NULL
allMonthes <- foreach(day=G.days,
        .inorder=FALSE, .combine='nullCombine') %dopar%
    {
      daySuccess <- paste("Unkown result for day",day)
      
      tryCatch({
            
            daySuccess <<- compoundUnigramsFromNgrams(day, 
                epoch2 = G.epoch2, ngramlen2 = G.ngramlen2, support = G.support, db = G.db)
            
             
          }
          ,error=function(e) daySuccess <<- paste("Failure for day",day,e)
          ,finally=try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - ", daySuccess)))
      )
    }










