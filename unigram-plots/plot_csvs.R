# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

require(reshape)
require(MARSS)
setwd("/u2/yaboulnaga/data/twitter-trec2011/timeseries")

sumN <- function (inFrame, colname, n) {
	len <- dim(inFrame)[1]
	if(len %% n != 0)
		stop("n must be a divisor for inFrame's length")
	
	retVal <- data.frame(TIMESTAMP=inFrame$TIMESTAMP[seq(n,len,by=n)])
	retVal[colname] <- colSums(matrix(inFrame[[colname]], nrow=n))
	return(retVal)
}

hrs.files <- list.files()
counts <- NULL
for(i in 1:length(hrs.files)) counts <- rbind.fill(counts, read.table(hrs.files[i], header=TRUE, sep='\t', quote="\"")[c("TIMESTAMP", "the", "of")])

plot(counts$TIMESTAMP,counts$the,type="l",pch="o",col="red",ylim=c(0,80)) #,xaxp=c(counts$TIMESTAMP[2],tail(counts$TIMESTAMP,n=2)[1],16),xlab=)
grid(17,8)
#abline(lm(log2(the) ~ TIMESTAMP, data=counts))

#lines(counts$TIMESTAMP,log2(counts$of),type="l", pch="x",col="blue")

