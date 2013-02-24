
# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

MILLIS_PUT_1000 <- 1

kTS <- "epochstartux"
TOTAL <- "TOTAL"

EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1 <- TRUE

DEBUG_CTC <- FALSE
CTC.TRACE <- FALSE
#options(error=utils::recover) 
#For debug
if(DEBUG_CTC){
  if(CTC.TRACE){
    day<-121106
    epoch1<-'1hr'
    ngramlen1<-1
    ngramlen2<-ngramlen1+1
    support<-5
    epoch2<-NULL
    db<-"sample-0.01"
    alignEpochs<-FALSE
    appendPosixTime<-FALSE
    withTotal<-TRUE
    #parallel<-FALSE
    parOpts <- "cores=2"
    progress<-"none" #text isn't good with parallel
  }  
}

while(!require(plyr)){
  install.packages("plyr")
}
while(!require(Matrix)){
  install.packages("Matrix")
}


########################################################

source("compgrams_utils.R")

##########################################################
# Makes sure all epochs are the same length
# TODO: Right now only epochs that are missing in the middle are solved, we should consider
# passing an expected epoch start and end times and pre/ap-pend NAs accordingly
SEC_IN_EPOCH <- c(X5min=(60*5), X1hr=(60*60), X1day=(24*60*60)) 
align_epochs <- function(dframe, epoch) {
  ############### Fill the gaps in the data with filling to make sure epochs are fixed ###############
  kEpochLenTemp <- SEC_IN_EPOCH[[paste("X",epoch,sep="")]]
  for(i in rev(which(diff(dframe[[kTS]]) !=  kEpochLenTemp))){
    numMissingEpochs <- (floor( (dframe[[kTS]][i+1] - dframe[[kTS]][i]) / kEpochLenTemp) - 1)
    missingEpochs <- data.frame(c(dframe[[kTS]][i] + ( seq( 1: numMissingEpochs) * kEpochLenTemp)))
    names(missingEpochs) <- c(kTS)
    
    
    dframe <- rbind.fill(dframe[1:i, ], 
        missingEpochs,
        dframe[(i+1):nrow(dframe), ])
  }
  return(dframe);
}
#debug(align_epochs)


#####################################3
toPosixTime <- function(timestamp){
  return(as.POSIXct(timestamp/MILLIS_PUT_1000,origin="1970-01-01", tz="GMT"))
}


