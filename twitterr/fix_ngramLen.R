# TODO: Add comment
# 
# Author: yia
###############################################################################



while(!require(foreach)){
  install.packages("foreach")
}
while(!require(doMC)){
  install.packages("doMC")
}
registerDoMC(cores=30)

removeExtraCol <- function(day,inRoot){
  inPath<-paste(inRoot,day,".csv",sep="")
orig <- read.table(inPath, header = FALSE, quote = "", comment.char="", 
    sep = "\t", na = "NA", dec = ".", row.names = NULL,fill=TRUE,
    col.names = c("id","timemillis","date","ngram","ngramlen","tweetlen","pos","extra"),
    colClasses = c("character","numeric","integer","character","integer","integer","integer","integer"),
    fileEncoding = "UTF-8")
longerMask <- which(!is.na(orig$extra))
orig[longerMask,] <- within(orig[longerMask,],{ngramlen<-extra})
orig$extra <- NULL
file.rename(inPath,paste(inPath,"extra",sep="."))
write.table(orig, file = inPath, append = TRUE, quote = FALSE, sep = "\t",
    eol = "\n", na = "NA", dec = ".", row.names = FALSE,
    col.names = FALSE, # qmethod = c("escape", "double"),
    fileEncoding = "UTF-8")

return(paste("Ignored result for day",day))
}



nullCombine <- function(a,b) NULL
foreach(day=c(121110), #130103, 121016, 121206, 121210, 120925, 121223, 121205, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116, 121106, 121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219),
        .inorder=FALSE, .combine='nullCombine') %dopar%
    {
      daySuccess <- paste("Unkown result for day",day)
      
      tryCatch({
            
            daySuccess <<- removeExtraCol("~/r_output/compgrams_byday/compgrams_1hr2/") 
            
          }
          ,error=function(e) daySuccess <<- paste("Failure for day",day,e)
          ,finally=try(stop(paste(Sys.time(), 
                      daySuccess,
                      sep=" - ")))
      )
    }



