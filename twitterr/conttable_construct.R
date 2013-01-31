
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

#" select ngram, 121221 as date, array_agg(a.epochstartmillis) as epochstartuxArr, array_agg(unigram) AS unigramArr,
#    array_agg(togetherCnt) as togetherCntArr, array_agg(aloneCnt) as aloneCntArr, 
#    array_agg(unigramCnt) as unigramCntArr, array_agg(epochVol) as epochVolArr, array_agg(ngramLen) as ngramLenArr 		
#    FROM (select a.epochstartmillis, a.ngramarr as unigram, b.ngramarr as ngram, 
#    b.cnt as togethercnt, a.cnt - b.cnt as alonecnt, a.cnt as unigramcnt, v.totalcnt as epochvol, b.ngramlen as ngramlen 
#    from ((cnt_5min1 a join cnt_5min2 b on 
#    a.epochstartmillis = b.epochstartmillis and a.ngramArr[1] = ANY (b.ngramarr))
#    join volume_5min1 v on v.epochstartmillis = b.epochstartmillis)
#    where a.date = 121221 and b.date=121221 and b.cnt > 3 GROUP BY b.ngramarr) AS r;"
require(plyr)
df <- fetch(rs, n=-1);

numNGrams <- nrow(df) / df[1,"ngramlen"]
if(numNGrams != floor(numNGrams)){
  stop("There was a duplicate unigram in some ngrams and thus the code below will not work!
In case of bigrams it was enough to append 'and NOT a.ngramArr[1] = ALL (b.ngramarr)' to the SQL")
}
#idata.frame(
ngramGrps <- ddply(df, c("epochstartux","ngram"), function(bg){
      bgRow <- bg[1,1:6]
      for(i in 1:nrow(bg)) {
#        if(!identical(bgRow[,1:6], bg[i,1:6])){
        if(any(bgRow[,1:6] != bg[i,1:6])){
          stop(paste("This is a debug message because the SQL and grouping produced ngram groups that differ at i =",
                  i, str(bgRow[,1:6]), str(bg[i,1:6])))
        }
        bgRow[paste("unigram", i, sep=".")] = bg[i,"unigram"]
        bgRow[paste("alonecnt", i, sep=".")] = bg[i,"alonecnt"]
        bgRow[paste("unigramcnt", i, sep=".")] = bg[i,"unigramcnt"]
      }
      
      return(bgRow)
#      str(list(bg))
#      str(join_all(as.list(bg), by=c("epochstartux","ngram")))
    })

#bigramOccs <- duplicated(df$epochstartux, df$bigram)
#comp1 <- df[!bigramOccs,]
#comp2 <- df[bigramOccs,]


#bigrams = factor;
#tapply(create congengency table with time)

#trans <- transform(df, group = cbind(bigram,epochstartux))
#df$bound <- with(df, cbind(togethercnt, alonecnt, unigramcnt, epochvol))
#reshape from stat was the most intereting:
#reshape(bg,v.name="alonecnt",timevar=)
#require(reshape)
#bi <- cast(df, bigram~unigram+epochstartux+date,bound)

#cleanup
rm(df)
# dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.
dbClearResult(rs)
# dbDisconnect(con, ...) closes the connection. Eg.
dbDisconnect(con)
# dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
dbUnloadDriver(drv)

