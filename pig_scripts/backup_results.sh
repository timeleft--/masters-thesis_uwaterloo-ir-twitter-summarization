#!/bin/sh
for p in {0..70}
do
hdfs dfs -cat bypos/pos${p} > ~/vmshared/backup/full/bypos_onefile/pos${p} &
done