# TODO: Add comment
# 
# Author: yaboulna
###############################################################################


date<-121106
epoch<-'1hr'
ngramlen<-2
db<-"full" #"sample-0.01" #"full"
supp<-5
parallel<-FALSE
parOpts<-"cores=24" #2 for debug
source("conttable_construct.R")

dayGrpsVec <- conttable_construct(date, epoch, ngramlen, retEpochGrps=T, retNgramGrps=F, db=db, support=supp,
     parallel=parallel,parOpts=parOpts)
epochGrps <- dayGrpsVec$epochGrps[[1]]


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


agreementTable <- function(comps,cooccurs, notoccurs, compsIx) {
  
  #TODO iterate over indeces and place the right cooc or notoc
  
  agreement <- matrix(c(cooccurs[compsIx[1],compsIx[2]],notoccurs[compsIx[1],compsIx[2]],
          notoccurs[compsIx[2], compsIx[1]],cooccurs[compsIx[2],compsIx[1]]),
      ncol=2,byrow=TRUE)
  
  return(agreement)
}

############################
  while(!require(plyr)){
    install.packages("plyr")
  }
  calcEpochAssoc <- function(eg){
  
    uniqueUgrams <- eg$uniqueUnigrams[[1]]
    nUnique <- length(uniqueUgrams)
    cooccurs <- eg$unigramsCooccurs[[1]]
    notoccurs <- eg$unigramsNotoccurs[[1]]
    
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
      
      agreet <- agreementTable(comps, cooccurs, notoccurs,compsIx)
      
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
      
      #L(p,k1,n1)L(p,k2,n2) = p^k1*(1-p)^(n1-k1)*p^k2*(1-p)^(n2-k2) = p^(k1+k2)*(1-p)^(n1+n2-(k1+k2))
      numer <- (pNumer^cooccurs[compsIx[1],totalIx]) * ((1-pNumer)^(epochvolume-cooccurs[compsIx[1],totalIx]))
      
      #L(p1,k1,n1)L(p2,k2,n2)
      denim <- (p1^k1)*((1-p1)^(n1-k1))*(p2^k2)*((1-p2)^(n2-k2))
      
      lhr <- numer / denim
      
      ngRes[1,"dunningLambda"] <- -2 * log(lhr)
      
      return(ngRes)
    }
#    debug(calcNgramAssoc)
  
    ngAssoc <- adply(uniqueNgrams,1,calcNgramAssoc,.expand=F)
    
    ngAssoc <- arrange(ngAssoc, -dunningLambda) #-yuleQ)
    
    return(data.frame(epochstartux=eg$epochstartux,epochvol=eg$epochvol,ngramAssoc=I(list(ngAssoc))))
  }
  
 # debug(calcEpochAssoc)


  ngrams2AssocT <- adply(epochGrps, 1, calcEpochAssoc, .expand=F, .progress="text",
      .parallel = parallel,.paropts=parOpts)  

  
