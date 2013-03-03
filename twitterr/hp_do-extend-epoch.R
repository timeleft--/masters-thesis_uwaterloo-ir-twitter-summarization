## "Output" FTX.extensible FTX.len1OccsDf

FTX.DEBUG <- FALSE
FTX.TRACE <- FALSE

FTX.epoch2 <- '1hr'
FTX.secsInEpoch <- 3600
FTX.epoch1 <- FTX.epoch2
#Threshold got by executing 
#select ngramarr, avg(CAST(cnt as float8)/CAST(totalcnt AS float8)) from cnt_1hr1 c join volume_1hr1 v on c.epochstartmillis=v.epochstartmillis where ngramarr[1] = 'obama' group by ngramarr;
FTX.candidateThreshold <- 0.000126097580224557
# Didn't use the average of the counts because this doesn't take into account the seasonal part
#146.8455795677799607 is the average of obama in all of the collection (not taking into account missing data.. 2 types)

if(FTX.DEBUG){
#  FTX.dataRoot <- "~/r_march_debug/"
#  FTX.db <- "sample-0.01"
} else {
#  FTX.dataRoot <- "~/r_march/"
#  FTX.db <- "full"
}

if(FTX.TRACE) {
  FTX.day <- 121105
  FTX.epochstartux <- 1352109600 + (3600 * 10)
  FTX.len1 <- 1
  FTX.parentHgramsTable <- paste("hgram_occ",FTX.day,FTX.len1+1, sep="_")
  
}

FTX.startPos <- 0
FTX.maxPos <- 70

