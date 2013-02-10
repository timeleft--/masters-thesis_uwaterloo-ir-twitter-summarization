# TODO: Add comment
# 
# Author: yaboulna
###############################################################################



############################
while(!require(plyr)){
  install.packages("plyr")
}
lookupIxs <- function(comps, lkp){
#  comps <- strsplit(ngram,",")
  return(laply(comps, function(cmp) lkp[cmp]))
}

# Unit tests
#testIxs <- lookupIxs(unlist(strsplit("ug1,ug3",",")),testLkp)
#str(testIxs)
## testIxs[["ug1"]]
#testIxs[[1]]
#testIxs[1]

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
  firstBeforeNotSec <- cooccurs[compsIx[1],totalIx] - cooccurs[compsIx[1],compsIx[2]] # notoccurs[compsIx[1], compsIx[2]]
  
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
    print(e)
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
  calcEpochAssoc <- function(eg,ngramlen,day){
  
    try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Starting to calc epoch",eg[1,"epochstartux"])))
    
    uniqueUgrams <- eg$uniqueUnigrams[[1]]
    nUnique <- length(uniqueUgrams)
    cooccurs <- eg$unigramsCooccurs[[1]]
  #No notoccurrs
#    notoccurs <- eg$unigramsNotoccurs[[1]]
    
    epochvolume <- eg$epochvol
    
    ixLkp <- array(1:(nUnique+1))
    rownames(ixLkp) <- c(uniqueUgrams,TOTAL)
    totalIx <- (nUnique+1)
    
    uniqueNgrams <- eg$uniqueNgrams[[1]]
    
    calcNgramAssoc <- function(ng){
      
      ngram <- ng # there will be only one (unique)
      
      comps <- strsplit(ngram,",")
      
      ngRes <- data.frame(ngram=ngram,#comps = I(comps), 
          stringsAsFactors=F)
      
      comps <- unlist(comps)
      
      compsIx <- lookupIxs(comps, ixLkp)
      
      if(any(is.na(compsIx))){
        tryCatch(
            stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - ERROR: compsIx not positive:",paste(compsIx,collapse="|"),eg$epochstartux,paste(ng,collapse="|")))
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
      
      # As per Dunning (1993): Using likelihood ration test for testing the hypothesis that 
      # the unigrams are independent, that is p(first|second) = p(first|~second)= p(first)
      # The first row of agreement table can give the distribution of "first" given presence
      # of second: P(f|s) = P(f,s) / p(s) = (cnt(f,s)/epochvol) / (cnt(s)/epochvol) = agreet[1,1]/cnt(s)
      # The second row gives: P(f|~s) = P(f,~s) / p(~s) = agreet[2,1]/(epochvol - cnt(s))
      # Notice that p(~f|s) = 1 - p(f|s) = (cnt(s) - agreet[1,1])/cnt(s) => not in table
      # Also: (epochvol - cnt(s)) != cnt(first), as could be thought from looking at agreement table
      # Using the formula in the paper for the likelihood ratio, we put
      # n1 = cnt(s), k1 = cnt(f,s), n2 = (epochvol - cnt(s)), k2 = cnt(f,~s)
      n1 <- cooccurs[compsIx[2],totalIx]
      n2 <- (epochvolume - n1) #is this too large? should we use grand total of strong ngrams?
      k1 <- agreet[1,1]
      k2 <- agreet[2,1]
      p1 <- k1 / n1 # k1/n1
      p2 <- k2 / n2 # k2/n2
      pNumer <- cooccurs[compsIx[1],totalIx] / epochvolume #(k1+k2)/(n1+n2) = cnt(first)/(n1+n2)
      
      # for numerical stability
      lp1 <- log(p1)
      lp2 <- log(p2)
      lpNumer <- log(pNumer)
      
      lp1C <- log(1-p1)
      lp2C <- log(1-p2)
      lpNumerC <- log(1-pNumer) 
      
      lnumer <- (cooccurs[compsIx[1],totalIx] * lpNumer) + ((epochvolume-cooccurs[compsIx[1],totalIx]) * lpNumerC)
      
      ldenim <- (k1 * lp1) + ((n1-k1) * lp1C) + (k2 * lp2) + ((n2-k2) * lp2C) 
      
# It happens when one of the two unigrams appears only with the other.. that is if n1==k1 or if k2 == 0
#      if(is.nan(lnumer) || is.nan(ldenim)){
#        warning(paste("Dunning Lambda Not a Number (aOccs,k1,n1,k2,n2)=",cooccurs[compsIx[1],totalIx],k1,n1,k2,n2,
#                "ngram=",ngram))
#      }
      
      ngRes[1,"dunningLambda"] <- -2 * (lnumer - ldenim)
      
#      #L(p,k1,n1)L(p,k2,n2) = p^k1*(1-p)^(n1-k1)*p^k2*(1-p)^(n2-k2) = p^(k1+k2)*(1-p)^(n1+n2-(k1+k2))
#      numer <- (pNumer^cooccurs[compsIx[1],totalIx]) * ((1-pNumer)^(epochvolume-cooccurs[compsIx[1],totalIx]))
#      
#      #L(p1,k1,n1)L(p2,k2,n2)
#      denim <- (p1^k1)*((1-p1)^(n1-k1))*(p2^k2)*((1-p2)^(n2-k2))
#      
#      lhr <- numer / denim
#      
#      ngRes[1,"dunningLambda"] <- -2 * log(lhr)
      
      ngRes[1,"a1b1"] <- agreet[1,1]
      ngRes[1,"a1b0"] <- agreet[2,1]
      ngRes[1,"a0b1"] <- agreet[1,2]
      ngRes[1,"a0b0"] <- agreet[2,2]
      
      return(ngRes)
    }
#    debug(calcNgramAssoc)
  
    #idata.frame( causes Error in seq_len(nrow(df)) :   argument must be coercible to non-negative integer 
    ngAssoc <- adply(uniqueNgrams,1,calcNgramAssoc,.expand=F)
    
#    ngAssoc <- arrange(ngAssoc, -dunningLambda) #-yuleQ)
    ngAssoc["X1"] <- NULL
    
    try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Finished to calc epoch",eg[1,"epochstartux"])))
    
    return(data.frame(ngramlen=ngramlen,date=day,epochstartux=eg$epochstartux,epochvol=eg$epochvol,ngramAssoc=ngAssoc)) 
  }
  
#  debug(calcEpochAssoc)


####################################################    
#driver
DEBUG_NGA<-FALSE

REMOVE_EXITING_OUTPUTS<-FALSE

# parallelWithinDay<-FALSE
#parOpts<-"cores=24" #2 for debug 
#progress<-"none"

if(DEBUG_NGA){
  days<-c(121106,121110)
  db<-"sample-0.01" #"full"
  nCores <- 2
} else {
  days<-c() #all done
      #c(121021,121229)
      #c(121110, 130103, 121016, 121206, 121210, 120925, 121223, 121205, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116, 121106, 121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219)
  db<-"full"
  nCores <- 50 #30
}



  supp<-5
  epoch<-'1hr'
  ngramlen<-2

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
  
  nullCombine <- function(a,b) NULL
  allMonthes <- foreach(day=days,
          .inorder=FALSE, .combine='nullCombine') %dopar%
      {
        daySuccess <- paste("Unkown result for day",day)
        
        tryCatch({
        tableName <- paste('assoc',epoch,ngramlen,'_',day,sep="") 
        
        drv <- dbDriver("PostgreSQL")
        con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
            host="hops.cs.uwaterloo.ca", port="5433")
        if(dbExistsTable(con,tableName)){
          if(REMOVE_EXITING_OUTPUTS){
            dbRemoveTable(con,tableName)
            try(dbDisconnect(con))
            try(dbUnloadDriver(drv))
          } else {
            try(dbDisconnect(con))
            try(dbUnloadDriver(drv))
            stop(paste("Output table",tableName,"already exist. Please remove it yourself."))
          }
        }
        
        dayEpochGrps <- # doesn't work in case of dopar.. they must be doing something with environments NULL 
          conttable_construct(day, db=db, ngramlen2=ngramlen, epoch1=epoch, support=supp)
          #, parallel=parallelWithinDay, parOpts=parOpts)
        if(is.null(dayEpochGrps)){
          stop(paste("ngram_assoc() for day:", day, " - Didn't get  back the cooccurrence matrix"))
        } else {
          try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Got back the cooccurrence matrix")))
        }
        ngrams2AssocT <- 
          adply(idata.frame(dayEpochGrps), 1, calcEpochAssoc, ngramlen=ngramlen,day=day, .expand=F) #, .progress=progress)
              # This will be a disaster, because we are already in dopar: .parallel = parallelWithinDay,.paropts=parOpts)
        #Leave the hour of the day.. it's good
#            ngrams2AssocT['X1'] <- NULL
        
        try(stop(paste(Sys.time(), "ngram_assoc() for day:", day, " - Will write ngrams2AssocT to DB")))
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
  