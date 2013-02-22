#!/bin/bash
echo 'for job in `jobs -p` 
do 
echo $job 
wait $job 
done' 

#tail -f /dev/null &
#tail -f /dev/null &
#tail -f /dev/null &
#jobs -p

for job in `jobs -p`
do
echo $job
wait $job 
done

