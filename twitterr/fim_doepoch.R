FIME.DEBUG <- TRUE
FIME.SKIP_IF_OUTFILE_EXISTS <- TRUE
FIME.calcInterest <- FALSE

FIME.DOWNSAMPLE <- TRUE
FIME.downSampleProportion <- 0.33

FIME.label <- "FIME"

FIME.epochstartux<-FIME.compgramOccs$epochstartux[1]

print(paste(Sys.time(),FIME.label,FIME.day, " - FIM for epoch:",FIME.epochstartux, "num occs before pruning:",nrow(FIME.compgramOccs)))

##############

FIME.skipThisEpoch <- FALSE
FIME.epochFile<-paste(FIME.outDir,"/fis_",FIME.epochstartux,".csv",sep="")
if(file.exists(FIME.epochFile)) {
  if(FIME.SKIP_IF_OUTFILE_EXISTS){
    FIME.skipThisEpoch <- TRUE
  } else {
    FIME.bakFile <- paste(FIME.epochFile,"_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="")
    print(paste(Sys.time(),FIME.label,FIME.day, " - Renaming existing output file",FIME.epochFile,FIME.bakFile))
    file.rename(FIME.epochFile, #from
        FIME.bakFile)
  }
}

##############

if(FIME.skipThisEpoch){
  print(paste(Sys.time(),FIME.label,FIME.day, " - Skipping epoch:", FIME.epochstartux, "file:",FIME.epochFile))
} else {

  if(FIME.DOWNSAMPLE){
     # sample must be without replacement because picking up the same item twice will cause error when coercing to transactions
     sampleIx <- sample(nrow(FIME.compgramOccs),size=FIME.downSampleProportion * nrow(FIME.compgramOccs),replace = FALSE)
     FIME.sampleOccs <- FIME.compgramOccs[sampleIx,]
     rm(sampleIx)
  } else {
    FIME.sampleOccs <- FIME.compgramOccs
  }
  FIME.sampleSize <- nrow(FIME.sampleOccs)
  
if(FIM.PRUNE_HIGHER_THAN_OBAMA){
  
  ########Read the compgram vocabulary
  FLO.epochstartux <- FIME.epochstartux
  FLO.day <- FIME.day
  
  source("fim_less-than-obama.R", local = TRUE, echo = TRUE)
  #FLO.compgramsDf should appear in the current environment after sourcing

  FIME.midFreqIx <- match(FIME.sampleOccs$compgram,FLO.compgramsDf$compgram,nomatch=0)
  if(FLO.more){
    FIME.midFreq <- FIME.sampleOccs[which(FIME.midFreqIx==0),]
  } else {
    FIME.midFreq <- FIME.sampleOccs[which(FIME.midFreqIx>0),]
  }
  
  rm(FIME.midFreqIx)
  rm(FIME.sampleOccs)
  rm(FLO.compgramsDf)

  if(FIME.DEBUG){
    midFreqFile <- paste(FIME.outDir,"/occ-less-than-obama_",FIME.epochstartux,".csv",sep="")
    write.table(FIME.midFreq , file = midFreqFile, append = FALSE, quote = FALSE, sep = "\t",
        eol = "\n", na = "NA", dec = ".", row.names = FALSE,
        col.names = FALSE, # qmethod = c("escape", "double"),
        fileEncoding = "UTF-8") 
  }
} else {
  # renaming will cost us a copy in case we don't want to do anything, right? NO:
  # From http://cran.r-project.org/doc/manuals/R-ints.html
  # The named field is set and accessed by the SET_NAMED and NAMED macros, and take values 0, 1 and 2. R has a ‘call by value’ illusion, so an assignment like
  #     b <- a
  #appears to make a copy of a and refer to it as b. However, if neither a nor b are subsequently altered there is no need to copy. What really happens is that a new symbol b is bound to the same value as a and the named field on the value object is set (in this case to 2). When an object is about to be altered, the named field is consulted. A value of 2 means that the object must be duplicated before being changed. (Note that this does not say that it is necessary to duplicate, only that it should be duplicated whether necessary or not.)
  FIME.midFreq <- FIME.sampleOccs
}

print(paste(Sys.time(),FIME.label,FIME.day, " - FIM for epoch:",FIME.epochstartux, "num occs after pruning:",nrow(FIME.midFreq),"before pruning:",FIME.sampleSize))

# trans4 <- as(split(a_df3[,"item"], a_df3[,"TID"]), "transactions") 
FIME.transacts <- as(split(FIME.midFreq$compgram, FIME.midFreq$id), "transactions")

rm(FIME.midFreq)

print(paste(Sys.time(),FIME.label,FIME.day, " - num transactions:",length(FIME.transacts)))

FIME.epochFIS <- eclat(FIME.transacts,parameter = list(supp = FIM.support/length(FIME.transacts),minlen=2, maxlen=FIM.fislenm))

#  # inspect(head(sort(dayFIS,by="crossSupportRatio")))
print(paste(Sys.time(),FIME.label,FIME.day, " - Done mining for epoch:", FIME.epochstartux, "num FIS:",length(FIME.epochFIS)))


tryCatch({
if(length(FIME.epochFIS) > 0){
  write(FIME.epochFIS,file=paste(FIME.epochFile,"all",sep="."),append = FALSE, quote = FALSE, sep = "\t",
      eol = "\n", na = "NA", dec = ".", row.names = FALSE,
      col.names = FALSE, # qmethod = c("escape", "double"),
      fileEncoding = "UTF-8")
  unlink(FIME.epochFile)
  
  FIME.epochFIS <- FIME.epochFIS[which(is.closed(FIME.epochFIS)),]
  
  print(paste(Sys.time(),FIME.label,FIME.day, " - Chose only closed itemsets for epoch:", FIME.epochstartux, "num closed FIS:",length(FIME.epochFIS)))
  
  write(FIME.epochFIS,file=FIME.epochFile,append = FALSE, quote = FALSE, sep = "\t",
      eol = "\n", na = "NA", dec = ".", row.names = FALSE,
      col.names = FALSE, # qmethod = c("escape", "double"),
      fileEncoding = "UTF-8")
  unlink(FIME.epochFile)
  
  if(FIME.calcInterest){
    interest<-interestMeasure(FIME.epochFIS, c("lift","allConfidence","crossSupportRatio"),transactions = FIME.transacts)
    quality(FIME.epochFIS) <- cbind(quality(FIME.epochFIS), interest)
    # rewrite with interest
    print(paste(Sys.time(),FIME.label,FIME.day, " - Rewriting FIS for epoch:", FIME.epochstartux, "with interest"))
    
    write(FIME.epochFIS,file=FIME.epochFile,append = FALSE, quote = FALSE, sep = "\t",
        eol = "\n", na = "NA", dec = ".", row.names = FALSE,
        col.names = FALSE, # qmethod = c("escape", "double"),
        fileEncoding = "UTF-8")
    unlink(FIME.epochFile)
    rm(interest)
  }
} else {
  file.create(paste(FIME.epochFile,"empty",sep="."))
}
},finally=
rm(FIME.transacts)
)



print(paste(Sys.time(),FIME.label,FIME.day, " - Done for epoch:", FIME.epochstartux, "file:",FIME.epochFile))
}
