# TODO: Add comment
# 
# Author: yia
###############################################################################

SKIP_DAYS_FOR_WHICH_OUTPUT_EXISTS<-FALSE

CGX.DEBUG <- TRUE

CGX.eopch2 <- '1hr'
CGX.ngramlen2 <- 2
CGX.db <- 'full'

CGX.loglabel.DEFAULT <- "compgrams-extend"
CGX.loglabel <- CGX.loglabel.DEFAULT

if(CGX.DEBUG){
  epoch2=CGX.epoch2
  ngramlen2=CGX.ngramlen2
  db='sample-0.01'
  day<-121110
  maxPos=70
  startPos=0
  inputPath = "~/r_output/compound_unigrams/"
  outputRoot = "~/r_output/"
}


while(!require(foreach)){
  install.packages("foreach")
}
while(!require(doMC)){
  install.packages("doMC")
}
registerDoMC(cores=CPU.nCores)

while(!require(plyr)){
  install.packages("plyr")
}

while(!require(RPostgreSQL)){
  install.packages("RPostgreSQL")
} 

CGX.log <- function(msg){
  try(stop(paste(Sys.time(), CGX.loglabel, msg, sep=" - "))) 
}


stripEndChars <- function(ngram) {
  return(substring(ngram, 2, nchar(ngram)-1))
}

extendCompgramOfDay <- function(day, epoch2=CGX.epoch2, ngramlen2=CGX.ngramlen2,db=CGX.db,maxPos=70,startPos=0,
    inputPath = "~/r_output/compound_unigrams/",outputRoot = "~/r_output/"){
  
  # those can't change
  epoch1 <- epoch2
  ngramlen1 <- 1

  CGX.loglabel <- paste("extendCompgramOfDay(day=",day,",epoch2=",epoch2,",ngramlen2=",ngramlen2,",db=",db)
  
  outPath <- paste(outputRoot,"/compgrams_",epoch2,ngramlen2,"_",day,".csv",sep="")

  if(file.exists(outPath)){
    if(SKIP_DAYS_FOR_WHICH_OUTPUT_EXISTS){
       stop(paste("Output already exists:",outPath))
    }
    bakname <- paste(outPath,"_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="")
    warning(paste("Renaming existing output file",outPath,bakname))
    file.rename(outPath,bakname)
   } else {
    if(!file.exists(outputRoot))
      dir.create(outputRoot,recursive = TRUE)
  }

  stagingPath <- paste(outPath,"staging",sep=".")
  # create file to make sure this will be possible 
  # AND ALSO TO TRUNCATE ANY PARTIAL OUTPUT FROM EARLIER
  file.create(stagingPath)
  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
  CGX.log("Connected to DB")
  
  origCompgramOccPath <- paste(inputPath,day,".csv",sep="");
  if(!file.exists(origCompgramOccPath)){
    stop(paste("Compgram occurrences input for day doesn't exist!"))
  }
  
  cgOcc <- read.table(origCompgramOccPath, header = FALSE, quote = NULL, sep = "\t",
        na = "NA", dec = ".", row.names = NULL,
        col.names = c("id","timemillis","date","ngram","ngramlen","tweetlen","pos"),
        colClasses = c("numeric","numeric","integer","character","integer","integer","integer"),
        fileEncoding = "UTF-8")
    
  sqlTemplate <- sprintf("SELECT id,ngram as unigram from unigramsp%%d where date=%d and id in (%s);",day,
     paste(cgOcc$id,collapse=","))
  
#  ugDfCache <- data.frame(pos=c(startPos:maxPos))
      
  for(p in c(startPos:(maxPos - ngramlen2))) { # ( c( startPos : floor((maxPos+1)/2)) * 2 ) ){
    
    CGX.log(paste("Proccessing position",p))

    
    ##### Join the unigram before the compgram
#      if(p<ngramlen2){
      
        sql <- sprintf(sqlTemplate,p)
      
        CGX.log(paste("Fetching unigrams of Start positions, using sql:\n",sql))
      
        ugStartPosRs <- dbSendQuery(con,sql) 
        ugStartPosDf <- fetch(ugStartPosRs,n=-1)
      
        CGX.log(paste("Fetched unigrams of Start position, num rows:",nrow(ugStartPosDf)))
      
        dbClearResult(ugStartPosRs)
#      } else {
#        ugStartPosDf <- ugDfCache['pos'==p,'ugrams'][[1]]
#        ugDfCache['pos'==p,'ugrams'] <- NULL
#      }
      
      beforeJoin <- join(ugStartPosDf, cgOcc[which(cgOcc$pos==(p+1)),], by="id", type="inner", match="all")
      
      beforeJoin$ngram = paste(stripEndChars(beforeJoin$unigram),stripEndChars(beforeJoin$ngram),sep=",")
      beforeJoin$unigram <- NULL
      beforeJoin$ngramlen <- ngramlen2 + 1 #beforeJoin$ngramlen + 1
      beforeJoin$pos <- p
      
      write.table(beforeJoin, file = stagingPath, append = TRUE, quote = FALSE, sep = "\t",
          eol = "\n", na = "NA", dec = ".", row.names = FALSE,
          col.names = FALSE, # qmethod = c("escape", "double"),
          fileEncoding = "UTF-8")
      
      rm(ugStartPosDf)
  
  ###### join the unigram after the compgram  
      sql <- sprintf(sqlTemplate, p+ngramlen2)
      
      CGX.log(paste("Fetching unigrams of end position, using sql:\n",sql))
      
      ugEndPosRs <- dbSendQuery(con,sql)
      ugEndPosDf <- fetch(ugEndPosRs,n=-1)
      
      CGX.log(paste("Fetched unigrams of end position, num rows:",nrow(ugEndPosDf)))
      
      dbClearResult(ugEndPosRs)
      
      afterJoin <- join(ugEndPosDf, cgOcc[which(cgOcc$pos==p),], by="id", type="inner", match="all")
      
      afterJoin$ngram = paste(stripEndChars(afterJoin$ngram),stripEndChars(afterJoin$unigram),sep=",")
      afterJoin$unigram <- NULL
      afterJoin$ngramLen <- ngramlen2 + 1 
      
      # already afterJoin$pos <- p
  
      write.table(afterJoin, file = stagingPath, append = TRUE, quote = FALSE, sep = "\t",
          eol = "\n", na = "NA", dec = ".", row.names = FALSE,
          col.names = FALSE, # qmethod = c("escape", "double"),
          fileEncoding = "UTF-8")
    
      
#      ugDfCache['pos'==p+ngramlen2,'ugrams'] <- I(list(ugEndPosDf))
    
  }
 
  file.rename(stagingPath, outPath)
  
  return(paste("Success for day:"),day)
}
