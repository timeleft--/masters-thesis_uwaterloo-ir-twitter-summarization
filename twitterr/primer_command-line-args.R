# TODO: Add comment
# 
# Author: yia
###############################################################################


argv <- commandArgs(trailingOnly = TRUE)
# only for trailing FALSE: print(paste("The R script name is:",argv[1]))
print(paste("The command line arg:",argv[1]))
twice <- as.integer(argv[1]) * 2
print(paste("The command line arg x 2:",twice))