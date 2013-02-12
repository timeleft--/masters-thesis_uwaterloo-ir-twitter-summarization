# TODO: Add comment
# 
# Author: yia
###############################################################################

SKIP_DAYS_FOR_WHICH_OUTPUT_EXISTS<-FALSE

CGX.DEBUG <- FALSE

CGX.epoch2 <- '1hr'
CGX.ngramlen2 <- 2
CGX.support <- 5

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
  outputRoot = "~/r_output/compgrams_byday/"
  CGX.days <- c(121110, 130103)
  CGX.db <- 'full'
  CGX.nCores<-2
} else {
  CGX.days <- c(121110, 130103, 121016, 121206, 121210, 120925, 121223, 121205, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116, 121106, 121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219)
  CGX.db <- 'full'
  CGX.nCores<-30
}


while(!require(foreach)){
  install.packages("foreach")
}
while(!require(doMC)){
  install.packages("doMC")
}
registerDoMC(cores=CGX.nCores)

while(!require(plyr)){
  install.packages("plyr")
}

while(!require(RPostgreSQL)){
  install.packages("RPostgreSQL")
} 

#CGX.log <- function(msg){
#  try(stop(paste(Sys.time(), CGX.loglabel, msg, sep=" - "))) 
#}


stripEndChars <- function(ngram) {
  return(substring(ngram, 2, nchar(ngram)-1))
}

