# TODO: Add comment
# 
# Author: yaboulna
###############################################################################
NGA.argv <- commandArgs(trailingOnly = TRUE)
NGA.ngramlen1<-as.integer(NGA.argv[1])

NGA.ngramlen2<-NGA.ngramlen1+1

G.workingRoot <- "~/r_output/occ_yuleq_working/"
G.dataRoot <- "~/r_output/"

NGA.logLabel <- "ngram_assoc"

DEBUG_NGA<-TRUE
NGA.TRACE<-FALSE
REMOVE_EXITING_OUTPUTS<-TRUE
SKIP_DAY_IF_COMPGRAM_FILE_EXISTS<-FALSE

# parallelWithinDay<-FALSE
#parOpts<-"cores=24" #2 for debug 
#progress<-"none"

if(DEBUG_NGA){
  days<-c(121106,121110)
  db<-"sample-0.01" #"full"
  nCores <- 2
  
  workingRoot <- G.workingRoot <- "~/r_output_debug/occ_yuleq_working/"
  dataRoot<-G.dataRoot<-"~/r_output_debug/"
  
  if(NGA.TRACE){
    NGA.ngramlen1<-1
    NGA.ngramlen2<-NGA.ngramlen1+1
      
    ngramlen1<-1
    ngramlen2<-ngramlen1+1
  }
} else {
  
#  days1<- unique(c(121123,121105,121104,121106,121215,121222,130104,120914,121231,121223,121013,120925,121016,120926,121026,120930,121008,121110,121119,121206,121122,121125))       
  days <- unique(c( 120925,  120926,  120930,  121008,  121013,  121016,  121026,  121027,  121028,  121029,  121030,  121103,  121104,  121105,  121106,  121108,  121110,  121116,  121119,  121120,  121122,  121123,  121125,  121205,  121206,  121210,  121214,  121215,  121231,  130103,  130104)) #missing data: 120914,121222,  121223,
  # length 2:
  #c(121021,121229)
  #c(121110, 130103, 121016, 121206, 121210, 120925, 121223, 121205, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116, 121106, 121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219)
  db<-"full"
  nCores <- 31
  
 
}


supp<-5
epoch<-'1hr'




source("conttable_construct.R")

while(!require(plyr)){
  install.packages("plyr")
}
while(!require(foreach)){
  install.packages("foreach")
}
while(!require(doMC)){
  install.packages("doMC")
}
registerDoMC(cores=nCores)

while(!require(RPostgreSQL)){
  install.packages("RPostgreSQL")
}  

require(Matrix)
############################
while(!require(plyr)){
  install.packages("plyr")
}
lookupIxs <- function(comps, lkp){
  return(laply(comps, function(cmp) lkp[cmp]))
}


############################

# This focuses on the meaning that the event is appearance of first preceeding second, against appearance of first
# preceeding anything else.. or appearnce of second preceeded by anything else
agreementTable <- function(comps,cooccurs, 
    totalIx, #notoccurs,
    compsIx, volume) {
  
  #TODONOT iterate over indeces and place the right cooc or notoc
  
  ## result matrix will be:
#  sec\fst| fst1 | fst0 |
#  sec2   |      |      |
#  sec0   |      |      |
     
  secAfterNotFirst <- cooccurs[compsIx[2],totalIx] - cooccurs[compsIx[1],compsIx[2]] # THIS WAS WRONG notoccurs[compsIx[2],compsIx[1]],
  
  if(secAfterNotFirst < 0){
    try(stop(paste("WARNING: a0b1 was negative: ",secAfterNotFirst,". bCnt =",cooccurs[compsIx[2],totalIx],", compsIx:", paste(compsIx,collapse="|"))))
    secAfterNotFirst <- 0
  }
  
  firstBeforeNotSec <- cooccurs[compsIx[1],totalIx] - cooccurs[compsIx[1],compsIx[2]] # notoccurs[compsIx[1], compsIx[2]]
  
  if(secAfterNotFirst < 0){
    try(stop(paste("WARNING: a1b0 was negative: ",firstBeforeNotSec,". aCnt =",cooccurs[compsIx[1],totalIx],", compsIx:", paste(compsIx,collapse="|"))))
    firstBeforeNotSec <- 0
  }
  
  agreement <- matrix(c(cooccurs[compsIx[1],compsIx[2]],secAfterNotFirst,
          firstBeforeNotSec,
          (volume-cooccurs[compsIx[1],compsIx[2]]-firstBeforeNotSec-secAfterNotFirst)),
      ncol=2,byrow=TRUE)
  
  return(agreement)
}
# debug(agreementTable)

