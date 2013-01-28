#!/bin/bash
if [ $# -ne 1 ]; then
    echo "usage"
    exit 1
fi
db=${1}
psql="psql -p 5433 -d ${db} -c "
for epoch in '5min' '1hr' '1day' # More than a day date becomes meaningless '1week' '1month'
do
    echo "${psql} 'DROP TABLE IF EXISTS cnt_${epoch};'"
    echo "${psql} 'CREATE TABLE cnt_${epoch} (ngramLen int2, ngram text, date int4, epochStartMillis int8, cnt int4, pkey serial Primary key);'"
    echo "${psql} 'CREATE INDEX cnt_${epoch}_date ON cnt_${epoch}(date);'"
    echo "${psql} 'CREATE INDEX cnt_${epoch}_ngramLen ON cnt_${epoch}(ngramLen);'"
done
