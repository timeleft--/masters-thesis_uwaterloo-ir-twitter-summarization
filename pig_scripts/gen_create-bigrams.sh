#!/bin/bash
echo "SPLIT $1 INTO "
for x in {0..69}
do
  echo "  $2$x IF $2==$x,"
done

for x in {0..68}
do
  y=`expr $x+1`
  echo "$1X2S$x = JOIN $2$x BY id, $2$y BY id;"
  echo "$1C2S$x = FOREACH $1X2S$x GENERATE CONCAT(CONCAT($2$x::token, 'C'), $2$y::token) as token, $2$x::day as day, $2$x::id as id, $2$x::pos as pos;"
done

echo "ngramC2 = UNION "
for x in {0..68}
do
  echo "  $1C2S$x,"
done  

