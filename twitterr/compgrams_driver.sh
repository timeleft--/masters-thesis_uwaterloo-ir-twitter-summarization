#!/bin/sh
if [ $# -ne 3 ]; then
echo "usage"
exit 1
fi

runTS=${1}
db=${2}
root=${3}

for ngramlen1 in 2 3 4 5 6 7 8 9 10
do
    ngramlen2=`expr ${ngramlen1} + 1`

echo "#!/bin/bash" > compgrams-driver_${ngramlen1}-${ngramlen2}_${runTS}.sh

if [ $ngramlen1 -gt 1 ]
then
    echo "\
echo \"Extending good ngrams of length ${ngramlen1} by another unigram. Follow: ~/logs_r/compgrams-extend_${ngramlen2}_${runTS}.err\" \n\
R -f compgrams_extend.R --args ${ngramlen1} > ~/logs_r/compgrams-extend_${ngramlen2}_${runTS}.out 2> ~/logs_r/compgrams-extend_${ngramlen2}_${runTS}.err \n\
\n\
echo \"Populating DB by candidate compgrams of length ${ngramlen2} and their counts. Commands logged in: ../postgresql/compgrams_${ngramlen2}_populate_${runTS}.sh\" \n\
echo "#!/bin/bash" > ../postgresql/compgrams_${ngramlen2}_populate_${runTS}.sh \n\
sh ../postgresql/compgrams_create-len-date_populate.sh ${db} ${ngramlen2} ${root} >> ../postgresql/compgrams_${ngramlen2}_populate_${runTS}.sh \n\
chmod +x ../postgresql/compgrams_${ngramlen2}_populate_${runTS}.sh \n\
bash ../postgresql/compgrams_${ngramlen2}_populate_${runTS}.sh > ../postgresql/compgrams_${ngramlen2}_populate_${runTS}.out 2> ../postgresql/compgrams_${ngramlen2}_populate_${runTS}.err \n\
\n\
echo \"Indexing newly populated tables. Commands logged in: ../postgresql/compgrams_${ngramlen2}_index_${runTS}.sh\" \n\
echo "#!/bin/bash" > ../postgresql/compgrams_${ngramlen2}_index_${runTS}.sh \n\
sh ../postgresql/compgrams_index.sh ${db} ${ngramlen2} >> ../postgresql/compgrams_${ngramlen2}_index_${runTS}.sh \n\
chmod +x ../postgresql/compgrams_${ngramlen2}_index_${runTS}.sh \n\
bash ../postgresql/compgrams_${ngramlen2}_index_${runTS}.sh > ../postgresql/compgrams_${ngramlen2}_index_${runTS}.out 2> ../postgresql/compgrams_${ngramlen2}_index_${runTS}.err \n\
\n\
echo \"Creating volume table as aggregate of counts of compgrams of legnthes UPTO ${ngramlen1}. Commands logged in: ../postgresql/volume_1hr${ngramlen1}_aggregate_${runTS}.sh\"\n\
echo "#!/bin/bash" > ../postgresql/volume_1hr${ngramlen1}_aggregate_${runTS}.sh \n\
sh ../postgresql/compound_aggregate.sh ${db} ${ngramlen1} >> ../postgresql/volume_1hr${ngramlen1}_aggregate_${runTS}.sh \n\
chmod +x ../postgresql/volume_1hr${ngramlen1}_aggregate_${runTS}.sh \n\
bash ../postgresql/volume_1hr${ngramlen1}_aggregate_${runTS}.sh > ../postgresql/volume_1hr${ngramlen1}_aggregate_${runTS}.out 2> ../postgresql/volume_1hr${ngramlen1}_aggregate_${runTS}.err \n\
" >> compgrams-driver_${ngramlen1}-${ngramlen2}_${runTS}.sh
fi

echo "echo \"Calculating ngram association for candidates of length ${ngramlen2}, follow: ~/logs_r/ngram-assoc_${ngramlen2}_${runTS}.err\" \n\
    R -f ngram_association.R --args ${ngramlen1} > ~/logs_r/ngram-assoc_${ngramlen2}_${runTS}.out 2> ~/logs_r/ngram-assoc_${ngramlen2}_${runTS}.err \n\
\n\
    echo \"Creating and populating occurrence table for selected compgrams of length ${ngramlen2}. Commands logged in: ../postgresql/occs_${ngramlen2}_populate_${runTS}.sh\" \n\
echo "#!/bin/bash" > ../postgresql/occs_${ngramlen2}_populate_${runTS}.sh \n\
sh ../postgresql/occs_create-len-date_populate.sh ${db} ${ngramlen2} ${root} ${runTS} >> ../postgresql/occs_${ngramlen2}_populate_${runTS}.sh \n\
chmod +x ../postgresql/occs_${ngramlen2}_populate_${runTS}.sh \n\
bash ../postgresql/occs_${ngramlen2}_populate_${runTS}.sh > ../postgresql/occs_${ngramlen2}_populate_${runTS}.out 2> ../postgresql/occs_${ngramlen2}_populate_${runTS}.err \n\
\n\
    echo \"Adjusting counts to incorporate good ngrams of length  ${ngramlen2} as compgrams. Follow: ~/logs_r/compgrams-count_${ngramlen2}_${runTS}.err\" \n\
    R -f compgrams_count.R --args ${ngramlen1} > ~/logs_r/compgrams-count_${ngramlen2}_${runTS}.out 2>  ~/logs_r/compgrams-count_${ngramlen2}_${runTS}.err \n\
\n\
    echo \"Creating compcnt inheritence heirarchny, just for convinence of analysis. Commands logged in: ../postgresql/compcnt-hier_1hr${ngramlen2}_alter_${runTS}.sh\" \n\
echo "#!/bin/bash" >  ../postgresql/compcnt-hier_1hr${ngramlen2}_alter_${runTS}.sh \n\
sh ../postgresql/compound_inherit.sh ${db} ${ngramlen2} >> ../postgresql/compcnt-hier_1hr${ngramlen2}_alter_${runTS}.sh \n\
    chmod +x ../postgresql/compcnt-hier_1hr${ngramlen2}_alter_${runTS}.sh \n\
    bash ../postgresql/compcnt-hier_1hr${ngramlen2}_alter_${runTS}.sh > ../postgresql/compcnt-hier_1hr${ngramlen2}_alter_${runTS}.out 2> ../postgresql/compcnt-hier_1hr${ngramlen2}_alter_${runTS}.err \n\
\n\
echo \"Done for ngramlen1: ${ngramlen1} and ngramlen2: ${ngramlen2}\"" >> compgrams-driver_${ngramlen1}-${ngramlen2}_${runTS}.sh
chmod +x compgrams-driver_${ngramlen1}-${ngramlen2}_${runTS}.sh
#./compgrams-driver_${ngramlen1}-${ngramlen2}_${runTS}.sh

done
