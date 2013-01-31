# TODO: Add comment
# 
# Author: yaboulna
###############################################################################

require(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="sample", user="yaboulna", password="5#afraPG",
    host="hops.cs.uwaterloo.ca", port="5433")
rs <- dbSendQuery(con, "select * from cnt_1hr where (ngramLen=1 or ngramLen=2) and date=121221")

df <- fetch(rs, n=-1);

# dbClearResult(rs, ...) flushes any pending data and frees the resources used by resultset. Eg.

dbClearResult(rs)

# dbDisconnect(con, ...) closes the connection. Eg.

dbDisconnect(con)

# dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.

dbUnloadDriver(drv)

