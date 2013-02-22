# TODO: Add comment
# 
# Author: yia
###############################################################################

SKIP_DAYS_FOR_WHICH_OUTPUT_EXISTS<-FALSE

CGX.DEBUG <- FALSE
CGX.TRACE <- FALSE

CGX.argv <- commandArgs(trailingOnly = TRUE)
#CGX.epoch2 <- '1hr'
# FIXME ngramlen2 should say ngramlen orig.. but that's fine!
CGX.ngramlen2 <- as.integer(CGX.argv[1])
#CGX.support <- 5

CGX.loglabel.DEFAULT <- "compgrams-extend"
CGX.loglabel <- CGX.loglabel.DEFAULT

if(CGX.DEBUG){
#  epoch2=CGX.epoch2
  CGX.db <- 'sample-0.01'
  
  CGX.dataPath <- "~/r_output_debug/"
  CGX.workingRoot <- "~/r_output_debug/occ_extended_working/"

  CGX.days <- c(121106, 121110)
  
  CGX.nCores<-2
  if(CGX.TRACE){
    ngramlen2=CGX.ngramlen2
  
    db<-CGX.db
    day<-121106
    maxPos=70
    startPos=0
    
    dataPath <- CGX.dataPath
    workingRoot <- CGX.workingRoot
  }
} else {
  CGX.dataPath <- "~/r_output/"
  CGX.workingRoot <- "~/r_output/occ_extended_working/"
  CGX.days <- unique(c( 120925,  120926,  120930,  121008,  121013,  121016,  121026,  121027,  121028,  121029,  121030,  121103,  121104,  121105,  121106,  121108,  121110,  121116,  121119,  121120,  121122,  121123,  121125,  121205,  121206,  121210,  121214,  121215,  121231,  130103,  130104)) #missing data: 120914,121222,  121223,
      #c(121114,121009,121129)
      #c(121110, 130103, 121016, 121206, 121210, 120925, 121223, 121205, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116, 121106, 121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219)
  CGX.db <- 'full'
  CGX.nCores<-min(50, length(CGX.days)) 
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

source("compgrams_utils.R")

extendCompgramOfDay <- function(day, 
#    epoch2=CGX.epoch2, support=CGX.support,
    ngramlen2=CGX.ngramlen2,db=CGX.db,maxPos=70,startPos=0,
    dataPath = "~/r_output/",workingRoot = "~/r_output/occ_extended_working/"){
  
  # those can't change
#  epoch1 <- epoch2
# This is useless here:  ngramlen1 <- 1

  CGX.loglabel <- paste("extendCompgramOfDay(day=",day,
#      ",epoch2=",epoch2,
      ",ngramlen2=",ngramlen2,",db=",db)
  
  lenDir <- paste("/occ_extended",
      #      epoch2,
      ngramlen2 + 1, sep="")
  outDir <- paste(dataPath,lenDir,sep="")
  
  dayFile <- paste(lenDir,"/",day,".csv",sep="")
  outPath <- paste(dataPath,dayFile,sep="")

  # if(!file.exists(dataPath)) will fail when trying to find the input file
  if(file.exists(outPath)){
    if(SKIP_DAYS_FOR_WHICH_OUTPUT_EXISTS){
       stop(paste("Output already exists:",outPath))
    }
    bakname <- paste(outPath,"_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="")
    warning(paste("Renaming existing output file",outPath,bakname))
    file.rename(outPath,bakname)
  } else {
    if(!file.exists(outDir)){
      dir.create(outDir,recursive = TRUE)
    }
  }
  
  stagingDir <- paste(workingRoot,lenDir,sep="")  
  
  if(!file.exists(stagingDir))
    dir.create(stagingDir,recursive = TRUE)
  
  
  # create file to make sure this will be possible 
  # AND ALSO TO TRUNCATE ANY PARTIAL OUTPUT FROM EARLIER
  stagingPath <- paste(workingRoot,dayFile,sep="")
  file.create(stagingPath)
  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
  try(stop(paste(Sys.time(), CGX.loglabel, paste("Connected to DB",db), sep=" - "))) 
  
  origCompgramOccPath <- paste(dataPath,"/occ_yuleq_",ngramlen2,"/",day,".csv",sep="");
  
  try(stop(paste(Sys.time(), CGX.loglabel, paste("Reading original compound unigrams from file", origCompgramOccPath), sep=" - ")))
  
  if(!file.exists(origCompgramOccPath)){
    stop(paste("Compgram occurrences input for day doesn't exist!"))
  }
  
  cgOcc <- read.table(origCompgramOccPath, header = FALSE, quote = "", comment.char="", 
        sep = "\t", na = "NA", dec = ".", row.names = NULL,
        col.names = c("id","timemillis","date","ngram","ngramlen","tweetlen","pos"),
        colClasses = c("character","numeric","integer","character","integer","integer","integer"),
        fileEncoding = "UTF-8")
  
  try(stop(paste(Sys.time(), CGX.loglabel, paste("Read original compound unigrams - nrows:", nrow(cgOcc)), sep=" - ")))
  
  #TODONOT: stripEndChars from cgOcc
  
  # Distinct on id because the position can appear only once per tweet!
  # SELECT DISTINCT on (id) id,ngram as unigram from unigramsp3 where date=121110  
  sqlTemplate <- sprintf("SELECT DISTINCT ON (id) CAST(id as varchar),ngram as unigram from unigramsp%%d where date=%d order by id;",day)
#  sqlTemplate <- sprintf("SELECT id,ngram as unigram from unigramsp%%d where date=%d and id in (",day)
#      # and cnt > %d, support
  
  compgramLeft <- ifelse(ngramlen2==2,"(","{")
  compgramRight <- ifelse(ngramlen2==2,")","}")

#  ugDfCache <- vector("list",(maxPos-startPos+1))
  ugDfCache <- new.env()
  cgOccMaskForBeforePrevIter<-NULL      
  for(p in c(startPos:(maxPos - ngramlen2))) { # ( c( startPos : floor((maxPos+1)/2)) * 2 ) ){
  
    try(stop(paste(Sys.time(), CGX.loglabel,
                paste("Proccessing position",p),
                sep=" - ")))
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
        
        if(nrow(ugStartPosDf)>0){
          ugStartPosDf <- within(ugStartPosDf,{unigram=stripEndChars(unigram)})
        }
      } else {
#        ugStartPosDf <- ugDfCache[[p+1]]
      ugStartPosDf <- get(paste("unigrams",p,sep=""),envir=ugDfCache,inherits = FALSE)
        try(stop(paste(Sys.time(), CGX.loglabel,
                    paste("Loaded cached unigrams of Start position"), # , from:",str(ugDfCache)),
                    sep=" - ")))
      }
      if(is.null(ugStartPosDf)){
        try(stop(paste(Sys.time(), CGX.loglabel,
                    paste("ERROR failed to load unigrams of Start position:",p),
                    sep=" - ")))
      }else
      if(nrow(ugStartPosDf)>0){
      # This merge results in multiple rows for each id.. the mask already selects one pos, so how are there 
    # multiple records with the same id after selecting one pos!!!! Check the by pos tables!
#        beforeJoin <- join(ugStartPosDf, cgOcc[cgOccMaskForBefore,], by="id", type="inner", match="all")
      beforeJoin <- merge(ugStartPosDf, cgOcc[cgOccMaskForBefore,], by="id", sort=F, suffixes=c("",""))
        if(nrow(beforeJoin) > 0){
          beforeJoin$ngram = paste(beforeJoin$unigram,paste(compgramLeft,beforeJoin$ngram,compgramRight,sep=""),sep="+")
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
#        ugDfCache[[p+1]] <- NULL
      assign(paste("unigrams",p,sep=""),NULL,envir=ugDfCache)
    },
      error=function(e) NULL
    )
    ###### join the unigram after the compgram  
    if(!is.null(cgOccMaskForBeforePrevIter)) {
      cgOccMaskForAfter <- cgOccMaskForBeforePrevIter 
    } else {
      cgOccMaskForAfter <- which(cgOcc$pos==p)
    }
#    idsForAfter<-paste(cgOcc[cgOccMaskForAfter,"id"],collapse=",")
#    if(length(cgOccMaskForAfter)){
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
     
      if(nrow(ugEndPosDf) > 0){
        
        ugEndPosDf <- within(ugEndPosDf,{unigram=stripEndChars(unigram)})
        
#        afterJoin <- join(ugEndPosDf, cgOcc[cgOccMaskForAfter,], by="id", type="inner", match="all")
        afterJoin <- merge(ugEndPosDf, cgOcc[cgOccMaskForAfter,], by="id", sort=F,suffixes=c("",""))
        if(nrow(afterJoin)>0){
          afterJoin$ngram = paste(paste(compgramLeft,afterJoin$ngram,compgramRight,sep=""),afterJoin$unigram,sep="+")
          afterJoin$unigram <- NULL
          afterJoin$ngramlen <- ngramlen2 + 1 
          
          # already afterJoin$pos <- p
      
          write.table(afterJoin, file = stagingPath, append = TRUE, quote = FALSE, sep = "\t",
              eol = "\n", na = "NA", dec = ".", row.names = FALSE,
              col.names = FALSE, # qmethod = c("escape", "double"),
              fileEncoding = "UTF-8")
        }
      }
#      ugDfCache[[p+ngramlen2+1]] <- ugEndPosDf
      assign(paste("unigrams",p+ngramlen2,sep=""),ugEndPosDf,envir=ugDfCache)
#      rm(afterJoin)
#      rm(ugEndPosDf)
#    }
    cgOccMaskForBeforePrevIter <<- cgOccMaskForBefore
#    ugDfCache <<- ugDfCache
  }
 
  file.rename(stagingPath, outPath)
  
  # dbDisconnect(con, ...) closes the connection. Eg.
  try(dbDisconnect(con))
  # dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
  try(dbUnloadDriver(drv))
  
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
            
             extendCompgramOfDay(day,dataPath = CGX.dataPath,workingRoot = CGX.workingRoot) 
#                epoch2 = CGX.epoch2, ngramlen2 = CGX.ngramlen2,  db = CGX.db) #, support = CGX.support)
            daySuccess <<-paste("Success for day:",day)
          }
          ,error=function(e) daySuccess <<- paste("Failure for day",day,e)
          ,finally=try(stop(paste(Sys.time(), CGX.loglabel,
                      daySuccess,
                      sep=" - ")))
      )
    }



