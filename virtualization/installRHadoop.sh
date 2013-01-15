#!/bin/bash
# needs to be run as root
echo 'options(repos=structure(c(CRAN="http://cran.rstudio.com/")))' >> /usr/lib/R/library/base/R/Rprofile 

R CMD javareconf

#wget 'https://github.com/downloads/RevolutionAnalytics/RHadoop/rmr2_2.0.2.tar.gz'&
#wget 'https://github.com/downloads/RevolutionAnalytics/RHadoop/rhdfs_1.0.5.tar.gz'&
#wget 'https://github.com/downloads/RevolutionAnalytics/RHadoop/rhbase_1.1.tar.gz'&

Rscript --vanilla --default-packages=utils -e 'try(install.packages("RJSONIO"))' -e 'try(install.packages("itertools"))' -e 'try(install.packages("digest"))' -e 'try(install.packages("rJava"))' -e 'try(install.packages("Rcpp"))' -e 'try(install.packages("functional"))' -e 'try(install.packages("stringr"))' -e 'try(install.packages("plyr"))'  

echo "HADOOP_CMD=/usr/bin/hadoop" >> /etc/environment
echo "HADOOP_STREAMING=/usr/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.0.0-mr1-cdh4.1.2.jar" >> /etc/environment
source /etc/environment

R CMD INSTALL /nfs/vmshared/rmr/rmr2_2.0.2.tar.gz 
R CMD INSTALL /nfs/vmshared/rmr/rhdfs_1.0.5.tar.gz

 
