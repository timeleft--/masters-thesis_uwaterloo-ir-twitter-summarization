G.plotsRoot <- "~/plots_r/"

logLabelCPU <- "compgrams_plot-vs-unigrams"

DEBUG_CPU <- TRUE

CPU.epoch2 <- '1hr'
CPU.ngramlen2 <- 2

if(DEBUG_CPU){
  G.dbCPU<-'full' #'sample-0.01'
  CPU.days <- c(121106,121110)
  CPU.nCores <- 2
  day <- 121106 
  db <-G.dbCPU 
} else {
  G.dbCPU<-'full'
  CPU.days <- c(121110, 130103, 121016, 121206, 121210, 120925, 121223, 121205, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116, 121106, 121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219)
  CPU.nCores <- 50
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

while(!require(sm)){
  install.packages("sm")
}

plotDensitiesForDay <- function (day, epoch2=CPU.epoch2, ngramlen2=CPU.ngramlen2, db = G.dbCPU) {
 
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=db, user="yaboulna", password="5#afraPG",
      host="hops.cs.uwaterloo.ca", port="5433")
  
  try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Connected to DB",db)))
  
  inTable <- paste('compound',epoch2,ngramlen2,'_',day,sep="")
  if(!dbExistsTable(con,inTable)){
    stop(paste("Input table",inTable,"doesn't exist.. cannot process the day")) #skippinng the day
  }
  
  
  outRoot <- paste(G.plotsRoot,"/unigramVsCompound_",day, sep="")
  if(file.exists(outRoot)){
    bakname <- paste(outRoot,"_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="")
    warning(paste("Renaming existing output dir",outRoot,bakname))
    file.rename(outRoot, #from
        bakname) #to
  }
  
  dir.create(outRoot,recursive = TRUE)
  
  ################
  
  sql <- sprintf("SELECT epochstartux,ngramlen,cnt FROM %s", inTable)
  
  try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Fetching compgrams using sql: \n", sql)))
  
  compgramsRs <- dbSendQuery(con, sql)
  
  compgramsDf <- fetch(compgramsRs,n=-1)
  
  
  try(dbClearResult(compgramsRs))
  # dbDisconnect(con, ...) closes the connection. Eg.
  try(dbDisconnect(con))
  # dbUnloadDriver(drv,...) frees all the resources used by the driver. Eg.
  try(dbUnloadDriver(drv))
  
  
  ###################
  
  divideByngramLenAndPlot <- function(eg){
   
    #sm.density.compare does this for us
#    compgramMask <- eg$ngramlen == ngramlen2
#    compoundDf <- eg[which(compgramMask),"cnt"]
#    unigramDf <- eg[which(!compgramMask),"cnt"]
    
    # function calls will result in copying of large amounts of data
#    plotUnigramVsCompoundHistogram(compoundDf,unigramDf)
    
    try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Will plot epoch", eg$epochstartux[1])))
  
    epochOut <- paste(outRoot, "/density_", epoch2,ngramlen2,'_',day,"-",eg$epochstartux[1],".pdf",sep="")
    
    pdf(epochOut)
   
    sm.density.compare(eg$cnt, eg$ngramlen, xlab=paste("Number of occurrences per",epoch2)) #model="equal"
    title(main=paste("Densities of unigrams and compgrams of length",ngramlen2,"in the",epoch2,"starting",eg$epochstartux[1]))
    
    # do we need a legend?
   
    dev.off()
    
    try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - Finished plotting epoch", eg$epochstartux[1])))
  }
  
  d_ply(idata.frame(compgramsDf), c("epochstartux"), divideByngramLenAndPlot)
  
  return(paste("Success for day", day))
}


## Driver

nullCombine <- function(a,b) NULL
allMonthes <- foreach(day=CPU.days,
        .inorder=FALSE, .combine='nullCombine') %dopar%
    {
      daySuccess <- paste("Success for day", day) #"Unkown result for day",day)
      
      tryCatch({
            
            daySuccess <<- plotDensitiesForDay(day) 
#                epoch2 = CPU.epoch2, ngramlen2 = CPU.ngramlen2,  db = G.dbCPU)
            
          }
          ,error=function(e) daySuccess <<- paste("Failure for day",day,e)
          ,finally=try(stop(paste(Sys.time(), logLabelCPU, " for day:", day, " - ", daySuccess)))
      )
    }

