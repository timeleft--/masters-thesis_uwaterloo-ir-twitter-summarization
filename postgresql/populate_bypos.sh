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
echo "${psql} 'CREATE TABLE bypos() INHERITS(ngrams);'"
#(id int8, timeMillis int8, date int4, ngram text, ngramLen int2, tweetLen int2, pos int2);'"

for p in {53..70} 
do
# DROP TABLE IF EXISTS unigramsP${p};
echo "${psql} \" \
    CREATE  TABLE unigramsP${p} (CHECK (pos = ${p})) INHERITS(bypos); \
    COPY unigramsP${p} FROM '${root}bypos_onefile/unigramsP${p}';   \
    CREATE INDEX unigramsP${p}_date ON unigramsP${p}(date);\
    CREATE INDEX unigramsP${p}_pos ON unigramsP${p}(pos);\"&"

done


running="-n \$(ps r -U postgres  | grep -e \"${db} \[local\] \")"
echo "while : ; do "
echo " while [[ ${running} ]]; do sleep 5; done "
echo " sleep 3; "
echo " if [[ ! ${running} ]]; then echo 'DONE'; break; fi "
echo "done "


