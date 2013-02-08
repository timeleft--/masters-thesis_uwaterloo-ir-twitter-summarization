#!/bin/bash
if [ $# -ne 2 ]; then
echo "usage"
exit 1
fi
db=${1}
root=${2}
psql="psql -p 5433 -d ${db} -c "
#echo "${psql} 'DROP TABLE IF EXISTS compgrams CASCADE;'"
#${psql} 'CREATE UNLOGGED TABLE bypos() INHERITS(ngrams);'
#(id int8, timeMillis int8, date int4, ngram text, ngramLen int2, tweetLen int2, pos int2);'"
for p in 0 10 20 30 40 50 60 70 
do
screen ${psql} "CREATE UNLOGGED TABLE unigramsP${p} (CHECK (pos = ${p})) INHERITS(bypos); \
    COPY unigramsP${p} FROM '${root}bypos_onefile/unigramsP${p}';   \
    CREATE INDEX unigramsP${p}_date ON unigramsP${p}(date);"
#    CREATE INDEX ngrams${len}_ngramLen ON ngrams${len}(ngramLen);\""
done

