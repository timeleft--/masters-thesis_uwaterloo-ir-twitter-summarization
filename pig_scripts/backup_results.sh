#!/bin/bash
for p in {0..70}
do
hdfs dfs -cat bypos/unigrams/pos${p}/* > ~/vmshared/backup/full/bypos_onefile/unigramsP${p} &
done