#####################

NGA.handleErrors <- function(e) {
  if(NGA.DEBUG_ERRORS){
    try(stop(e))
  } else {
    stop(e)
  }
}
# DEBUG_ERRORS <- TRUE
# debug(handleErrors)
NGA.DEBUG_ERRORS <- TRUE

############################
  while(!require(plyr)){
    install.packages("plyr")
  }
  
  
  
calcEpochAssoc <- function(eg,ngramlen2,day,alloccStaging,
#    cntStaging,
    selStaging){
  
    try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Starting to calc  pair-wise association in epoch",eg[1,"epochstartux"])))
    
    uniqueUgrams <- eg$uniqueUnigrams[[1]]
    nUnique <- length(uniqueUgrams)
    cooccurs <- eg$unigramsCooccurs[[1]]
  #No notoccurrs
#    notoccurs <- eg$unigramsNotoccurs[[1]]
    
    epochvolume <- eg$epochvol[1]
    
    ixLkp <- array(1:(nUnique+1))
    rownames(ixLkp) <- c(uniqueUgrams,TOTAL)
    totalIx <- (nUnique+1)
    
    uniqueNgrams <- eg$uniqueNgrams[[1]]
    
    calcNgramAssoc <- function(ng){
      
      ngram <- ng # there will be only one (unique)
      
      comps <- splitNgramToCompgrams(ngram,ngramlen2)
      
      ngRes <- data.frame(ngram=ngram,#comps = I(comps), 
          stringsAsFactors=F)
      
      comps <- unlist(comps)
      
      compsIx <- lookupIxs(comps, ixLkp)
      
      if(any(is.na(compsIx))){
        tryCatch(
            stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - ERROR: compsIx not positive:",paste(compsIx,collapse="|"),
                    eg$epochstartux[1],paste(ng,collapse="|")))
            ,error=NGA.handleErrors)
        return(NULL)
      }
      
      agreet <- agreementTable(comps, cooccurs, 
        totalIx, #notoccurs,
        compsIx,epochvolume)
      
      while(!require(psych)){
        install.packages("psych")
      }
      ngRes[1,"yuleQ"] <-  Yule(agreet,Y=F)
      
      if(ngRes[1,"yuleQ"]<=0){
        return(NULL)
      }
#      # As per Dunning (1993): Using likelihood ration test for testing the hypothesis that 
#      # the unigrams are independent, that is p(first|second) = p(first|~second)= p(first)
#      # The first row of agreement table can give the distribution of "first" given presence
#      # of second: P(f|s) = P(f,s) / p(s) = (cnt(f,s)/epochvol) / (cnt(s)/epochvol) = agreet[1,1]/cnt(s)
#      # The second row gives: P(f|~s) = P(f,~s) / p(~s) = agreet[2,1]/(epochvol - cnt(s))
#      # Notice that p(~f|s) = 1 - p(f|s) = (cnt(s) - agreet[1,1])/cnt(s) => not in table
#      # Also: (epochvol - cnt(s)) != cnt(first), as could be thought from looking at agreement table
#      # Using the formula in the paper for the likelihood ratio, we put
#      # n1 = cnt(s), k1 = cnt(f,s), n2 = (epochvol - cnt(s)), k2 = cnt(f,~s)
#      n1 <- cooccurs[compsIx[2],totalIx]
#      n2 <- (epochvolume - n1) #is this too large? should we use grand total of strong ngrams?
#      k1 <- agreet[1,1]
#      k2 <- agreet[2,1]
#      p1 <- k1 / n1 # k1/n1
#      p2 <- k2 / n2 # k2/n2
#      pNumer <- cooccurs[compsIx[1],totalIx] / epochvolume #(k1+k2)/(n1+n2) = cnt(first)/(n1+n2)
#      
#      # for numerical stability
#      lp1 <- log(p1)
#      lp2 <- log(p2)
#      lpNumer <- log(pNumer)
#      
#      lp1C <- log(1-p1)
#      lp2C <- log(1-p2)
#      lpNumerC <- log(1-pNumer) 
#      
#      lnumer <- (cooccurs[compsIx[1],totalIx] * lpNumer) + ((epochvolume-cooccurs[compsIx[1],totalIx]) * lpNumerC)
#      
#      ldenim <- (k1 * lp1) + ((n1-k1) * lp1C) + (k2 * lp2) + ((n2-k2) * lp2C) 
#      
## It happens when one of the two unigrams appears only with the other.. that is if n1==k1 or if k2 == 0
##      if(is.nan(lnumer) || is.nan(ldenim)){
##        warning(paste("Dunning Lambda Not a Number (aOccs,k1,n1,k2,n2)=",cooccurs[compsIx[1],totalIx],k1,n1,k2,n2,
##                "ngram=",ngram))
##      }
#      
#      ngRes[1,"dunningLambda"] <- -2 * (lnumer - ldenim)
#      
##      #L(p,k1,n1)L(p,k2,n2) = p^k1*(1-p)^(n1-k1)*p^k2*(1-p)^(n2-k2) = p^(k1+k2)*(1-p)^(n1+n2-(k1+k2))
##      numer <- (pNumer^cooccurs[compsIx[1],totalIx]) * ((1-pNumer)^(epochvolume-cooccurs[compsIx[1],totalIx]))
##      
##      #L(p1,k1,n1)L(p2,k2,n2)
##      denim <- (p1^k1)*((1-p1)^(n1-k1))*(p2^k2)*((1-p2)^(n2-k2))
##      
##      lhr <- numer / denim
##      
##      ngRes[1,"dunningLambda"] <- -2 * log(lhr)
      
      ngRes[1,"a1b1"] <- agreet[1,1]
      ngRes[1,"a1b0"] <- agreet[2,1]
      ngRes[1,"a0b1"] <- agreet[1,2]
      ngRes[1,"a0b0"] <- agreet[2,2]
      
      return(ngRes)
    }
