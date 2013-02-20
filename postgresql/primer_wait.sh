#!/bin/bash

tail -f /dev/null &
tail -f /dev/null &
tail -f /dev/null &
jobs -p

for job in `jobs -p`
do
echo $job
wait $job 
done

