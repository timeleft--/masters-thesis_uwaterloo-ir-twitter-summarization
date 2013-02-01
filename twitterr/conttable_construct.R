
# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

# TODO: Make sure all epochs are the same length
SEC_IN_EPOCH <- c(X5min=(60*5), X1hr=(60*60), X1day=(24*60*60)) 

MILLIS_PUT_1000 <- 1

TOTAL <- "TOTAL"

DEBUG <- TRUE
#options(error=utils::recover) 
#For debug
if(DEBUG){
date<-121221
epoch1<-'5min'
ngramlen2<-2
ngramlen1<-1
support<-3
epoch2<-NULL
}

conttable_construct <- function(date, epoch1, ngramlen2, epoch2=NULL, ngramlen1=1, support=3) {
  

if(is.null(epoch2)){
  epoch2<-epoch1
}
require(RPostgreSQL)  
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="sample-0.01", user="yaboulna", password="5#afraPG",
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

epochGrps <- ddply(ngramGrps, c("epochstartux"), function(eg) {
      egRow <- eg[1,1:3]
      #if unique unigrams are c(blah, blah) exit
      uniqueUgrams <- unique(eg["unigram.1"])
      for(l in 2:ngramlen2){
        uniqueUgrams <- union(uniqueUgrams, unique(eg[c(paste("unigram", l, sep="."))]))
      }
      nUnique <- length(uniqueUgrams)
      dnames <- c(uniqueUgrams, TOTAL)
      ixLookup <- data.frame(ix=1:(nUnique+1), row.names=dnames, check.names=TRUE)
      if(DEBUG){
        str(uniqueUgrams)
        str(dnames)  
      }
      cooccurs <- array(rep(0,(nUnique+1)^2), dim=c(nUnique+1,nUnique+1))
      #dimnames starts behaving wierdly after 5 iterations by using the string c(...) as the dimns!
#      , dimnames=list(dnames,dnames))
#      cooccurs <- matrix(rep(0,(nUnique+1)^2), nrow=nUnique+1, dimnames=list(dnames,dnames))
##      dim=c(nUnique+1,nUnique+1)
##          dimnames=list(cbind(uniqueUgrams, TOTAL), cbind(uniqueUgrams, TOTAL)))
#      colnames(cooccurs)<-dnames
#      rownames(cooccurs)<-dnames
      
      if(DEBUG){
        str(cooccurs)
##        str(ixLookup[TOTAL,'ix'])
#        str( eg[1,"epochvol"])
##        str(cooccurs[ixLookup[TOTAL,'ix'],ixLookup[TOTAL,'ix']])
      }
#      cooccurs[ixLookup[TOTAL,'ix'],ixLookup[TOTAL,'ix']] <- eg[1,"epochvol"]
      ixTOTAL <- ixLookup[TOTAL, 'ix']
      cooccurs[ixTOTAL,ixTOTAL] <- eg[1,"epochvol"]
#      if(DEBUG){
#        str(cooccurs)
#      }
      for(l in 1:(ngramlen2)){
        
        unigGrp <- ddply(eg, c(paste("unigram", l, sep=".")), function(ug) {
              
              ugram <- ug[1,paste("unigram", l, sep=".")]
              ixugram <- ixLookup[ugram, 'ix']
              if(DEBUG){
                str(ugram)
#                if((!ugram %in% colnames(cooccurs))){
#                  print(paste("Colnames: " , colnames(cooccurs)))
#                }else if((!ugram %in% rownames(cooccurs))){
#                  print(paste("Rownames: " , rownames(cooccurs)))
#                }
          str(cooccurs)
                str(cooccurs[ixugram,ixugram])
                str(cooccurs[ixugram,ixTOTAL])
                str(cooccurs[ixTOTAL, ixugram])
          str(ug)
          str(ug[1,paste("unigramcnt", l, sep=".")])
              }
              
              cooccurs[ixugram,ixugram] <- ug[1,paste("unigramcnt", l, sep=".")]
                  # This is good in case of bigrams only.. but really alone need reducing all 
              # occurrences with anything else from the unigramcnt (appearing ALONE... how!)
                  #ug[1,paste("alonecnt", l, sep=".")]
              cooccurs[ixugram,ixTOTAL] <- ug[1,paste("unigramcnt", l, sep=".")]
              cooccurs[ixTOTAL, ixugram] <- cooccurs[ixugram,ixTOTAL] 
              
              
#              if(DEBUG){
#                str(cooccurs)
#              }
                
              for(r in 1:nrow(ug)){
#                if(DEBUG){
#                  print(paste("ug[r,]",str(ug[r,])))
#                }
                
#                if(DEBUG){
#                 print(paste("cnt: ", str(ug[r,"togethercnt"])))
#                }
                
                cnt <- ug[r,"togethercnt"]
                aloneCnt <- ug[1,paste("alonecnt", l, sep=".")]
                
                #diagonal is the occurrence of the unigram without any of the others
                cooccurs[ixugram,ixugram] <- cooccurs[ixugram,ixugram] - cnt
#                if(DEBUG){
#                  str(cooccurs)
#                } 
                
                if(l == ngramlen2){
                  next # continue
                }
                for(u in (l+1):ngramlen2){
#                  if(DEBUG){
#                     paste("ugram2 to be", ug[r,paste("unigram", u, sep=".")])
#                  }
    
                  ugram2 <- ug[r,paste("unigram", u, sep=".")]
                  ixugram2 <- ixLookup[ugram2, 'ix']
                  
#                  if(is.null(ugram2) || is.na(ugram2)){
#                    stop("ugram2 is null", str(ugram2))
#                  }
#                  if(DEBUG){
#                    print(paste("ugram2",str(ugram2)))
#                    str(cooccurs)
#                    if((!ugram2 %in% colnames(cooccurs))){
#                      print(paste("Colnames: " , colnames(cooccurs)))
#                    }else if((!ugram2 %in% rownames(cooccurs))){
#                      print(paste("Rownames: " , rownames(cooccurs)))
#                    }
#                  }
                  # upper triangle is the co-occurrence counts
                  cooccurs[ixugram,ixugram2] <- cooccurs[ixugram,ixugram2] + cnt
#                  if(DEBUG){
#                    str(cooccurs)
#                  }
                  # lower triangle is the occurrences of this bigram but not the other
                  cooccurs[ixugram2,ixugram] <-  cooccurs[ixugram2,ixugram] + aloneCnt 
#                  if(DEBUG){
#                    str(cooccurs)
#                  }
                }
              }
              
# Adds to it directly             return(cooccurs)
              cooccurs <<- cooccurs
            })
      }
#      if(DEBUG){
#        print(paste("Will place ", str(cooccurs)))
#      }
      #this will flatten the matrix
#      egRow[["cooccurs"]] <- cooccurs

#      epochNgrams <- eg["ngram"]
#      epochTable <- array(dim=c(nrow(epochNgrams),nrow(epochNgrams)),dimnames=epochNgrams)
#      
#      for(i in 1:nrow(epochNgrams)){
#        
#        epochNgrams[i]
#      }
#  str(list(uniqueUgrams))
#  str(list(cooccurs))
  res <- data.frame(egRow, uniqueUnigams=I(list(uniqueUgrams)), unigramCooccurs=I(list(cooccurs)))
#  if(DEBUG){
#    str(res)
#  }
  return(res)    
})

#cleanup
rm(df)
# dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
try(dbClearResult(rs))
# dbDisconnect(con, ...) closes the connection. Eg.
try(dbDisconnect(con))
# dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
try(dbUnloadDriver(drv))

return(c(ngramGrps=ngramGrps, epochGrps))
}

