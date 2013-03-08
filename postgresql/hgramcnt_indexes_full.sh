psql -h hops -U yaboulna -p 5433 -d full -c  'CREATE TABLE hgram_cnt_1hr2 ( ngramlen     integer,  date         integer,  epochstartux bigint,  ngram        text,  cnt          integer );'
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121110_date ON hgram_cnt_1hr2_121110(date); CREATE INDEX hgram_cnt_1hr2_121110_ngramlen ON hgram_cnt_1hr2_121110(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_130103_date ON hgram_cnt_1hr2_130103(date); CREATE INDEX hgram_cnt_1hr2_130103_ngramlen ON hgram_cnt_1hr2_130103(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121016_date ON hgram_cnt_1hr2_121016(date); CREATE INDEX hgram_cnt_1hr2_121016_ngramlen ON hgram_cnt_1hr2_121016(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121206_date ON hgram_cnt_1hr2_121206(date); CREATE INDEX hgram_cnt_1hr2_121206_ngramlen ON hgram_cnt_1hr2_121206(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121210_date ON hgram_cnt_1hr2_121210(date); CREATE INDEX hgram_cnt_1hr2_121210_ngramlen ON hgram_cnt_1hr2_121210(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120925_date ON hgram_cnt_1hr2_120925(date); CREATE INDEX hgram_cnt_1hr2_120925_ngramlen ON hgram_cnt_1hr2_120925(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121223_date ON hgram_cnt_1hr2_121223(date); CREATE INDEX hgram_cnt_1hr2_121223_ngramlen ON hgram_cnt_1hr2_121223(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121205_date ON hgram_cnt_1hr2_121205(date); CREATE INDEX hgram_cnt_1hr2_121205_ngramlen ON hgram_cnt_1hr2_121205(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_130104_date ON hgram_cnt_1hr2_130104(date); CREATE INDEX hgram_cnt_1hr2_130104_ngramlen ON hgram_cnt_1hr2_130104(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121108_date ON hgram_cnt_1hr2_121108(date); CREATE INDEX hgram_cnt_1hr2_121108_ngramlen ON hgram_cnt_1hr2_121108(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121214_date ON hgram_cnt_1hr2_121214(date); CREATE INDEX hgram_cnt_1hr2_121214_ngramlen ON hgram_cnt_1hr2_121214(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121030_date ON hgram_cnt_1hr2_121030(date); CREATE INDEX hgram_cnt_1hr2_121030_ngramlen ON hgram_cnt_1hr2_121030(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120930_date ON hgram_cnt_1hr2_120930(date); CREATE INDEX hgram_cnt_1hr2_120930_ngramlen ON hgram_cnt_1hr2_120930(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121123_date ON hgram_cnt_1hr2_121123(date); CREATE INDEX hgram_cnt_1hr2_121123_ngramlen ON hgram_cnt_1hr2_121123(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121125_date ON hgram_cnt_1hr2_121125(date); CREATE INDEX hgram_cnt_1hr2_121125_ngramlen ON hgram_cnt_1hr2_121125(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121027_date ON hgram_cnt_1hr2_121027(date); CREATE INDEX hgram_cnt_1hr2_121027_ngramlen ON hgram_cnt_1hr2_121027(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121105_date ON hgram_cnt_1hr2_121105(date); CREATE INDEX hgram_cnt_1hr2_121105_ngramlen ON hgram_cnt_1hr2_121105(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121116_date ON hgram_cnt_1hr2_121116(date); CREATE INDEX hgram_cnt_1hr2_121116_ngramlen ON hgram_cnt_1hr2_121116(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121106_date ON hgram_cnt_1hr2_121106(date); CREATE INDEX hgram_cnt_1hr2_121106_ngramlen ON hgram_cnt_1hr2_121106(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121222_date ON hgram_cnt_1hr2_121222(date); CREATE INDEX hgram_cnt_1hr2_121222_ngramlen ON hgram_cnt_1hr2_121222(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121026_date ON hgram_cnt_1hr2_121026(date); CREATE INDEX hgram_cnt_1hr2_121026_ngramlen ON hgram_cnt_1hr2_121026(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121028_date ON hgram_cnt_1hr2_121028(date); CREATE INDEX hgram_cnt_1hr2_121028_ngramlen ON hgram_cnt_1hr2_121028(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120926_date ON hgram_cnt_1hr2_120926(date); CREATE INDEX hgram_cnt_1hr2_120926_ngramlen ON hgram_cnt_1hr2_120926(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121008_date ON hgram_cnt_1hr2_121008(date); CREATE INDEX hgram_cnt_1hr2_121008_ngramlen ON hgram_cnt_1hr2_121008(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121104_date ON hgram_cnt_1hr2_121104(date); CREATE INDEX hgram_cnt_1hr2_121104_ngramlen ON hgram_cnt_1hr2_121104(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121103_date ON hgram_cnt_1hr2_121103(date); CREATE INDEX hgram_cnt_1hr2_121103_ngramlen ON hgram_cnt_1hr2_121103(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121122_date ON hgram_cnt_1hr2_121122(date); CREATE INDEX hgram_cnt_1hr2_121122_ngramlen ON hgram_cnt_1hr2_121122(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121114_date ON hgram_cnt_1hr2_121114(date); CREATE INDEX hgram_cnt_1hr2_121114_ngramlen ON hgram_cnt_1hr2_121114(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121231_date ON hgram_cnt_1hr2_121231(date); CREATE INDEX hgram_cnt_1hr2_121231_ngramlen ON hgram_cnt_1hr2_121231(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120914_date ON hgram_cnt_1hr2_120914(date); CREATE INDEX hgram_cnt_1hr2_120914_ngramlen ON hgram_cnt_1hr2_120914(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121120_date ON hgram_cnt_1hr2_121120(date); CREATE INDEX hgram_cnt_1hr2_121120_ngramlen ON hgram_cnt_1hr2_121120(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121119_date ON hgram_cnt_1hr2_121119(date); CREATE INDEX hgram_cnt_1hr2_121119_ngramlen ON hgram_cnt_1hr2_121119(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121029_date ON hgram_cnt_1hr2_121029(date); CREATE INDEX hgram_cnt_1hr2_121029_ngramlen ON hgram_cnt_1hr2_121029(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121215_date ON hgram_cnt_1hr2_121215(date); CREATE INDEX hgram_cnt_1hr2_121215_ngramlen ON hgram_cnt_1hr2_121215(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121013_date ON hgram_cnt_1hr2_121013(date); CREATE INDEX hgram_cnt_1hr2_121013_ngramlen ON hgram_cnt_1hr2_121013(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121220_date ON hgram_cnt_1hr2_121220(date); CREATE INDEX hgram_cnt_1hr2_121220_ngramlen ON hgram_cnt_1hr2_121220(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121212_date ON hgram_cnt_1hr2_121212(date); CREATE INDEX hgram_cnt_1hr2_121212_ngramlen ON hgram_cnt_1hr2_121212(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121111_date ON hgram_cnt_1hr2_121111(date); CREATE INDEX hgram_cnt_1hr2_121111_ngramlen ON hgram_cnt_1hr2_121111(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121217_date ON hgram_cnt_1hr2_121217(date); CREATE INDEX hgram_cnt_1hr2_121217_ngramlen ON hgram_cnt_1hr2_121217(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_130101_date ON hgram_cnt_1hr2_130101(date); CREATE INDEX hgram_cnt_1hr2_130101_ngramlen ON hgram_cnt_1hr2_130101(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121226_date ON hgram_cnt_1hr2_121226(date); CREATE INDEX hgram_cnt_1hr2_121226_ngramlen ON hgram_cnt_1hr2_121226(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121127_date ON hgram_cnt_1hr2_121127(date); CREATE INDEX hgram_cnt_1hr2_121127_ngramlen ON hgram_cnt_1hr2_121127(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121128_date ON hgram_cnt_1hr2_121128(date); CREATE INDEX hgram_cnt_1hr2_121128_ngramlen ON hgram_cnt_1hr2_121128(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121124_date ON hgram_cnt_1hr2_121124(date); CREATE INDEX hgram_cnt_1hr2_121124_ngramlen ON hgram_cnt_1hr2_121124(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121229_date ON hgram_cnt_1hr2_121229(date); CREATE INDEX hgram_cnt_1hr2_121229_ngramlen ON hgram_cnt_1hr2_121229(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121020_date ON hgram_cnt_1hr2_121020(date); CREATE INDEX hgram_cnt_1hr2_121020_ngramlen ON hgram_cnt_1hr2_121020(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120913_date ON hgram_cnt_1hr2_120913(date); CREATE INDEX hgram_cnt_1hr2_120913_ngramlen ON hgram_cnt_1hr2_120913(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121121_date ON hgram_cnt_1hr2_121121(date); CREATE INDEX hgram_cnt_1hr2_121121_ngramlen ON hgram_cnt_1hr2_121121(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121007_date ON hgram_cnt_1hr2_121007(date); CREATE INDEX hgram_cnt_1hr2_121007_ngramlen ON hgram_cnt_1hr2_121007(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121010_date ON hgram_cnt_1hr2_121010(date); CREATE INDEX hgram_cnt_1hr2_121010_ngramlen ON hgram_cnt_1hr2_121010(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121203_date ON hgram_cnt_1hr2_121203(date); CREATE INDEX hgram_cnt_1hr2_121203_ngramlen ON hgram_cnt_1hr2_121203(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121207_date ON hgram_cnt_1hr2_121207(date); CREATE INDEX hgram_cnt_1hr2_121207_ngramlen ON hgram_cnt_1hr2_121207(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121218_date ON hgram_cnt_1hr2_121218(date); CREATE INDEX hgram_cnt_1hr2_121218_ngramlen ON hgram_cnt_1hr2_121218(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_130102_date ON hgram_cnt_1hr2_130102(date); CREATE INDEX hgram_cnt_1hr2_130102_ngramlen ON hgram_cnt_1hr2_130102(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121025_date ON hgram_cnt_1hr2_121025(date); CREATE INDEX hgram_cnt_1hr2_121025_ngramlen ON hgram_cnt_1hr2_121025(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120920_date ON hgram_cnt_1hr2_120920(date); CREATE INDEX hgram_cnt_1hr2_120920_ngramlen ON hgram_cnt_1hr2_120920(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120929_date ON hgram_cnt_1hr2_120929(date); CREATE INDEX hgram_cnt_1hr2_120929_ngramlen ON hgram_cnt_1hr2_120929(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121009_date ON hgram_cnt_1hr2_121009(date); CREATE INDEX hgram_cnt_1hr2_121009_ngramlen ON hgram_cnt_1hr2_121009(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121126_date ON hgram_cnt_1hr2_121126(date); CREATE INDEX hgram_cnt_1hr2_121126_ngramlen ON hgram_cnt_1hr2_121126(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121021_date ON hgram_cnt_1hr2_121021(date); CREATE INDEX hgram_cnt_1hr2_121021_ngramlen ON hgram_cnt_1hr2_121021(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121002_date ON hgram_cnt_1hr2_121002(date); CREATE INDEX hgram_cnt_1hr2_121002_ngramlen ON hgram_cnt_1hr2_121002(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121201_date ON hgram_cnt_1hr2_121201(date); CREATE INDEX hgram_cnt_1hr2_121201_ngramlen ON hgram_cnt_1hr2_121201(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120918_date ON hgram_cnt_1hr2_120918(date); CREATE INDEX hgram_cnt_1hr2_120918_ngramlen ON hgram_cnt_1hr2_120918(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120919_date ON hgram_cnt_1hr2_120919(date); CREATE INDEX hgram_cnt_1hr2_120919_ngramlen ON hgram_cnt_1hr2_120919(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120927_date ON hgram_cnt_1hr2_120927(date); CREATE INDEX hgram_cnt_1hr2_120927_ngramlen ON hgram_cnt_1hr2_120927(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121012_date ON hgram_cnt_1hr2_121012(date); CREATE INDEX hgram_cnt_1hr2_121012_ngramlen ON hgram_cnt_1hr2_121012(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120924_date ON hgram_cnt_1hr2_120924(date); CREATE INDEX hgram_cnt_1hr2_120924_ngramlen ON hgram_cnt_1hr2_120924(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120928_date ON hgram_cnt_1hr2_120928(date); CREATE INDEX hgram_cnt_1hr2_120928_ngramlen ON hgram_cnt_1hr2_120928(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121024_date ON hgram_cnt_1hr2_121024(date); CREATE INDEX hgram_cnt_1hr2_121024_ngramlen ON hgram_cnt_1hr2_121024(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121209_date ON hgram_cnt_1hr2_121209(date); CREATE INDEX hgram_cnt_1hr2_121209_ngramlen ON hgram_cnt_1hr2_121209(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121115_date ON hgram_cnt_1hr2_121115(date); CREATE INDEX hgram_cnt_1hr2_121115_ngramlen ON hgram_cnt_1hr2_121115(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121112_date ON hgram_cnt_1hr2_121112(date); CREATE INDEX hgram_cnt_1hr2_121112_ngramlen ON hgram_cnt_1hr2_121112(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121227_date ON hgram_cnt_1hr2_121227(date); CREATE INDEX hgram_cnt_1hr2_121227_ngramlen ON hgram_cnt_1hr2_121227(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121101_date ON hgram_cnt_1hr2_121101(date); CREATE INDEX hgram_cnt_1hr2_121101_ngramlen ON hgram_cnt_1hr2_121101(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121113_date ON hgram_cnt_1hr2_121113(date); CREATE INDEX hgram_cnt_1hr2_121113_ngramlen ON hgram_cnt_1hr2_121113(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121211_date ON hgram_cnt_1hr2_121211(date); CREATE INDEX hgram_cnt_1hr2_121211_ngramlen ON hgram_cnt_1hr2_121211(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121204_date ON hgram_cnt_1hr2_121204(date); CREATE INDEX hgram_cnt_1hr2_121204_ngramlen ON hgram_cnt_1hr2_121204(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120921_date ON hgram_cnt_1hr2_120921(date); CREATE INDEX hgram_cnt_1hr2_120921_ngramlen ON hgram_cnt_1hr2_120921(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121224_date ON hgram_cnt_1hr2_121224(date); CREATE INDEX hgram_cnt_1hr2_121224_ngramlen ON hgram_cnt_1hr2_121224(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121130_date ON hgram_cnt_1hr2_121130(date); CREATE INDEX hgram_cnt_1hr2_121130_ngramlen ON hgram_cnt_1hr2_121130(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121208_date ON hgram_cnt_1hr2_121208(date); CREATE INDEX hgram_cnt_1hr2_121208_ngramlen ON hgram_cnt_1hr2_121208(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120922_date ON hgram_cnt_1hr2_120922(date); CREATE INDEX hgram_cnt_1hr2_120922_ngramlen ON hgram_cnt_1hr2_120922(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121230_date ON hgram_cnt_1hr2_121230(date); CREATE INDEX hgram_cnt_1hr2_121230_ngramlen ON hgram_cnt_1hr2_121230(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121001_date ON hgram_cnt_1hr2_121001(date); CREATE INDEX hgram_cnt_1hr2_121001_ngramlen ON hgram_cnt_1hr2_121001(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121006_date ON hgram_cnt_1hr2_121006(date); CREATE INDEX hgram_cnt_1hr2_121006_ngramlen ON hgram_cnt_1hr2_121006(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121031_date ON hgram_cnt_1hr2_121031(date); CREATE INDEX hgram_cnt_1hr2_121031_ngramlen ON hgram_cnt_1hr2_121031(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121015_date ON hgram_cnt_1hr2_121015(date); CREATE INDEX hgram_cnt_1hr2_121015_ngramlen ON hgram_cnt_1hr2_121015(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121129_date ON hgram_cnt_1hr2_121129(date); CREATE INDEX hgram_cnt_1hr2_121129_ngramlen ON hgram_cnt_1hr2_121129(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121014_date ON hgram_cnt_1hr2_121014(date); CREATE INDEX hgram_cnt_1hr2_121014_ngramlen ON hgram_cnt_1hr2_121014(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121003_date ON hgram_cnt_1hr2_121003(date); CREATE INDEX hgram_cnt_1hr2_121003_ngramlen ON hgram_cnt_1hr2_121003(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121117_date ON hgram_cnt_1hr2_121117(date); CREATE INDEX hgram_cnt_1hr2_121117_ngramlen ON hgram_cnt_1hr2_121117(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121118_date ON hgram_cnt_1hr2_121118(date); CREATE INDEX hgram_cnt_1hr2_121118_ngramlen ON hgram_cnt_1hr2_121118(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121213_date ON hgram_cnt_1hr2_121213(date); CREATE INDEX hgram_cnt_1hr2_121213_ngramlen ON hgram_cnt_1hr2_121213(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121107_date ON hgram_cnt_1hr2_121107(date); CREATE INDEX hgram_cnt_1hr2_121107_ngramlen ON hgram_cnt_1hr2_121107(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121109_date ON hgram_cnt_1hr2_121109(date); CREATE INDEX hgram_cnt_1hr2_121109_ngramlen ON hgram_cnt_1hr2_121109(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121004_date ON hgram_cnt_1hr2_121004(date); CREATE INDEX hgram_cnt_1hr2_121004_ngramlen ON hgram_cnt_1hr2_121004(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121019_date ON hgram_cnt_1hr2_121019(date); CREATE INDEX hgram_cnt_1hr2_121019_ngramlen ON hgram_cnt_1hr2_121019(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121022_date ON hgram_cnt_1hr2_121022(date); CREATE INDEX hgram_cnt_1hr2_121022_ngramlen ON hgram_cnt_1hr2_121022(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121017_date ON hgram_cnt_1hr2_121017(date); CREATE INDEX hgram_cnt_1hr2_121017_ngramlen ON hgram_cnt_1hr2_121017(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121023_date ON hgram_cnt_1hr2_121023(date); CREATE INDEX hgram_cnt_1hr2_121023_ngramlen ON hgram_cnt_1hr2_121023(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121216_date ON hgram_cnt_1hr2_121216(date); CREATE INDEX hgram_cnt_1hr2_121216_ngramlen ON hgram_cnt_1hr2_121216(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121225_date ON hgram_cnt_1hr2_121225(date); CREATE INDEX hgram_cnt_1hr2_121225_ngramlen ON hgram_cnt_1hr2_121225(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121102_date ON hgram_cnt_1hr2_121102(date); CREATE INDEX hgram_cnt_1hr2_121102_ngramlen ON hgram_cnt_1hr2_121102(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121202_date ON hgram_cnt_1hr2_121202(date); CREATE INDEX hgram_cnt_1hr2_121202_ngramlen ON hgram_cnt_1hr2_121202(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121018_date ON hgram_cnt_1hr2_121018(date); CREATE INDEX hgram_cnt_1hr2_121018_ngramlen ON hgram_cnt_1hr2_121018(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121005_date ON hgram_cnt_1hr2_121005(date); CREATE INDEX hgram_cnt_1hr2_121005_ngramlen ON hgram_cnt_1hr2_121005(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121011_date ON hgram_cnt_1hr2_121011(date); CREATE INDEX hgram_cnt_1hr2_121011_ngramlen ON hgram_cnt_1hr2_121011(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120917_date ON hgram_cnt_1hr2_120917(date); CREATE INDEX hgram_cnt_1hr2_120917_ngramlen ON hgram_cnt_1hr2_120917(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121221_date ON hgram_cnt_1hr2_121221(date); CREATE INDEX hgram_cnt_1hr2_121221_ngramlen ON hgram_cnt_1hr2_121221(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121228_date ON hgram_cnt_1hr2_121228(date); CREATE INDEX hgram_cnt_1hr2_121228_ngramlen ON hgram_cnt_1hr2_121228(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_120923_date ON hgram_cnt_1hr2_120923(date); CREATE INDEX hgram_cnt_1hr2_120923_ngramlen ON hgram_cnt_1hr2_120923(ngramlen);"
psql -h hops -U yaboulna -p 5433 -d full -c  "CREATE INDEX hgram_cnt_1hr2_121219_date ON hgram_cnt_1hr2_121219(date); CREATE INDEX hgram_cnt_1hr2_121219_ngramlen ON hgram_cnt_1hr2_121219(ngramlen);"
