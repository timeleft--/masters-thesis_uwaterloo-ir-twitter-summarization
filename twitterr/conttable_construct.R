
# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

require(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="sample-0.01", user="yaboulna", password="5#afraPG",
    host="hops.cs.uwaterloo.ca", port="5433")
rs <- dbSendQuery(con,
    "select a.epochstartmillis/1000 as epochstartux, 121221 as date, v.totalcnt as epochvol, b.ngramlen as ngramlen, 
				b.ngramarr as ngram, b.cnt as togethercnt,
				a.ngramarr as unigram, a.cnt - b.cnt as alonecnt, a.cnt as unigramcnt 
    from (cnt_5min1 a join cnt_5min2 b on 
          a.epochstartmillis = b.epochstartmillis and a.ngramArr[1] = ANY (b.ngramarr)
          and NOT a.ngramArr[1] = ALL (b.ngramarr))
       join volume_5min1 v on v.epochstartmillis = b.epochstartmillis
    where a.date = 121221 and b.date=121221 and b.cnt > 3;")

require(plyr)
df <- fetch(rs, n=-1);

numNGrams <- nrow(df) / df[1,"ngramlen"]
if(numNGrams != floor(numNGrams)){
  stop("There was a duplicate unigram in some ngrams and thus the code below will not work!
In case of bigrams it was enough to append 'and NOT a.ngramArr[1] = ALL (b.ngramarr)' to the SQL")
}

ngramGrps <- ddply(idata.frame(df), c("epochstartux","ngram"), function(bg){
      bgRow <- bg[1,1:6]
      for(i in 1:nrow(bg)) {
##        if(!identical(bgRow[,1:6], bg[i,1:6])){
##        if(any(as.list(bgRow[1,1:6]) != as.list(bg[i,1:6]))){
##        if(any(bgRow[1,1:6] != bg[i,1:6]))
#        #It alwas fails the first time complaining that comparison of these types is not implemented
#        # or that comparison si for atimoc and list types
#          stop(paste("This is a debug message because the SQL and grouping produced ngram groups that differ at i =",
#                  i, str(bgRow[,1:6]), str(bg[i,1:6])))
#        }
        bgRow[paste("unigram", i, sep=".")] = bg[i,"unigram"]
        bgRow[paste("alonecnt", i, sep=".")] = bg[i,"alonecnt"]
        bgRow[paste("unigramcnt", i, sep=".")] = bg[i,"unigramcnt"]
      }
      
      return(bgRow)
    }) #,.parallel = TRUE)  will use doMC to parallelize on a higher level then no need here 

#cleanup
rm(df)
# dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
dbClearResult(rs)
# dbDisconnect(con, ...) closes the connection. Eg.
dbDisconnect(con)
# dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
dbUnloadDriver(drv)