#    debug(calcNgramAssoc)
  
    #idata.frame( causes Error in seq_len(nrow(df)) :   argument must be coercible to non-negative integer 
    ngAssoc <- adply(uniqueNgrams,1,calcNgramAssoc,.expand=F)
    
    if(is.null(ngAssoc) || is.null(ngAssoc$yuleQ)) {
      try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - no ngrams with positive yuleQ for epoch",eg[1,"epochstartux"])))
      return(NULL)
    }
    
#    ngAssoc <- arrange(ngAssoc, -dunningLambda) #-yuleQ)
    ngAssoc["X1"] <- NULL
    
    try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Finished to calc paiswise associtation for epoch",eg[1,"epochstartux"])))
    
    #######################################################
    
    try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Starting to form compgrams according to high association in epoch",eg[1,"epochstartux"])))
    
    epochstartux<-eg$epochstartux[1]
    
#  ########################
#  sec0CurrDay <-  as.numeric(as.POSIXct(strptime(paste(day,"0000",sep=""),
#              "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01"))
#  #a7'er elshahr ya me3allem
    ##  sec0NextDay <-  as.numeric(as.POSIXct(strptime(paste(day+1,"0000",sep=""),
    ##              "%y%m%d%H%M", tz="Pacific/Honolulu"),origin="1970-01-01"))
#  sec0NextDay <- sec0CurrDay + (60*60*24)
#  
#  sql <- sprintf("select epochstartmillis, totalcnt
#          from volume_%s%d%s where epochstartmillis >= %.0f and epochstartmillis < %.0f;", epoch, ngramlen2, ifelse(ngramlen2<3,'',paste("_",day, sep="")),
#      (sec0CurrDay-(120*60)) * 1000, (sec0NextDay+(120*60)) * 1000) # add 2 hours to either side to avoid timezone shit
#  
#  try(stop(paste(Sys.time(),NGA.logLabel, "for day:",day, " - Fetching ngram volumes using sql:\n ", sql)))
#  
#  ngramVolRs <- dbSendQuery(con, sql)
#  
#  ngramVolDf <- fetch(ngramVolRs, n=-1)
#  
#  try(stop(paste(Sys.time(),NGA.logLabel, "for day:",day, " - Fetched ngram volumes. Num Rows: ", nrow(ngramVolDf))))
#  
#  try(dbClearResult(ngramVolRs))
#  
#  ############################ 
#  # sorted because we'll use the volume to load the data for each epoch.. this is different from using indexes for
#  # loading parts of the cnt tables, which proved tricky :(
#  # cannot neglect any part of the data bceause we use vollume to skip ahead: and cnt > %d support
# 
#  if(ngramlen2 == 2){
#	  sql <- sprintf("select * from ngrams%d where date=%d order by timemillis;",ngramlen2,day)
#  } else {
#    sql <- sprintf("select * from compgrams%d_%d order by timemillis;",ngramlen2,day)    
#  }
#  
#  try(stop(paste(Sys.time(),NGA.logLabel, "for day:",day, " - Fetching ngram occurrences using sql:\n ", sql)))
#  
#  ngramOccRs <- dbSendQuery(con,sql)
#  
    ##  ngramOccDf <- fetch(ngramOccRs, n=-1) # if ordered we can fetch them in chuncks
    ##  
    ##  try(stop(paste(Sys.time(), NGA.logLabel, "for day:", day, " - Fetched ngram occurrences. Num Rows: ", length(ngramOccDf))))
    ##  
    ##  try(dbClearResult(ngramOccRs))
