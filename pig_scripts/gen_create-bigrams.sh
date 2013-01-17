#!/bin/bash
origLen=${1}
orig=ngram${origLen}
echo "SPLIT ${orig} INTO "
for x in {0..69}
do
  echo "  ${orig}P$x IF pos==${x},"
done
#maxPos=`expr 69 - ${origLen}`
#for x in {0..${maxPos}}
for x in {0..68}
do
  y=`expr ${x} + 1`
  echo "${orig}X2S${x} = JOIN ${orig}P$x BY id, ${orig}P$y BY id;"
  echo "${orig}C2S${x} = FOREACH ${orig}X2S${x} GENERATE (${orig}P${x}::token, ${orig}P${y}::token) as token, ${orig}P${x}::date as date, ${orig}P${x}::id as id, ${orig}P${x}::pos as pos, ${orig}P${x}::timeMillis as timeMillis, (${orig}P${x}::len + ${orig}P${y}::len) as len;"
done

#TODO: generalize
echo "ngram2 = UNION "
for x in {0..68}
do
  echo "  ${orig}C2S${x},"
done  

