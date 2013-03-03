annotPrint <- function(label,...){
  cat(paste(Sys.time(), label, paste(...), sep=" | "))
  cat('\n')
} 


createOutFile <- function(outDir, outFile){
  
  if(!file.exists(outDir)){
    dir.create(outDir,recursive = T)
  }
  
  if(file.exists(outFile)){
    bakname <- paste(outFile,"_",format(Sys.time(),format="%y%m%d%H%M%S"),".bak",sep="")
    warning(paste("Renaming existing output file",outFile,bakname))
    file.rename(outFile,bakname)
  }
  
  retVal <- paste(outFile,"staging",sep=".")
  
  file.create(retVal)
  
  return(retVal)
}

execCmd <- function(cmd, local=TRUE, asynch=FALSE){
  if(!local){
    stop("We will need to supply the pass phrase.. so this can't be done, and I won't make a key without a passphrase")
    cmd <- "ssh yaboulna@hops.cs.uwaterloo.ca"
  }
  return(system(cmd,intern=FALSE,wait=!asynch)) #intern=TRUE causes cannot popen too many open files
}

#Make sure that ~/.pgpass contains hops.cs.uwaterloo.ca:5433:*:yaboulna:5#afraPG
execSql <- function (sql,db, asynch=FALSE){ 
  psql <- sprintf("psql -p 5433 -h hops.cs.uwaterloo.ca -U yaboulna  %s -c \"%%s\"",db)
  cmd <- sprintf(psql,sql)
  annotPrint("execSql",cmd)
  return(execCmd(cmd,asynch = asynch))
}