extendCompgramOfDay <- function(day, epoch2=CGX.epoch2, ngramlen2=CGX.ngramlen2,db=CGX.db,maxPos=70,startPos=0,
    inputPath = "~/r_output/compound_unigrams/",outputRoot = "~/r_output/compgrams_byday/"){
  
  # those can't change
  epoch1 <- epoch2
  ngramlen1 <- 1

  CGX.loglabel <- paste("extendCompgramOfDay(day=",day,",epoch2=",epoch2,",ngramlen2=",ngramlen2,",db=",db)
  
  outputRoot <- paste(outputRoot,"/compgrams_",epoch2,ngramlen2,sep="")
  
  outPath <- paste(outputRoot,"/",day,".csv",sep="")

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
  
  try(stop(paste(Sys.time(), CGX.loglabel, paste("Connected to DB",db), sep=" - "))) 
  
  origCompgramOccPath <- paste(inputPath,day,".csv",sep="");
  
  try(stop(paste(Sys.time(), CGX.loglabel, paste("Reading original compound unigrams from file", origCompgramOccPath), sep=" - ")))
  
  if(!file.exists(origCompgramOccPath)){
    stop(paste("Compgram occurrences input for day doesn't exist!"))
  }
  
  cgOcc <- read.table(origCompgramOccPath, header = FALSE, quote = "", comment.char="", 
        sep = "\t", na = "NA", dec = ".", row.names = NULL,
        col.names = c("id","timemillis","date","ngram","ngramlen","tweetlen","pos"),
        colClasses = c("numeric","numeric","integer","character","integer","integer","integer"),
        fileEncoding = "UTF-8")
  
  try(stop(paste(Sys.time(), CGX.loglabel, paste("Read original compound unigrams - nrows:", nrow(cgOcc)), sep=" - ")))
  
    
  sqlTemplate <- sprintf("SELECT id,ngram as unigram from unigramsp%%d where date=%d ;",day)
#  sqlTemplate <- sprintf("SELECT id,ngram as unigram from unigramsp%%d where date=%d and id in (",day)
#      # and cnt > %d, support
  
  ugDfCache <- vector("list",(maxPos-startPos+1))
  cgOccMaskForBeforePrevIter<-NULL      
  for(p in c(startPos:(maxPos - ngramlen2))) { # ( c( startPos : floor((maxPos+1)/2)) * 2 ) ){
    
#    CGX.log(paste("Proccessing position",p))

    ##### Join the unigram before the compgram
    cgOccMaskForBefore <- which(cgOcc$pos==(p+1))
#    idsForBefore<-paste(cgOcc[cgOccMaskForBefore,"id"],collapse=",")
    if(length(cgOccMaskForBefore)>0){
      
      if(p<ngramlen2){
        
#        sql <- paste(sprintf(sqlTemplate,p),idsForBefore,");",sep="")
        sql <- sprintf(sqlTemplate,p)
        
#        CGX.log(paste("Fetching unigrams of Start positions, using sql:\n",sql))
      try(stop(paste(Sys.time(), CGX.loglabel,
                  paste("Fetching unigrams of Start positions, using sql:\n",sql),
                  sep=" - ")))
      
        ugStartPosRs <- dbSendQuery(con,sql) 
        ugStartPosDf <- fetch(ugStartPosRs,n=-1)
          
#        CGX.log(paste("Fetched unigrams of Start position, num rows:",nrow(ugStartPosDf)))
      try(stop(paste(Sys.time(), CGX.loglabel,
                  paste("Fetched unigrams of Start position, num rows:",nrow(ugStartPosDf)),
                  sep=" - ")))
      
        dbClearResult(ugStartPosRs)
        
#        if(nrow(ugStartPosDf)>0){
#           within(ugStartPosDf,{unigram=stripEndChars(unigram)})
#        }
      } else {
        ugStartPosDf <- ugDfCache[[p+1]]
      }
      if(nrow(ugStartPosDf)>0){
        
        beforeJoin <- join(ugStartPosDf, cgOcc[cgOccMaskForBefore,], by="id", type="inner", match="all")
#      beforeJoin <- merge(ugStartPosDf, cgOcc[cgOccMaskForBefore,], by="id", sort=F, suffixes=c("",""))
        if(nrow(beforeJoin) > 0){
          beforeJoin$ngram = paste(stripEndChars(beforeJoin$unigram),beforeJoin$ngram,sep=",")
          beforeJoin$unigram <- NULL
          beforeJoin$ngramlen <- ngramlen2 + 1 #beforeJoin$ngramlen + 1
          beforeJoin$pos <- p
          
          write.table(beforeJoin, file = stagingPath, append = TRUE, quote = FALSE, sep = "\t",
              eol = "\n", na = "NA", dec = ".", row.names = FALSE,
              col.names = FALSE, # qmethod = c("escape", "double"),
              fileEncoding = "UTF-8")
        }
      }
#      rm(ugStartPosDf)
#      rm(beforeJoin)
    }
    tryCatch({
#        rm(ugDfCache[[p+1]])
        ugDfCache[[p+1]] <- NULL },
      error=function(e) NULL
    )
    ###### join the unigram after the compgram  
    if(!is.null(cgOccMaskForBeforePrevIter)) {
      cgOccMaskForAfter <- cgOccMaskForBeforePrevIter 
    } else {
      cgOccMaskForAfter <- which(cgOcc$pos==p)
    }
    idsForAfter<-paste(cgOcc[cgOccMaskForAfter,"id"],collapse=",")
    if(length(cgOccMaskForAfter)){
#      sql <- paste(sprintf(sqlTemplate, p+ngramlen2),
#          idsForAfter,");",sep="")
      sql <- sprintf(sqlTemplate, p+ngramlen2)
        
#      CGX.log(paste("Fetching unigrams of end position, using sql:\n",sql))
      try(stop(paste(Sys.time(), CGX.loglabel,
                  paste("Fetching unigrams of end position, using sql:\n",sql),
                  sep=" - ")))
      
        
      ugEndPosRs <- dbSendQuery(con,sql)
      ugEndPosDf <- fetch(ugEndPosRs,n=-1)
        
#      CGX.log(paste("Fetched unigrams of end position, num rows:",nrow(ugEndPosDf)))
      try(stop(paste(Sys.time(), CGX.loglabel,
                  paste("Fetched unigrams of end position, num rows:",nrow(ugEndPosDf)),
                  sep=" - ")))
      
      
      dbClearResult(ugEndPosRs)
     
      if(nrow(ugEndPosDf)){
        
#        within(ugEndPosDf,{unigram=stripEndChars(unigram)})
        
        afterJoin <- join(ugEndPosDf, cgOcc[cgOccMaskForAfter,], by="id", type="inner", match="all")
#        afterJoin <- merge(ugEndPosDf, cgOcc[cgOccMaskForAfter,], by="id", sort=F,suffixes=c("",""))
        if(nrow(afterJoin)>0){
          afterJoin$ngram = paste(afterJoin$ngram,stripEndChars(afterJoin$unigram),sep=",")
          afterJoin$unigram <- NULL
          afterJoin$ngramLen <- ngramlen2 + 1 
          
          # already afterJoin$pos <- p
      
          write.table(afterJoin, file = stagingPath, append = TRUE, quote = FALSE, sep = "\t",
              eol = "\n", na = "NA", dec = ".", row.names = FALSE,
              col.names = FALSE, # qmethod = c("escape", "double"),
              fileEncoding = "UTF-8")
        }
      }
      ugDfCache[[p+ngramlen2+1]] <- ugEndPosDf
#      rm(afterJoin)
#      rm(ugEndPosDf)
    }
    cgOccMaskForBeforePrevIter <- cgOccMaskForBefore
  }
 
  file.rename(stagingPath, outPath)
  
  CGX.loglabel <- CGX.loglabel.DEFAULT
  
  return(paste("Success for day:",day))
}


#debug(extendCompgramOfDay)
#setBreakpoint(findLineNum("compgrams_extend.R#176"))

###############################
### Driver
##############################

nullCombine <- function(a,b) NULL
foreach(day=CGX.days,
        .inorder=FALSE, .combine='nullCombine') %dopar%
    {
      daySuccess <- paste("Unkown result for day",day)
      
      tryCatch({
            
            daySuccess <<- extendCompgramOfDay(day, 
                epoch2 = CGX.epoch2, ngramlen2 = CGX.ngramlen2,  db = CGX.db) #, support = CGX.support)
            
          }
          ,error=function(e) daySuccess <<- paste("Failure for day",day,e)
          ,finally=try(stop(paste(Sys.time(), CGX.loglabel,
                      daySuccess,
                      sep=" - ")))
      )
    }



