#!/bin/bash
if [ $# -ne 4 ]; then
    echo "usage"
    exit 1
fi
db=${1}
root=${2}
psql="psql -p 5433 -d ${db} -c "
for epoch in '1hr' #'1day' '5min'# More than a day date becomes meaningless '1week' '1month'
do
    #echo "${psql} 'DROP TABLE IF EXISTS cnt_${epoch} CASCADE;'"
    echo "${psql} 'CREATE TABLE cnt_${epoch} (ngramLen int2, ngram text, date int4, epochStartMillis int8, cnt int4);'" #, pkey serial Primary key);'"
#    for len in 1 2  #{1..71}
    len=$3
    while [ $len -le $4 ] 
    do
	# echo "hdfs dfs -cat ${root}/cnt_${epoch}/ngrams1/part* | ${psql} 'COPY cnt_${epoch} (ngram, date, epochstartmillis, cnt) FROM STDIN;'"
	echo "${psql} 'CREATE TABLE cnt_${epoch}${len} (ngramLen int2, ngram text, date int4, epochStartMillis int8, cnt int4);'"
	echo "${psql} \"COPY cnt_${epoch}${len} (ngramLen, ngram, date, epochstartmillis, cnt) FROM '${root}cnt_${epoch}_onefile/ngrams${len}';\""
#	echo "${psql} \"CREATE TABLE cnt_${epoch}${len} as select ngramlen, regexp_split_to_array(trim(trailing ')' from trim(leading '(' from ngram)), ',') as ngramArr, date, epochstartmillis, cnt from cnt_${epoch}${len}_staging;\"" # where date = 121221 and cnt > 3;'
	echo "${psql} 'ALTER TABLE cnt_${epoch}${len} INHERIT cnt_${epoch};'"
	echo "${psql} 'ALTER TABLE cnt_${epoch}${len} ALTER COLUMN ngramlen SET DEFAULT ${len};'"
#	echo "${psql} 'DROP TABLE cnt_${epoch}${len}_staging;'"
	echo "${psql} 'CREATE INDEX cnt_${epoch}${len}_date ON cnt_${epoch}${len}(date);'"
#	echo "${psql} 'CREATE INDEX cnt_${epoch}${len}_ngramLen ON cnt_${epoch}${len}(ngramLen);'"
	echo "${psql} 'CREATE TABLE volume_${epoch}${len} as select min(ngramLen) as ngramLen, min(date) as date, epochstartmillis, sum(cnt) as totalcnt from cnt_${epoch}${len} group by epochstartmillis;'"
	echo ""
	len=`expr $len + 1`
    done
done
