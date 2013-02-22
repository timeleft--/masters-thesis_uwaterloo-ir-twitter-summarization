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

YOU CANNOT WAIT FOR A PROCESS THAT IS NOT A DIRECT CHILD OF YOUR PROCESS.. so db commands are out of the question:
echo "while [[ -n \$(ps r -U postgres  | grep -e \"${db} \[local\] \") ]]; do sleep 0.1; done " 
