# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

require(reshape)
setwd("/u2/yaboulnaga/data/twitter-trec2011/timeseries")
hrs.files <- list.files()
#hrs.list <- NULL
#for(i in 1:length(hrs.files)) hrs.list[[i]] <- read.table(hrs.files[i], header=TRUE, sep='\t', quote="\"")
# counts <- rbind.fill(hrs.list)
counts <- NULL
for(i in 1:length(hrs.files)) counts <- rbind.fill(counts, read.table(hrs.files[i], header=TRUE, sep='\t', quote="\"")[c("TIMESTAMP", "the", "of")])

plot(counts$TIMESTAMP,log2(counts$the),type="l",pch="o",col="red")
#abline(lm(log2(the) ~ TIMESTAMP, data=counts))

lines(counts$TIMESTAMP,log2(counts$of),type="l", pch="x",col="blue")