#  
#  #########################
#  
    
    if(ngramlen2 == 2){
      sqlTemplate <- sprintf("select CAST(id as varchar), CAST(timemillis as varchar), date, ngram, ngramlen, tweetlen, pos from ngrams%d where date=%d and timemillis >= (%%.0f * 1000::INT8) and timemillis < (%%.0f * 1000::INT8) order by timemillis;",ngramlen2,day)
    } else {
      sqlTemplate <- sprintf("select CAST(id as varchar), CAST(timemillis as varchar), date, ngram, ngramlen, tweetlen, pos from compgrams%d_%d where timemillis >= (%%.0f * 1000::INT8) and timemillis < (%%.0f * 1000::INT8) order by timemillis;",ngramlen2,day)    
    }
    
    SEC_IN_EPOCH <- c(X5min=(60*5), X1hr=(60*60), X1day=(24*60*60)) 
    
    flattenNgram <- function(ngram){
      paste("{",paste(splitNgramToCompgrams(ngram,ngramlen2),collapse=","),"}",sep="")
    } 
    
    
    #    epochNgramVol <- ngramVolDf[ngramVolDf$epochstartux == (epochstartux), "totalcnt"]
#    
#    epochNgramOccs <- fetch(ngramOccRs, n=epochNgramVol) # if ordered we can fetch them in chuncks
    
    sql <- sprintf(sqlTemplate,
        epochstartux, (epochstartux + SEC_IN_EPOCH[[paste("X",epoch,sep="")]]))
    
    try(stop(paste(Sys.time(),NGA.logLabel, "for day:",day, " - Fetching ngram occurrences for epoch using sql:\n ", sql)))
    
    drv <- dbDriver("PostgreSQL")
    con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
        host="hops.cs.uwaterloo.ca", port="5433")
    
    epochNgramOccRs <- dbSendQuery(con,sql)
    epochNgramOccs <- fetch(epochNgramOccRs, n=-1)
    try(dbClearResult(epochNgramOccRs))
    
    # dbDisconnect(con, ...) closes the connection. Eg.
    try(dbDisconnect(con))
    # dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
    try(dbUnloadDriver(drv))
    
    try(stop(paste(Sys.time(), NGA.logLabel, "for day:", day, " - Fetched ngram occurrences for epoch",epochstartux,". Num Rows: ", nrow(epochNgramOccs))))
    
    # epochNgramOccs will be in the uni+(ngA,ngB,..) remove the paranthesis and convert plus to ,
    if(ngramlen2>3){
      epochNgramOccs <- within(epochNgramOccs,{
            # This doesn't have any effect... the encoding remains "unkown" Encoding(ngram) <- "UTF-8"
            #FIXME: Any non-latin character gets messed up here.. that's a big bummer for R; the second!
            ngram <-  sub('{','"{',ngram,fixed=TRUE)
            ngram <-  sub('}','}"',ngram,fixed=TRUE)
            ngram <-  sub('+',',',ngram,fixed=TRUE)
          })
    } else if(ngramlen2==3){
      epochNgramOccs <- within(epochNgramOccs,{
            # This doesn't have any effect... the encoding remains "unkown" Encoding(ngram) <- "UTF-8"
            #FIXME: Any non-latin character gets messed up here.. that's a big bummer for R; the second!
            ngram <-  sub('(','"(',ngram,fixed=TRUE)
            ngram <-  sub(')',')"',ngram,fixed=TRUE)
            ngram <-  sub('+',',',ngram,fixed=TRUE)
          })
    } else {
      epochNgramOccs <- within(epochNgramOccs,{
            ngram <- stripEndChars(ngram)
          })
    }