FTX.alterTableInheritTemplate <- paste("ALTER TABLE %s 
    ALTER COLUMN id TYPE int8 USING CAST(id AS int8), 
    ALTER COLUMN timemillis TYPE int8 USING CAST(timemillis AS int8), 
    ALTER COLUMN ngramlen TYPE int2, ALTER tweetlen TYPE int2, 
    ALTER pos TYPE int2, INHERIT ", FTX.parentHgramsTable)
FTX.createIndexesTemplate <- "CREATE INDEX ${TNAME}_timemillis ON ${TNAME}(timemillis);
CREATE INDEX ${TNAME}_date ON ${TNAME}(date);
CREATE INDEX ${TNAME}_ngramlen ON ${TNAME}(ngramlen);
CREATE INDEX ${TNAME}_pos ON ${TNAME}(pos);"
###############################################


while(!require(RPostgreSQL)){
  install.packages("RPostgreSQL")
} 

source("yaboulna_utils.R")
source("compgrams_utils.R")

###############################################

FTX.label <- paste("FTX", FTX.day, FTX.epochstartux, sep="_")

#FTX.epochFile <- paste(FTX.dayDir,"/hgram_",FTX.epochstartux,".csv",sep="")

# TODO if(FTX.SKIP_EXISTING_OUT && file.exists()) 

#FTX.stagingFile <- createOutFile(FTX.dayDir,FTX.epochFile)

#annotPrint(FTX.label, "Prepared outfile", FTX.epochFile)

annotPrint(FTX.label, "Connected to DB", HPD.db)

# Get what needs to be extended
FTX.len1GramsSql <- sprintf("select b.epochstartmillis/1000 as epochstartux, 
        %s as ngram, b.cnt as cnt, CAST(b.cnt AS float8)/CAST(v.totalcnt AS float8) as prop
        from %s_%s%d%s b 
        join %s_%s%d%s v on v.epochstartmillis = b.epochstartmillis
        where b.date=%d and b.epochstartmillis = (%d * 1000::INT8) 
				and CAST(b.cnt AS float8)/CAST(v.totalcnt AS float8) > %g;",
    ifelse(FTX.len1==1," ngramarr[1] ","ngram"),
    ifelse(FTX.len1==1,"cnt","hgram_cnt"),
    FTX.epoch1, FTX.len1, ifelse(FTX.len1==1,'',paste("_",FTX.day, sep="")), 
    ifelse(FTX.len1==1,"volume","hgram_vol"),
    FTX.epoch1, FTX.len1, ifelse(FTX.len1==1,'',paste("_",FTX.day,sep="")), 
    FTX.day, FTX.epochstartux, FTX.candidateThreshold) 

annotPrint(FTX.label, "Fetching candidates:\n",FTX.len1GramsSql)

FTX.len1GramsRs <- dbSendQuery(FTX.con,FTX.len1GramsSql) 
FTX.len1GramsDf <- fetch(FTX.len1GramsRs, n=-1)

dbClearResult(FTX.len1GramsRs)

annotPrint(FTX.label, "Fetched:", nrow(FTX.len1GramsDf))

#ASSERTION: Check that for FTX.len1 > 1 then all(FTX.len1GramsDf$ngramlen) == FTX.len1 

# Get epoch occurrences
FTX.len1OccsSql <- sprintf("SELECT CAST(id AS varchar), timemillis, date, ngram, ngramlen, tweetlen, pos from %s 
 where date=%d and timemillis >= (%d * 1000::INT8) and timemillis < (%d * 1000::INT8) order by id,pos",
ifelse(FTX.len1==1,"ngrams1",paste("hgram_occ",FTX.day,FTX.len1, sep="_")),
FTX.day, FTX.epochstartux, FTX.epochstartux + FTX.secsInEpoch)

annotPrint(FTX.label, "Fetching epoch occurrences:\n", FTX.len1OccsSql)

# This SQL is independent from the previous and could be executed in a spawned process,
# however I'd rather parallelize on a higher level and not write crazy code (it seems I have to)
FTX.len1OccsRs <- dbSendQuery(FTX.con,FTX.len1OccsSql)
FTX.len1OccsDf <- fetch(FTX.len1OccsRs, n=-1)

dbClearResult(FTX.len1OccsRs)

annotPrint(FTX.label, "Fetched epoch occs: ", nrow(FTX.len1OccsDf))


if(FTX.len1 == 1){
  FTX.len1OccsDf <- within(FTX.len1OccsDf,{ngram=stripEndChars(ngram)})
}


## Mark occurrences on candidates
FTX.occCandidate <- match(FTX.len1OccsDf$ngram, FTX.len1GramsDf$ngram, nomatch = 0)
FTX.extensible <- FTX.occCandidate != 0
#Don't get confused.. the extension of an Ngram by a unigram doesn't mean that the ngram
# occurence before or after the extended occurrence shuldn't get copied.. except in the
# case when ngrams are of legnth 1, that is unigrams..
if(FTX.len1 == 1){
  FTX.dontCopyUgrams <- FTX.extensible
} 

rm(FTX.occCandidate)
rm(FTX.len1GramsDf)

## Get the candidate occurrrences directly
#FTX.len1OccsSql <- sprintf("
#SELECT * from %s 
# where date=%d and timemillis >= (%d * 1000::INT8) and timemillis < (%d * 1000::INT8) 
# and ngram in 
#   (select %s
#				from cnt_%s%d%s b 
#        join volume_%s%d%s v on v.epochstartmillis = b.epochstartmillis
#        where b.date=%d and b.epochstartmillis = (%d * 1000::INT8) 
#				and CAST(b.cnt AS float8)/CAST(v.totalcnt AS float8) > %g);",
#    ifelse(FTX.len1==1,"ngrams1",paste("hgram",FTX.len1, sep="_")),
#		 FTX.day, FTX.epochstartux, FTX.epochstartux + FTX.secsInEpoch,
#    ifelse(FTX.len1==1,"'(' || ngramarr[1] || ')'","ngram"),
#    FTX.epoch1, FTX.len1, ifelse(FTX.len1==1,"",paste("_",FTX.day, sep="")), 
#    FTX.epoch1, FTX.len1, ifelse(FTX.len1==1,"",paste("_",FTX.day, sep="")), 
#    FTX.day, FTX.epochstartux, FTX.candidateThreshold) 
#
#annotPrint(FTX.label, "Fetching\n",FTX.len1OccsSql)
#
#FTX.len1OccsRs <- dbSendQuery(FTX.con,FTX.len1OccsSql) 
#FTX.len1OccsDf <- fetch(FTX.len1OccsRs, n=-1)
#
#annotPrint(FTX.label, "Fetched:", nrow(FTX.len1OccsDf))


######################## extend by unigrams

# Distinct on id because the position can appear only once per tweet!
# SELECT DISTINCT on (id) id,ngram as unigram from unigramsp3 where date=121110  
# order by id <- no reason why to do that.. just extra work!!
sqlTemplate <- sprintf("SELECT DISTINCT ON (id) CAST(id as varchar),ngram as unigram from unigramsp%%d where date=%d
and timemillis >= (%d * 1000::INT8) and timemillis < (%d * 1000::INT8)",day,FTX.epochstartux, FTX.epochstartux + FTX.secsInEpoch)

#if(FTX.len1 == 1){
#  FTX.compgramLeft <- FTX.compgramRight <- ""
#} else {
#  FTX.compgramLeft <- FTX.compgramRight <- '"'
#}
FTX.ugDfCache <- new.env()
FTX.cgOccMaskForBeforePrevIter<-NULL

for(p in c(FTX.startPos:(FTX.maxPos - FTX.len1))){

  annotPrint(FTX.label, "Processing pos", p)
  
  FTX.labelOrig <- FTX.label
  
  FTX.label <- paste(FTX.label,"pos",p)
  
  cgMaskForBefore <- which(FTX.extensible & (FTX.len1OccsDf$pos==(p+1)))
  
  if(length(cgMaskForBefore) > 0){
    if(p<FTX.len1) {
      
      sql <- sprintf(sqlTemplate,p)
      
      annotPrint(FTX.label, "Fetching unigrams of start position, using SQL:\n",sql)
      
      ugStartPosRs <- dbSendQuery(FTX.con,sql)
      ugStartPosDf <- fetch(ugStartPosRs, n = -1)
      
      annotPrint(FTX.label, "Fetched unigrams of start position: ", nrow(ugStartPosDf))
      
      dbClearResult(ugStartPosRs)
      
#      if(nrow(ugStartPosDf) > 0){
#        ugStartPosDf <- within(ugStartPosDf, {unigram=stripEndChars(unigram)})
#      }
    } else {

      ugStartPosDf <- get(paste("u",p,sep=""),envir=FTX.ugDfCache,inherits = FALSE)
      
      annotPrint(FTX.label,"Loaded cached unigrams of start position by sql:\n",sql)
      
    }
    if(is.null(ugStartPosDf)){
      annotPrint(FTX.label,"ERROR failed to load unigrams of Start position")
    } else if(nrow(ugStartPosDf) > 0){
      beforeJoin <- merge(ugStartPosDf, FTX.len1OccsDf[cgMaskForBefore,], by="id", sort=F, suffixes=c("",""))
      rm(ugStartPosDf)
      
      if(nrow(beforeJoin) > 0){
        
        if(FTX.len1==1){
          newlyOccupied <- cgMaskForBefore - 1
          FTX.dontCopyUgrams[newlyOccupied] <- TRUE
          rm(newlyOccupied)
        }
        
#        beforeJoin$ngram <- paste(beforeJoin$unigram,paste(FTX.compgramLeft,beforeJoin$ngram,FTX.compgramRight,sep=""),sep=",")
        beforeJoin$ngram <- paste(stripEndChars(beforeJoin$unigram),beforeJoin$ngram,sep=",")
        beforeJoin$unigram <- NULL
        beforeJoin$ngramlen <- FTX.len1 + 1
        beforeJoin$pos <- p
        
#        write.table(beforeJoin, file = FTX.stagingFile, append = TRUE, quote = FALSE, sep = "\t",
#            eol = "\n", na = "NA", dec = ".", row.names = FALSE,
#            col.names = FALSE, # qmethod = c("escape", "double"),
#            fileEncoding = "UTF-8")
#        
#        rm(beforeJoin)
      }
    } else {
      annotPrint(FTX.label,"WARNING nrow(ugStartPosDf)=",nrow(ugStartPosDf))
    }
  }
  tryCatch({
        assign(paste("u",p,sep=""),NULL,envir=FTX.ugDfCache)
      },
      error=function(e) NULL
  )
  
  ###### join the unigram after the compgram 
  if(!is.null(FTX.cgOccMaskForBeforePrevIter)) {
    cgOccMaskForAfter <- FTX.cgOccMaskForBeforePrevIter 
  } else {
    cgOccMaskForAfter <-  FTX.extensible & FTX.len1OccsDf$pos==p
  }
  
  if(FTX.len1==1){
    newlyOccupied <- cgOccMaskForAfter[(FTX.len1OccsDf$tweetlen[cgOccMaskForAfter] - FTX.len1OccsDf$pos[cgOccMaskForAfter]) >= (FTX.len1+1)]
    newlyOccupied <- newlyOccupied + FTX.len1
    FTX.dontCopyUgrams[newlyOccupied] <- TRUE
    rm(newlyOccupied)
  }
  
  sql <- sprintf(sqlTemplate,p+FTX.len1)
  
  annotPrint(FTX.label, "Fetching unigrams of end position by sql:\n",sql)
  
  ugEndPosRs <- dbSendQuery(FTX.con,sql)
  ugEndPosDf <- fetch(ugEndPosRs,n=-1)
  
  annotPrint(FTX.label,"Fetched unigrams of end position:", nrow(ugEndPosDf))
  
  dbClearResult(ugEndPosRs)
  
  if(is.null(ugEndPosDf)){
    annotPrint(FTX.label,"ERROR failed to load unigrams of end position")
  } else if(nrow(ugEndPosDf) > 0){
    
#    ugEndPosDf <- within(ugEndPosDf,{unigram=stripEndChars(unigram)})
    if(FTX.DEBUG) annotPrint(FTX.label,"Will merge ugEndPos and FTX.len1OccsDf")
      
    afterJoin <- merge(ugEndPosDf,  FTX.len1OccsDf[cgOccMaskForAfter,], by="id", sort=F,suffixes=c("",""))
    
    if(FTX.DEBUG) annotPrint(FTX.label,"Merged ugEndPos and FTX.len1OccsDf")
    
    if(nrow(afterJoin) > 0){
      
#      afterJoin$ngram <- paste(paste(FTX.compgramLeft,afterJoin$ngram,FTX.compgramRight,sep=""),afterJoin$unigram,sep=",")
      afterJoin$ngram <- paste(afterJoin$ngram,stripEndChars(afterJoin$unigram),sep=",")
      afterJoin$unigram <- NULL
      afterJoin$ngramlen <- FTX.len1 + 1
      #already afterJoin$pos <- p
    
#      write.table(afterJoin, file = FTX.stagingFile, append = TRUE, quote = FALSE, sep = "\t",
#        eol = "\n", na = "NA", dec = ".", row.names = FALSE,
#        col.names = FALSE, # qmethod = c("escape", "double"),
#        fileEncoding = "UTF-8")
#    
#      rm(afterJoin)
    }
  } else {
    annotPrint(FTX.label,"WARNING nrow(ugEndPosDf)=",nrow(ugEndPosDf))
  }
  
  assign(paste("u",p+FTX.len1,sep=""),ugEndPosDf,envir=FTX.ugDfCache)
  
  FTX.cgOccMaskForBeforePrevIter <<- cgMaskForBefore
  FTX.label <- FTX.labelOrig
  
  if(FTX.DEBUG) annotPrint(FTX.label,"Seeing what's there to be written")
  
  if(exists("beforeJoin") && exists("afterJoin")){
    
    if(FTX.DEBUG) annotPrint(FTX.label,"rbind(beforeJoin,afterJoin)",str(beforeJoin),str(afterJoin))
    toWrite <- rbind(beforeJoin,afterJoin)  
    
    if(FTX.DEBUG) annotPrint(FTX.label,"Total nrow: ", nrow(toWrite))
    toWrite <- toWrite[!duplicated(toWrite[,c("id","pos")]),]
    
    if(FTX.DEBUG) annotPrint(FTX.label,"nrow after dedup: ", nrow(toWrite))
    
  } else if(exists("afterJoin")){
    
    if(FTX.DEBUG) annotPrint(FTX.label,"only afterJoin")
    toWrite <- afterJoin
    
  }  else if(exists("beforeJoin")){
    
    if(FTX.DEBUG) annotPrint(FTX.label,"only beforeJoin")
    toWrite <- beforeJoin
    
  } else {
    
    annotPrint(FTX.label,"Nothing to be written")
    next
    
  }
  
  try(rm(beforeJoin))
  try(rm(afterJoin))
  
  pospartitionName <- paste("hgram_occ",FTX.day,FTX.len1+1,FTX.epochstartux,p, sep="_")
  
  annotPrint(FTX.label,"Writing table",pospartitionName)
  
  if(dbExistsTable(FTX.con,pospartitionName)){
    annotPrint(FTX.label,"Removing existing table",pospartitionName)
    dbRemoveTable(FTX.con,pospartitionName)
  }
  dbWriteTable(FTX.con,pospartitionName,toWrite)

  annotPrint(FTX.label,"Wrote table",pospartitionName)
  
  rm(toWrite)
  
  alterTableSQL <- sprintf(FTX.alterTableInheritTemplate, pospartitionName)
  execSql(alterTableSQL,FTX.db)
  
  annotPrint(FTX.label,"Creating indexes",pospartitionName)
  
  createIndexSQL <- gsub("${TNAME}",pospartitionName,FTX.createIndexesTemplate,fixed=TRUE)
  execSql(createIndexSQL,FTX.db,asynch = TRUE)

  if(FTX.DEBUG) annotPrint(FTX.label,"Moving on leaving indexes",pospartitionName)
}

if(FTX.len1==1){
  unigramsPartitionName <- paste("hgram_occ",FTX.day,FTX.len1+1,FTX.epochstartux,"unextended", sep="_")
  
  annotPrint(FTX.label,"Writing table",unigramsPartitionName)
  
  if(dbExistsTable(FTX.con,unigramsPartitionName)){
    annotPrint(FTX.label,"Removing exiting table",unigramsPartitionName)
    
    dbRemoveTable(FTX.con,unigramsPartitionName)
  }
  
  dbWriteTable(FTX.con,unigramsPartitionName,FTX.len1OccsDf[!FTX.dontCopyUgrams,])
  
  annotPrint(FTX.label,"Wrote table",unigramsPartitionName)
  
  
  alterTableSQL <- sprintf(FTX.alterTableInheritTemplate, unigramsPartitionName)
  execSql(alterTableSQL,FTX.db)
  
  createIndexSQL <- gsub("${TNAME}",unigramsPartitionName,FTX.createIndexesTemplate,fixed=TRUE)
  execSql(createIndexSQL,FTX.db,asynch = TRUE)
  
#  write.table(FTX.len1OccsDf[!FTX.dontCopyUgrams,], file = FTX.stagingFile, append = TRUE, quote = FALSE, sep = "\t",
#      eol = "\n", na = "NA", dec = ".", row.names = FALSE,
#      col.names = FALSE, # qmethod = c("escape", "double"),
#      fileEncoding = "UTF-8")
  rm(FTX.dontCopyUgrams)
}

#file.rename(FTX.stagingFile,FTX.epochFile)

