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
kUnigram <- "the"
#kEpochMins <- 5
kSupport <- 30 # must be greater than kNormalityAssumptionThreshold = 30
kSuppedQtile <- 0.95

kFitMethod <- "MLE"
# FKF is the best, FKAS is also good
# but dlm is so heavy weight that day of week seasonal causes the diffuse to fail because of negative
# variance (cycle) or hangs up the computer (dummy seasonal)
kBackEnd <- "FKF" # KFAS, FKF or dlm
kRawResult <- TRUE
kModelName <- "random-walk+days" #-drift+weeks+days"
kComp <- "level" #"+trend"
kRepeating<-"cycle" # "seasonal+cycle"
kCycleOrder <- 3

kTrainingFraction <- 1

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

kTraining <- as.numeric(ceiling(dim(uniCntT)[1] * kTrainingFraction))
# determing the epoch length
suppLag <- supportLag(uniCntT[1:kTraining,], kUnigram, kSupport)
##The 3rd quartile of the suppLag assuming uniform distrib
#kEpochMins <- quantile(suppLag, probs=c(0.75))

# The maximum likelihood rate assuming an exponential distrib
# kEpochMins <- mean(suppLag)

# The upper bound of the 95% CI of the MLE of rate, assuming exponential distrib of suppLag
#kEpochMins <- mean(suppLag) * (1 + (1.96 * sqrt(length(suppLag)))) 

#The 3rd quartile of the suppLag assuming exponential distrib
kEpochMins <- qexp(kSuppedQtile, rate=1/mean(suppLag))

##Exponentially moving average of the support lag
#kSuppLagExpW <- 2/(length(suppLag)+1) #0.8
#kEpochMins <- suppLag[1]
#for(i in 2:length(suppLag)){
#  kEpochMins <- kEpochMins + kSuppLagExpW * (suppLag[i] - kEpochMins)
#}

##Linear Weighted moving average of the support lag
#require(TTR)
#lastN <- length(suppLag)
#kEpochMins <- WMA(suppLag,lastN,1:lastN)[lastN]

# assert that the minutes are less than a day, or else the cycle will have not meaning
kEpochMins <- min(c(ceiling(as.numeric(kEpochMins)),24*60))

# round up to the next divisor of the minutes in a day
while(((24*60) %% kEpochMins) > 0){
  kEpochMins <- kEpochMins + 1 
}

#Aggregate the epochs
uniCntT <- sumN(uniCntT, kUnigram, kEpochMins)
kTraining <- as.numeric(ceiling(dim(uniCntT)[1] * kTrainingFraction))
uniTrainM <- t(as.matrix(uniCntT[1:kTraining,kUnigram]))

#sdNoise <- 0 #deterministic: caused very noisy curve 
#sdNoise <- sd(uniCntT[1:kTraining/2,kUnigram]) #fixed: didn't make a difference from stochastic (only scaled)


rm(uniModel)
uniModel <- dlmodeler.build.structural(
                            pol.order=0, #1 -> trend isn't large enough to justify this extra state 
                            pol.sigmaQ=NA, #c(NA,0), -> Even as deterministic trend, it doesn't work
                            #daily repeating as harmonics in a spectral component
                            tseas.order=kCycleOrder, 
                            tseas.period=as.numeric(ceiling(24*(60/kEpochMins))),
                            tseas.sigmaQ=NA,
                            #weekly repeating as harmonics in a spectral component
                            #tseas.order=7, 
                            #tseas.period=as.numeric(ceiling(7*24*(60/kEpochMins))),
                            #tseas.sigmaQ=0,
                            #daily repeating as dummy seasonal
                            #dseas.order=max(2,as.numeric(ceiling(24*(60/kEpochMins)))),
                            #dseas.sigmaQ=0,
                            #sigmaH=NA,
                            name=kModelName)
rm(uniFit)

