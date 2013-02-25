#!/bin/bash

root=${1}
bak=`ls -1 | grep .*csv_.*bak`
for b in ${bak}
do
n=`echo "${b}" | cut -d '_' -f 1`
mv ${n} ${n}_reverted_${ts}
mv ${b} ${n}
done