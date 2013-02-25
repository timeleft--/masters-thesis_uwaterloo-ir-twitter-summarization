# TODO: Add comment
# 
# Author: yia
###############################################################################


stripEndChars <- function(ngram) {
  return(substring(ngram, 2, nchar(ngram)-1))
}

########################################################


splitNgramToCompgrams <- function(ngram,compgramlen){
  if(ngram[1]=='{'||ngram[1]=='('){
    ngram <- stripEndChars(ngram)
  }
  if(compgramlen == 2){
    ugramsInNgram <- unlist(strsplit(ngram, ",",fixed = TRUE))
  } else {
    ugramsInNgram <- unlist(strsplit(ngram, '"',fixed = TRUE))
    ugramsInNgram <- aaply(ugramsInNgram[which(nzchar(ugramsInNgram))],1,function(s){
          Encoding(s) <- "UTF-8"
          ch1 <- substring(s,1,1)
          if(ch1=='{'||ch1=='('){
            return(stripEndChars(s))
          } else if(ch1==','){
            return(substring(s,2,nchar(s)))
          } else { # The coma will be the last char
            return(substring(s,1,nchar(s)-1))
          }
        })
  }
  return(ugramsInNgram)
}


########################################################

initOccupiedEnv <- function(docLen) {
  occupiedPos <- new.env()
  for(id in row.names(docLen)){
    len <- docLen[id]
    if(is.na(len)){
      try(stop(paste("compgrams_utils#initOccupiedEnv - WARNING! Encountered an NA/NAN length. Setting to 71:",id)))
      len <- 71
    }
    assign(paste("o",id,sep=""),rep(0,len),envir=occupiedPos)
#    assign(paste("s",id,sep=""),1,envir=occupiedPos)
  }
  return(occupiedPos)
}

selectOccurrences <- function(occ, ngramlen2, occupiedEnv, allowOverlap = FALSE,colsToReturn=NULL) { #occs should come in descending order of prefernce
  
  if(is.na(occ$pos)){
    try(stop(paste("compgrams_utils#selectOccurrences - WARNING! Encountered an NA/NAN occ pos. Skipping:",paste(occ,collapse="|"))))
    return(NULL)
  }
  
  startPos <- occ$pos + 1 # pos is 0 based
  endPos <- startPos + ngramlen2 - 1
  
  key<-paste("o",occ$id,sep="")
  occPosId <- get(key,envir=occupiedEnv,inherits = FALSE)
  if((!allowOverlap && any(occPosId[startPos:endPos]>0))
   || (allowOverlap && all(occPosId[startPos:endPos]>0))){
    return(NULL)
  } # else 
  
  occPosId[startPos:endPos] <- occPosId[startPos:endPos] + 1
  assign(key,occPosId,envir=occupiedEnv)
  
  # This has to be the last statement
  if(is.null(colsToReturn)){
    return(occ)
  } else {
    return(occ[1,colsToReturn])
  }
}
#debug(selectOccurrences)

