FLO.DEBUG <- TRUE

FIME.epochstartux<-FIME.compgramOccs$epochstartux[1]

print(paste(Sys.time(),FIM.label, " - FIM for epoch:",FIME.epochstartux, "num occs before pruning:",nrow(FIME.compgramOccs)))

if(FIM.PRUNE_HIGHER_THAN_OBAMA){
  
  ########Read the compgram vocabulary
  #day alread set
  source("fim_less-than-obama.R", local = TRUE, echo = TRUE)
  #FLO.compgramsDf should appear in the current environment after sourcing

#  # Fails because 'by' must specify uniquely valid column(s) --> that is one row cannot be matched to many
#  # Note that FLO.compgramDf is for one epoch only
#  FIME.midFreq <- merge(FIME.compgramOccs,FLO.compgramsDf,by="compgram",sort=F, suffixes=c("","FLO"))
  
#      cntFLO <- array(FLO.compgramsDf$cnt)
#      names(cntFLO) <-FLO.compgramsDf$compgram
#      
##      filterFunc <- function(occ) {
##        if(is.na(cntFLO[occ$compgram])) 
##          if(FLO.more){return(occ)} else {return(NULL)}
##        else
##        if(FLO.more){return(NULL)} else {return(occ)}
##      }
#      if(FLO.more){
#        filterFunc <- function(occ) {
#          if(is.na(cntFLO[occ$compgram])) 
#            return(occ)
#          else
#            return(NULL)
#        }
#      } else {
#        filterFunc <- function(occ) {
#          if(is.na(cntFLO[occ$compgram])) 
#            return(NULL)
#          else
#            return(occ)
#        }
#      }
#      
#      FIME.midFreq <- a_ply(FIME.compgramOccs,1, filterFunc,.expand = FALSE)
#       rm(cntFLO)
  
  FIME.midFreqIx <- match(FIME.compgramOccs$compgram,FLO.compgramsDf$compgram,nomatch=0)
  if(FLO.more){
    FIME.midFreq <- FIME.compgramOccs[which(FIME.midFreqIx==0),]
  } else {
    FIME.midFreq <- FIME.compgramOccs[which(FIME.midFreqIx>0),]
  }
  
   # Be polite and don't delete your caller's stuff
#  rm(FIME.compgramOccs)
  rm(FLO.compgramsDf)

  if(FLO.DEBUG){
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
  FIME.midFreq <- FIME.compgramOccs
}

print(paste(Sys.time(),FIM.label, " - FIM for epoch:",FIME.epochstartux, "num occs after pruning:",nrow(FIME.midFreq),"before pruning:",nrow(FIME.compgramOccs)))

# trans4 <- as(split(a_df3[,"item"], a_df3[,"TID"]), "transactions") 
FIME.transacts <- as(split(FIME.midFreq$compgram, FIME.midFreq$id), "transactions")

rm(FIME.midFreq)

print(paste(Sys.time(),FIM.label, " - num transactions:",length(FIME.transacts)))

FIMW.epochFIS <- eclat(FIME.transacts,parameter = list(supp = FIM.support/length(FIME.transacts),minlen=2, maxlen=FIM.fislenm))

#  # inspect(head(sort(dayFIS,by="crossSupportRatio")))
print(paste(Sys.time(),FIM.label, " - Done mining for epoch:", FIME.epochstartux, "num FIS:",length(FIMW.epochFIS)))

epochFile<-paste(FIME.outDir,"/fis_",FIME.epochstartux,".csv",sep="")

if(length(FIMW.epochFIS) > 0){
  write(FIMW.epochFIS,file=epochFile,sep="\t",
      col.names=NA) #TODO: colnames
  
  interest<-interestMeasure(FIMW.epochFIS, c("lift","allConfidence","crossSupportRatio"),transactions = FIME.transacts)
  quality(FIMW.epochFIS) <- cbind(quality(FIMW.epochFIS), interest)
  # rewrite with interest
  ry(stop(paste(Sys.time(),FIM.label, " - Rewriting FIS for epoch:", FIME.epochstartux, "with interest")))
  
  write(FIMW.epochFIS,file=epochFile,sep="\t",
      col.names=NA) #TODO: colnames
  rm(interest)
} else {
  file.create(paste(epochFile,"empty",sep="."))
}
rm(FIME.transacts)




print(paste(Sys.time(),FIM.label, " - Done for epoch:", FIME.epochstartux, "file:",epochFile))
