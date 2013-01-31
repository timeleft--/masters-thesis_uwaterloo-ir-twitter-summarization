
# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

MILLIS_PUT_1000 <- 1;
conttable_construct <- function(date, epoch1, ngramlen2, epoch2=NULL, ngramlen1=1, support=3) {
if(is.null(epoch2)){
  epoch2=epoch1
}
require(RPostgreSQL)  
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="sample-0.01", user="yaboulna", password="5#afraPG",
    host="hops.cs.uwaterloo.ca", port="5433")
rs <- dbSendQuery(con,
    sprintf("select a.epochstartmillis/1000 as epochstartux, %d as date, v.totalcnt as epochvol, b.ngramlen as ngramlen, 
				b.ngramarr as ngram, b.cnt as togethercnt,
				a.ngramarr as unigram, a.cnt - b.cnt as alonecnt, a.cnt as unigramcnt 
    from (cnt_%s%d a join cnt_%s%d b on 
          a.epochstartmillis = b.epochstartmillis and a.ngramArr[1] = ANY (b.ngramarr)
          and NOT a.ngramArr[1] = ALL (b.ngramarr))
       join volume_5min1 v on v.epochstartmillis = b.epochstartmillis
    where a.date = %d and b.date=%d and b.cnt > %d;", date, epoch1, ngramlen1, epoch2, ngramlen2, date, date, support))

require(plyr)
df <- fetch(rs, n=-1);

numNGrams <- nrow(df) / df[1,"ngramlen"]
if(numNGrams != floor(numNGrams)){
  stop("There was a duplicate unigram in some ngrams and thus the code below will not work!
In case of bigrams it was enough to append 'and NOT a.ngramArr[1] = ALL (b.ngramarr)' to the SQL")
}
#idata.frame( object environment is not subsettable
ngramGrps <- ddply(df, c("epochstartux","ngram"), function(bg){
      bgRow <- bg[1,1:6]
      for(i in 1:nrow(bg)) {
        bgRow[paste("unigram", i, sep=".")] = bg[i,"unigram"]
        bgRow[paste("alonecnt", i, sep=".")] = bg[i,"alonecnt"]
        bgRow[paste("unigramcnt", i, sep=".")] = bg[i,"unigramcnt"]
      }
      bgRow["POSIXtime"] <- as.POSIXct(bgRow[1,"epochstartux"]/MILLIS_PUT_1000,origin="1970-01-01",
          tz="GMT-5")
      return(bgRow)
    }) #,.parallel = TRUE)  will use doMC to parallelize on a higher level then no need here 

#cleanup
rm(df)
# dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
try(dbClearResult(rs))
# dbDisconnect(con, ...) closes the connection. Eg.
try(dbDisconnect(con))
# dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
try(dbUnloadDriver(drv))

return(ngramGrps)
}

