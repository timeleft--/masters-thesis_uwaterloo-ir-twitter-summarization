# TODO: Add comment
# 
# Author: yaboulna
###############################################################################


date<-121221
epoch<-'1hr'
ngramlen<-2
db<-"full" #"sample-0.01" #"full"
supp<-5

source("conttable_construct.R")

dayGrpsVec <- conttable_construct(date, epoch, ngramlen, retEpochGrps=T, retNgramGrps=F, db=db, support=supp)
epochGrps <- dayGrpsVec$epochGrps[[1]]


############################
require(plyr)
lookupIxs <- function(comps, lkp){
#  comps <- strsplit(ngram,",")
  return(laply(comps, function(cmp) lkp[cmp,'ix']))
}

# Unit tests
#testLkp <- data.frame(ix=1:3, row.names=c("ug1","ug2","ug3"))
#testIxs <- lookupIxs(unlist(strsplit("ug1,ug3",",")),testLkp)
#str(testIxs)
## testIxs[["ug1"]]
#testIxs[[1]]
#testIxs[1]

############################


agreementTable <- function(comps,cooccurs, notoccurs, compsIx) {
  
  #TODO iterate over indeces and place the right cooc or notoc
  
  agreement <- matrix(c(cooccurs[compsIx[1],compsIx[2]],notoccurs[compsIx[1],compsIx[2]],
          notoccurs[compsIx[2], compsIx[1]],cooccurs[compsIx[2],compsIx[1]]),
      ncol=2,byrow=TRUE)
  
  return(agreement)
}

############################
  require(plyr)
  calcEpochAssoc <- function(eg){
  
    uniqueUgrams <- eg$uniqueUnigams[[1]]
    nUnique <- length(uniqueUgrams)
    cooccurs <- eg$unigramCooccurs[[1]]
    notoccurs <- eg$unigramsNotoccurs[[1]]
    ixLkp <- data.frame(ix=1:(nUnique+1), row.names=c(uniqueUgrams,TOTAL), check.names=TRUE)
    
    # take the last occurrence of every ngram (they will be repeated by the SQL join)
    uniqueNgrams <- eg$notuniqueNgrams[[1]][((1:(length(eg$notuniqueNgrams[[1]])/ngramlen)) * ngramlen)]
    
    
    calcNgramAssoc <- function(ng){
      
      require(psych)
      
      ngram <- ng # there will be only one (unique)
      
      comps <- strsplit(ngram,",")
      
      ngRes <- data.frame(ngram=ngram,comps = I(comps), stringsAsFactors=F)
      
      comps <- unlist(comps)
      
      compsIx <- lookupIxs(comps, ixLkp)
      
      agreet <- agreementTable(comps, cooccurs, notoccurs,compsIx)
      
      ngRes[1,"yuleq"] <-  Yule(agreet,Y=F)
       
      return(ngRes)
    }
#    debug(calcNgramAssoc)
  
    ngAssoc <- adply(uniqueNgrams,1,calcNgramAssoc,.expand=F)
    
    ngAssoc <- arrange(ngAssoc, -yuleq)
    
    require(stats)
    
# Preliminary test showed that this returns some negative corrs but no new positive correlations;
# they were all correlations between pairs that appear in highly supported bigrams (1+2,..etc)
    epochChisq <- chisq.test(cooccurs)
    positiveCorr <- which(epochChisq$stdres >= 2, arr.ind=TRUE)
    negativeCorr <- which(epochChisq$stdres <= -2, arr.ind=TRUE)
    
# Preliminary test showed that this returns no negative corrs but same positive ones as when using the 
# daigonal that represents the number of times the row unigram appears with/before "other" unigarms
# Actually they were all correlations between pairs that appear in highly supported bigrams (1+2,..etc)
#    cooccursZeroDiag <- cooccurs
#    diag(cooccursZeroDiag) <- 0
#    epochChisqZeroDiag <- chisq.test(cooccursZeroDiag) 
#    positiveCorrZeroDiag <- which(epochChisqZeroDiag$stdres >= 2, arr.ind=TRUE)
#    negativeCorrZeroDiag <- which(epochChisqZeroDiag$stdres <= -2, arr.ind=TRUE)
  
    return(data.frame(epochstartux=eg$epochstartux,date=eg$date,epochvol=eg$epochvol,ngramAssoc=I(list(ngAssoc))))
    
#  ngramLen <- row[1,"ngramlen"]
#  for(i in 1:nrow(ngramLen)) {
#    aloneCnt <- row[paste("alonecnt", i, sep=".")]
#    unigCnt <- bgRow[paste("unigramcnt", i, sep=".")]
#    
#    res["yuleq"] <- 
#  }
#  return(res)
  }
  
#  debug(calcEpochAssoc)


  ngrams2AssocT <- adply(epochGrps, 1, calcEpochAssoc, .expand=F) #,.parallel = TRUE)  will use doMC to parallelize on a higher level then no need here 

  