sink(paste("~/Desktop/",kModelName,"_",  kUnigram, ".log", sep=""))
print(paste("Epoch in minutes:", kEpochMins))
print(paste("Time for", kFitMethod, "of model parameters (initialization) using backend", kBackEnd))
print(system.time(uniFit <- dlmodeler.fit(uniTrainM, uniModel, 
        filter=FALSE, smooth=FALSE, verbose=FALSE, 
        method=kFitMethod, backend=kBackEnd)))
print("Convergence (uniFit$convergence): ")
print(uniFit$convergence)
print("Optim message (uniFit$message): ")
print(uniFit$message)
print("Number of hyper parameter [variances] (length(uniFit$par)):")
print(length(uniFit$par))
print("Number of diffuse elements [initial values] (length(uniFit$model$a0)):")
print(length(uniFit$model$a0))
print("Irregular Variance Matrix (uniFit$model$Ht): ") 
print(uniFit$model$Ht)
print("State Variance Matrix (uniFit$model$Qt): ")
print(uniFit$model$Qt)
print("Akaike Information Criterion (AIC(uniFit, k=2/kTraining): ")
print(AIC(uniFit, k=2/kTraining)) # the lower the better, absolute value meaningless

# should AIC be -ve number of a small absolute value?? like -1.19 is worse than -1.20 and -1.25 
# Text book method.. exactly the value from the package method
#print("Akaike Information Criterion = (2 / kTraining) * (-2 * (kTraining/2) * uniFit$logLik +  2 * (length(uniFit$par) +length(uniFit$model$a0))): ")
#(2 / kTraining) * (-2 * (kTraining/2) * uniFit$logLik +  2 * (length(uniFit$par) + length(uniFit$model$a0))) # the lower the better..

rm(uniFilter)
print(paste("Time for", kFitMethod, "of filtering using backend", kBackEnd))
print(system.time(uniFilter <- dlmodeler.filter(uniTrainM,uniFit$model,smooth=FALSE, 
        backend=kBackEnd, raw.result=kRawResult)))

# This return just a zero.. well, the textbook says the logLik of the diffuse should be used
#print("Akaike Information Criterion (AIC(uniFilter, k=2/kTraining): ")
#print(AIC(uniFilter, k=2/kTraining)) # the lower the better..


#compnames can be "level+trend+hourly"(kModelName) or "level+trend" or "seasonal"
# find out using: summary(uniFit$model$components)
uniComp <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames=kComp, value="interval")
#uniSeasonal <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames="seasonal", value="mean")
#uniCycle <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames="cycle", value="mean")
uniRepeating <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames=kRepeating, value="mean")
#uniAll <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames=kModelName, value="mean")


