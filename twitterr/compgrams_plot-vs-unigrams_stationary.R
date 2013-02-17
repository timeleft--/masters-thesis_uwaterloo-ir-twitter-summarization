G.plotsRoot <- "~/plots_r/"

logLabelCPU <- "compgrams_plot-vs-unigrams"

DEBUG_CPU <- FALSE

CPU.epoch2 <- '1hr'
CPU.ngramlen2 <- 2
CPU.supp <- 5

if(DEBUG_CPU){
  G.dbCPU<-'full' #'sample-0.01'
  CPU.days <- c(121106,121110)
  CPU.nCores <- 2
  day <- 121106 
  db <-G.dbCPU 
  support <- CPU.supp
} else {
  G.dbCPU<-'full'
  CPU.days <- c(121110, 130103, 121016, 121206, 121210, 120925, 121223, 121205,121106) #, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116,  121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219)
  CPU.nCores <- 30
}

while(!require(foreach)){
  install.packages("foreach")
}
while(!require(doMC)){
  install.packages("doMC")
}
registerDoMC(cores=CPU.nCores)

while(!require(plyr)){
  install.packages("plyr")
}

while(!require(RPostgreSQL)){
  install.packages("RPostgreSQL")
} 


plotDensitiesForDay <- function (day, epoch1=NULL, ngramlen1=1, epoch2=CPU.epoch2, ngramlen2=CPU.ngramlen2, db = G.dbCPU, support=CPU.supp) {
 
  if(is.null(epoch1)){
    epoch1 <- epoch2
  }
  
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
  try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Connected to DB",db)))
  
  inTable <- paste('compcnt_',epoch2,ngramlen2,'_',day,sep="")
  if(!dbExistsTable(con,inTable)){
    stop(paste("Input table",inTable,"doesn't exist.. cannot process the day")) #skippinng the day
  }
  
  
  outRoot <- paste(G.plotsRoot,sprintf("/ngram%s%d-vs-compound%s%d_",epoch1,ngramlen1,epoch2,ngramlen2),day, sep="")
  if(file.exists(outRoot)){
    bakname <- paste(outRoot,"_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="")
    warning(paste("Renaming existing output dir",outRoot,bakname))
    file.rename(outRoot, #from
        bakname) #to
  }
  
  dir.create(outRoot,recursive = TRUE)
  
  ################
  
  sql <- sprintf("SELECT epochstartmillis/1000 as epochstartux,cnt FROM  cnt_%s%d where date=%d  and cnt > %d;",epoch1, ngramlen1, day, support)

  try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Fetching ngrams using sql: \n", sql)))
  
  ngramsRs <- dbSendQuery(con,sql)
  
  ngramsDf <- fetch(ngramsRs,n=-1)
  
  try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Fetched ngrams num rows: ", nrow(ngramsDf))))
  
  try(dbClearResult(ngramsRs))
  
  #####################
  
  sql <- sprintf("SELECT epochstartux,cnt FROM %s;", inTable)
  
  try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Fetching compound using sql: \n", sql)))
  
  compoundRs <- dbSendQuery(con,sql)
  
  compoundDf <- fetch(compoundRs,n=-1)
  
  try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Fetched compound num rows: ", nrow(compoundDf))))
  
  try(dbClearResult(compoundRs))
  
  #####################
  # dbDisconnect(con, ...) closes the connection. Eg.
  try(dbDisconnect(con))
  # dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
  try(dbUnloadDriver(drv))
  
  ##################
  ygrid <- c((1:20)*0.05)
  histogramPerEpoch <- function(eg){
    
    try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Will plot histogram for epoch", eg$epochstartux[1])))
  
    ngramEpochMask <- which(ngramsDf$epochstartux==eg$epochstartux[1])
    
    summaryNgrams <- summary(ngramsDf[ngramEpochMask,"cnt"])
    summaryCompgrams <- summary(eg$cnt)
    
#    occBreaks <- c(5,10,20,30,40,50,100,200,300,400,500,1000,2000,(summaryNgrams['Max.']+1)) # >= summaryCompgrams['Max.']
    occBreaks <- c(1:(log(max(summaryCompgrams['Max.']+1,summaryNgrams['Max.']+1))+1)) 

    epochOut <- paste(outRoot, "/hist_",day,"-",eg$epochstartux[1],sep="")
    
    par(mfrow=c(2,1))
    
    pdf(paste(epochOut,".pdf",sep=""))
    logNgrams <- log(ngramsDf[ngramEpochMask,"cnt"])
    hist(logNgrams, occBreaks, freq=FALSE, 
        axes=FALSE, xlab="LOG Occurrences less than or equal",
        main=paste("Density of Ngrams of length",ngramlen1,"in each occurrences per",epoch1,"bin.\nN",
            paste(names(summaryNgrams),collapse="\t"),"\n",length(ngramEpochMask),paste(summaryNgrams,collapse="\t")))
    axis(2,c(0,ygrid))
    axis(1,c(0,occBreaks))
    abline(h=ygrid,col="gray", lty=3)

    rug(logNgrams)
    
    legend("topright",legend=c("log(mean)","log(median)"),fill=c("blue","green"))
    abline(v=log(summaryNgrams['Mean']),col="blue")
    abline(v=log(summaryNgrams['Median']),col="green")
    
    logCompgrams <- log(eg$cnt)
    hist(logCompgrams, occBreaks, freq=FALSE, 
        axes=FALSE,xlab="LOG Occurrences less than or equal",
        main=paste("Density of Compgrams of length",ngramlen2,"in each occurrences per",epoch2,"bin.\nN",
            paste(names(summaryNgrams),collapse="\t"),"\n",length(eg$cnt),paste(summaryCompgrams,collapse="\t")))
    axis(2,c(0,ygrid))
    axis(1,c(0,occBreaks))
    abline(h=ygrid,col="gray", lty=3)
    
    rug(logCompgrams)
    
    legend("topright",legend=c("log(mean)","log(median)"),fill=c("blue","green"))
    abline(v=log(summaryCompgrams['Mean']),col="blue")
    abline(v=log(summaryCompgrams['Median']),col="green")
    
    
    dev.off()
    
    try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Finished plotting histogram of epoch", eg$epochstartux[1])))
  }
#  debug(histogramPerEpoch)
  d_ply(idata.frame(compoundDf), c("epochstartux"), histogramPerEpoch)
  
  
  ###################
  
  densityPlotPerEpoch <- function(eg){
 
    try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Will plot epoch", eg$epochstartux[1])))
    
    ngramEpochMask <- which(ngramsDf$epochstartux==eg$epochstartux[1])
    
    epochOut <- paste(outRoot, "/density_",day,"-",eg$epochstartux[1],sep="")
    
    pdf(paste(epochOut,".pdf",sep=""))
   
#    #par(lwd=3)
#    plot(density(eg$cnt), #,kernel="cosine"),  
#        xlab=paste("Number of occurrences per",epoch2), 
#        main=paste("Densities of ngrams",epoch1,ngramlen1," and compgrams",epoch2,ngramlen2,"\n in the epoch starting",eg$epochstartux[1]),
#        col="blue",log="xy")
#    lines(density(ngramsDf[ngramEpochMask,"cnt"]), #kernel="cosine"),
#        col="red",lty=2)
#    #mean
#    #lines(c(rep(mean,2),c(0,1))
    
    # Add a legend (the color numbers start from 2 and go up)
    legend("topright", legend=c(paste("ngrams",ngramlen1),paste("compound",ngramlen2)), fill=c("red","blue"))
   
    dev.off()
    
    try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Finished plotting epoch", eg$epochstartux[1])))
  }
#  debug(densityPlotPerEpoch)
#  d_ply(idata.frame(compoundDf), c("epochstartux"), densityPlotPerEpoch)
  
  
  
  return(paste("Success for day", day))
}


## Driver

nullCombine <- function(a,b) NULL
allMonthes <- foreach(day=CPU.days,
        .inorder=FALSE, .combine='nullCombine') %dopar%
    {
      daySuccess <- paste("Success for day", day) #"Unkown result for day",day)
      
      tryCatch({
            
            daySuccess <<- plotDensitiesForDay(day, ngramlen1=2) 
#                epoch2 = CPU.epoch2, ngramlen2 = CPU.ngramlen2,  db = G.dbCPU)
            
          }
          ,error=function(e) daySuccess <<- paste("Failure for day",day,e)
          ,finally=try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - ", daySuccess)))
      )
    }

