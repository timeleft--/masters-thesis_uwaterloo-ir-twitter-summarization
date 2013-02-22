#!/bin/bash
# First install the conrib package
#CREATE EXTENSION dblink
# select * from dblink('dbname=full port=5433', 'select * from unigramsp0') as ugp0(id int8, timemillis int8, date int4, ngram text, ngramlen int2, tweetlen int2, pos int2);

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

for p in {0..70} 
do
echo "${psql} \"CREATE UNLOGGED TABLE unigramsP${p} (CHECK (pos = ${p})) INHERITS(bypos); \
    COPY unigramsP${p} FROM '${root}bypos_onefile/unigramsP${p}';   \
    CREATE INDEX unigramsP${p}_date ON unigramsP${p}(date);\"&"
#    CREATE INDEX ngrams${len}_ngramLen ON ngrams${len}(ngramLen);\""

done


running="-n \$(ps r -U postgres  | grep -e \"${db} \[local\] \")"
echo "while : ; do "
echo " while [[ ${running} ]]; do sleep 50; done "
echo " sleep 30; "
echo " if [[ ! ${running} ]]; then echo 'DONE'; break; fi "
echo "done "


