#!/bin/bash
db=${1}
psql="psql -p 5433 -d ${db} -c "
for epoch in '5min' '1hr' '1day' '1week' '1month'
do
  echo "${psql} 'CREATE UNLOGGED TABLE cnt_${epoch} (ngramLen int2, ngram text, date int4, epochStartMillis int8, cnt int4, pkey serial Primary key);'"
   echo "${psql} 'CREATE INDEX cnt_${epoch}_date ON cnt_${epoch}(date);'"
   echo "${psql} 'CREATE INDEX cnt_${epoch}_ngramLen ON cnt_${epoch}(ngramLen);'"
done
