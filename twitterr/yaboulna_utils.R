annotPrint <- function(label,...){
  print(paste(Sys.time(), label, paste(...), sep=" | "))
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
