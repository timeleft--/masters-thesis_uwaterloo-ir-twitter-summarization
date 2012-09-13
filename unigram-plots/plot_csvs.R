# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

require(reshape)
require(MARSS)
require(ggplot2)

setwd("/u2/yaboulnaga/data/twitter-trec2011/timeseries")
kTS <- "TIMESTAMP"
kUnigram <- "and"
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
counts <- NULL
for(i in 1:length(hrs.files)){ 
  counts <- rbind.fill(counts, 
      sumN(read.table(hrs.files[i], header=TRUE, sep='\t', quote="\"")
        [c(kTS, kUnigram)],kUnigram,kEpochMins))
}

qplot(get(kTS), get(kUnigram), data=counts, xlab="Date/Time", ylab=kUnigram, log="y") 
# Can't control point size or shape :( -->   size=get(kUnigram)) + scale_size(c(0.20,0.21)) cex=.1) 


