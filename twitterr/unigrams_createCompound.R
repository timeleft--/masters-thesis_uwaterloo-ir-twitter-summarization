# TODO: Add comment
# 
# Author: yia
###############################################################################
G.outputPath <- "~/r_output/compound_unigrams/"
G.epoch2 <- '1hr' 
G.ngramlen2 <- 2
G.support<-5

logLabelUGC <- "unigrams_createCompound()" #Recall()???

REMOVE_EXITING_COMPGRAM_TABLES<-FALSE
SKIP_DAY_IF_COMPGRAM_FILE_EXISTS<-TRUE
DEBUG_UGC <- FALSE

if(DEBUG_UGC){
  G.days<-c(121106,121110)
  G.nCores <- 2
  G.db <- "sample-0.01"
  
  ngramlen1<-1
  epoch1<-NULL
  
  
  epoch2 <- G.epoch2  
  ngramlen2 <- G.ngramlen2
  support <- G.support
  
  day <- 121110
  db <- G.db
}else {
  G.days<-c(121223,120914)
      #c(121021,121229)
      #c(121110, 130103, 121016, 121206, 121210, 120925, 121223, 121205, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116, 121106, 121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219)
  G.db<-"full"
  G.nCores <- 30 # because we load ngram occs.. so this might be too much for mem.. better safe than sorry
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
  
  try(stop(paste(Sys.time(), logLabelUGC, " for day:", day, " - Connected to DB",db)))
  
  
  
  inTable <- paste('assoc',epoch2,ngramlen2,'_',day,sep="")
  
  if(!dbExistsTable(con,inTable)){
    stop(paste("Input table",inTable,"doesn't exist.. cannot process the day")) #skippinng the day 
  }
  
  outTable <- paste('compound',epoch2,ngramlen2,'_',day,sep="") 
  
  
  
  
  dayNgramOccPath <- paste(G.outputPath,day,".csv",sep="");
  if(file.exists(dayNgramOccPath)){
    
    if(SKIP_DAY_IF_COMPGRAM_FILE_EXISTS){
      if(dbExistsTable(con,outTable)){
        return(paste("Skipping day for which output exists:",day)) # This gets ignored somehow.. connect then the default "Success"
      }
    }
    
    bakname <- paste(dayNgramOccPath,"_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="")
    warning(paste("Renaming existing output file",dayNgramOccPath,bakname))
    file.rename(dayNgramOccPath, #from
        bakname) #to
  } else {
    
    if(!file.exists(G.outputPath))
       dir.create(G.outputPath,recursive = TRUE)
  }
  
  # create file to make sure this will be possible
  file.create(dayNgramOccPath)
  
  
  if(dbExistsTable(con,outTable)){
    if(REMOVE_EXITING_COMPGRAM_TABLES){
      stop(paste("Output table",outTable,"already exist. Removing it."))
      dbRemoveTable(con,outTable)
    } else {
      try(dbDisconnect(con))
      try(dbUnloadDriver(drv))
      stop(paste("Output table",outTable,"already exist. Please remove it yourself."))
    }
  }
  
  
  #* 1000 as epochstartmillis
  # For lineage:  "row.names", "X1" as hod, but Later
  # Sorting to make sure that the epochs are proccessed in order, because we get ngramOccs by index shifting   
  sql <- sprintf('select  epochstartux , "ngramAssoc.ngram" as ngram, 
							"ngramAssoc.a1b1" as cnt
							from %s where 
							"ngramAssoc.yuleQ" > 0 order by epochstartux asc;', inTable) ########## THIS LINE IS CRUCIAL FOR WHAT THIS FUNCTION DOES

  try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - Fetching ngrams' association using sql: ", sql)))        
      
  ngramRs <- dbSendQuery(con,sql)
  
  ngramDf <- fetch(ngramRs, n=-1)
  
  try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - Fetched ngrams' association length: ", nrow(ngramDf))))
  #cleanup
  # dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
  try(dbClearResult(ngramRs))

  #####################
  
   #We want all unigrams, not only those with high support.. or not! Screw the low support unigrams.. yaay!
  # Sorting is good if we'd use index to split: order by epochstartmillis asc 
  sql <- sprintf("select *
          from cnt_%s%d where date=%d  and cnt > %d ;", epoch1, ngramlen1, day, support)
  
  try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - Fetching unigrams' cnts using sql:", sql)))
  
  ugramRs <- dbSendQuery(con,sql)

  ugramDf <- fetch(ugramRs, n=-1)
  
  try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - Fetched unigrams' num rows:", nrow(ugramDf))))
  #cleanup
  # dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
  try(dbClearResult(ugramRs))
  
  
  ########################
  sec0CurrDay <-  as.numeric(as.POSIXct(strptime(paste(day,"0000",sep=""),
              "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01"))
  #a7'er elshahr ya me3allem
#  sec0NextDay <-  as.numeric(as.POSIXct(strptime(paste(day+1,"0000",sep=""),
#              "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01"))
  sec0NextDay <- sec0CurrDay + (60*60*24)
  
  sql <- sprintf("select epochstartmillis, totalcnt
          from volume_%s%d where epochstartmillis >= %.0f and epochstartmillis < %.0f;", epoch2, ngramlen2,
      (sec0CurrDay-(120*60)) * 1000, (sec0NextDay+(120*60)) * 1000) # add 2 hours to either side to avoid timezone shit
  
  try(stop(paste(Sys.time(),logLabelUGC, "for day:",day, " - Fetching ngram volumes using sql:\n ", sql)))
  
  ngramVolRs <- dbSendQuery(con, sql)
  
  ngramVolDf <- fetch(ngramVolRs, n=-1)
  
  try(stop(paste(Sys.time(),logLabelUGC, "for day:",day, " - Fetched ngram volumes. Num Rows: ", nrow(ngramVolDf))))
  
  try(dbClearResult(ngramVolRs))
  
  ############################ 
  # sorted because we'll use the volume to load the data for each epoch.. this is different from using indexes for
  # loading parts of the cnt tables, which proved tricky :(
  # cannot neglect any part of the data bceause we use vollume to skip ahead: and cnt > %d support
  sql <- sprintf("select * from ngrams%d where date=%d order by timemillis;",ngramlen2,day)
  
  try(stop(paste(Sys.time(),logLabelUGC, "for day:",day, " - Fetching ngram occurrences using sql:\n ", sql)))
  
  ngramOccRs <- dbSendQuery(con,sql)
  
#  ngramOccDf <- fetch(ngramOccRs, n=-1) # if ordered we can fetch them in chuncks
#  
#  try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - Fetched ngram occurrences. Num Rows: ", length(ngramOccDf))))
#  
#  try(dbClearResult(ngramOccRs))
  
  #########################
  
  epochGroupFun <- function(eg) {
    
    currEpochMillis <- eg[1,"epochstartux"] * 1000
    epochUnigrams <- ugramDf[ugramDf$epochstartmillis == (currEpochMillis),]
    
    epochNgramVol <- ngramVolDf[ngramVolDf$epochstartmillis == (currEpochMillis), "totalcnt"]
    
    epochNgramOccs <- fetch(ngramOccRs, n=epochNgramVol) # if ordered we can fetch them in chuncks
    
    try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - Fetched ngram occurrences for epoch",currEpochMillis,". Num Rows: ", nrow(epochNgramOccs))))
    
    if(DEBUG_UGC){
      earlierEpochCheck <- which(epochNgramOccs$timemillis < currEpochMillis)
      if(any(earlierEpochCheck)){
        warning("Some ngrams we are fetching are of an earlier epoch", paste(earlierEpochCheck,collapse = "|"))
      }
      rm(earlierEpochCheck)
      
      laterEpochCheck <- which(epochNgramOccs$timemillis >= (3600000 + currEpochMillis)) # THIS IS for 1hr epoch only
      if(any(laterEpochCheck)){
        warning("Some ngrams we are fetching are of a later epoch", paste(laterEpochCheck,collapse = "|"))
      }
      rm(laterEpochCheck)
    }
     
    ngramOccCopyMask <- c()
    
    ngramFun <- function(ng){
      ugramsInNgram <- unlist(strsplit(ng[1,"ngram"],"+")) #","))
      
      #TODO Pure?
    
    ######## Mark occurrences for copying
    
    ngramOccs <- which(epochNgramOccs$ngram == paste("(",ng[1,"ngram"],")",sep=""))
    
    if(DEBUG_UGC){
      if(length(ngramOccs) != ng[1,"cnt"]){
        try(stop(paste("ngramOccs retrieved:",length(ngramOccs),"not equal to the recorded count",ng[1,"cnt"])))
      }
    }
    
    ngramOccCopyMask <<- c(ngramOccCopyMask, ngramOccs)
    
    ######## Reduce counts
      for(u in 1:length(ugramsInNgram)){
        ugram <- ugramsInNgram[u]
        
        ugramIx <- which(epochUnigrams$ngramarr == paste("{",ugram,"}",sep=""))
        
        epochUnigrams[ugramIx,"cnt"] <- epochUnigrams[ugramIx, "cnt"] - ng[1,"cnt"]
      }
      
      return(data.frame(ngramlen=ngramlen2,
              ngramarr=paste("{",ng[1,"ngram"],"}",sep=""), 
              date=day,epochstartmillis=currEpochMillis,
              cnt=ng[1,"cnt"])) #, TODO: lineage=ng[1,"row.names"]))
    } 
    #debug(ngramFun)
    
    epochCompound <- adply(idata.frame(eg),1,ngramFun,.expand=F) 
    epochCompound["X1"] <- NULL
    
    #### Copy Ngram Occs
    write.table(epochNgramOccs[ngramOccCopyMask,], file = dayNgramOccPath, append = TRUE, quote = FALSE, sep = "\t",
        eol = "\n", na = "NA", dec = ".", row.names = FALSE,
        col.names = FALSE, # qmethod = c("escape", "double"),
        fileEncoding = "UTF-8")
    
    
    ######################
    ######Plotting (TODO: move from here)
    ######################
#    
#    epochUnigrams <- arrange(epochUnigrams, -cnt)
#    origUnigrams <- arrange(ugramDf[ugramDf$epochstartmillis == (currEpochMillis),"cnt"],-ct)
#  source("plot_unigramVsCompound_hist.R")
#  plotUnigramVsCompoundHistogram(combinedDf, ugramDf);

    
    ### END PLOTTING#######
    
    res <- rbind(epochUnigrams, epochCompound) #.fill -> destroys the ngramarr of epochCompound
    
    return(res)
  }
  #debug(epochGroupFun)
      
  combinedDf <- ddply(idata.frame(ngramDf),c("epochstartux"), epochGroupFun)
  

  ######## STORE IT #######
  
  try(stop(paste(Sys.time(), logLabelUGC, " for day:", day, " - Connected to DB",db)))
  
  try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Will write combinedDf to DB")))
  dbWriteTable(con,outTable,combinedDf)
  try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Finished writing to DB")))
  
  
  #########################
  #  
  try(dbClearResult(ngramOccRs))
  # dbDisconnect(con, ...) closes the connection. Eg.
  try(dbDisconnect(con))
  # dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
  try(dbUnloadDriver(drv))
  
  ########################
  
  
#  return (combinedDf) 

   return(paste("Success for day",day)) #Somehow this doesn't make it to the value of daySuccess, so it's duplicated below
}

###############################
### Driver
##############################

nullCombine <- function(a,b) NULL
allMonthes <- foreach(day=G.days,
        .inorder=FALSE, .combine='nullCombine') %dopar%
    {
      daySuccess <- paste("Success for day", day) #"Unkown result for day",day)
      
      tryCatch({
            
            daySuccess <<- compoundUnigramsFromNgrams(day, 
                epoch2 = G.epoch2, ngramlen2 = G.ngramlen2,  db = G.db, support = G.support)
             
          }
          ,error=function(e) daySuccess <<- paste("Failure for day",day,e)
          ,finally=try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - ", daySuccess)))
      )
    }










