for nobraces in sel_121008.csv sel_121013.csv sel_121016.csv sel_121026.csv sel_121027.csv sel_121028.csv sel_121029.csv sel_121030.csv sel_121103.csv sel_121104.csv sel_121105.csv sel_121106.csv sel_121108.csv sel_121110.csv sel_121116.csv sel_121119.csv sel_121120.csv sel_121122.csv sel_121123.csv sel_121125.csv sel_121205.csv sel_121206.csv sel_121210.csv sel_121214.csv sel_121215.csv sel_121231.csv sel_130103.csv sel_130104.csv
do

cut -d "  " -f 1 ${root}/${nobraces} | nl -s "{" | cut -c7- > ${root}/${nobraces}_fix1.tmp
cut -d "  " -f 2- ${root}/${nobraces} | nl -s "  " | cut -c7- > ${root}/${nobraces}_fix2.tmp

paste -d "}" ${root}/${nobraces}_fix1.tmp ${root}/${nobraces}_fix2.tmp > ${root}/${nobraces}

done

for twobraces in sel_120925.csv sel_120926.csv sel_120930.csv
do

rm ${root}/${twobraces}
mv ${root}/${twobraces}_fix_130221-2135.bak ${root}/${twobraces}

done
 