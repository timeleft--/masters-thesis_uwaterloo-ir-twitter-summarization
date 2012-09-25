# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

require(reshape)
#require(ggplot2)
#require(MARSS)
require(dlmodeler)


setwd("/u2/yaboulnaga/data/twitter-trec2011/timeseries")
kTS <- "TIMESTAMP"
kUnigram <- "white"
#kEpochMins <- 5
kSupport <- 50 # must be greater than kNormalityAssumptionThreshold = 30

supportLag <- function(inFrame, colname, supp) {
  len <- dim(inFrame)[1]
  retVal <- NULL
  currSupp <- 0
  prevIntervalEnd <- 0
  nextIntervalIx <- 1
  for(i in 1:len){
    currSupp <- currSupp + inFrame[i,colname]
    if(currSupp >= supp){
      retVal[nextIntervalIx] <- i - prevIntervalEnd #if input isn't by minute, use TIMESTAMP
      prevIntervalEnd <- i
      currSupp = 0
      nextIntervalIx <- nextIntervalIx + 1
    }
  }
  # don't care about the interval len - prevIntervalEnd
  return(retVal)
}
# debug(supportLag)
# setBreakpoint("plot_csvs.R#27")

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
        read.table(hrs.files[i], header=TRUE, sep='\t', quote="\"")
        [c(kTS, kUnigram)])
}
suppLag <- supportLag(uniCntT, kUnigram, kSupport)
kEpochMins <- ceiling(as.numeric(quantile(suppLag, probs=c(0.95))))
uniCntT <- sumN(uniCntT, kUnigram, kEpochMins)

kTraining <- dim(uniCntT)[1] #/2

#sdNoise <- 0 #deterministic: caused very noisy curve 
#sdNoise <- sd(uniCntT[1:kTraining/2,kUnigram]) #fixed: didn't make a difference from stochastic (only scaled)

kModelName <- "level+trend+days"
uniModel <- dlmodeler.build.structural(
                            pol.order=1,
                            pol.sigmaQ=NA, 
                            tseas.order=3, # when increased the processing time increases a lot
                            tseas.period=24*(60/kEpochMins),
                            tseas.sigmaQ=NA,
                            # day of week seasonal causes the diffuse to fail because of negative
                            # variance (cycle) or hangs up the computer (dummy seasonal)
                            #dseas.period=7*24*(60/kEpochMins),
                            #dseas.sigmaQ=0,
                            sigmaH=NA,
                            name=kModelName)
system.time(uniFit <- dlmodeler.fit(t(as.matrix(uniCntT[1:kTraining,kUnigram])), uniModel, 
        filter=TRUE, smooth=FALSE, verbose=TRUE, 
        method="MLE", backend="FKF"))

uniFit$model$Ht
uniFit$model$Qt

system.time(uniFilter <- dlmodeler.filter(t(as.matrix(uniCntT[1:kTraining,kUnigram])),uniFit$model,smooth=FALSE))

kComp <- "level+trend"
#compnames can be "level+trend+hourly"(kModelName) or "level+trend" or "seasonal"
# find out using: summary(uniFit$model$components)
uniComp <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames=kComp, value="interval")
#uniSeasonal <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames="seasonal", value="mean")
uniCycle <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames="cycle", value="mean")
uniAll <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames=kModelName, value="mean")


pdf(paste("~/Desktop/", kUnigram, "_", kComp, ".pdf", sep=""))

dayDelims = seq(from=0,to=dim(uniCntT)[1],by=24*(60/kEpochMins));
mar.default <- par("mar")
#uniYLims <- quantile(uniCntT[1:kTraining,kUnigram], c(.25,.75))
#uniYLog <- ifelse(as.numeric(diff(quantile(uniCntT[1:kTraining,kUnigram], c(0.05,.95)))) > 100, TRUE, FALSE)   

#qplot(get(kTS), get(kUnigram), data=uniCntT, xlab="Date/Time", ylab=kUnigram, log="y")  
# Can't control point size or shape :( -->   size=get(kUnigram)) + scale_size(c(0.20,0.21)) cex=.1)
#TODO: + geom_line(uniCntT[(kTraining+1):dim(uniCntT)[1],kTS],uniComp$"level+trend+hourly"[(1):(dim(uniCntT)[1]-kTraining)])
par(mar = mar.default + c(7,0,0,0))
par(ylog=uniYLog)

plot(as.matrix(uniCntT[kUnigram]),type="p",
    cex=0.5,pch=20,
    ylab=paste("Occurences of '", kUnigram, "' per ", kEpochMins, " mins"), xlab="", #"Date/Time",
    main=paste(kUnigram, " occurrences, fitted model (red) and Confidence bands (blue)"),
    lab=c(1,10,7)) # ,ylim=uniYLims) #,log="y") #,ylim=c(0,400))
lines(uniComp[[kComp]]$lower[1,],col="blue",lty=2)
lines(uniComp[[kComp]]$mean[1,],col="red")
lines(uniComp[[kComp]]$upper[1,],col="blue",lty=2)

axis(1,at=dayDelims,tck=1,lty=3,labels=uniCntT[[kTS]][dayDelims+1],las=2)

dev.off()

pdf(paste("~/Desktop/", kUnigram, "_", "noise+cycle", ".pdf", sep=""))

# noiseYLim <- ???
# noiseYLog <- flase (-ve numbers)
    
par(mar = mar.default + c(7,0,0,0))
plot(as.matrix(uniCntT[1:kTraining,kUnigram]) - uniAll[[kModelName]][1,1:kTraining],type="l",
    ylab=paste("Occurences of '", kUnigram, "' per ", kEpochMins, " mins"), xlab="", #"Date/Time",
    main=paste(kUnigram, " Noise (black) and daily Cycle (green)"),
    ylim=c(-kSupport,kSupport),lab=c(1,10,7))
lines(uniCycle$cycle[1:kTraining],type='l',col="green")
axis(1,at=dayDelims,tck=1,lty=3,labels=uniCntT[[kTS]][dayDelims+1],las=2)

dev.off()

#lines((kTraining+1):dim(uniCntT)[1],uniComp$"level+trend+hourly"[(1):(dim(uniCntT)[1]-kTraining)],col="red")