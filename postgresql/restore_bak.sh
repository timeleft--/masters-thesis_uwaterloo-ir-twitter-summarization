#!/bin/bash

root=${1}
bak=`ls -1 *.bak`
for b in bak
do
n=`cut -d '_' -f 1 | echo "${b}"`
mv ${n} ${n}_reverted_${ts}
mv ${b} ${n}
done