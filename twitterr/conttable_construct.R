
# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

# TODO: Make sure all epochs are the same length
SEC_IN_EPOCH <- c(X5min=(60*5), X1hr=(60*60), X1day=(24*60*60)) 

MILLIS_PUT_1000 <- 1

TOTAL <- "TOTAL"

DEBUG <- FALSE
#options(error=utils::recover) 
#For debug
if(DEBUG){
date<-121212
epoch1<-'1hr'
ngramlen2<-2
ngramlen1<-1
support<-1
epoch2<-NULL
db<-"sample-0.01"
}

conttable_construct <- function(date, epoch1, ngramlen2, epoch2=NULL, ngramlen1=1, support=3,
  db="sample-0.01") {
  
  if(is.null(epoch2)){
    epoch2<-epoch1
  }
  require(RPostgreSQL)  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  rs <- dbSendQuery(con,
      sprintf("select a.epochstartmillis/1000 as epochstartux, %d as date, b.ngramlen as ngramlen, v.totalcnt as epochvol, 
  				b.ngramarr as ngram, b.cnt as togethercnt,
  				a.ngramarr as unigram, a.cnt - b.cnt as alonecnt, a.cnt as unigramcnt 
      from (cnt_%s%d a join cnt_%s%d b on 
            a.epochstartmillis = b.epochstartmillis and a.ngramArr[1] = ANY (b.ngramarr)
            and NOT a.ngramArr[1] = ALL (b.ngramarr))
         join volume_5min1 v on v.epochstartmillis = b.epochstartmillis
      where a.date = %d and b.date=%d and b.cnt > %d;", date, epoch1, ngramlen1, epoch2, ngramlen2, date, date, support))
  
  require(plyr)
  df <- fetch(rs, n=-1)
  
  numNGrams <- nrow(df) / df[1,"ngramlen"]
  if(numNGrams != floor(numNGrams)){
    stop("There was a duplicate unigram in some ngrams and thus the code below will not work!
  In case of bigrams it was enough to append 'and NOT a.ngramArr[1] = ALL (b.ngramarr)' to the SQL")
  }
  #idata.frame( object environment is not subsettable
  ngramGrps <- ddply(df, c("epochstartux","ngram"), function(bg){
        bgRow <- bg[1,1:6]
        for(i in 1:nrow(bg)) {
          bgRow[paste("unigram", i, sep=".")] <- bg[i,"unigram"]
          bgRow[paste("alonecnt", i, sep=".")] <- bg[i,"alonecnt"]
          bgRow[paste("unigramcnt", i, sep=".")] <- bg[i,"unigramcnt"]
        }
        bgRow["utctime"] <- as.POSIXct(bgRow[1,"epochstartux"]/MILLIS_PUT_1000,origin="1970-01-01", tz="GMT")
        return(bgRow)
      }) #,.parallel = TRUE)  will use doMC to parallelize on a higher level then no need here 

 
  createCooccurNooccur <- function(eg) {
    
      egRow <- eg[1,1:3]
      uniqueUgrams <- unique(eg[,"unigram"])
      
      nUnique <- length(uniqueUgrams)
      dnames <- c(uniqueUgrams, TOTAL)
      ixLookup <- data.frame(ix=1:(nUnique+1), row.names=dnames, check.names=TRUE)
      cooccurs <- array(rep(0,(nUnique+1)^2), dim=c(nUnique+1,nUnique+1))
      notoccurs <- array(rep(0,(nUnique)^2), dim=c(nUnique,nUnique))
      #dimnames starts behaving wierdly after 5 iterations by using the string c(...) as the dimns!
      
      ixTOTAL <- ixLookup[TOTAL, 'ix']
      cooccurs[ixTOTAL,ixTOTAL] <- eg[1,"epochvol"]
        
      countCooccurNooccurUnigram <- function(ug) {             
        ugram <- ug[1,"unigram"]
        ixugram <- ixLookup[ugram, 'ix']
        
        # The total num of occurrences for the unigram in this epoch, goes into 3 locations
        # the totals, and also the diagonal (to be reduced to become the "alone" cnt)      
        cooccurs[ixugram,ixugram] <- ug[1,"unigramcnt"]
        cooccurs[ixugram,ixTOTAL] <-  cooccurs[ixugram,ixugram]
        cooccurs[ixTOTAL, ixugram] <-  cooccurs[ixugram,ixugram]
        
        # To calculate how many times a unigram appears without another, we start by how many times
        # the unigram appears altogether then we reduce every time it appears with another
        notoccurs[ixugram,(1:nUnique)] <- ug[1,"unigramcnt"]
        
      #  if(DEBUG){
          if(cooccurs[ixugram,ixugram] <= 0){
            print(paste("WARNING: unigramcnt not positive:",cooccurs, ixugram,cooccurs[ixugram,ixugram],ugram,ug[1,"epochstartux"]))
            cooccurs[ixugram,ixugram] <- 0
          }
          if(notoccurs[ixugram,ixugram] <= 0){
            print(paste("WARNING: unigramcnt not positive:",notoccurs, ixugram,notoccurs[ixugram,ixugram],ugram,ug[1,"epochstartux"]))
            notoccurs[ixugram,ixugram] <- 0
          }
      #  }
        
      
        for(r in 1:nrow(ug)){
          
          cnt <- ug[r,"togethercnt"]
          
          #diagonal is the occurrence of the unigram without any of the others
          cooccurs[ixugram,ixugram] <- cooccurs[ixugram,ixugram] - cnt
          
      #    if(DEBUG){
            if(cooccurs[ixugram,ixugram] < 0){
              print(paste("WARNING: cooccurs negative after reducing cnt = ",cnt,cooccurs, ixugram,cooccurs[ixugram,ixugram],ugram,ug[1,"epochstartux"]))
              cooccurs[ixugram,ixugram] <- 0
              print(paste("------------------------------------------------------------------"))
            }
      #    }
          
          othersInNgram <- unlist(strsplit(ug[r,"ngram"],","))
          
          othersInNgram[1] <- substring(othersInNgram[1],2)
          othersInNgram[length(othersInNgram)] <- substring(othersInNgram[length(othersInNgram)],1,
              nchar(othersInNgram[length(othersInNgram)])-1)
          
          othersInNgram <- setdiff(othersInNgram, substring(ugram, 2, nchar(ugram)-1))
          
          
          for(o in 1:length(othersInNgram)){
            ugram2 <- paste("{",othersInNgram[o],"}", sep="")
            
            ixugram2 <- ixLookup[ugram2, 'ix']
            
            #increase the co-occurrence counts
            cooccurs[ixugram,ixugram2] <- cooccurs[ixugram,ixugram2] + cnt
            
            # decrease the occurrences of this bigram but not the other
            notoccurs[ixugram,ixugram2] <-  notoccurs[ixugram,ixugram2] - cnt
            if(DEBUG){
              if(notoccurs[ixugram,ixugram] < 0){
                print(paste("WARNING: notoccurs negative after reducing cnt=",cnt,notoccurs, ixugram,notoccurs[ixugram,ixugram],ugram, ugram2,ug[1,"epochstartux"]))
                print(paste("------------------------------------------------------------------"))
                notoccurs[ixugram,ixugram] <- 0
              }
            }
          }
        }
        
      # Adds to it directly             return(cooccurs)
        cooccurs <<- cooccurs
        notoccurs <<- notoccurs
      }

#debug(countCooccurNooccurUnigram)
      unigGrp <- ddply(eg, c("unigram"), countCooccurNooccurUnigram)
    
      res <- data.frame(egRow, uniqueUnigams=I(list(uniqueUgrams)), 
          unigramCooccurs=I(list(cooccurs)), unigramsNotoccurs=I(list(notoccurs)))
      if(DEBUG){
        str(res)
        print("=====================================================")
      }
      return(res)    
  }

#debug(createCooccurNooccur)
#setBreakpoint("concattable_construct.R#69")

  epochGrps <- ddply(df, c("epochstartux"), createCooccurNooccur)


  #cleanup
  rm(df)
  # dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
  try(dbClearResult(rs))
  # dbDisconnect(con, ...) closes the connection. Eg.
  try(dbDisconnect(con))
  # dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
  try(dbUnloadDriver(drv))
  
  res <- data.frame(ngramGrps=I(list(ngramGrps)), epochGrps=I(list(epochGrps)))
  if(DEBUG){
    str(res)
    print("+++++++++++++++++++++++++++++++++++++++++++++++++++")
  }
  return(res)
}

