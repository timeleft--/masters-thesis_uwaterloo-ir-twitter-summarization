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
for p in 6 7 8 9 16 17 18 19 26 27 28 29 36 37 38 39 46 47 48 49 56 57 58 59 66 67 68 69
do
${psql} "CREATE UNLOGGED TABLE unigramsP${p} (CHECK (pos = ${p})) INHERITS(bypos); \
    COPY unigramsP${p} FROM '${root}bypos_onefile/unigramsP${p}';   \
    CREATE INDEX unigramsP${p}_date ON unigramsP${p}(date);"&
#    CREATE INDEX ngrams${len}_ngramLen ON ngrams${len}(ngramLen);\""
done

