# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

epoch1<-epoch2<-'1hr'
ngramlen1<-3
ngramlen2<-ngramlen1+1
day<-121106

require(RPostgreSQL)

drv <- dbDriver("PostgreSQL")

conFull <- dbConnect(drv, dbname="full", user="yaboulna", password="5#afraPG",
    host="hops.cs.uwaterloo.ca", port="5433")
conSample <- dbConnect(drv, dbname="sample-0.01", user="yaboulna", password="5#afraPG",
    host="hops.cs.uwaterloo.ca", port="5433")

sql <- sprintf("select * from cnt_%s%d%s b where date=%s ;", epoch2, ngramlen2, ifelse(ngramlen2<3,'',paste("_",day, sep="")), 
    day)

ngramRs <- dbSendQuery(conFull,sql)
# Test SQL: select b.epochstartmillis/1000 as epochstartux, v.totalcnt as epochvol, b.ngramarr as ngram, b.cnt as togethercnt from cnt_1hr2 b join volume_1hr1 v on v.epochstartmillis = b.epochstartmillis where b.date=121106 and b.cnt > 5;

ngramDf <- fetch(ngramRs, n=-1)

try(dbClearResult(ngramRs))

chosenIx <- sample(1:nrow(ngramDf),nrow(ngramDf)/10)
ngramSample <- ngramDf[chosenIx,]

dbWriteTable(conSample,sprintf("cnt_%s%d%s",epoch2,ngramlen2,ifelse(ngramlen2<3,'',paste("_",day, sep=""))),ngramSample)

rm(ngramDf)
rm(ngramSample)


###################################

sql <- sprintf("SELECT * FROM volume_%s%d%s;", epoch1, ngramlen1, ifelse(ngramlen1<2,'',paste("_",day,sep="")))

volRs <- dbSendQuery(conFull,sql)

volDf <- fetch(volRs,n=-1)

try(dbClearResult(volRs))

dbWriteTable(conSample,sprintf("volume_%s%d%s", epoch1, ngramlen1, ifelse(ngramlen1<2,'',paste("_",day,sep=""))),volDf)

rm(volDf)

###################################
if(ngramlen1==1){
  sql <- sprintf("select * from cnt_%s%d where date=%d order by cnt desc;", epoch1, ngramlen1, day)
} else {
  sql <- sprintf("select * from compcnt_%s%d_%d;",epoch1, ngramlen1, day) #order by cnt desc
}
ugramRs <- dbSendQuery(conFull,sql)

ugramDf <- fetch(ugramRs, n=-1)
try(dbClearResult(ugramRs))

#Avoiding the following error
#Error in postgresqlExecStatement(conn, statement, ...) : 
#    RS-DBI driver: (could not Retrieve the result : ERROR:  column "row.names" specified more than once
#      )
#[1] FALSE
#Warning message:
#    In postgresqlWriteTable(conn, name, value, ...) :
#    could not create table: aborting assignTable
ugramDf["row.names"] <- NULL

dbWriteTable(conSample,sprintf("compcnt_%s%d_%d",epoch1, ngramlen1, day),ugramDf)

try(dbDisconnect(conFull))
try(dbDisconnect(conSample))
# dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
try(dbUnloadDriver(drv))
