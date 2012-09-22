# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

require(reshape)
require(ggplot2)
#require(MARSS)
require(dlmodeler)


setwd("/u2/yaboulnaga/data/twitter-trec2011/timeseries")
kTS <- "TIMESTAMP"
kUnigram <- "the"
kEpochMins <- 5

sumN <- function (inFrame, colname, n) {
	len <- dim(inFrame)[1]
	if(len %% n != 0) {
    xlen <- ceiling(len/n)*n
    deltaT <- inFrame$TIMESTAMP[2] - inFrame$TIMESTAMP[1]
    currT <- inFrame$TIMESTAMP[len]
    for(i in (len+1):xlen)  {
      currT <- currT + deltaT
      inFrame[i,] <- c(currT,NA)
    }
    len <-xlen
  }
	
	retVal <- data.frame(TIMESTAMP=as.POSIXct(inFrame$TIMESTAMP[seq(n,len,by=n)],origin="1970-01-01",
          tz="GMT"))
	retVal[colname] <- colSums(matrix(inFrame[[colname]], nrow=n),na.rm=TRUE)
	return(retVal)
}
#debug(sumN)
# setBreakpoint("plot_csvs.R#19")

hrs.files <- list.files(pattern=".*csv$")
uniCntT <- NULL
for(i in 1:length(hrs.files)){ 
  uniCntT <- rbind.fill(uniCntT, 
      sumN(read.table(hrs.files[i], header=TRUE, sep='\t', quote="\"")
        [c(kTS, kUnigram)],kUnigram,kEpochMins))
}
kTraining <- dim(uniCntT)[1] #/2

kModelName <- "level+trend+days"
uniModel <- dlmodeler.build.structural(
                            pol.order=1,
                            pol.sigmaQ=NA,
                            tseas.order=3, # when increased the processing time increases a lot
                            tseas.period=24*(60/kEpochMins),
                            tseas.sigmaQ=0,
                            # day of week seasonal causes the diffuse to fail because of negative
                            # variance (cycle) or hangs up the computer (dummy seasonal)
                            #dseas.period=7*24*(60/kEpochMins),
                            #dseas.sigmaQ=0,
                            sigmaH=NA,
                            name=kModelName)
system.time(uniFit <- dlmodeler.fit(t(as.matrix(uniCntT[1:kTraining,kUnigram])), uniModel, method="MLE"))

uniFit$model$Ht
uniFit$model$Qt

system.time(uniFilter <- dlmodeler.filter(t(as.matrix(uniCntT[1:kTraining,kUnigram])),uniFit$model,smooth=FALSE))

kComp <- kModelName
#compnames can be "level+trend+hourly"(kModelName) or "level+trend" or "seasonal"
uniComp <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames=kComp, value="interval")
uniSeasonal <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames="seasonal", value="mean")
uniCycle <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames="cycle", value="mean")

#qplot(get(kTS), get(kUnigram), data=uniCntT, xlab="Date/Time", ylab=kUnigram, log="y")  
# Can't control point size or shape :( -->   size=get(kUnigram)) + scale_size(c(0.20,0.21)) cex=.1)
#TODO: + geom_line(uniCntT[(kTraining+1):dim(uniCntT)[1],kTS],uniComp$"level+trend+hourly"[(1):(dim(uniCntT)[1]-kTraining)])
plot(as.matrix(uniCntT[kUnigram]),type="p",log="y") #,ylim=c(0,400))
lines(uniComp[[kComp]]$lower[1,],col="blue",lty=2)
lines(uniComp[[kComp]]$mean[1,],col="red")
lines(uniComp[[kComp]]$upper[1,],col="blue",lty=2)

plot(as.matrix(uniCntT[1:kTraining,kUnigram]) - uniComp[[kComp]]$mean[1,1:kTraining],type="l",ylim=c(-100,100))
lines(uniCycle$cycle[1:kTraining],type='l',col="green")


#lines((kTraining+1):dim(uniCntT)[1],uniComp$"level+trend+hourly"[(1):(dim(uniCntT)[1]-kTraining)],col="red")