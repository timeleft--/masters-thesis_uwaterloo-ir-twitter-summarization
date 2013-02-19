#!/bin/bash

for ngramlen1 in 5 6 7 8 9 10
do
    ngramlen2=`expr ${ngramlen1} + 1`
    echo "\
echo \"Extending good ngrams of length ${ngramlen1} by another unigram. Follow: ~/logs_r/compgrams-extend_${ngramlen2}_driven.err\" \n\
R -f compgrams_extend.R --args ${ngramlen1} > ~/logs_r/compgrams-extend_${ngramlen2}_driven.out 2> ~/logs_r/compgrams-extend_${ngramlen2}_driven.err \n\
\n\
echo \"Populating DB by candidate compgrams of length ${ngramlen2} and their counts. Commands logged in: ../postgresql/compgrams_${ngramlen2}_populate.sh\" \n\
sh ../postgresql/compgrams_create-len-date_populate.sh full ${ngramlen2} > ../postgresql/compgrams_${ngramlen2}_populate.sh \n\
sh ../postgresql/compgrams_${ngramlen2}_populate.sh > ../postgresql/compgrams_${ngramlen2}_populate.out 2> ../postgresql/compgrams_${ngramlen2}_populate.err \n\
\n\
echo \"Indexing newly populated tables. Commands logged in: ../postgresql/compgrams_${ngramlen2}_index.sh\" \n\
sh ../postgresql/compgrams_inex.sh full ${ngramlen2} > ../postgresql/compgrams_${ngramlen2}_index.sh \n\
sh ../postgresql/compgrams_${ngramlen2}_index.sh > ../postgresql/compgrams_${ngramlen2}_index.out 2> ../postgresql/compgrams_${ngramlen2}_index.err \n\
\n\
echo \"Creating volume table as aggregate of counts of compgrams of legnthes UPTO ${ngramlen1}. Commands logged in: ../postgresql/volume_1hr${ngramlen1}_aggregate.sh\"\n\
sh ../postgresql/compound_aggregate.sh full ${ngramlen1} > ../postgresql/volume_1hr${ngramlen1}_aggregate.sh \n\
sh ../postgresql/volume_1hr${ngramlen1}_aggregate.sh > ../postgresql/volume_1hr${ngramlen1}_aggregate.out 2> ../postgresql/volume_1hr${ngramlen1}_aggregate.err \n\
\n\
    echo \"Calculating ngram association for candidates of length ${ngramlen2}, follow: ~/logs_r/ngram-assoc_${ngramlen2}_driven.err\" \n\
    R -f ngram_association.R --args ${ngramlen1} > ~/logs_r/ngram-assoc_${ngramlen2}_driven.out 2> ~/logs_r/ngram-assoc_${ngramlen2}_driven.err \n\
\n\
    echo \"Adjusting counts to incorporate good ngrams of length  ${ngramlen2} as compgrams. Follow: ~/logs_r/compgrams-count_${ngramlen2}_driven.err\" \n\
    R -f compgrams_count.R --args ${ngramlen1} > ~/logs_r/compgrams-count_${ngramlen2}_driven.out 2>  ~/logs_r/compgrams-count_${ngramlen2}_driven.err \n\
\n\
    echo \"Creating compcnt inheritence heirarchny, just for convinence of analysis. Commands logged in: ../postgresql/compcnt-hier_1hr${ngramlen2}_alter.sh\" \n\
    sh ../postgresql/compound_inherit.sh full ${ngramlen2} > ../postgresql/compcnt-hier_1hr${ngramlen2}_alter.sh \n\
    sh ../postgresql/compcnt-hier_1hr${ngramlen2}_alter.sh > ../postgresql/compcnt-hier_1hr${ngramlen2}_alter.out 2> ../postgresql/compcnt-hier_1hr${ngramlen2}_alter.err \n\
\n\
echo \"Done for ngramlen1: ${ngramlen1} and ngramlen2: ${ngramlen2}\"" > compgrams-driver_${ngramlen1}-${ngramlen2}.sh
sh compgrams-driver_${ngramlen1}-${ngramlen2}.sh

done