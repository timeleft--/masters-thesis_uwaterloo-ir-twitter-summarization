#!/bin/bash

db=${1}

psql="psql -p 5433 -d ${db} -c "

echo "${psql} 'select * from ngrams1 a join ngrams2 b on a.id=b.id;'&"
echo "${psql} 'select * from ngrams2;'&"
echo "${psql} 'select * from ngrams1;'&"

running="-n \$(ps -U postgres  | grep -e \"${db} \[local\] \")"
echo "while : ; do "
echo " while [[ ${running} ]]; do sleep 5; done "
echo " sleep 3; "
echo " if [[ ! ${running} ]]; then echo 'DONE'; break; fi "
echo "done "
 