# Won't work now that the time is cast as a varchar    
#    if(DEBUG_NGA){
#      earlierEpochCheck <- which(epochNgramOccs$timemillis < (epochstartux * 1000))
#      if(any(earlierEpochCheck)){
#        warning("Some ngrams we are fetching are of an earlier epoch", paste(earlierEpochCheck,collapse = "|"))
#      }
#      rm(earlierEpochCheck)
#      
#      laterEpochCheck <- which(epochNgramOccs$timemillis >= ((3600 + epochstartux) * 1000)) # THIS IS for 1hr epoch only
#      if(any(laterEpochCheck)){
#        warning("Some ngrams we are fetching are of a later epoch", paste(laterEpochCheck,collapse = "|"))
#      }
#      rm(laterEpochCheck)
#    }
    
###########################
    
    ngAssoc <- arrange(ngAssoc,desc(yuleQ),desc(a1b1))
    
    epochDocId <- unique(epochNgramOccs$id)
   
    occupiedPos1 <- Matrix(0,
        nrow=length(epochDocId),
        ncol=71,
        byrow=FALSE,
        sparse=TRUE,
        dimnames=list(epochDocId,NULL))
    
    selOccsMask1 <- rep(FALSE, nrow(epochNgramOccs))
    
    ix1 <-1
    ngramSelect <- function(nga) { 
      
      ngramMask <- (epochNgramOccs$ngram == nga$ngram)
      ngramIxes <- which(ngramMask) 
          
      occSelect <- function(occ) { 
        startPos <- occ$pos + 1 # pos is 0 based
        endPos <- startPos + ngramlen2 - 1
        
        
        if(!any(occupiedPos1[occ$id,startPos:endPos]>0)){
          occupiedPos1[occ$id,startPos:endPos] <- occupiedPos1[occ$id,startPos:endPos] + 1
          selOccsMask1[ngramIxes[ix1]] <<- TRUE
        }
        
        ix1 <<- ix1 + 1
        
        occupiedPos1 <<- occupiedPos1
        
        return(occ)
      }
#      debug(occSelect)
      
      ngramOccsDf <- adply(epochNgramOccs[ngramMask,],1,occSelect,.expand=F)
      
      return(ngramOccsDf)
    }
#    debug(ngramSelect)
    
    yuleOccs <- adply(idata.frame(ngAssoc),1,ngramSelect, .expand=F)
    yuleOccs$X1 <- NULL
    
    write.table(yuleOccs, file = alloccStaging, append = TRUE, quote = FALSE, sep = "\t",
        eol = "\n", na = "NA", dec = ".", row.names = FALSE,
        col.names = FALSE, # qmethod = c("escape", "double"),
        fileEncoding = "UTF-8")

    selOccs <- subset(epochNgramOccs,selOccsMask1,select=c("ngram","id","timemillis","date","ngramlen","tweetlen","pos"))
    write.table(selOccs, file = selStaging, append = TRUE, quote = FALSE, sep = "\t",
        eol = "\n", na = "NA", dec = ".", row.names = FALSE,
        col.names = FALSE, # qmethod = c("escape", "double"),
        fileEncoding = "UTF-8")
    
