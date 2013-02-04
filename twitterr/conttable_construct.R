
# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

MILLIS_PUT_1000 <- 1

kTS <- "epochstartux"
TOTAL <- "TOTAL"

EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1 <- TRUE

DEBUG <- FALSE
#options(error=utils::recover) 
#For debug
if(DEBUG){
date<-121212
epoch1<-'1hr'
ngramlen2<-2
ngramlen1<-1
support<-3
epoch2<-NULL
db<-"sample-0.01"
retEpochGrps<-TRUE
retNgramGrps<-FALSE
alignEpochs<-FALSE
appendPosixTime<-FALSE
withTotal<-TRUE
}

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
    
    require(plyr)
    dframe <- rbind.fill(dframe[1:i, ], 
        missingEpochs,
        dframe[(i+1):nrow(dframe), ])
  }
  return(dframe);
}
#debug(align_epochs)


#####################################3
toPosixTime <- function(timestamp){
  as.POSIXct(timestamp/MILLIS_PUT_1000,origin="1970-01-01", tz="GMT")
}


########################################################

stripEndChars <- function(ngram) {
  return(substring(ngram, 2, nchar(ngram)-1))
}

############################################
conttable_construct <- function(date, epoch1, ngramlen2, epoch2=NULL, ngramlen1=1, support=5,
  db="sample-0.01", retEpochGrps=TRUE, retNgramGrps=FALSE, alignEpochs=FALSE, appendPosixTime=FALSE,
  withTotal=TRUE) {
  
  if(is.null(epoch2)){
    epoch2<-epoch1
  }
  if(epoch1 == '1day' || epoch2 == '1day'){
    stop("Because we calculate the date base on GMT-10 and the epochstartmillis is at GMT, using day 
				epochs will result in more than one record per unigram, which is not the expected")
    #TODO: subtract 10 hours from epochstartmillis to align both timezones.. but is this right?
  }
  require(RPostgreSQL)  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
  # b.date as date, b.ngramlen as ngramlen,
  ngramRs <- dbSendQuery(con,
      sprintf("select b.epochstartmillis/1000 as epochstartux, v.totalcnt as epochvol, 
  				b.ngramarr as ngram, b.cnt as togethercnt 
      from cnt_%s%d b 
         join volume_5min1 v on v.epochstartmillis = b.epochstartmillis
      where b.date=%d and b.cnt > %d;", epoch2, ngramlen2, date, support))
# Test SQL: select b.epochstartmillis/1000 as epochstartux, v.totalcnt as epochvol, b.ngramarr as ngram, b.cnt as togethercnt from cnt_1hr2 b join volume_5min1 v on v.epochstartmillis = b.epochstartmillis where b.date=121106 and b.cnt > 5;
  
  ngramDf <- fetch(ngramRs, n=-1)
  
# This is inevitable now that we don't do a join, will have to enforce this while looping  
#  numNGrams <- nrow(ngramDf) / ngramlen2
#  if(numNGrams != floor(numNGrams)){
#    stop("There was a duplicate unigram in some ngrams and thus the code below will not work!
#            In case of bigrams it was enough to append 'and NOT a.ngramArr[1] = ALL (b.ngramarr)' to the SQL")
#  }
  
  ngramDf <- within(ngramDf,{  # SQL below selects the array element: unigram=stripEndChars(unigram)
        ngram=stripEndChars(ngram)})
  
  #cleanup
  # dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
  try(dbClearResult(ngramRs))
  
  ugramRs <- dbSendQuery(con,
      sprintf("select epochstartmillis/1000 as epochstartux, ngramarr[1] as unigram, cnt as unigramcnt
               from cnt_%s%d where date=%d and cnt > %d;", epoch1, ngramlen1, date, support))
#Test SQL: select epochstartmillis/1000 as epochstartux, ngramarr[1] as unigram, cnt as unigramcnt from cnt_1hr1 where date=121106 and cnt > 5;
  
  ugramDf <- fetch(ugramRs, n=-1)

  #cleanup
  # dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
  try(dbClearResult(ugramRs))
  # dbDisconnect(con, ...) closes the connection. Eg.
  try(dbDisconnect(con))
  # dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
  try(dbUnloadDriver(drv))

  
  require(plyr)
  
  #idata.frame( object environment is not subsettable
  if(retNgramGrps){
    stop("Unsupported operation with the new SQL.. it requires the joined SQL (which was too slow)")
    ngramGrps <- ddply(ngramDf, c("epochstartux","ngram"), function(bg){
        bgRow <- bg[1,1:6]
         
        for(i in 1:nrow(bg)) {
          bgRow[paste("unigram", i, sep=".")] <- bg[i,"unigram"]
          bgRow[paste("alonecnt", i, sep=".")] <- bg[i,"alonecnt"]
          bgRow[paste("unigramcnt", i, sep=".")] <- bg[i,"unigramcnt"]
        }
        if(appendPosixTime)
          bgRow["utctime"] <- toPosixTime(bgRow[1,"epochstartux"])
        return(bgRow)
      }) #,.parallel = TRUE)  will use doMC to parallelize on a higher level then no need here 
  
    if(alignEpochs)
      ngramGrps <- align_epochs(ngramGrps, epoch1)
    
  }
  
  
  if(retEpochGrps){
    
#    currEpoch <- NULL  
#    uniqueUgrams <- NULL
#    dnames <- NULL
#    ixLookup <- NULL
#    nUnique <- -1
    
    createCooccurNooccur <- function(eg) {
    
      egRow <- eg[1,1:2] #epochstartux and epochvol
      
      pureNgrams <- as.array(rep.int(TRUE, length(eg$ngram)))
      rownames(pureNgrams) <- as.list(eg$ngram)
      
      #if and <<- not necessary since this will be called once per epoch anyway
#      if(uniqueUgramsEpoch != egRow[1,"epochstartux"]){
      currEpoch <- egRow[1,"epochstartux"]
#      uniqueUgrams <- ugramDf[epochUgramMas,"unigram"]
#      nUnique <- length(uniqueUgrams)
      epochUgramMas <- which(ugramDf$epochstartux==currEpoch)
      nUnique <- length(epochUgramMas)
#      }
#      uniqueUgrams <- unique(eg[, "unigram"]) 
      
#      nUnique <- length(uniqueUgrams)

      if(appendPosixTime)
        egRow["utctime"] <- toPosixTime(egRow[1,"epochstartux"])
    
    
      dnames <- ugramDf[epochUgramMas,"unigram"]
      if(withTotal){
#        dnames <- c(uniqueUgrams, TOTAL)
        dnames <- c(dnames, TOTAL)
#        ixLookup <- data.frame(ix=1:(nUnique+1), row.names=dnames, check.names=TRUE)
        ixLookup <- array(1:(nUnique+1))
        cooccurs <- array(rep(0,(nUnique+1)^2), dim=c(nUnique+1,nUnique+1))
      } else {
        # Removing the extra column of TOTALs, which is annoying afterwards
#        dnames <- uniqueUgrams
#        ixLookup <- data.frame(ix=1:nUnique, row.names=dnames, check.names=TRUE)
        ixLookup <- array(1:(nUnique+1))  
        cooccurs <- array(rep(0,(nUnique)^2), dim=c(nUnique,nUnique))
      }      
      rownames(ixLookup) <- dnames
      
      # The diagonal will contain the total number of occurrences of the row's unigrams
      notoccurs <- array(rep(0,(nUnique)^2), dim=c(nUnique,nUnique))
      #dimnames starts behaving wierdly after 5 iterations by using the string c(...) as the dimns!
      
      if(withTotal){
#        ixTOTAL <- ixLookup[TOTAL, 'ix']
        ixTOTAL <- ixLookup[TOTAL]
        
# This assumes that all unigrams will appear in string bigrams, which is not necessarily the case        
#        # Will be equal to epoch volume as long as the diagonal of coocurs contain the row's unigram
#        # coocurrences preceeding "other unigrams" that don't appear in any column
#        cooccurs[ixTOTAL,ixTOTAL] <- eg[1,"epochvol"]
      }
      
      initDiagonals <- function(ug){
        ugramCnt <- ug[1,"unigramcnt"]
        ixugram <- ixLookup[ug[1,"unigram"]]
        #  if(DEBUG){
        if(ugramCnt <= 0){
          print(paste("WARNING: unigramcnt not positive:",ixugram,ugramCnt,ugram,eg[1,"epochstartux"]))
          print("***********************************")
          ugramCnt <- 0
        }
        #  }
      
        # The total num of occurrences for the unigram in this epoch, goes into  the diagonal BUT 
        # it will be reduced to become the "alone" cnt.. that is cnt not with any of the col grams
        cooccurs[ixugram,ixugram] <- ugramCnt
      
        if(withTotal){
          # and also the totals
          cooccurs[ixugram,ixTOTAL] <-  ugramCnt
          cooccurs[ixTOTAL, ixugram] <-  ugramCnt
        }
      
        # To calculate how many times a unigram appears without another, we start by how many times
        # the unigram appears altogether then we reduce every time it appears with another
        notoccurs[ixugram,(1:nUnique)] <- ugramCnt
        
        cooccurs <<- cooccurs
        notoccurs <<- notoccurs
      }
      #debug(initDiagonals)
      a_ply(ugramDf[epochUgramMas,],1,.expand=FALSE,initDiagonals)
      
      if(withTotal){
        #Grand Total (do not set as epochvol)
        cooccurs[ixTOTAL,ixTOTAL] <- sum(cooccurs[ixTOTAL,])
      }
      
# will be a loop within epochgroup func   countCooccurNooccurUnigram <- function(ug) {   
      countCooccurNooccurNgram <- function(ng) {
        ugramsInNgram <- unlist(strsplit(ng[1,"ngram"],","))
        if(any(duplicated(ugramsInNgram))){
          pureNgrams[ng[1,"ngram"]] <- FALSE
          pureNgrams <<- pureNgrams
          return(NULL) # Will this be rbind()ed to the other results? I hope not
        }
        for(u in 1:length(ugramsInNgram)){
  #        ugram <- ug[1,"unigram"]
          ugram <- ugramsInNgram[u]
#          ixugram <- ixLookup[ugram, 'ix']
          ixugram <- ixLookup[ugram]
        
        #Move to wher cooccurs and notoccurs are created
#        ugramCnt <- ugramDf[epochUgramMas,ugramDf$unigram=ugram,"unigramcnt"]
#        #            ug[1,"unigramcnt"]
#        
#        #  if(DEBUG){
#        if(ugramCnt <= 0){
#          print(paste("WARNING: unigramcnt not positive:",ixugram,ugramCnt,ugram,eg[1,"epochstartux"]))
#          print("***********************************")
#          ugramCnt <- 0
#        }
#        #  }
#        
#        # The total num of occurrences for the unigram in this epoch, goes into  the diagonal BUT 
#        # it will be reduced to become the "alone" cnt.. that is cnt not with any of the col grams
#        cooccurs[ixugram,ixugram] <- ugramCnt
#
#        if(withTotal){
#        # and also the totals
#          cooccurs[ixugram,ixTOTAL] <-  ugramCnt
#          cooccurs[ixTOTAL, ixugram] <-  ugramCnt
#        }
#        
#        # To calculate how many times a unigram appears without another, we start by how many times
#        # the unigram appears altogether then we reduce every time it appears with another
#        notoccurs[ixugram,(1:nUnique)] <- ugramCnt
# End move
        
#        for(r in 1:nrow(ug)){
          
#        cnt <- ug[r,"togethercnt"]
          cnt <- ng[1,"togethercnt"]
          
          #Diagonal is the occurrence of the unigram without any of the others.
          #The division accounts for the repeated deduction of the cnt with each element of ngram
          #NO: The -1 accouts for the iteration that will be skipped which is that of ugram itself
          cooccurs[ixugram,ixugram] <- cooccurs[ixugram,ixugram] - (cnt/ngramlen2)
          
        #  if(DEBUG){
          if(cooccurs[ixugram,ixugram] < 0){
           # lapply(c(cnt, ixugram,cooccurs[ixugram,ixugram],ugram,ug[1,"epochstartux"]),str)
            print(paste("WARNING: cooccurs negative after reducing cnt = ",cnt, ixugram,cooccurs[ixugram,ixugram],ugram,eg[1,"epochstartux"]))
            cooccurs[ixugram,ixugram] <- 0
            print(paste("------------------------------------------------------------------"))
          }
        #  }
          
          
          ugramPos <- which(ugramsInNgram == ugram)
          if(EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1){
            if(ugramPos < length(ugramsInNgram)){
              othersInNgram <- ugramsInNgram[(ugramPos+1):length(ugramsInNgram)]
            } else {
              othersInNgram <- c()
            }
          } else {
            othersInNgram <- ugramsInNgram[-ugramPos]
          }
          
          # Prevent the loop to execute if the length is 0, since 1:0 generates 1, 0
          if(length(othersInNgram) > 0) {      
            for(o in 1:length(othersInNgram)){
              ugram2 <-othersInNgram[o]
            
#              ixugram2 <- ixLookup[ugram2, 'ix']
              ixugram2 <- ixLookup[ugram2]
            
              #increase the co-occurrence counts
              cooccurs[ixugram,ixugram2] <- cooccurs[ixugram,ixugram2] + cnt
            
              # decrease the occurrences of "ugram1 but not the others in the ngram"
              # NO, this doesn't make any sense.. -->The division accounts for the repeated deduction of the cnt with each element of ngram
              # using length accouts for the iterations that will be skipped (either ugram itself or preceeding ugrams) <-- No division
  #            notoccurs[ixugram,ixugram2] <-  notoccurs[ixugram,ixugram2] - (cnt/length(othersInNgram))
              notoccurs[ixugram,ixugram2] <-  notoccurs[ixugram,ixugram2] - cnt
  #            if(DEBUG){
              if(notoccurs[ixugram,ixugram2] < 0){
                #lapply(c(cnt, ixugram,notoccurs[ixugram,ixugram],ugram, ugram2,ug[1,"epochstartux"]), str)
                print(paste("WARNING: notoccurs negative after reducing cnt=",cnt, ixugram,notoccurs[ixugram,ixugram2],ugram, ugram2,eg[1,"epochstartux"], str(othersInNgram)))
                print(paste("------------------------------------------------------------------"))
                notoccurs[ixugram,ixugram2] <- 0
              }
  #           }
            }
          }
        }
        # Adds to it directly             return(cooccurs)
        cooccurs <<- cooccurs
        notoccurs <<- notoccurs
      }
      
      # Notoccurs with the diagonal should mean the number of times that the row's unigram appears
      # with anything in the columns.. that is its appearance count - the number in the diagonal of
      # cooccur (appearances with other that the ones in the column)
      diag(notoccurs) <- diag(notoccurs) - diag(cooccurs)[1:nUnique]
##debug(countCooccurNooccurUnigram)
#      unigGrp <- ddply(eg, c("unigram"), countCooccurNooccurUnigram)
  
#      debug(countCooccurNooccurNgram)
#      setBreakpoint("conttable_construct.R#249")
      ngramGrp <- ddply(eg, c("ngram"), countCooccurNooccurNgram)

# This is an overhead that will probably not be needed when full DB is used      
#      if(any(pureNgrams)){
        res <- data.frame(egRow, uniqueUnigams=I(list(ugramDf[epochUgramMas,"unigram"])), #uniqueUgrams)), 
            uniqueNgrams=I(list(eg[pureNgrams,"ngram"])), #unique( not necessary 
            unigramCooccurs=I(list(cooccurs)), unigramsNotoccurs=I(list(notoccurs)))
        if(DEBUG){
          str(res)
          print("=====================================================")
        }
        return(res)    
#      } else {
#        if(DEBUG){
#          print("No 'pure' ngrams (not including duplicates of the same unigram) this epoch")
#          print("=====================================================")
#        }
#        return(NULL)
#      }
    }
#    debug(createCooccurNooccur)
#setBreakpoint("concattable_construct.R#69")

    epochGrps <- ddply(ngramDf, c("epochstartux"), createCooccurNooccur)
    
    if(alignEpochs)
      epochGrps <- align_epochs(epochGrps,epoch1)
  }

  #cleanup
  rm(ngramDf)
  rm(ugramDf)
  
  res <- data.frame(ngramGrps=I(list(ngramGrps)), epochGrps=I(list(epochGrps)))
  if(DEBUG){
    str(res)
    print("+++++++++++++++++++++++++++++++++++++++++++++++++++")
  }
  return(res)
}

