
# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

require(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="sample-0.01", user="yaboulna", password="5#afraPG",
    host="hops.cs.uwaterloo.ca", port="5433")
rs <- dbSendQuery(con,
  " select a.epochstartmillis/1000 as epochstartux, 121221 as date, a.ngramarr as unigram, b.ngramarr as bigram, 
       b.cnt as togethercnt, a.cnt - b.cnt as alonecnt, a.cnt as unigramcnt, v.totalcnt as epochvol, b.ngramlen as ngramlen 
    from (cnt_5min1 a join cnt_5min2 b on 
          a.epochstartmillis = b.epochstartmillis and a.ngramArr[1] = ANY (b.ngramarr))
       join volume_5min1 v on v.epochstartmillis = b.epochstartmillis
    where a.date = 121221 and b.date=121221 and b.cnt > 3;")

#" select bigram, 121221 as date, array_agg(a.epochstartmillis) as epochstartuxArr, array_agg(unigram) AS unigramArr,
#    array_agg(togetherCnt) as togetherCntArr, array_agg(aloneCnt) as aloneCntArr, 
#    array_agg(unigramCnt) as unigramCntArr, array_agg(epochVol) as epochVolArr, array_agg(ngramLen) as ngramLenArr 		
#    FROM (select a.epochstartmillis, a.ngramarr as unigram, b.ngramarr as bigram, 
#    b.cnt as togethercnt, a.cnt - b.cnt as alonecnt, a.cnt as unigramcnt, v.totalcnt as epochvol, b.ngramlen as ngramlen 
#    from ((cnt_5min1 a join cnt_5min2 b on 
#    a.epochstartmillis = b.epochstartmillis and a.ngramArr[1] = ANY (b.ngramarr))
#    join volume_5min1 v on v.epochstartmillis = b.epochstartmillis)
#    where a.date = 121221 and b.date=121221 and b.cnt > 3 GROUP BY b.ngramarr) AS r;"

df <- fetch(rs, n=-1);

bigramOccs <- duplicated(df$epochstartux, df$bigram)
comp1 <- df[!bigramOccs,]
comp2 <- df[bigramOccs]

#bigrams = factor;
#tapply(create congengency table with time)

#trans <- transform(df, group = cbind(bigram,epochstartux))
#df$bound <- with(df, cbind(togethercnt, alonecnt, unigramcnt, epochvol))
#reshape from stat was the most intereting reshap(
#require(reshape)
#bi <- cast(df, bigram~unigram+epochstartux+date,bound)

# dbDisconnect(con, ...) closes the connection. Eg.
dbDisconnect(con)

# dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.

dbUnloadDriver(drv)

