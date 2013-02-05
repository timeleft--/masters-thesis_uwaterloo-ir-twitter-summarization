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


agreementTable <- function(comps,cooccurs, notoccurs, compsIx) {
  
  #TODONOT iterate over indeces and place the right cooc or notoc
  
  agreement <- matrix(c(cooccurs[compsIx[1],compsIx[2]],notoccurs[compsIx[1],compsIx[2]],
          cooccurs[compsIx[2],compsIx[1]],notoccurs[compsIx[2], compsIx[1]]),
      ncol=2,byrow=TRUE)
  
  return(agreement)
}

############################
  while(!require(plyr)){
    install.packages("plyr")
  }
  calcEpochAssoc <- function(eg,ngramlen,date){
  
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
      # The second row gives: P(f|~s) = P(f,~s) / p(~s) = agreet[1,2]/(epochvol - cnt(s))
      # Notice that p(~f|s) = 1 - p(f|s) = (cnt(s) - agreet[1,1])/cnt(s) => not in table
      # Also: (epochvol - cnt(s)) != cnt(first), as could be thought from looking at agreement table
      # Using the formula in the paper for the likelihood ratio, we put
      # n1 = cnt(s), k1 = cnt(f,s), n2 = (epochvol - cnt(s)), k2 = cnt(f,~s)
      n1 <- cooccurs[compsIx[2],totalIx]
      n2 <- (epochvolume - n1) #is this too large? should we use grand total of strong ngrams?
      k1 <- agreet[1,1]
      k2 <- agreet[1,2]
      p1 <- k1 / n1 # k1/n1
      p2 <- k2 / n2 # k2/n2
      pNumer <- cooccurs[compsIx[1],totalIx] / epochvolume #(k1+k2)/(n1+n2) = cnt(first)/(n1+n2)
      
      #L(p,k1,n1)L(p,k2,n2) = p^k1*(1-p)^(n1-k1)*p^k2*(1-p)^(n2-k2) = p^(k1+k2)*(1-p)^(n1+n2-(k1+k2))
      numer <- (pNumer^cooccurs[compsIx[1],totalIx]) * ((1-pNumer)^(epochvolume-cooccurs[compsIx[1],totalIx]))
      
      #L(p1,k1,n1)L(p2,k2,n2)
      denim <- (p1^k1)*((1-p1)^(n1-k1))*(p2^k2)*((1-p2)^(n2-k2))
      
      lhr <- numer / denim
      
      ngRes[1,"dunningLambda"] <- -2 * log(lhr)
      
      ngRes[1,"a1b1"] <- agreet[1,1]
      ngRes[1,"a1b0"] <- agreet[1,2]
      ngRes[1,"a0b1"] <- agreet[2,1]
      ngRes[1,"a0b0"] <- agreet[2,2]
      
      return(ngRes)
    }
#    debug(calcNgramAssoc)
  
    ngAssoc <- adply(uniqueNgrams,1,calcNgramAssoc,.expand=F)
    
#    ngAssoc <- arrange(ngAssoc, -dunningLambda) #-yuleQ)
    ngAssoc["X1"] <- NULL
    return(data.frame(ngramlen=ngramlen,date=date,epochstartux=eg$epochstartux,epochvol=eg$epochvol,ngramAssoc=ngAssoc)) 
  }
  
 # debug(calcEpochAssoc)


####################################################    
#driver
DEBUG<-TRUE
if(DEBUG){
#  date<-121106
#  epoch<-'1hr'
  db<-"sample-0.01" #"full"
#  supp<-5
#  parallel<-FALSE
#  parOpts<-"cores=24" #2 for debug
  nCores <- 2
} else {
  db<-"full"
  nCores <- 31
}
  ngramlen2<-2

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
  
  nullCombine <- function(a,b) NULL
  allMonthes <- foreach(date=c(121110, 130103),#, 121016, 121206, 121210, 120925, 121223, 121205, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116, 121106, 121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219),
          .inorder=FALSE, .combine='nullCombine') %dopar%
      {
        dayGrpsVec <- conttable_construct(date, retEpochGrps=T, retNgramGrps=F, db=db)
          #, support=supp, parallel=parallel, parOpts=parOpts,ngramlen=2,epoch1=epoch)
        epochGrps <- dayGrpsVec$epochGrps[[1]]
        ngrams2AssocT <- 
          adply(epochGrps, 1, calcEpochAssoc, ngramlen=ngramlen2,date=date, .expand=F, .progress="text")
            # This doesn't work .parallel = parallel,.paropts=parOpts)
        ngrams2AssocT['X1'] <- NULL
        
        tableName <- paste('assoc',ngramlen2,'_',date,sep="") 
        
        drv <- dbDriver("PostgreSQL")
        con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
            host="hops.cs.uwaterloo.ca", port="5433")
        if(dbExistsTable(con,tableName)){
          dbRemoveTable(con,tableName)
        }
        dbWriteTable(con,tableName,ngrams2AssocT)
        try(dbDisconnect(con))
        try(dbUnloadDriver(drv))
      }
  
  