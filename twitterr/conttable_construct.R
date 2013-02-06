
# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

MILLIS_PUT_1000 <- 1

kTS <- "epochstartux"
TOTAL <- "TOTAL"

EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1 <- TRUE

DEBUG_CTC <- FALSE
#options(error=utils::recover) 
#For debug
if(DEBUG_CTC){
date<-121110
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
parallel<-FALSE
parOpts <- "cores=2"
progress<-"none" #text isn't good with parallel
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
    
    while(!require(plyr)){
      install.packages("plyer")
    }
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
conttable_construct <- function(date, epoch1='1hr', ngramlen2=2, epoch2=NULL, ngramlen1=1, support=5,
  db="sample-0.01", retEpochGrps=TRUE, retNgramGrps=FALSE, alignEpochs=FALSE, appendPosixTime=FALSE,
  withTotal=TRUE, parallel=FALSE, parOpts="cores=24", progress="none") {
  
  if(is.null(epoch2)){
    epoch2<-epoch1
  }
  if(epoch1 == '1day' || epoch2 == '1day'){
    stop("Because we calculate the date base on GMT-10 and the epochstartmillis is at GMT, using day 
        epochs will result in more than one record per unigram, which is not the expected")
    #TODO: subtract 10 hours from epochstartmillis to align both timezones.. but is this right?
  }
  while(!require(RPostgreSQL)){
    install.packages("RPostgreSQL")
  }  
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

  
  while(!require(plyr)){
    install.packages("plyr")
  }
  if(parallel){
    while(!require(foreach)){
      install.packages("foreach")
    }
    if(!require(doMC)){
      install.packages("doMC")
    }
    registerDoMC()
  }
  
  while(!require(Matrix)){
    install.packages("Matrix")
  }
  
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
      }) #,.parallel = TRUE) TODOIf this was supported again 
  
    if(alignEpochs)
      ngramGrps <- align_epochs(ngramGrps, epoch1)
    
  }
  
  
  if(retEpochGrps){
 
    ## THE MOST IMPORTANT CODE START HERE
    
    createCooccurNooccur <- function(eg) {
    
      egRow <- eg[1,1:2] #epochstartux and epochvol
      
      if(!EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1){
          pureNgrams <- as.array(rep.int(TRUE, length(eg$ngram)))
          rownames(pureNgrams) <- as.list(eg$ngram)
      }
    
      currEpoch <- egRow[1,"epochstartux"]
      epochUgramMas <- which(ugramDf$epochstartux==currEpoch)
      nUnique <- length(epochUgramMas)

      if(appendPosixTime)
        egRow["utctime"] <- toPosixTime(egRow[1,"epochstartux"])
    
      dnames <- ugramDf[epochUgramMas,"unigram"]
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
          byrow=FALSE, # I don't care. But since they prefer to store by column, I add the Totals
          # as a column because there will always be numbers in the total and this
          # will disrupt the sparsity.. if it can span more than one columne
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
          ugramCnt <- ug[1,"unigramcnt"]
          ixugram <- ixLookup[ug[1,"unigram"]]
          #  if(DEBUG_CTC){
          if(ugramCnt <= 0){
            print(paste("WARNING: unigramcnt not positive:",ixugram,ugramCnt,ugram,eg[1,"epochstartux"]))
            print("***********************************")
            ugramCnt <- 0
          }
          #  }
        
          if(!EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1){
            # The total num of occurrences for the unigram in this epoch, goes into  the diagonal BUT 
            # it will be reduced to become the "alone" cnt.. that is cnt not with any of the col grams
            cooccurs[ixugram,ixugram] <- ugramCnt
           }
      
          cooccurs <<- cooccurs
        }
        #debug(initDiagonals)
        a_ply(ugramDf[epochUgramMas,],1,.expand=FALSE,initDiagonals)
      }
    
      
      if(withTotal){
        cooccurs[,ixTOTAL] <- ugramDf[epochUgramMas,"unigramcnt"]
      }
      
      # apply to each ngram in the epoch   
      countCooccurNooccurNgram <- function(ng) {
        
        ugramsInNgram <- unlist(strsplit(ng[1,"ngram"],","))
        
        if(!EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1 && any(duplicated(ugramsInNgram))){
          pureNgrams[ng[1,"ngram"]] <- FALSE
          pureNgrams <<- pureNgrams
          return(NULL) 
        }
        
        for(u in 1:length(ugramsInNgram)){
          ugram <- ugramsInNgram[u]
          ixugram <- ixLookup[ugram]
        
          cnt <- ng[1,"togethercnt"]
          
      if(!EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1){
            #Diagonal is the occurrence of the unigram without any of the other ngrams in the columns
            #NOT AFTER THE NEW SQL: The division accounts for the repeated deduction of the cnt with each element of ngram
            #NO: The -1 accouts for the iteration that will be skipped which is that of ugram itself
            cooccurs[ixugram,ixugram] <- cooccurs[ixugram,ixugram] - cnt #(cnt/ngramlen2)
          #  if(DEBUG_CTC){
            if(cooccurs[ixugram,ixugram] < 0){
              print(paste("WARNING: cooccurs negative after reducing cnt = ",cnt, ixugram,cooccurs[ixugram,ixugram],ugram,eg[1,"epochstartux"]))
              cooccurs[ixugram,ixugram] <- 0
              print(paste("------------------------------------------------------------------"))
            }
          #  }
      }
          
          ugramPos <- which(ugramsInNgram == ugram)
          if(EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1){
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
            
              #increase the co-occurrence counts
              cooccurs[ixugram,ixugram2] <- cooccurs[ixugram,ixugram2] + cnt
            }
          }
        }
        cooccurs <<- cooccurs
      }
   
      #debug(countCooccurNooccurNgram)
#      setBreakpoint("conttable_construct.R#249")
      ngramGrp <- d_ply(eg, c("ngram"), countCooccurNooccurNgram)

        res <- data.frame(egRow, uniqueUnigrams=I(list(ugramDf[epochUgramMas,"unigram"])),  
            uniqueNgrams=I(list(ifelse(EPOCH_GRPS_COUNT_NUM_U2_AFTER_U1,eg[,"ngram"],eg[pureNgrams,"ngram"]))),  
            unigramsCooccurs=I(list(cooccurs))) # notoccurs had to go: , unigramsNotoccurs=I(list(notoccurs)))
        if(DEBUG_CTC){
          str(res)
          print(".........................................")
        }
        return(res)    
    }
    #debug(createCooccurNooccur)
#setBreakpoint("concattable_construct.R#69")
    
    epochGrps <- ddply(ngramDf, c("epochstartux"), createCooccurNooccur,
       .progress = progress) #, .paropts=parOpts,.parallel = parallel, It doesn't work  
    
    if(alignEpochs)
      epochGrps <- align_epochs(epochGrps,epoch1)
  }

  #cleanup
  rm(ngramDf)
  rm(ugramDf)
  
  res <- data.frame(ngramGrps=I(list(ngramGrps)), epochGrps=I(list(epochGrps)))
  if(DEBUG_CTC){
    str(res)
    print("+++++++++++++++++++++++++++++++++++++++++++++++++++")
  }
  return(res)
}

