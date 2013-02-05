# TODO: Add comment
# 
# Author: yaboulna
###############################################################################


date<-121221
epoch<-'1hr'
ngramlen<-2
db<-"sample-0.01" #"sample-0.01" #"full"
supp<-5

source("conttable_construct.R")

dayGrpsVec <- conttable_construct(date, epoch, ngramlen, retEpochGrps=T, retNgramGrps=F, db=db, support=supp)
epochGrps <- dayGrpsVec$epochGrps[[1]]


############################
require(plyr)
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
  
    uniqueUgrams <- eg$uniqueUnigrams[[1]]
    nUnique <- length(uniqueUgrams)
    cooccurs <- eg$unigramsCooccurs[[1]]
    notoccurs <- eg$unigramsNotoccurs[[1]]
    
    ixLkp <- array(1:(nUnique+1))
    rownames(ixLkp) <- c(uniqueUgrams,TOTAL)
    
    uniqueNgrams <- eg$uniqueNgrams[[1]]
    
    calcNgramAssoc <- function(ng){
      
      ngram <- ng # there will be only one (unique)
      
      comps <- strsplit(ngram,",")
      
      ngRes <- data.frame(ngram=ngram,#comps = I(comps), 
          stringsAsFactors=F)
      
      comps <- unlist(comps)
      
      compsIx <- lookupIxs(comps, ixLkp)
      
      agreet <- agreementTable(comps, cooccurs, notoccurs,compsIx)
      
      require(psych)
      ngRes[1,"yuleq"] <-  Yule(agreet,Y=F)
       
      return(ngRes)
    }
#    debug(calcNgramAssoc)
  
    ngAssoc <- adply(uniqueNgrams,1,calcNgramAssoc,.expand=F)
    
    ngAssoc <- arrange(ngAssoc, -yuleq)
    
    require(stats)
    
    return(data.frame(epochstartux=eg$epochstartux,epochvol=eg$epochvol,ngramAssoc=I(list(ngAssoc))))
  }
  
  debug(calcEpochAssoc)


  ngrams2AssocT <- adply(epochGrps, 1, calcEpochAssoc, .expand=F) #,.parallel = TRUE)  will use doMC to parallelize on a higher level then no need here 

  
