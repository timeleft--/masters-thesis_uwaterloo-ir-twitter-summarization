#!/bin/bash

for ngramlen1 in {4..10}
do
    ngramlen2=`expr ${ngramlen1} + 1`

    echo "Calculating ngram association for candidates of length ${ngramlen2}, follow: ~/logs_r/ngram-assoc_${ngramlen2}_driven.err" 
    R -f ngram_association.R --args ${ngramlen1} > ~/logs_r/ngram-assoc_${ngramlen2}_driven.out 2> ~/logs_r/ngram-assoc_${ngramlen2}_driven.err 

    echo "Adjusting counts to incorporate good ngrams of length  ${ngramlen2} as compgrams. Follow: ~/logs_r/compgrams-count_${ngramlen2}_driven.err"
    R -f compgrams_count.R --args ${ngramlen1} > ~/logs_r/compgrams-count_${ngramlen2}_driven.out 2>  ~/logs_r/compgrams-count_${ngramlen2}_driven.err

    echo "Extending good ngrams of length ${ngramlen2} by yet another unigram. Follow: ~/logs_r/compgrams-extend_${ngramlen2}_driven.err"
    R -f compgrams_extend.R --args ${ngramlen1} > ~/logs_r/compgrams-extend_${ngramlen2}_driven.out 2> ~/logs_r/compgrams-extend_${ngramlen2}_driven.err

    echo "Populating DB by candidate compgrams of length ${ngramlen2} and their counts. Commands logged in: ../postgresql/compgrams_${ngramlen2}_populate.sh"
    sh ../postgresql/compgrams_create-len-date_populate.sh full ${ngramlen2} > ../postgresql/compgrams_${ngramlen2}_populate.sh
    sh ../postgresql/compgrams_${ngramlen2}_populate.sh > ../postgresql/compgrams_${ngramlen2}_populate.out

    echo "Indexing newly populated tables. Commands logged in: ../postgresql/compgrams_${ngramlen2}_index.sh"
    sh ../postgresql/compgrams_inex.sh full ${ngramlen2} > ../postgresql/compgrams_${ngramlen2}_index.sh
    sh ../postgresql/compgrams_${ngramlen2}_index.sh > ../postgresql/compgrams_${ngramlen2}_index.out

    echo "Creating volume table as aggregate of counts of compgrams of legnthes UPTO ${ngramlen1}. Commands logged in: ../postgresql/volume_1hr${ngramlen1}_aggregate.sh"
    sh ../postgresql/compound_aggregate.sh full ${ngramlen1} > ../postgresql/volume_1hr${ngramlen1}_aggregate.sh
    sh ../postgresql/volume_1hr${ngramlen1}_aggregate.sh > ../postgresql/volume_1hr${ngramlen1}_aggregate.out

    echo "Creating compcnt inheritence heirarchny, just for convinence of analysis. Commands logged in: ../postgresql/compcnt-hier_1hr${ngramlen1}_alter.sh"
    sh ../postgresql/compound_inherit.sh full ${ngramlen1} > ../postgresql/compcnt-hier_1hr${ngramlen1}_alter.sh
    sh ../postgresql/compcnt-hier_1hr${ngramlen1}_alter.sh > ../postgresql/compcnt-hier_1hr${ngramlen1}_alter.out

    echo "Done for ngramlen1: ${ngramlen1} and ngramlen2: ${ngramlen2}"
done