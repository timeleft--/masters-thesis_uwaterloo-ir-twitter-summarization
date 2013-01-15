#!/bin/bash
orig=${1}
echo "SPLIT ${orig} INTO "
for x in {0..69}
do
  echo "  ${orig}P$x IF pos==${x},"
done

for x in {0..68}
do
  y=`expr ${x} + 1`
  echo "${orig}X2S${x} = JOIN ${orig}P$x BY id, ${orig}P$y BY id;"
  echo "${orig}C2S${x} = FOREACH ${orig}X2S${x} GENERATE CONCAT(CONCAT(${orig}P${x}::token, 'C'), ${orig}P${y}::token) as token, ${orig}P${x}::day as day, ${orig}P${x}::id as id, ${orig}P${x}::pos as pos;"
done

echo "bigrams = UNION "
for x in {0..68}
do
  echo "  $1C2S$x,"
done  

