# TODO: Add comment
# 
# Author: yia
###############################################################################



splitNgramToCompgrams <- function(ngram,compgramlen){
  if(compgramlen == 2){
    ugramsInNgram <- unlist(strsplit(ngram, ",",fixed = TRUE))
  } else {
    ugramsInNgram <- unlist(strsplit(ngram, '"',fixed = TRUE))
    ugramsInNgram <- aaply(ugramsInNgram[which(nzchar(ugramsInNgram))],1,function(s){
          Encoding(s) <- "UTF-8"
          ch1 <- substring(s,1,1)
          if(ch1=='('){
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
