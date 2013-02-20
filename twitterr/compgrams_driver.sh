#!/bin/bash
if [ $# -ne 1 ]; then
echo "usage"
exit 1
fi

runTS=${1}
db=full

for ngramlen1 in 1 #2 3 4 5 6 7 8 9 10
do
    ngramlen2=`expr ${ngramlen1} + 1`
    echo "\
echo \"Extending good ngrams of length ${ngramlen1} by another unigram. Follow: ~/logs_r/compgrams-extend_${ngramlen2}_${runTS}.err\" \n\
R -f compgrams_extend.R --args ${ngramlen1} > ~/logs_r/compgrams-extend_${ngramlen2}_${runTS}.out 2> ~/logs_r/compgrams-extend_${ngramlen2}_${runTS}.err \n\
\n\
echo \"Populating DB by candidate compgrams of length ${ngramlen2} and their counts. Commands logged in: ../postgresql/compgrams_${ngramlen2}_populate.sh\" \n\
sh ../postgresql/compgrams_create-len-date_populate.sh ${db} ${ngramlen2} > ../postgresql/compgrams_${ngramlen2}_populate.sh \n\
chmod +x ../postgresql/compgrams_${ngramlen2}_populate.sh \n\
./../postgresql/compgrams_${ngramlen2}_populate.sh > ../postgresql/compgrams_${ngramlen2}_populate.out 2> ../postgresql/compgrams_${ngramlen2}_populate.err \n\
\n\
echo \"Indexing newly populated tables. Commands logged in: ../postgresql/compgrams_${ngramlen2}_index.sh\" \n\
sh ../postgresql/compgrams_index.sh ${db} ${ngramlen2} > ../postgresql/compgrams_${ngramlen2}_index.sh \n\
chmod +x ../postgresql/compgrams_${ngramlen2}_index.sh \n\
./../postgresql/compgrams_${ngramlen2}_index.sh > ../postgresql/compgrams_${ngramlen2}_index.out 2> ../postgresql/compgrams_${ngramlen2}_index.err \n\
\n\
echo \"Creating volume table as aggregate of counts of compgrams of legnthes UPTO ${ngramlen1}. Commands logged in: ../postgresql/volume_1hr${ngramlen1}_aggregate.sh\"\n\
sh ../postgresql/compound_aggregate.sh ${db} ${ngramlen1} > ../postgresql/volume_1hr${ngramlen1}_aggregate.sh \n\
chmod + ../postgresql/volume_1hr${ngramlen1}_aggregate.sh \n\
./../postgresql/volume_1hr${ngramlen1}_aggregate.sh > ../postgresql/volume_1hr${ngramlen1}_aggregate.out 2> ../postgresql/volume_1hr${ngramlen1}_aggregate.err \n\
\n\
    echo \"Calculating ngram association for candidates of length ${ngramlen2}, follow: ~/logs_r/ngram-assoc_${ngramlen2}_${runTS}.err\" \n\
    R -f ngram_association.R --args ${ngramlen1} > ~/logs_r/ngram-assoc_${ngramlen2}_${runTS}.out 2> ~/logs_r/ngram-assoc_${ngramlen2}_${runTS}.err \n\
\n\
    echo \"Creating and populating occurrence table for selected compgrams of length ${ngramlen2}. Commands logged in: ../postgresql/occs_${ngramlen2}_populate.sh\" \n\
sh ../postgresql/occs_create-len-date_populate.sh ${db} ${ngramlen2} > ../postgresql/occs_${ngramlen2}_populate.sh \n\
chmod +x ../postgresql/occs_${ngramlen2}_populate.sh \n\
./../postgresql/occs_${ngramlen2}_populate.sh > ../postgresql/occs_${ngramlen2}_populate.out 2> ../postgresql/occs_${ngramlen2}_populate.err \n\
\n\
    echo \"Adjusting counts to incorporate good ngrams of length  ${ngramlen2} as compgrams. Follow: ~/logs_r/compgrams-count_${ngramlen2}_${runTS}.err\" \n\
    R -f compgrams_count.R --args ${ngramlen1} > ~/logs_r/compgrams-count_${ngramlen2}_${runTS}.out 2>  ~/logs_r/compgrams-count_${ngramlen2}_${runTS}.err \n\
\n\
    echo \"Creating compcnt inheritence heirarchny, just for convinence of analysis. Commands logged in: ../postgresql/compcnt-hier_1hr${ngramlen2}_alter.sh\" \n\
    sh ../postgresql/compound_inherit.sh ${db} ${ngramlen2} > ../postgresql/compcnt-hier_1hr${ngramlen2}_alter.sh \n\
    chmod +x ../postgresql/compcnt-hier_1hr${ngramlen2}_alter.sh \n\
    ./../postgresql/compcnt-hier_1hr${ngramlen2}_alter.sh > ../postgresql/compcnt-hier_1hr${ngramlen2}_alter.out 2> ../postgresql/compcnt-hier_1hr${ngramlen2}_alter.err \n\
\n\
echo \"Done for ngramlen1: ${ngramlen1} and ngramlen2: ${ngramlen2}\"" > compgrams-driver_${ngramlen1}-${ngramlen2}_${runTS}.sh
#sh compgrams-driver_${ngramlen1}-${ngramlen2}_${runTS}.sh

done