#Validate Assumptions
validateAssumps <- function(predictionErr){
stdzdErr <- predictionErr / sd(predictionErr)

print("Tests for independence of residuals from previous ones")
print("In Box-Ljung test The hypothesis of randomness is rejected if
    QLB > CHSPPF((1-alpha),h) 
where CHSPPF is the percent point function of the chi-square distribution.
That is, small p-value indicate that there's no enough evidence of independence.")
print(paste("lag=24*60/kEpochMins=",as.numeric(ceiling(24*60/kEpochMins))))
print(Box.test(stdzdErr,lag=as.numeric(ceiling(24*60/kEpochMins)),type="Ljung-Box",fitdf=length(uniFit$par)))

print(paste("lag=7*24*60/kEpochMins=",as.numeric(ceiling(7*24*60/kEpochMins))))
print(Box.test(stdzdErr,lag=as.numeric(ceiling(7*24*60/kEpochMins)),type="Ljung-Box",fitdf=length(uniFit$par)))


print("lag=20:")
print(Box.test(stdzdErr,lag=20,type="Ljung-Box",fitdf=length(uniFit$par)))

print(paste("lag=ln(kTraining)=",ceiling(log(kTraining))))
print(Box.test(stdzdErr,lag=as.numeric(ceiling(log(kTraining))),type="Ljung-Box",fitdf=length(uniFit$par)))


#Null hypothesis that variances of the residuals in the first third of the sequence is equal to the
# variances of those in the last third (Homoscedacity)
diffuseElts <- length(uniFit$model$a0)
h <- floor((length(stdzdErr) - diffuseElts)/3)

#text book test for homoscedacity (I guess this is the Box Q test)
#Hh <- sum(stdzdErr[(diffuseElts+1):(diffuseElts+h)]^2) / sum(stdzdErr[(kTraining-h+1):(kTraining)]^2)
#print(paste("Ratio of variances of first and last (h=",h,") elements = ", Hh))
#qFhh.025 <- qf(0.975,h,h) #,lower.tail=FALSE)
#constVar <- if(Hh>=1){
#  Hh < qFhh.025
#} else {
#  (1/Hh) < qFhh.025
#}
#print(paste("The null hypothesis of constant variance (homoscedacity) is (critical =", qFhh.025, ") = ", constVar))

print("Tests for homoginity of variances of each third of the data (homoscedacity):")

range <- (diffuseElts+1):length(stdzdErr)
groups <- gl(3,h)
range <- range[1:length(groups)]

#print("Bartlett's test is sensitive to departures from normality. H0 that all k population variances are equal.")
#print(bartlett.test(stdzdErr[range],groups))

if(library(car, logical.return=TRUE)){
  print("If the Levene's Test is significant, the variances are significantly different")
  print(leveneTest(stdzdErr[range],groups))
} 

#the FK test originated for the cross-sectional data, not time series objects. Even in subsamples the data points will be dependent, thus the tests are probably not applicable. 
#print(fligner.test(stdzdErr[range],groups))

print("Tests for the null that standardized errors are normally distributed:")
print("Remember if the p-value is less than the chosen alpha level, then the null hypothesis is rejected (i.e. one concludes the data are not from a normally distributed population)")
#TODO: better sampling of the 5000 errors
#print(shapiro.test(stdzdErr[if((length(stdzdErr)-diffuseElts)>5000){
#                  round(runif(5000,diffuseElts+1,length(stdzdErr)))
#                }else{
#                  (diffuseElts+1):length(stdzdErr)
#                }]))

if(library(fBasics, logical.return=TRUE)){
# jarqueberaTest used in the text book
  print(jarqueberaTest(stdzdErr[(diffuseElts+1):length(stdzdErr)]))
#  print(ksnormTest(stdzdErr[(diffuseElts+1):length(stdzdErr)]))
}
}


print("******************** One step ahead error for validating assumptions *******************")
oneStepAheadPredictionErr <- uniTrainM[1:kTraining] - uniFilter$f[1:kTraining] # balash hals -> +1]
validateAssumps(oneStepAheadPredictionErr)
print("******************** ********************************************** *******************")
#they are the same
#print("******************** irregular for validating assumptions *******************")
#irregular <- uniTrainM[1:kTraining] - uniAll[[kModelName]][1,1:kTraining]
#validateAssumps(irregular)
#print("******************** ********************************************** *******************")
sink()

pdf(paste("~/Desktop/",kModelName,"_",  kUnigram, "_", "autocorrelation", ".pdf", sep=""))
acf(oneStepAheadPredictionErr, lag=20)
dev.off()


#if(library(corrgram, logical.return=TRUE)){
#  pdf(paste("~/Desktop/",kModelName,"_",  kUnigram, "_", "correlogram-stderr-filter", ".pdf", sep=""))
#
#  corrgram(t(stdzdErr), order=FALSE, lower.panel=panel.shade, upper.panel=panel.pie, text.panel=panel.txt, main="Autocorrelation of standardized onestep ahead prediction error")
#    
#  dev.off()
#}

########### FORECASTING #############
# I can't get it to work, and I don't really need it anyway as we intend to use Filtering
#uniTestM <- t(as.matrix(uniCntT[(kTraining+1):length(uniCntT),kUnigram]))
#uniFore <- dlmodeler.forecast(uniTestM, uniFit$model,start=1,ahead=1,iters=dim(uniTestM)[1])  



############## PLOTS ################

#qplot(get(kTS), get(kUnigram), data=uniCntT, xlab="Date/Time", ylab=kUnigram, log="y")  
# Can't control point size or shape :( -->   size=get(kUnigram)) + scale_size(c(0.20,0.21)) cex=.1)
#TODONOT: + geom_line(uniCntT[(kTraining+1):dim(uniCntT)[1],kTS],uniComp$"level+trend+hourly"[(1):(dim(uniCntT)[1]-kTraining)])

pdf(paste("~/Desktop/",kModelName,"_",  kUnigram, "_", kComp, ".pdf", sep=""))

dayDelims = seq(from=0,to=dim(uniCntT)[1],by=as.numeric(ceiling(24*(60/kEpochMins))));

mar.default <- par("mar")
par(mar = mar.default + c(7,0,0,0))

#uniYLims <- quantile(uniCntT[1:kTraining,kUnigram], c(.25,.75))
#uniYLog <- ifelse(as.numeric(diff(quantile(uniCntT[1:kTraining,kUnigram], c(0.05,.95)))) > 100, TRUE, FALSE)   
#par(ylog=uniYLog)

plot(t(uniTrainM),type="p",
    cex=0.5,pch=20,
    ylab=paste("Occurences of '", kUnigram, "' per ", kEpochMins, " mins"), xlab="", #"Date/Time",
    main=paste(kUnigram, " occurrences, ", kComp, " (red) and Confidence bands (blue)"),
    lab=c(1,10,7)) # ,ylim=uniYLims) #,log="y") #,ylim=c(0,400))
lines(uniComp[[kComp]]$lower[1,],col="blue",lty=2)
lines(uniComp[[kComp]]$mean[1,],col="red")
lines(uniComp[[kComp]]$upper[1,],col="blue",lty=2)

#TODONE: why dayDelims + 1??? Why shift?
# Because the day delims are zero based, and the indeces are 1 based
axis(1,at=dayDelims,tck=1,lty=3,labels=uniCntT[[kTS]][dayDelims+1],las=2)

dev.off()

pdf(paste("~/Desktop/", kModelName,"_", kUnigram, "_", "irregular+repeating", ".pdf", sep=""))

# noiseYLim <- ???
# noiseYLog <- flase (-ve numbers)
    
par(mar = mar.default + c(7,0,0,0))
plot(oneStepAheadPredictionErr,type="l",
    ylab=paste("Occurences of '", kUnigram, "' per ", kEpochMins, " mins"), xlab="", #"Date/Time",
    main=paste(kUnigram, "Irregular (black) and daily Cycle (green)"),
    ylim=c(-kSupport,kSupport),lab=c(1,10,7))
lines(uniRepeating[[kRepeating]][1:kTraining],type='l',col="green")
axis(1,at=dayDelims,tck=1,lty=3,labels=uniCntT[[kTS]][dayDelims+1],las=2)

dev.off()

pdf(paste("~/Desktop/", kModelName,"_", kUnigram, "_", "full-predicted", ".pdf", sep=""))
par(mar = mar.default + c(7,0,0,0))
plot(t(uniTrainM), type="p", cex=0.5,pch=20,
  ylab=paste("Occurences of '", kUnigram, "' per ", kEpochMins, " mins"), xlab="",
  main=paste(kUnigram, kComp, "(red) and",  kModelName, " (blue)"),
  lab=c(1,10,7)) #ylim=c(-kSupport,kSupport),
axis(1,at=dayDelims,tck=1,lty=3,labels=uniCntT[[kTS]][dayDelims+1],las=2)
lines(t(uniComp[[kComp]]$mean), type="l", col="red", lty=2)
lines(t(uniFilter$f), type="l",col="blue")

dev.off()

cat("Done\n")
#lines((kTraining+1):dim(uniCntT)[1],uniComp$"level+trend+hourly"[(1):(dim(uniCntT)[1]-kTraining)],col="red")