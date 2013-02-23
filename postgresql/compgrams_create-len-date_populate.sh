#!/bin/bash
if [ $# -ne 3 ]; then 
    echo "usage"
    exit 1
fi
db=${1}
len=${2}
root=${3}
epoch='1hr'
psql="psql -p 5433 -d ${db} -c "

echo "${psql} 'CREATE TABLE compgrams () INHERITS(ngrams);'"
echo "${psql} 'CREATE TABLE cnt_${epoch}${len} () INHERITS(cnt_${epoch});'"

for day in 120925  120926  120930  121008  121013  121016  121026  121027  121028  121029  121030  121103  121104  121105  121106  121108  121110  121116  121119  121120  121122  121123  121125  121205  121206  121210  121214  121215  121231  130103  130104
# 121106 121110 130103 121016 121206 121210 120925 121223 121205 130104 121108 121214 121030 120930 121123 121125 121027 121105 121116 121106 121222 121026 121028 120926 121008 121104 121103 121122 121114 121231 120914 121120 121119 121029 121215 121013 121220 121212 121111 121217 130101 121226 121127 121128 121124 121229 121020 120913 121121 121007 121010 121203 121207 121218 130102 121025 120920 120929 121009 121126 121021 121002 121201 120918 120919 120927 121012 120924 120928 121024 121209 121115 121112 121227 121101 121113 121211 121204 120921 121224 121130 121208 120922 121230 121001 121006 121031 121015 121129 121014 121003 121117 121118 121213 121107 121109 121004 121019 121022 121017 121023 121216 121225 121102 121202 121018 121005 121011 120917 121221 121228 120923 121219
do
echo "${psql} 'DROP TABLE IF EXISTS compgrams${len}_${day};'"
echo "${psql} 'DROP TABLE IF EXISTS cnt_${epoch}${len}_${day};'"

echo "${psql} 'CREATE TABLE compgrams${len}_${day} (CHECK (ngramLen = ${len} and date = ${day})) INHERITS(compgrams);'"
echo "${psql} 'ALTER TABLE compgrams${len}_${day} ALTER COLUMN ngramlen SET DEFAULT ${len};'"

#echo "${psql} 'CREATE TABLE cnt_${epoch}${len}_${day} () INHERITS(cnt_${epoch}${len});'"
# floor(timemillis/3600000),ngram
echo "${psql} \"COPY compgrams${len}_${day} FROM '${root}/occ_extended${len}/${day}.csv'; \
 CREATE TABLE cnt_${epoch}${len}_${day} AS select CAST( ${len} as int2) as ngramlen, CAST('{' || ngram || '}' as text[]) as ngramarr, CAST (${day} as int4) as date, cast( floor(timemillis/3600000) * 3600000 as int8) as epochstartmillis, cast(count(*) as int4) as cnt from compgrams${len}_${day} \
    group by ngramarr, epochstartmillis; \
    ALTER TABLE cnt_${epoch}${len}_${day} INHERIT cnt_${epoch}${len}; \"&"
#Will insert  need explicit type casing? No, it didn't

done

running="-n \$(ps r -U postgres  | grep -e \"${db} \[local\] \")"
echo "while : ; do "
echo " while [[ ${running} ]]; do sleep 5; done "
echo " sleep 3; "
echo " if [[ ! ${running} ]]; then echo 'DONE'; break; fi "
echo "done "
 

