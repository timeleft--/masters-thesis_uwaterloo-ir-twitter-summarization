# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

require(reshape)
#require(ggplot2)
#require(MARSS)
require(KFAS)


setwd("/u2/yaboulnaga/data/twitter-trec2011/timeseries")
kTS <- "TIMESTAMP"
kUnigram <- "white"
kEpochMins <- 5

kModelName <- "random-walk+days" #-trend+weeks+days"
kComp <- "level"
kRepeating<-"cycle" # "seasonal+cycle"

hrs.files <- list.files(pattern=".*csv$")
uniCntT <- NULL
for(i in 1:length(hrs.files)){ 
  uniCntT <- rbind.fill(uniCntT, 
        read.table(hrs.files[i], header=TRUE, sep='\t', quote="\"")
        [c(kTS, kUnigram)])
}

kTraining <- dim(uniCntT)[1] #/ 2
    
uniTS <- ts(uniCntT[,kUnigram][1:kTraining], frequency=kEpochMins)

rm(uniModel)
uniModel <- structSSM(uniTS, 
      trend = "level", 
      seasonal = "freq",
      Q.seasonal=0,
      distribution="Poisson")
    
rm(uniFit)

sink(paste("~/Desktop/kfas/",kModelName,"_",  kUnigram, ".log", sep=""))
print(paste("Epoch in minutes:", kEpochMins))
print(paste("Time for", kFitMethod, "of model parameters (initialization) using backend", kBackEnd))
print(system.time(uniFit <- fitSSM(inits=rep(0.5*log(0.005)), model=uniModel)))
print("Convergence (uniFit$opt$convergence): ")
print(uniFit$opt$convergence)
print("Optim message (uniFit$opt$message): ")
print(uniFit$opt$message)
print("Number of hyper parameter [variances] (length(uniFit$opt$par)):")
print(length(uniFit$opt$par))
print("Number of diffuse elements [initial values] (length(uniFit$model$a1)):")
print(length(uniFit$model$a1))
print("Irregular Variance Matrix (uniFit$model$H): ") 
print(uniFit$model$H)
print("State Variance Matrix (uniFit$model$Q): ")
print(uniFit$model$Q)
#print("Akaike Information Criterion (AIC(uniFit, k=2/kTraining): ")
#print(AIC(uniFit$model, k=2/kTraining)) # the lower the better, absolute value meaningless
# should AIC be -ve number of a small absolute value?? like -1.19 is worse than -1.20 and -1.25 
# Text book method.. exactly the value from the package method
print("Akaike Information Criterion = (2 / kTraining) * (-2 * (kTraining/2) * uniFit$logLik +  2 * (length(uniFit$par) +length(uniFit$model$a0))): ")
print((2 / kTraining) * (-2 * (kTraining/2) * logLik(uniFit$model) +  2 * (length(uniFit$opt$par) + length(uniFit$model$a1)))) # the lower the better..

print("*************** Approximate Gaussian Model *****************")
print(amod <- approxSSM(uniFit$model))
print("Akaike Information Criterion = (2 / kTraining) * (-2 * (kTraining/2) * uniFit$logLik +  2 * (length(uniFit$par) +length(uniFit$model$a0))): ")
print((2 / kTraining) * (-2 * (kTraining/2) * logLik(amod) +  2 * (length(uniFit$opt$par) + length(amod$a1)))) # the lower the better..


rm(uniFilter)
print(paste("Time for", kFitMethod, "of filtering using backend", kBackEnd))
print(system.time(uniFilter <- KFS(uniFit$model,smooth="none")))


ts.plot(cbind(uniFit$model$y,uniFilter$yhat,exp(amod$theta)),col=1:3)

thirteen <- length(uniFit$model$a1)

# It is more interesting to look at the smoothed values of exp(level + intervention)
lev1<-exp(signal(uniFilter,states=c(1,thirteen))$s)
#lev2<-exp(signal(amod,states=c(1,thirteen))$s)
# These are slightly biased as E[exp(x)] > exp(E[x]), better to use importance sampling:
vansample<-importanceSSM(uniFit$model,save.model=FALSE,nsim=250)
# nsim is number of independent samples, as default two antithetic variables are used,
# so total number of samples is 1000.

w<-vansample$weights/sum(vansample$weights)

level<-colSums(t(exp(vansample$states[1,,]+uniFit$model$Z[1,thirteen,]*vansample$states[thirteen,,]))*w)
ts.plot(cbind(uniFit$model$y,lev1,level),col=1:3) #’ Almost identical results


