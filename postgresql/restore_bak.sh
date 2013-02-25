#!/bin/bash

root=${1}
bak=`ls -1 ${root} | grep .*csv_.*bak`
for b in ${bak}
do
n=`echo "${b}" | cut -d '_' -f 1`
mv ${root}/${n} ${root}/${n}_reverted_${ts}
mv ${root}/${b} ${root}/${n}
done