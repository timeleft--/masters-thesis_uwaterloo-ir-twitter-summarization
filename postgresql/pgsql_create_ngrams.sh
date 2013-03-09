#!/bin/bash
if [ $# -ne 2 ]; then
    echo "usage"
    exit 1
fi
db=${1}
root=${2}
psql="psql -p 5433 -d ${db} -c "
    #echo "${psql} 'DROP TABLE IF EXISTS ngrams CASCADE;'"
    echo "${psql} 'CREATE TABLE ngrams (id int8, timeMillis int8, date int4, ngram text, ngramLen int2, tweetLen int2, pos int2);'"
    for len in 1 #{1..71} 
    do
	echo "${psql} 'CREATE TABLE ngrams${len} (CHECK (ngramLen = ${len})) INHERITS(ngrams);'" 
	echo "${psql} 'ALTER TABLE ngrams${len} ALTER COLUMN ngramlen SET DEFAULT ${len};'"
	echo "${psql} \"COPY ngrams${len} FROM '${root}ngrams_onefile/ngrams${len}';\""
	echo "${psql} 'CREATE INDEX ngrams${len}_date ON ngrams${len}(date);'"
	echo "${psql} 'CREATE INDEX ngrams${len}_ngramLen ON ngrams${len}(ngramLen);'"
    done