# Confidence intervals (no seasonal component)
varlevel<-colSums(t(exp(vansample$states[1,,]+uniFit$model$Z[1,thirteen,]*vansample$states[thirteen,,])^2)*w)-level^2
intv<-level + qnorm(0.975)*varlevel%o%c(-1,1)
ts.plot(cbind(uniFit$model$y,level,intv),col=c(1,2,3,3))


#compnames can be "level+trend+hourly"(kModelName) or "level+trend" or "seasonal"
# find out using: summary(uniFit$model$components)
uniComp <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames=kComp, value="interval")
#uniSeasonal <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames="seasonal", value="mean")
#uniCycle <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames="cycle", value="mean")
uniRepeating <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames=kRepeating, value="mean")
uniAll <- dlmodeler.extract(uniFilter,uniFit$model,type="observation", compnames=kModelName, value="mean")


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
oneStepAheadPredictionErr <- uniCntM[1:kTraining] - uniFilter$f[1:kTraining]
validateAssumps(oneStepAheadPredictionErr)
print("******************** ********************************************** *******************")
#they are the same
#print("******************** irregular for validating assumptions *******************")
#irregular <- uniCntM[1:kTraining] - uniAll[[kModelName]][1,1:kTraining]
#validateAssumps(irregular)
#print("******************** ********************************************** *******************")
sink()

#if(library(corrgram, logical.return=TRUE)){
#  pdf(paste("~/Desktop/",kModelName,"_",  kUnigram, "_", "correlogram-stderr-filter", ".pdf", sep=""))
#
#  corrgram(t(stdzdErr), order=FALSE, lower.panel=panel.shade, upper.panel=panel.pie, text.panel=panel.txt, main="Autocorrelation of standardized onestep ahead prediction error")
#    
#  dev.off()
#}

#qplot(get(kTS), get(kUnigram), data=uniCntT, xlab="Date/Time", ylab=kUnigram, log="y")  
# Can't control point size or shape :( -->   size=get(kUnigram)) + scale_size(c(0.20,0.21)) cex=.1)
#TODONOT: + geom_line(uniCntT[(kTraining+1):dim(uniCntT)[1],kTS],uniComp$"level+trend+hourly"[(1):(dim(uniCntT)[1]-kTraining)])

pdf(paste("~/Desktop/",kModelName,"_",  kUnigram, "_", kComp, ".pdf", sep=""))

dayDelims = seq(from=0,to=dim(uniCntT)[1],by=24*(60/kEpochMins));

mar.default <- par("mar")
par(mar = mar.default + c(7,0,0,0))

#uniYLims <- quantile(uniCntT[1:kTraining,kUnigram], c(.25,.75))
#uniYLog <- ifelse(as.numeric(diff(quantile(uniCntT[1:kTraining,kUnigram], c(0.05,.95)))) > 100, TRUE, FALSE)   
#par(ylog=uniYLog)

plot(t(uniCntM),type="p",
    cex=0.5,pch=20,
    ylab=paste("Occurences of '", kUnigram, "' per ", kEpochMins, " mins"), xlab="", #"Date/Time",
    main=paste(kUnigram, " occurrences, ", kComp, " (red) and Confidence bands (blue)"),
    lab=c(1,10,7)) # ,ylim=uniYLims) #,log="y") #,ylim=c(0,400))
lines(uniComp[[kComp]]$lower[1,],col="blue",lty=2)
lines(uniComp[[kComp]]$mean[1,],col="red")
lines(uniComp[[kComp]]$upper[1,],col="blue",lty=2)

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
plot(t(uniCntM), type="p", cex=0.5,pch=20,
  ylab=paste("Occurences of '", kUnigram, "' per ", kEpochMins, " mins"), xlab="",
  main=paste(kUnigram, kComp, "(red) and",  kModelName, " (blue)"),
  lab=c(1,10,7)) #ylim=c(-kSupport,kSupport),
axis(1,at=dayDelims,tck=1,lty=3,labels=uniCntT[[kTS]][dayDelims+1],las=2)
lines(t(uniComp[[kComp]]$mean), type="l", col="red", lty=2)
lines(t(uniFilter$f), type="l",col="blue")

dev.off()

cat("Done\n")
#lines((kTraining+1):dim(uniCntT)[1],uniComp$"level+trend+hourly"[(1):(dim(uniCntT)[1]-kTraining)],col="red")