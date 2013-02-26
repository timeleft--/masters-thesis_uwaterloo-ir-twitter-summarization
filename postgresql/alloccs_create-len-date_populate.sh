#!/bin/bash
if [ $# -ne 4 ]; then 
    echo "usage"
    exit 1
fi
db=${1}
len=${2}
root=${3}
runid=${4}

epoch='1hr'
psql="psql -p 5433 -d ${db} -c "

for day in 120925  120926  120930  121008  121013  121016  121026  121027  121028  121029  121030  121103  121104  121105  121106  121108  121110  121116  121119  121120  121122  121123  121125  121205  121206  121210  121214  121215  121231  130103  130104
#121106 121110 130103 121016 121206 121210 120925 121223 121205 130104 121108 121214 121030 120930 121123 121125 121027 121105 121116 121106 121222 121026 121028 120926 121008 121104 121103 121122 121114 121231 120914 121120 121119 121029 121215 121013 121220 121212 121111 121217 130101 121226 121127 121128 121124 121229 121020 120913 121121 121007 121010 121203 121207 121218 130102 121025 120920 120929 121009 121126 121021 121002 121201 120918 120919 120927 121012 120924 120928 121024 121209 121115 121112 121227 121101 121113 121211 121204 120921 121224 121130 121208 120922 121230 121001 121006 121031 121015 121129 121014 121003 121117 121118 121213 121107 121109 121004 121019 121022 121017 121023 121216 121225 121102 121202 121018 121005 121011 120917 121221 121228 120923 121219
do
#echo "${psql} 'DROP TABLE IF EXISTS ngrams_${len}_${day};'"
#echo "${psql} 'CREATE TABLE ngrams_${len}_${day} (id numeric, timemillis numeric, date int4, ngram text, ngramlen int2, tweetlen int2, pos int2 \
#CHECK (ngramlen = ${len} and date = ${day}));'"
#echo "${psql} 'ALTER TABLE ngrams_${len}_${day} ALTER COLUMN compgramlen SET DEFAULT ${len};'"

#echo "${psql} 'ALTER TABLE ngrams_2_${day} ADD yuleq float8, ADD epochcnt int8, ADD dunningl float8;'"

fpath=${root}/occ_yuleq_${len}/${day}.csv

#echo "cut -d '	' -f 1 ${fpath} | nl -w 9 -s '{' | cut -c10- > ${fpath}_fix1_tmp"
#echo "cut -d '	' -f 2- ${fpath} | nl -w 9 -s '	' | cut -c10- > ${fpath}_fix2_tmp"
#echo "mv ${fpath} ${fpath}_fix_${runid}.bak"
#echo "paste -d '}' ${fpath}_fix1_tmp ${fpath}_fix2_tmp > ${fpath}"
#echo "rm ${fpath}_fix1_tmp"
#echo "rm ${fpath}_fix2_tmp"

# No need to do the same for the file with all occurrences.. use it just to extend the compgrams,
# unlike the selection file which is insert into the ngramss tables used by FIM

#echo "${psql} \"COPY ngrams_${len}_${day} FROM '${fpath}' WITH NULL AS 'NA';\
#ALTER TABLE ngrams_${len}_${day} ALTER COLUMN id TYPE int8, ALTER COLUMN timemillis TYPE int8, INHERIT bak_alloccs;\"&"
echo "${psql} \"CREATE INDEX ngrams_${len}_${day}_date ON ngrams_${len}_${day}(date); \
    CREATE INDEX ngrams_${len}_${day}_len ON ngrams_${len}_${day}(ngramlen); \
    CREATE INDEX ngrams_${len}_${day}_timem ON ngrams_${len}_${day}(timemillis);\"&"
done


running="-n \$(ps r -U postgres  | grep -e \"${db} \[local\] \")"
echo "while : ; do "
echo " while [[ ${running} ]]; do sleep 5; done "
echo " sleep 3; "
echo " if [[ ! ${running} ]]; then echo 'DONE'; break; fi "
echo "done "