############################################
conttable_construct <- function(day, epoch1='1hr', ngramlen2=2, epoch2=NULL, ngramlen1=1, support=5,
  db="sample-0.01", alignEpochs=FALSE, appendPosixTime=FALSE,
  withTotal=TRUE) { #, parallel=FALSE, parOpts="cores=24", progress="none") {
  
  if(is.null(epoch2)){
    epoch2<-epoch1
  }
  if(epoch1 == '1day' || epoch2 == '1day'){
    stop("Because we calculate the day base on GMT-10 and the epochstartmillis is at GMT, using day 
        epochs will result in more than one record per unigram, which is not the expected")
    #TODO: subtract 10 hours from epochstartmillis to align both timezones.. but is this right?
  }
  while(!require(RPostgreSQL)){
    install.packages("RPostgreSQL")
  }  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
  try(stop(paste(Sys.time(), "conttable_construct() for day:", day, " - Connected to DB", db)))
  
  # b.date as date, b.ngramlen as ngramlen,
  sql <- sprintf("select b.epochstartmillis/1000 as epochstartux, v.totalcnt as epochvol, 
          b.ngramarr as ngram, b.cnt as togethercnt
          from cnt_%s%d%s b 
          join volume_%s%d%s v on v.epochstartmillis = b.epochstartmillis
          where b.date=%d and b.cnt > %d;", epoch2, ngramlen2, ifelse(ngramlen2<3,'',paste("_",day, sep="")), 
      epoch1, ngramlen1, ifelse(ngramlen1<2,'',paste("_",day,sep="")), 
      day, support)
  # order by b.epochstartmillis asc <- necessary for the index shifting idea
  ngramRs <- dbSendQuery(con,sql)
# Test SQL: select b.epochstartmillis/1000 as epochstartux, v.totalcnt as epochvol, b.ngramarr as ngram, b.cnt as togethercnt from cnt_1hr2 b join volume_1hr1 v on v.epochstartmillis = b.epochstartmillis where b.date=121106 and b.cnt > 5;
  
  ngramDf <- fetch(ngramRs, n=-1)
  
  try(stop(paste(Sys.time(), "conttable_construct() for day:", day, " - Fetched ngrams' cnts using sql: ", sql)))
  
  #cleanup
  # dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
  try(dbClearResult(ngramRs))
  
  ngramDf <- within(ngramDf,{  # SQL below selects the array element: unigram=stripEndChars(unigram)
        ngram=stripEndChars(ngram)})
  
  if(ngramlen1==1){
    sql <- sprintf("select epochstartmillis/1000 as epochstartux, ngramarr[1] as unigram, cnt as unigramcnt
                  from cnt_%s%d where date=%d and cnt > %d;", epoch1, ngramlen1, day, support) # order by cnt desc
  } else {
    # after reducing the support of compgrams of lengths UP TO ngramlen1 in compgram_count, some of the unigams
    # seize to have enough support by themselves, yet they are part of compgrams with enough support (the downward
    # closure rule doesn't apply any more).. they shouldn't participate in compgrams any more because
    # without overlap then there can't be enough support for the newly formed compgrams.
    sql <- sprintf("select epochstartux, ngramarr as unigram, cnt as unigramcnt
										from compcnt_%s%d_%d where cnt > %d;",epoch1, ngramlen1, day, support) #order by cnt desc
  }
  ugramRs <- dbSendQuery(con,sql)
   #epochstartmillis asc, -> I had an idea but if I can't get it right.. screw it! I wanna finish my masters!
#Test SQL: select epochstartmillis/1000 as epochstartux, ngramarr[1] as unigram, cnt as unigramcnt from cnt_1hr1 where date=121106 and cnt > 5 order by cnt desc;
  
  ugramDf <- fetch(ugramRs, n=-1)
  
  try(stop(paste(Sys.time(), "conttable_construct() for day:", day, " - Fetched unigrams' cnts using sql:", sql)))
  #cleanup
  # dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
  try(dbClearResult(ugramRs))
  
  if(ngramlen1!=1){ #maybe == 2 and stripEndChars when constructing the trigram??
    ugramDf <- within(ugramDf,{ unigram=stripEndChars(unigram)})
  }
  
#  # The idea is that number of unique unigrams will be added to the mask start index, so that we don't have
#  # to do any checks of equality with epochstartux to find the unigrams pertaining to the current epoch
#  sql <- sprintf("select epochstartmillis/1000 as epochstartux, count(*) as nunique 
#                  from cnt_%s%d where date=%d and cnt > %d group by epochstartmillis 
#                  order by epochstartmillis asc;", epoch1, ngramlen1, day, support)
#  nuniqueRs <- dbSendQuery(con,sql)
##Test SQL: select epochstartmillis/1000 as epochstartux, count(*) as nunique from cnt_1hr1 where date=121110 and cnt>5 group by epochstartmillis;
#  
#  nuniqueDf <- fetch(nuniqueRs, n=-1)
#  
#  try(stop(paste(Sys.time(), "conttable_construct() for day:", day, " - Fetched number of unique ngrams using sql:",sql)))
#  
#  try(dbClearResult(nuniqueRs))

  # dbDisconnect(con, ...) closes the connection. Eg.
  try(dbDisconnect(con))
  # dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
  try(dbUnloadDriver(drv))


  
  handleErrors <- function(e) {
    if(DEBUG_ERRORS){
      try(stop(e))
    } else {
      stop(e)
    }
  }
 # DEBUG_ERRORS <- TRUE
 # debug(handleErrors)
  DEBUG_ERRORS <- TRUE
  
   ## THE MOST IMPORTANT CODE START HERE
#    epochUgramsIxStart <- 1
    createCooccurNooccur <- function(eg) {
      
      currEpoch <- eg[1,"epochstartux"]
      
      #unneccessary copy operation
     # egRow <- eg[1,1:2] #epochstartux and epochvol
      try(stop(paste(Sys.time(), "conttable_construct() for day:", day, " - Starting to create cooccurrence matrix for row",
                  currEpoch)))
      
      if(!EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1){
          pureNgrams <- as.array(rep.int(TRUE, length(eg$ngram)))
          rownames(pureNgrams) <- as.list(eg$ngram)
      }
    
 
      #The index shifting failure
#      # do we need to check if the epoch changed by storing the prevEpoch??
#      nUnique <- nuniqueDf[nuniqueDf$epochstartux==currEpoch,"nunique"]
#      epochUgramMask <- c(epochUgramsIxStart:(epochUgramsIxStart+nUnique-1))
#      epochUgramsIxStart <<-epochUgramsIxStart+nUnique #oops.. +1
      epochUgramMask <- which(ugramDf$epochstartux==currEpoch)
      nUnique <- length(epochUgramMask)    
  
      dnames <- ugramDf[epochUgramMask,"unigram"]
      if(withTotal){
        dnames <- c(dnames, TOTAL)
        maxIx <- (nUnique+1) #+1 for totals
      } else {
        maxIx <- nUnique
      }
    
      ixLookup <- array(1:maxIx)
      rownames(ixLookup) <- dnames
      
      cooccurs <- Matrix(0, #intially zeros
          nrow=nUnique, #no total because ther grand total isn't really useful
          ncol=maxIx,  # Will either contain +1 for total or not
          # The byrow has no effect on how the matrix is stored.. only how it is constructed
        #byrow=TRUE, # because I will add each row up, so I suspect that storing by row will be faster in that
#          byrow=FALSE, # I don't care. But since they prefer to store by column, I add the Totals
#          # as a column because there will always be numbers in the total and this
#          # will disrupt the sparsity.. if it can span more than one columne
          sparse=TRUE)
    
      
      if(withTotal){
        ixTOTAL <- ixLookup[TOTAL]
# This assumes that all unigrams will appear in string bigrams, which is not necessarily the case        
#        # Will be equal to epoch volume as long as the diagonal of coocurs contain the row's unigram
#        # coocurrences preceeding "other unigrams" that don't appear in any column
#        cooccurs[ixTOTAL,ixTOTAL] <- eg[1,"epochvol"]
      }
    
      if(!EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1){
        initDiagonals <- function(ug){
          
          ugram <- ug[1,"unigram"]
          
          ugramCnt <- ug[1,"unigramcnt"]
          
          #  if(DEBUG_CTC){
          if(is.na(ugramCnt) || ugramCnt <= 0){
            try(stop(paste(Sys.time(), "conttable_construct() for day:", day, " - WARNING: unigramcnt not positive:",ixugram,ugramCnt,ugram,currEpoch)))
            ugramCnt <- 0
          }
          #  }
        
          ixugram <- ixLookup[ugram]
          if(is.na(ixugram) || ixugram <= 0){
            if(any(ugram==',')){
            #this is the compgram in the unigram-compgram bigram  
            
            tryCatch(
                stop(paste("conttable_construct() for day:", day, " - ERROR: ixugram not positive:",ixugram,ugramCnt,ugram,currEpoch,nUnique,
                            epochUgramMask[1],"-",epochUgramMask[length(epochUgramMask)],paste(ugramDf[epochUgramMask[1],],collapse="|"),paste(ugramDf[epochUgramMask[length(epochUgramMask)],],collapse="|")))
                   ,error=handleErrors)
             } # else: it's a unigram that used to have enough support, but now it doesn't after moving some of it to compgrams in which it participates
             
            return(NULL)
            #ixugram <- 0
            
            
          }
          
          
          if(!EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1){
            # The total num of occurrences for the unigram in this epoch, goes into  the diagonal BUT 
            # it will be reduced to become the "alone" cnt.. that is cnt not with any of the col grams
            cooccurs[ixugram,ixugram] <- ugramCnt
           }
      
          cooccurs <<- cooccurs
          return("ignored")
        }
        #debug(initDiagonals)
        a_ply(idata.frame(ugramDf[epochUgramMask,]),1,.expand=FALSE,initDiagonals)
      }
    
      
#      if(withTotal){
#        # start the total by the "alone/with others" count
#        cooccurs[,ixTOTAL] <- ugramDf[epochUgramMask,"unigramcnt"]
#      }
      
      # apply to each ngram in the epoch   
      countCooccurNooccurNgram <- function(ng) {
        
        ugramsInNgram <- splitNgramToCompgrams(ng[1,"ngram"],ngramlen2)
        
        if(!EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1 && any(duplicated(ugramsInNgram))){
          pureNgrams[ng[1,"ngram"]] <- FALSE
          pureNgrams <<- pureNgrams
          return(NULL) 
        }
        
        for(u in 1:length(ugramsInNgram)){
          ugram <- ugramsInNgram[u]
          
          cnt <- ng[1,"togethercnt"]
          
          #  if(DEBUG_CTC){
          if(is.na(cnt) || cnt <= 0){
            try(stop(paste(Sys.time(), "conttable_construct#countCooccurNooccurNgram() for day:", day, " - WARNING: togthercnt not positive:",ixugram,cnt,paste(ugramsInNgram,collapse="|"),ugram,currEpoch)))
            cnt <- 0
          }
          #  }
          
          ixugram <- ixLookup[ugram]
          
          if(is.na(ixugram) || ixugram <= 0){
            if(any(ugram==',')){
              #this is the compgram in the unigram-compgram bigram  
              
            tryCatch(
                stop(paste("conttable_construct#countCooccurNooccurNgram() for day:", day, " - ERROR: ixugram not positive:",ixugram,cnt,paste(ugramsInNgram,collapse="|"),ugram,currEpoch,nUnique,
                        epochUgramMask[1],"-",epochUgramMask[length(epochUgramMask)],paste(ugramDf[epochUgramMask[1],],collapse="|"),paste(ugramDf[epochUgramMask[length(epochUgramMask)],],collapse="|")))
            ,error=handleErrors)
            } # else: it's a unigram that used to have enough support, but now it doesn't after moving some of it to compgrams in which it participates
      
            next
            #ixugram <- 0
              
          }
          
    
          if(!EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1){
                #Diagonal is the occurrence of the unigram without any of the other ngrams in the columns
                #NOT AFTER THE NEW SQL: The division accounts for the repeated deduction of the cnt with each element of ngram
                #NO: The -1 accouts for the iteration that will be skipped which is that of ugram itself
                cooccurs[ixugram,ixugram] <- cooccurs[ixugram,ixugram] - cnt #(cnt/ngramlen2)
              #  if(DEBUG_CTC){
                if(cooccurs[ixugram,ixugram] < 0){
                  try(stop(paste(Sys.time(), "conttable_construct() for day:", day, " - WARNING: cooccurs negative after reducing cnt = ",cnt, ixugram,cooccurs[ixugram,ixugram],ugram,currEpoch)))
                  cooccurs[ixugram,ixugram] <- 0
                }
              #  }
          }
          
          ugramPos <- u # residues from old SQL: which(ugramsInNgram == ugram)
          if(EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1){
            #not needed because it is just = u
#            if(length(ugramPos)>1){
#              #non-pure ngram, and there will be warnings about how the values were ignored
#              #TODO: handle in case of more than a bigram, where there could be other ugrams involved
#              ugramPos <- ugramPos[1]
#            }
            if(ugramPos < length(ugramsInNgram)){
              othersInNgram <- ugramsInNgram[(ugramPos+1):length(ugramsInNgram)]
            } else {
              othersInNgram <- c()
            }
          } else {
            # The diagonal is meaningless since order is not maintained, thus we use it for something else
            othersInNgram <- ugramsInNgram[-ugramPos]
          }
          
          # Prevent the loop to execute if the length is 0, since 1:0 generates 1, 0
          if(length(othersInNgram) > 0) {      
            for(o in 1:length(othersInNgram)){
              ugram2 <-othersInNgram[o]
            
              ixugram2 <- ixLookup[ugram2]
              
              if(is.na(ixugram2) || ixugram2 <= 0){
                if(any(ugram==',')){
                  #this is the compgram in the unigram-compgram bigram  
                  
                tryCatch(
                    stop(paste("conttable_construct() for day:", day, 
                            " - ERROR: ixugram2 not positive:",
                            ixugram2,cnt,paste(ugramsInNgram,collapse="|"),ugram2,currEpoch,nUnique,
                            epochUgramMask[1],"-",epochUgramMask[length(epochUgramMask)],paste(ugramDf[epochUgramMask[1],],collapse="|"),paste(ugramDf[epochUgramMask[length(epochUgramMask)],],collapse="|")))
                ,error=handleErrors)
                }# else: it's a unigram that used to have enough support, but now it doesn't after moving some of it to compgrams in which it participates
          
                next
                #ixugram2 <- 0
        
                
              }
            
              #increase the co-occurrence counts
              cooccurs[ixugram,ixugram2] <- cooccurs[ixugram,ixugram2] + cnt
            }
          }
        }
        
        if(withTotal){
          if(ngramlen2 > 2) {
            # start the total by the "alone/with other unigrams of low suppoer" count, then
            # add to it the sum of each row: the number of times it comes first in a unigram-compgram bigram
            # and the sum of each column: the number of times it comes second in a compgram-unigram bigram
            # and subtract the diagonal which was added twice
            cooccurs[,ixTOTAL] <- ugramDf[epochUgramMask,"unigramcnt"] + rowSums(cooccurs[,-ixTOTAL]) + colSums(cooccurs[,-ixTOTAL]) - diag(cooccurs)
          } else {
            # start the total by the "alone/with other unigrams of low suppoer" count, 
            cooccurs[,ixTOTAL] <- ugramDf[epochUgramMask,"unigramcnt"]
          }
        }
        
        cooccurs <<- cooccurs
        return("ignrored")
      }
   
     # debug(countCooccurNooccurNgram)
#      setBreakpoint("conttable_construct.R#249")
      d_ply(idata.frame(eg), c("ngram"), countCooccurNooccurNgram)

      try(stop(paste(Sys.time(), "conttable_construct() for day:", day, " - Finished creating cooccurrence matrix for",currEpoch)))
      if(EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1){
        resNgrams <- eg[,"ngram"]
      } else {
        resNgrams <- eg[pureNgrams,"ngram"]
      }
      
      res <- data.frame(epochstartux=eg[1,"epochstartux"],epochvol=eg[1,"epochvol"], uniqueUnigrams=I(list(ugramDf[epochUgramMask,"unigram"])),  
            uniqueNgrams=I(list(resNgrams)), #ifelse(EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1,eg[,"ngram"],eg[pureNgrams,"ngram"])  
            unigramsCooccurs=I(list(cooccurs))) # notoccurs had to go: , unigramsNotoccurs=I(list(notoccurs)))
      
      if(appendPosixTime)
        res["utctime"] <- toPosixTime(currEpoch)
      
      if(DEBUG_CTC){
        str(res)
      }
      return(res)    
    }
    #debug(createCooccurNooccur)
#setBreakpoint("concattable_construct.R#69")
   
    try(stop(paste(Sys.time(), "conttable_construct() for day:", day, " - Will create epoch groups")))
    
    #idata.frame( cannot access the internal dataframe afterwards.. not here!!
    epochGrps <- ddply(idata.frame(ngramDf), c("epochstartux"), createCooccurNooccur)
       #.progress = progress, .paropts=parOpts,.parallel = parallel, Parallel doesn't work  
   
    try(stop(paste(Sys.time(), "conttable_construct() for day:", day, " - Finished creating epoch groups")))
   
    if(alignEpochs)
      epochGrps <- align_epochs(epochGrps,epoch1)
   ### END OF IMPORTANT CODE
  
  #cleanup
  rm(ngramDf)
  rm(ugramDf)
  #rm(nuniqueDf)
  
#  dayEpochGrps <<- epochGrps
   return(epochGrps)
}

