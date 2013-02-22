# TODO: Add comment
# 
# Author: yia
###############################################################################

CGC.argv <- commandArgs(trailingOnly = TRUE)
G.ngramlen1 <- as.integer(CGC.argv[1])
#G.ngramlen2 <- G.ngramlen1 + 1


G.epoch2 <- '1hr'
G.support<-5

logLabelUGC <- "unigrams_createCompound()" #Recall()???

REMOVE_EXITING_COMPGRAM_TABLES<-TRUE
#SKIP_DAY_IF_COMPGRAM_FILE_EXISTS<-FALSE
DEBUG_UGC <- FALSE
UGC.TRACE <- FALSE

if(DEBUG_UGC){
  G.days<-c(121106,121110)
  G.nCores <- 2
  G.db <- "sample-0.01"

  CGC.dataRoot <- "~/r_output_debug/"
  
#  workingRoot="~/r_output_debug/occ_yuleq_working/"
#  dataRoot="~/r_output_debug/"
#  
  G.ngramlen1 <- 1
#G.ngramlen2 <- G.ngramlen1 + 1
  if(UGC.TRACE){
    ngramlen1<-G.ngramlen1
    epoch1<-NULL
    epoch2 <- G.epoch2  
  #  ngramlen2 <- G.ngramlen2
    support <- G.support
    
    day <- 121106
    db <- G.db
  }
}else {
  
  G.days <- unique(c( 120925,  120926,  120930,  121008,  121013,  121016,  121026,  121027,  121028,  121029,  121030,  121103,  121104,  121105,  121106,  121108,  121110,  121116,  121119,  121120,  121122,  121123,  121125,  121205,  121206,  121210,  121214,  121215,  121231,  130103,  130104)) #missing data: 120914,121222,  121223, 
      
      #c(121223,120914)
      #c(121021,121229)
      #c(121110, 130103, 121016, 121206, 121210, 120925, 121223, 121205, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116, 121106, 121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219)
  G.db<-"full"
  G.nCores <- min(50, length(G.days)) # because we load ngram occs.. so this might be too much for mem.. better safe than sorry
  
  CGC.dataRoot <- "~/r_output/"
 
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

source("compgrams_utils.R")

compoundUnigramsFromNgrams <- function(day, epoch2,  ngramlen1=1, epoch1=NULL,support=5,db=G.db){
#    workingRoot=G.workingRoot,dataRoot=G.dataRoot

  #can't be changed
  ngramlen2 <- ngramlen1 + 1
  
  # opposite of what happens in conttable_construct
  if(is.null(epoch1)){
    epoch1<-epoch2
  }
  if(epoch1 == '1day' || epoch2 == '1day'){
    stop("Because we calculate the day base on GMT-10 and the epochstartmillis is at GMT, using day 
            epochs will result in more than one record per unigram, which is not the expected")
    #TODO: subtract 10 hours from epochstartmillis to align both timezones.. but is this right?
  }
  
#  occCntFile <- paste(CGC.dataRoot,"/occ_yuleq_",ngramlen2,"/cnt_",day,".csv",sep="")
#  if(!file.exists(occCntFile)){
#    stop(pate(Sys.time(), logLabelUGC, " for day:", day, " - Cannot process day because counts file not found:",occCntFile))  
#  }
  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
  try(stop(paste(Sys.time(), logLabelUGC, " for day:", day, " - Connected to DB",db)))
  
  
  
  
#  stagingDir <- workingRoot
#  if(!file.exists(stagingDir))
#    dir.create(stagingDir,recursive = T)
#  
#  stagingFile <- paste(stagingDir,"/",day,".csv",sep="")
#  file.create(stagingFile) #create or truncate
#  
#  outputDir <- paste(dataRoot,"/occ_yuleq_",ngramlen2,"/",sep="")
#  
#  outputFile <- paste(outputDir,day,".csv",sep="");
#  
#  if(file.exists(outputFile)){
#    
#    if(SKIP_DAY_IF_COMPGRAM_FILE_EXISTS){
#      if(dbExistsTable(con,outTable)){
#        return(paste("Skipping day for which output exists:",day)) # This gets ignored somehow.. connect then the default "Success"
#      }
#    }
#    
#    bakname <- paste(outputFile,"_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="")
#    warning(paste("Renaming existing output file",outputFile,bakname))
#    file.rename(outputFile, #from
#        bakname) #to
#  } else {
#    
#    if(!file.exists(outputDir))
#       dir.create(outputDir,recursive = TRUE)
#  }
#  
##  # create file to make sure this will be possible
##  file.create(outputFile)
##  
  outTable <- paste('compcnt_',epoch2,ngramlen2,'_',day,sep="") 

  if(dbExistsTable(con,outTable)){
    if(REMOVE_EXITING_COMPGRAM_TABLES){
      try(stop(paste("Output table",outTable,"already exist. Removing it.")))
      dbRemoveTable(con,outTable)
    } else {
      try(dbDisconnect(con))
      try(dbUnloadDriver(drv))
      stop(paste("Output table",outTable,"already exist. Please remove it yourself."))
    }
  }
 
  
  #  inTable <- paste('assoc',epoch2,ngramlen2,'_',day,sep="")
#  
#  if(!dbExistsTable(con,inTable)){
#    stop(paste("Input table",inTable,"doesn't exist.. cannot process the day")) #skippinng the day 
#  }
#  #* 1000 as epochstartmillis
#  # For lineage:  "row.names", "X1" as hod, but Later
#  # Sorting to make sure that the epochs are proccessed in order, because we get ngramOccs by index shifting   
#  sql <- sprintf('select  epochstartux , "ngramAssoc.ngram" as ngram, 
#							"ngramAssoc.a1b1" as cnt
#							from %s where 
#							"ngramAssoc.yuleQ" > 0 order by epochstartux asc;', inTable) ########## THIS LINE IS CRUCIAL FOR WHAT THIS FUNCTION DOES
#
#  try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - Fetching ngrams' association using sql: ", sql)))        
#      
#  ngramRs <- dbSendQuery(con,sql)
#  
#  ngramDf <- fetch(ngramRs, n=-1)
#  
#  try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - Fetched ngrams' association length: ", nrow(ngramDf))))
#  #cleanup
#  # dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
#  try(dbClearResult(ngramRs))

#ngramDf <- read.table(occCntFile, header = FALSE, quote = "", comment.char="", 
#    sep = "\t", na = "NA", dec = ".", row.names = NULL,
#    col.names = c("ngram","cnt","epochstartux","date","ngramlen"),
#    colClasses = c("character","integer","numeric","integer","integer"),
#    fileEncoding = "UTF-8")

  occTable <- paste("occ",ngramlen2,day,sep="_")
  if(!dbExistsTable(con,occTable)){
    stop(paste("Occurrences table",occTable,"doesn't exist.. cannot process the day"))
  }

  SEC_IN_EPOCH <- c(X5min=(60*5), X1hr=(60*60), X1day=(24*60*60)) 
  MILLIS_IN_EPOCH <- SEC_IN_EPOCH * 1000
  
  # 1) where date=%d <- they will be already partitioned
  # 2) where cnt > support <- since the candidates for which yuleq was calculated orignally had high support, then no
  #  low support compgram can make it to the positive yuleQ pool   
  sql <-  sprintf("select floor(timemillis/%d)*%d as epochstartux, compgram as ngram, count(*) as cnt from %s group by epochstartux,compgram;",
      MILLIS_IN_EPOCH[[paste("X",epoch2,sep="")]],SEC_IN_EPOCH[[paste("X",epoch2,sep="")]],occTable,day)

  try(stop(paste(Sys.time(), logLabelUGC, paste("Fetching  compound-grams epoch counts - sql:\n", sql), sep=" - ")))
  
  ngramRs <- dbSendQuery(con,sql)
  ngramDf <- fetch(ngramRs,n=-1)
  
  try(dbClearResult(ngramRs))
  
  try(stop(paste(Sys.time(), logLabelUGC, paste("Fetched  compound-grams epoch counts - nrows:", nrow(ngramDf)), sep=" - ")))

  #####################
# I think it's good that we don't filter with support when choosing unigrams, because this will lead to errors that 
# the unigram cannot be found... the logic below is actualy flawed since the compcnt table includes counts for
# compgrams up to length l.. which includes the unigrams whcih are used blindly to extend compgrams. Exceptionally
# when the cnts come from cnt_XX1 the support is important because .. hold on... 

#THE ABOVE AND THE BELOW ARE BOTH FLAWED: we check for the support when selecting the extended candidates for which we want to 
# calculate association in conttable_construct.. thus no compgram would make it to the yuleq selection unless it
# oringially had support high enough... that is, checking for support here woulndn't have any effect at all 

#   #We write counts of compgrams with high support only.. because those counts will be used for calculating the
#  # association of bigrams with high support. That is, if a compgram doesn't have high support it can't be part of
#  # such a bigram when conttable_construct is fetching candidates. This however doesn't make it unnecssary to check for
#  # cnt > support when fetching candidates, because extending them reduces their support (in table cnt_ not compcnt_)
#  # Sorting is good if we'd use index to split: order by epochstartmillis asc
  if(ngramlen1==1){
    sql <- sprintf("select ngramlen, ngramarr, date, epochstartmillis/1000 as epochstartux, cnt 
          from cnt_%s%d%s where date=%d and cnt > %d;", epoch1, ngramlen1, ifelse(ngramlen2<3,'',paste("_",day, sep="")), day, support)
  } else {
    sql <- sprintf("select ngramlen, ngramarr, date, epochstartmillis/1000 as epochstartux, cnt
					from compcnt_%s%d_%d;", epoch1, ngramlen1, day) #  where cnt > %d, support)
  }
  try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - Fetching unigrams' cnts using sql:", sql)))
  
  ugramRs <- dbSendQuery(con,sql)

  ugramDf <- fetch(ugramRs, n=-1)
  
  try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - Fetched unigrams' num rows:", nrow(ugramDf))))
  #cleanup
  # dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
  try(dbClearResult(ugramRs))
#  
#  
##  ########################
##  sec0CurrDay <-  as.numeric(as.POSIXct(strptime(paste(day,"0000",sep=""),
##              "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01"))
##  #a7'er elshahr ya me3allem
###  sec0NextDay <-  as.numeric(as.POSIXct(strptime(paste(day+1,"0000",sep=""),
###              "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01"))
##  sec0NextDay <- sec0CurrDay + (60*60*24)
##  
##  sql <- sprintf("select epochstartmillis, totalcnt
##          from volume_%s%d%s where epochstartmillis >= %.0f and epochstartmillis < %.0f;", epoch2, ngramlen2, ifelse(ngramlen2<3,'',paste("_",day, sep="")),
##      (sec0CurrDay-(120*60)) * 1000, (sec0NextDay+(120*60)) * 1000) # add 2 hours to either side to avoid timezone shit
##  
##  try(stop(paste(Sys.time(),logLabelUGC, "for day:",day, " - Fetching ngram volumes using sql:\n ", sql)))
##  
##  ngramVolRs <- dbSendQuery(con, sql)
##  
##  ngramVolDf <- fetch(ngramVolRs, n=-1)
##  
##  try(stop(paste(Sys.time(),logLabelUGC, "for day:",day, " - Fetched ngram volumes. Num Rows: ", nrow(ngramVolDf))))
##  
##  try(dbClearResult(ngramVolRs))
##  
##  ############################ 
##  # sorted because we'll use the volume to load the data for each epoch.. this is different from using indexes for
##  # loading parts of the cnt tables, which proved tricky :(
##  # cannot neglect any part of the data bceause we use vollume to skip ahead: and cnt > %d support
## 
##  if(ngramlen2 == 2){
##	  sql <- sprintf("select * from ngrams%d where date=%d order by timemillis;",ngramlen2,day)
##  } else {
##    sql <- sprintf("select * from compgrams%d_%d order by timemillis;",ngramlen2,day)    
##  }
##  
##  try(stop(paste(Sys.time(),logLabelUGC, "for day:",day, " - Fetching ngram occurrences using sql:\n ", sql)))
##  
##  ngramOccRs <- dbSendQuery(con,sql)
##  
###  ngramOccDf <- fetch(ngramOccRs, n=-1) # if ordered we can fetch them in chuncks
###  
###  try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - Fetched ngram occurrences. Num Rows: ", length(ngramOccDf))))
###  
###  try(dbClearResult(ngramOccRs))
##  
##  #########################
##  
#
#  if(ngramlen2 == 2){
#    sqlTemplate <- sprintf("select * from ngrams%d where date=%d where timemillis >= (%%.0f * 1000::INT8) and timemillis < (%%.0f * 10000::INT8) order by timemillis;",ngramlen2,day)
#  } else {
#    sqlTemplate <- sprintf("select * from compgrams%d_%d where timemillis >= (%%.0f * 1000::INT8) and timemillis < (%%.0f * 1000::INT8) order by timemillis;",ngramlen2,day)    
#  }
#
#  SEC_IN_EPOCH <- c(X5min=(60*5), X1hr=(60*60), X1day=(24*60*60)) 
#  
#  flattenNgram <- function(ngram){
#    paste("{",paste(splitNgramToCompgrams(ngram,ngramlen2),collapse=","),"}",sep="")
#  } 

# dbDisconnect(con, ...) closes the connection. Eg.
try(dbDisconnect(con))
# dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
try(dbUnloadDriver(drv))

  epochGroupFun <- function(eg) {
    
    epochstartux <- eg[1,"epochstartux"] #stay away from large numbers * 1000
    epochUnigrams <- ugramDf[ugramDf$epochstartux == (epochstartux),]
    
##    epochNgramVol <- ngramVolDf[ngramVolDf$epochstartux == (epochstartux), "totalcnt"]
##    
##    epochNgramOccs <- fetch(ngramOccRs, n=epochNgramVol) # if ordered we can fetch them in chuncks
#    
#    sql <- sprintf(sqlTemplate,
#         epochstartux, (epochstartux + SEC_IN_EPOCH[[paste("X",epoch2,sep="")]]))
#  
#    try(stop(paste(Sys.time(),logLabelUGC, "for day:",day, " - Fetching ngram occurrences for epoch using sql:\n ", sql)))
#  
#    epochNgramOccRs <- dbSendQuery(con,sql)
#    epochNgramOccs <- fetch(epochNgramOccRs, n=-1)
#    try(dbClearResult(epochNgramOccRs))
#  
#    try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - Fetched ngram occurrences for epoch",epochstartux,". Num Rows: ", nrow(epochNgramOccs))))
#    
#    # epochNgramOccs will be in the uni+(ngA,ngB,..) remove the paranthesis and convert plus to ,
#    # The we need to remove duplicates
#    if(ngramlen2>3){
#      epochNgramOccs <- within(epochNgramOccs,{
#          # This doesn't have any effect... the encoding remains "unkown" Encoding(ngram) <- "UTF-8"
#          #FIXME: Any non-latin character gets messed up here.. that's a big bummer for R; the second!
#          ngram <-  sub('{','"{',ngram,fixed=TRUE)
#          ngram <-  sub('}','}"',ngram,fixed=TRUE)
#          ngram <-  sub('+',',',ngram,fixed=TRUE)
#        })
#    } else {
#      epochNgramOccs <- within(epochNgramOccs,{
#            # This doesn't have any effect... the encoding remains "unkown" Encoding(ngram) <- "UTF-8"
#            #FIXME: Any non-latin character gets messed up here.. that's a big bummer for R; the second!
#            ngram <-  sub('(','"(',ngram,fixed=TRUE)
#            ngram <-  sub(')',')"',ngram,fixed=TRUE)
#            ngram <-  sub('+',',',ngram,fixed=TRUE)
#          })
#    }
#    if(DEBUG_UGC){
#      earlierEpochCheck <- which(epochNgramOccs$timemillis / 1000 < epochstartux)
#      if(any(earlierEpochCheck)){
#        warning("Some ngrams we are fetching are of an earlier epoch", paste(earlierEpochCheck,collapse = "|"))
#      }
#      rm(earlierEpochCheck)
#      
#      laterEpochCheck <- which(epochNgramOccs$timemillis / 1000 >= (3600 + epochstartux)) # THIS IS for 1hr epoch only
#      if(any(laterEpochCheck)){
#        warning("Some ngrams we are fetching are of a later epoch", paste(laterEpochCheck,collapse = "|"))
#      }
#      rm(laterEpochCheck)
#    }
#     
#    ngramOccCopyMask <- c()
#    
    ngramFun <- function(ng){
      
#      ######## Mark occurrences for copying
#      if(ngramlen2<3){
#        ngramOccs <- which(epochNgramOccs$ngram == paste("(",ng[1,"ngram"],")",sep=""))
#      } else {
#        ngramOccs <- which(epochNgramOccs$ngram == ng[1,"ngram"])
#      }
#      if(DEBUG_UGC){
#        if(length(ngramOccs) != ng[1,"cnt"]){
#          try(stop(paste(ng[1,"ngram"],"ngram Occs retrieved:",length(ngramOccs),"not equal to the recorded count:",
#                      ng[1,"cnt"])))
#        }
#      }
#      
#      ngramOccCopyMask <<- c(ngramOccCopyMask, ngramOccs)
#      
      ###### Reduce counts
      
#      ugramsInNgram <- splitNgramToCompgrams(ng[1,"ngram"],ngramlen2) 
      ugramsInNgram <- unlist(strsplit(stripEndChars(ng[1,"ngram"]), ",",fixed = TRUE))
      #TODO Pure?
      for(u in 1:length(ugramsInNgram)){
        ugram <- ugramsInNgram[u]
        
        srchStr <- paste("{",ugram,"}",sep="")
        
        ugramIx <- which(epochUnigrams$ngramarr == srchStr)
        
        if(is.null(ugramIx)){ # I trust my earlier debugging, even though I'd say this should be is.an or == 0
          try(stop(paste(Sys.time(), logLabelUGC, "for day:", day, " - WARNING: couldn't find index for component in compgrams cnt DF when trying to deduct the count of ngram",ng[1,"ngram"],"from its component",ugram)))
          next
        }
        #No problem because of overlapping "(i,love)",u and i,"(love,u)" since their components will be
        # different compgrams from the begining so the cnt will be reduced once from each component
        epochUnigrams[ugramIx,"cnt"] <- epochUnigrams[ugramIx, "cnt"] - ng[1,"cnt"]
      }
      
      epochUnigrams <<- epochUnigrams
      
      return(data.frame(ngramlen=ngramlen2,
              ngramarr=paste("{",paste(ugramsInNgram,collapse=","),"}",sep=""), 
              date=day,#epochstartux=epochstartux,
              cnt=ng[1,"cnt"])) #, TODO: lineage=ng[1,"row.names"]))
    } 
#    debug(ngramFun)
    
    epochCompound <- adply(idata.frame(eg),1,ngramFun,.expand=F) 
    epochCompound["X1"] <- NULL
    
    #
#    ngramOccCopy <- epochNgramOccs[ngramOccCopyMask,]
    if(ngramlen2>2){

      #The returned compgrams is now flattened so that (i,love),u and i,(love,u) become i,love,u 
      # so all the different ways it got composed should be mapped to one row with one of their counts
      # (all counts should be the same because the YuleQ is calculated per epoch) 
      epochCompound <- epochCompound[!duplicated(epochCompound["ngramarr"]),]
#      
#      ngramOccCopy$ngram <- aaply(ngramOccCopy$ngram,1,flattenNgram)
#
#      #same idea for occurrences, but this time per tweet
#      ngramOccCopy <- ngramOccCopy[!duplicated(ngramOccCopy["id","ngram"]),]    
    } 
    
    
#    #### Copy Ngram Occs
#    write.table(ngramOccCopy, file = stagingFile, append = TRUE, quote = FALSE, sep = "\t",
#        eol = "\n", na = "NA", dec = ".", row.names = FALSE,
#        col.names = FALSE, # qmethod = c("escape", "double"),
#        fileEncoding = "UTF-8")
#    
    
    ######################
    ######Plotting (TODO: move from here)
    ######################
#    
#    epochUnigrams <- arrange(epochUnigrams, -cnt)
#    origUnigrams <- arrange(ugramDf[ugramDf$epochstartmillis == (epochstartux),"cnt"],-ct)
#  source("plot_unigramVsCompound_hist.R")
#  plotUnigramVsCompoundHistogram(combinedDf, ugramDf);

    
    ### END PLOTTING#######
    epochUnigrams$epochstartux <- NULL # Will be added by ddply
    res <- rbind(epochUnigrams, epochCompound) #.fill -> destroys the ngramarr of epochCompound
    
    return(res)
  }
#  debug(epochGroupFun)
      
  combinedDf <- ddply(idata.frame(ngramDf),c("epochstartux"), epochGroupFun)
  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
  ######## STORE IT #######
  try(stop(paste(Sys.time(), logLabelUGC, " for day:", day, " - Connected to DB",db)))
  
  try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Will write combinedDf to DB:",outTable)))
  dbWriteTable(con,outTable,combinedDf)
  try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Finished writing to DB")))
  
#  file.rename(stagingFile, outputFile)
  
  #########################
  #  
#  try(dbClearResult(ngramOccRs))
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
      daySuccess <- paste("Unkown result for day",day)
      
      tryCatch({
            
            compoundUnigramsFromNgrams(day, 
                epoch2 = G.epoch2, ngramlen1 = G.ngramlen1,  db = G.db, support = G.support)
            daySuccess <<- paste("Success for day", day)
          }
          ,error=function(e) daySuccess <<- paste("Failure for day",day,e)
          ,finally=try(stop(paste(Sys.time(), logLabelUGC ,"for day:", day, " - ", daySuccess)))
      )
    }