##    # If there are duplicates then assignment problem solution will not work.. we don't want to risk that
##    epochNgramOccs <- epochNgramOccs[!duplicated(epochNgramOccs["id","ngram","pos"]),]
#    
#    positiveYuleQ <- which(ngAssoc$yuleQ > 0)
#    
#    occAssoc <- merge(epochNgramOccs, subset(ngAssoc,yuleQ > 0,select=c(ngram,yuleQ,a1b1,dunningLambda)), by="ngram", sort=F, suffixes=c("",""))
#    
#    #### Copy Ngram Occs
#    if(ngramlen2>2){
#      
#      occAssoc <- within(occAssoc,{
#            ngram<-flattenNgram(ngram)
#          })
##          aaply(occAssoc,1,function(occ) { 
##            occ$ngram<-flattenNgram(occ$ngram)
##            return(occ)
##          } )
#      
#    } else {
#      
#      occAssoc <- within(occAssoc,{
#            ngram<-paste("{",ngram,"}",sep="")
#          })
#      
#    }
#    
#    write.table(occAssoc[,c("id","timemillis","date","ngram","ngramlen","tweetlen","pos")], file = alloccStaging, append = TRUE, quote = FALSE, sep = "\t",
#        eol = "\n", na = "NA", dec = ".", row.names = FALSE,
#        col.names = FALSE, # qmethod = c("escape", "double"),
#        fileEncoding = "UTF-8")
#    
#    rm(towrite)
#    ####### Select the occurrences for which to discount counts of shorter compgrams
#    contextualAssoc <- function(tweetOccs){
#      if(nrow(tweetOccs) == 1){
#        return(tweetOccs)
#      }
#      
#      #tweetOccs$dunningLambda[which(is.na(tweetOccs$dunningLambda))] <- Inf
#      
#      tweetOccs <- arrange(tweetOccs,desc(yuleQ),desc(a1b1),desc(dunningLambda))
#
#      occupied <- rep(0,tweetOccs$tweetlen[1])
#      
#      selection <- adply(tweetOccs,1,function(occ){
#        startPos <- occ$pos
#        endPos <- startPos + ngramlen2 - 1
#        
#        if(any(occupied[startPos:endPos]>0)){
#          return(NULL)
#        } 
#        
#        occupied[startPos:endPos] <- occupied[startPos:endPos] + 1
#        occupied <<- occupied
#        
#        return(occ)
#      })
#  
#      if(any(occupied>1)){
#        try(stop(paste("ERROR! Overlapping NGram Occurrences after all in ", tweetOccs$id[1], ":", paste(tweetOccs$ngram[which(occupied>1)],collapse="|"))))
#      }
#      
#      if(all(occupied==0)){
#        try(stop(paste("WARNING! Nothing selected from the occurrences in ", tweetOccs$id[1])))
#      }
#  
#      return(selection)
#    }
##    debug(contextualAssoc)
#    
#    #idata.frame(
#    selOcc <- ddply(occAssoc,c("id"),contextualAssoc)
#    
#    write.table(selOcc, file = selStaging, append = TRUE, quote = FALSE, sep = "\t",
#        eol = "\n", na = "NA", dec = ".", row.names = FALSE,
#        col.names = FALSE, # qmethod = c("escape", "double"),
#        fileEncoding = "UTF-8")
#    
##    selCnt <- ddply(idata.frame(selOcc),c("ngram"),summarize,cnt=length(id))
##    selCnt$epochstartux<-epochstartux
##    selCnt$date<-day
##    selCnt$ngramlen<-ngramlen2
##    
##    write.table(selCnt, file = cntStaging, append = TRUE, quote = FALSE, sep = "\t",
##        eol = "\n", na = "NA", dec = ".", row.names = FALSE,
##        col.names = FALSE, # qmethod = c("escape", "double"),
##        fileEncoding = "UTF-8")
#   
#    ### Aggregate to counts by ngram
#    
#    
#    try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Finished forming compgrams for epoch",eg[1,"epochstartux"])))
#    
    
    #######################################
    
    
    return(data.frame(ngramlen=ngramlen2,date=day,epochstartux=eg$epochstartux[1],epochvol=eg$epochvol[1],ngramAssoc=ngAssoc)) 
  }
  
#  debug(calcEpochAssoc)


