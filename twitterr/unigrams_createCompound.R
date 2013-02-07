# TODO: Add comment
# 
# Author: yia
###############################################################################

db <- "sample-0.01"
logLabel <- "unigrams_compound_merge()" #Recall()???
epoch2 <- '1hr' 
ngramlen2 <- 2

DEBUG_UGC <- TRUE
if(DEBUG_UGC){
day<-121110
ngramlen1<-1
epoch1<-NULL
support<-5
}


while(!require(plyr)){
  install.packages("plyr")
}

while(!require(RPostgreSQL)){
  install.packages("RPostgreSQL")
} 

compoundUnigramsFromNgrams <- function(day, epoch2, ngramlen2, ngramlen1=1, epoch1=NULL,support=5){

  
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
  
  tableName <- paste('assoc',epoch2,ngramlen2,'_',day,sep="")
  #* 1000 as epochstartmillis
  # For lineage:  "row.names", "X1" as hod,
  sql <- sprintf('select "row.names", epochstartux , "ngramAssoc.ngram" as ngram, 
							"ngramAssoc.a1b1" as cnt
							from %s where "ngramAssoc.yuleQ" > 0 order by epochstartux asc;', tableName)

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
 
  return (combinedDf)
# Trying to avoid copying, but I found that I'll end up copying the whole DF in and out of rbind  
# Can I use bigmemory's pointers to avoid copying??
#  currTime <- NULL
#  epochUnigrams <- NULL
#  compoundGrams <- data.frame(stringsAsFactors = F) 
#  
#  reduceCompsCnt <- function(ng){
#    
#    if(!identical(ng[1,"epochstartmillis"],currTime)){
#      currTime <<- ng[1,"epochstartmillis"]
#      # TODO I won't try to get the idea of shifting start index to work.. I already tried, and there's something tricky 
#      epochUnigrams <<- ugramDf[ugramDf$epochstartmillis == currTime,]
#    }
#    ugramsInNgram <- unlist(strsplit(ng[1,"ngram"],","))
#    
#    #TODO Pure?
#  
#    for(u in 1:length(ugramsInNgram)){
#      ugram <- ugramsInNgram[u]
#      
#      ugramIx <- which(epochUnigrams$ngram == ugram)
#      epochUnigrams[ugramIx,"cnt"] <- epochUnigrams[ugramIx, "cnt"] - ng[1,"cnt"]
#    }
#    
#    compoundGrams <<- rbind(compoundGrams, )
#  }
#  a_ply(idata.frame(ngramDf, 1, reduceCompsCnt, .expand=F)
  
}