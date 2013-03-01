FTX.DEBUG <- TRUE
FTX.TRACE <- TRUE

FTX.epoch2 <- '1hr'
FTX.secsInEpoch <- 3600
FTX.epoch1 <- FTX.epoch2
#Threshold got by executing 
#select ngramarr, avg(CAST(cnt as float8)/CAST(totalcnt AS float8)) from cnt_1hr1 c join volume_1hr1 v on c.epochstartmillis=v.epochstartmillis where ngramarr[1] = 'obama' group by ngramarr;
FTX.candidateThreshold <- 0.000126097580224557
# Didn't use the average of the counts because this doesn't take into account the seasonal part
#146.8455795677799607 is the average of obama in all of the collection (not taking into account missing data.. 2 types)

if(FTX.DEBUG){
  FTX.dataRoot <- "~/r_output_debug/"
  FTX.db <- "sample-0.01"
} else {
  FTX.dataRoot <- "~/r_output/"
  FTX.db <- "full"
}

if(FTX.TRACE) {
  FTX.day <- 121105
  FTX.epochstartux <- 1352109600 + (3600 * 10)
  FTX.len2 <- 2
  
}

FTX.len1 <- FTX.len2 - 1

###############################################


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

source("yaboulna_utils.R")

###############################################

FTX.label <- paste("FTX", FTX.day, FTX.epochstartux, sep="_")

FTX.lenDir <- paste(FTX.dataRoot,"ngram_occ",FTX.len2, sep="/")

FTX.epochFile <- paste(FTX.lenDir,"/",day,"_",FTX.epochstartux,".csv",sep="")

# TODO if(FTX.SKIP_EXISTING_OUT && file.exists()) 

FTX.stagingFile <- createOutFile(FTX.lenDir,FTX.epochFile)

annotPrint(FTX.label, "Prepared outfile", FTX.epochFile)

FTX.drv <- dbDriver("PostgreSQL")
FTX.con <- dbConnect(drv, dbname=FTX.db, user="yaboulna", password="5#afraPG",
    host="hops.cs.uwaterloo.ca", port="5433")

annotPrint(FTX.label, "Connected to DB", FTX.db)

# Get what needs to be extended
FTX.len1GramsSql <- sprintf("select b.epochstartmillis/1000 as epochstartux, 
        %s as ngram, b.cnt as cnt, CAST(b.cnt AS float8)/CAST(v.totalcnt AS float8) as prop
        from %s_%s%d%s b 
        join volume_%s%d%s v on v.epochstartmillis = b.epochstartmillis
        where b.date=%d and b.epochstartmillis = (%d * 1000::INT8) 
				and CAST(b.cnt AS float8)/CAST(v.totalcnt AS float8) > %g;",
    ifelse(FTX.len1==1,"'(' || ngramarr[1] || ')'","ngram"),ifelse(FTX.len1==1,"cnt","hgram_cnt"),
    FTX.epoch1, FTX.len1, ifelse(FTX.len1==1,'',paste("_",FTX.day, sep="")), 
    FTX.epoch1, FTX.len1, ifelse(FTX.len1==1,'',paste("_",FTX.day,sep="")), 
    FTX.day, FTX.epochstartux, FTX.candidateThreshold) 

annotPrint(FTX.label, "Fetching candidates:\n",FTX.len1GramsSql)

FTX.len1GramsRs <- dbSendQuery(FTX.con,FTX.len1GramsSql) 
FTX.len1GramsDf <- fetch(FTX.len1GramsRs, n=-1)

dbClearResult(FTX.len1GramsRs)

annotPrint(FTX.label, "Fetched:", nrow(FTX.len1GramsDf))

# Get epoch occurrences
FTX.len1OccsSql <- sprintf("SELECT * from %s 
 where date=%d and timemillis >= (%d * 1000::INT8) and timemillis < (%d * 1000::INT8)",
ifelse(FTX.len1==1,"ngrams1",paste("hgrams_occ",FTX.len1, sep="_")),
FTX.day, FTX.epochstartux, FTX.epochstartux + FTX.secsInEpoch)

annotPrint(FTX.label, "Fetching epoch occurrences:\n", sql)

# This SQL is independent from the previous and could be executed in a spawned process,
# however I'd rather parallelize on a higher level and not write crazy code (it seems I have to)
FTX.len1OccsRs <- dbSendQuery(FTX.con,FTX.len1OccsSql)
FTX.len1OccsDf <- fetch(FTX.len1OccsRs, n=-1)

dbClearResult(FTX.len1OccsRs)

annotPrint(FTX.label, "Fetched epoch occs: ", nrow(FTX.len1OccsDf))

## Mark occurrences on candidates
candidateOccs <- match(FTX.len1OccsDf$ngram, FTX.len1GramsDf$ngram, nomatch = 0)

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
#    ifelse(FTX.len1==1,"ngrams1",paste("hgrams",FTX.len1, sep="_")),
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