####################################################    
#driver

  
  nullCombine <- function(a,b) NULL
  allMonthes <- foreach(day=days,
          .inorder=FALSE, .combine='nullCombine') %dopar%
      {
        daySuccess <- paste("Unknown result for day",day)
        
        tryCatch({
        tableName <- paste('assoc',epoch,NGA.ngramlen2,'_',day,sep="") 
        
        drv <- dbDriver("PostgreSQL")
        con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
            host="hops.cs.uwaterloo.ca", port="5433")
        if(dbExistsTable(con,tableName)){
          if(REMOVE_EXITING_OUTPUTS){
            dbRemoveTable(con,tableName)
#            try(dbDisconnect(con))
#            try(dbUnloadDriver(drv))
          } else {
            try(dbDisconnect(con))
            try(dbUnloadDriver(drv))
            stop(paste("Output table",tableName,"already exist. Please remove it yourself."))
          }
        }
        try(dbDisconnect(con))
        try(dbUnloadDriver(drv))
        
        workingRoot<-G.workingRoot
        dataRoot<-G.dataRoot
        stagingDir <- workingRoot
        if(!file.exists(stagingDir))
          dir.create(stagingDir,recursive = T)
        
        alloccStaging <- paste(stagingDir,"/",day,".csv",sep="")
        file.create(alloccStaging) #create or truncate
        
#        cntStaging <- paste(stagingDir,"cnt_",day,".csv",sep="")
#        file.create(cntStaging)
        
        selStaging <- paste(stagingDir,"sel_",day,".csv",sep="")
        file.create(selStaging)
        
        
        outputDir <- paste(dataRoot,"/occ_yuleq_",NGA.ngramlen2,"/",sep="")
        
        
        if(!file.exists(outputDir))
          dir.create(outputDir,recursive = TRUE)
        
        
        outputFile <- paste(outputDir,day,".csv",sep="");
        
        if(file.exists(outputFile)){
          
          if(SKIP_DAY_IF_COMPGRAM_FILE_EXISTS){
            return(paste("Skipping day for which output exists:",day)) # This gets ignored somehow.. connect then the default "Success"
          }
          
          bakname <- paste(outputFile,"_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="")
          warning(paste("Renaming existing output file",outputFile,bakname))
          file.rename(outputFile, #from
              bakname) #to
        }
        
        
        
#        cntOutput <- paste(outputDir,"/cnt_",day,".csv",sep="");
#        
#        if(file.exists(cntOutput)){
#          
#          if(SKIP_DAY_IF_COMPGRAM_FILE_EXISTS){
#            return(paste("Skipping day for which output exists:",day)) # This gets ignored somehow.. connect then the default "Success"
#          }
#          
#          bakname <- paste(cntOutput,"_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="")
#          warning(paste("Renaming existing output file",cntOutput,bakname))
#          file.rename(cntOutput, #from
#              bakname) #to
#        }
       

        
        selOutput <- paste(outputDir,"/sel_",day,".csv",sep="");
        
        if(file.exists(selOutput)){
          
          if(SKIP_DAY_IF_COMPGRAM_FILE_EXISTS){
            return(paste("Skipping day for which output exists:",day)) # This gets ignored somehow.. connect then the default "Success"
          }
          
          bakname <- paste(selOutput,"_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="")
          warning(paste("Renaming existing output file",selOutput,bakname))
          file.rename(selOutput, #from
              bakname) #to
        }
        
        
        
#  # create file to make sure this will be possible
#  file.create(outputFile)
        
        dayEpochGrps <- # doesn't work in case of dopar.. they must be doing something with environments NULL 
          conttable_construct(day, db=db, ngramlen1=NGA.ngramlen1,ngramlen2=NGA.ngramlen2, epoch1=epoch, support=supp)
          #, parallel=parallelWithinDay, parOpts=parOpts)
        if(is.null(dayEpochGrps)){
          stop(paste("ngram_assoc() for day:", day, " - Didn't get  back the cooccurrence matrix"))
        } else {
          try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Got back the cooccurrence matrix")))
        }
        
        ngrams2AssocT <- 
          adply(idata.frame(dayEpochGrps), 1, calcEpochAssoc, ngramlen2=NGA.ngramlen2,day=day, .expand=F,
              alloccStaging=alloccStaging,
#              cntStaging=cntStaging,
              selStaging=selStaging) #, .progress=progress)
              # This will be a disaster, because we are already in dopar: .parallel = parallelWithinDay,.paropts=parOpts)
        #Leave the hour of the day.. it's good
#            ngrams2AssocT['X1'] <- NULL
     
        try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - writing", outputFile)))
        file.rename(alloccStaging, outputFile)    
#        file.rename(cntStaging, cntOutput)
  
         try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - writing", selOutput)))
        file.rename(selStaging, selOutput)
        
        drv <- dbDriver("PostgreSQL")
        con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
                host="hops.cs.uwaterloo.ca", port="5433")
        try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Will write", tableName, "to DB")))
        dbWriteTable(con,tableName,ngrams2AssocT)
        try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Finished writing to DB")))
        try(dbDisconnect(con))
        try(dbUnloadDriver(drv))
        daySuccess <<- paste("Success for day",day) 
      }
      ,error=function(e) daySuccess <<- paste("Failure for day",day,e)
      ,finally=try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - ", daySuccess)))
      )
      }
  