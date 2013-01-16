REGISTER file:///nfs/vmshared/Code/thesis/pig_udf/target/yaboulna-udf-0.0.1-SNAPSHOT.jar; 
-- hdfs://yaboulna222:8020/user/younos/
tweets = LOAD 'tweets_raw/spritzer_debug.bz' USING PigStorage('\t') AS (id:long, screenname:chararray, timestamp:long, tweet:chararray); -- spritzer_2012-09-14_2013-01-11.bz
tokenPosBag = FOREACH tweets GENERATE id, FLATTEN(yaboulna.pig.DateFromSnowflake(id)) as (timeMillis, date), FLATTEN(yaboulna.pig.TweetTokenizer(tweet)) as (token, positions);
ngram1 = FOREACH tokenPosBag GENERATE id, timeMillis, date, token, FLATTEN(positions) as pos, 1 as len;
SPLIT ngram1 INTO 
  ngram1P0 IF pos==0,
  ngram1P1 IF pos==1,
  ngram1P2 IF pos==2,
  ngram1P3 IF pos==3,
  ngram1P4 IF pos==4,
  ngram1P5 IF pos==5,
  ngram1P6 IF pos==6,
  ngram1P7 IF pos==7,
  ngram1P8 IF pos==8,
  ngram1P9 IF pos==9,
  ngram1P10 IF pos==10,
  ngram1P11 IF pos==11,
  ngram1P12 IF pos==12,
  ngram1P13 IF pos==13,
  ngram1P14 IF pos==14,
  ngram1P15 IF pos==15,
  ngram1P16 IF pos==16,
  ngram1P17 IF pos==17,
  ngram1P18 IF pos==18,
  ngram1P19 IF pos==19,
  ngram1P20 IF pos==20,
  ngram1P21 IF pos==21,
  ngram1P22 IF pos==22,
  ngram1P23 IF pos==23,
  ngram1P24 IF pos==24,
  ngram1P25 IF pos==25,
  ngram1P26 IF pos==26,
  ngram1P27 IF pos==27,
  ngram1P28 IF pos==28,
  ngram1P29 IF pos==29,
  ngram1P30 IF pos==30,
  ngram1P31 IF pos==31,
  ngram1P32 IF pos==32,
  ngram1P33 IF pos==33,
  ngram1P34 IF pos==34,
  ngram1P35 IF pos==35,
  ngram1P36 IF pos==36,
  ngram1P37 IF pos==37,
  ngram1P38 IF pos==38,
  ngram1P39 IF pos==39,
  ngram1P40 IF pos==40,
  ngram1P41 IF pos==41,
  ngram1P42 IF pos==42,
  ngram1P43 IF pos==43,
  ngram1P44 IF pos==44,
  ngram1P45 IF pos==45,
  ngram1P46 IF pos==46,
  ngram1P47 IF pos==47,
  ngram1P48 IF pos==48,
  ngram1P49 IF pos==49,
  ngram1P50 IF pos==50,
  ngram1P51 IF pos==51,
  ngram1P52 IF pos==52,
  ngram1P53 IF pos==53,
  ngram1P54 IF pos==54,
  ngram1P55 IF pos==55,
  ngram1P56 IF pos==56,
  ngram1P57 IF pos==57,
  ngram1P58 IF pos==58,
  ngram1P59 IF pos==59,
  ngram1P60 IF pos==60,
  ngram1P61 IF pos==61,
  ngram1P62 IF pos==62,
  ngram1P63 IF pos==63,
  ngram1P64 IF pos==64,
  ngram1P65 IF pos==65,
  ngram1P66 IF pos==66,
  ngram1P67 IF pos==67,
  ngram1P68 IF pos==68,
  ngram1P69 IF pos==69;
ngram1X2S0 = JOIN ngram1P0 BY id, ngram1P1 BY id;
ngram1C2S0 = FOREACH ngram1X2S0 GENERATE CONCAT(CONCAT(ngram1P0::token, 'C'), ngram1P1::token) as token, ngram1P0::date as date, ngram1P0::id as id, ngram1P0::pos as pos, ngram1P0::timeMillis as timeMillis, (ngram1P0::len + ngram1P1::len) as len;
ngram1X2S1 = JOIN ngram1P1 BY id, ngram1P2 BY id;
ngram1C2S1 = FOREACH ngram1X2S1 GENERATE CONCAT(CONCAT(ngram1P1::token, 'C'), ngram1P2::token) as token, ngram1P1::date as date, ngram1P1::id as id, ngram1P1::pos as pos, ngram1P1::timeMillis as timeMillis, (ngram1P1::len + ngram1P2::len) as len;
ngram1X2S2 = JOIN ngram1P2 BY id, ngram1P3 BY id;
ngram1C2S2 = FOREACH ngram1X2S2 GENERATE CONCAT(CONCAT(ngram1P2::token, 'C'), ngram1P3::token) as token, ngram1P2::date as date, ngram1P2::id as id, ngram1P2::pos as pos, ngram1P2::timeMillis as timeMillis, (ngram1P2::len + ngram1P3::len) as len;
ngram1X2S3 = JOIN ngram1P3 BY id, ngram1P4 BY id;
ngram1C2S3 = FOREACH ngram1X2S3 GENERATE CONCAT(CONCAT(ngram1P3::token, 'C'), ngram1P4::token) as token, ngram1P3::date as date, ngram1P3::id as id, ngram1P3::pos as pos, ngram1P3::timeMillis as timeMillis, (ngram1P3::len + ngram1P4::len) as len;
ngram1X2S4 = JOIN ngram1P4 BY id, ngram1P5 BY id;
ngram1C2S4 = FOREACH ngram1X2S4 GENERATE CONCAT(CONCAT(ngram1P4::token, 'C'), ngram1P5::token) as token, ngram1P4::date as date, ngram1P4::id as id, ngram1P4::pos as pos, ngram1P4::timeMillis as timeMillis, (ngram1P4::len + ngram1P5::len) as len;
ngram1X2S5 = JOIN ngram1P5 BY id, ngram1P6 BY id;
ngram1C2S5 = FOREACH ngram1X2S5 GENERATE CONCAT(CONCAT(ngram1P5::token, 'C'), ngram1P6::token) as token, ngram1P5::date as date, ngram1P5::id as id, ngram1P5::pos as pos, ngram1P5::timeMillis as timeMillis, (ngram1P5::len + ngram1P6::len) as len;
ngram1X2S6 = JOIN ngram1P6 BY id, ngram1P7 BY id;
ngram1C2S6 = FOREACH ngram1X2S6 GENERATE CONCAT(CONCAT(ngram1P6::token, 'C'), ngram1P7::token) as token, ngram1P6::date as date, ngram1P6::id as id, ngram1P6::pos as pos, ngram1P6::timeMillis as timeMillis, (ngram1P6::len + ngram1P7::len) as len;
ngram1X2S7 = JOIN ngram1P7 BY id, ngram1P8 BY id;
ngram1C2S7 = FOREACH ngram1X2S7 GENERATE CONCAT(CONCAT(ngram1P7::token, 'C'), ngram1P8::token) as token, ngram1P7::date as date, ngram1P7::id as id, ngram1P7::pos as pos, ngram1P7::timeMillis as timeMillis, (ngram1P7::len + ngram1P8::len) as len;
ngram1X2S8 = JOIN ngram1P8 BY id, ngram1P9 BY id;
ngram1C2S8 = FOREACH ngram1X2S8 GENERATE CONCAT(CONCAT(ngram1P8::token, 'C'), ngram1P9::token) as token, ngram1P8::date as date, ngram1P8::id as id, ngram1P8::pos as pos, ngram1P8::timeMillis as timeMillis, (ngram1P8::len + ngram1P9::len) as len;
ngram1X2S9 = JOIN ngram1P9 BY id, ngram1P10 BY id;
ngram1C2S9 = FOREACH ngram1X2S9 GENERATE CONCAT(CONCAT(ngram1P9::token, 'C'), ngram1P10::token) as token, ngram1P9::date as date, ngram1P9::id as id, ngram1P9::pos as pos, ngram1P9::timeMillis as timeMillis, (ngram1P9::len + ngram1P10::len) as len;
ngram1X2S10 = JOIN ngram1P10 BY id, ngram1P11 BY id;
ngram1C2S10 = FOREACH ngram1X2S10 GENERATE CONCAT(CONCAT(ngram1P10::token, 'C'), ngram1P11::token) as token, ngram1P10::date as date, ngram1P10::id as id, ngram1P10::pos as pos, ngram1P10::timeMillis as timeMillis, (ngram1P10::len + ngram1P11::len) as len;
ngram1X2S11 = JOIN ngram1P11 BY id, ngram1P12 BY id;
ngram1C2S11 = FOREACH ngram1X2S11 GENERATE CONCAT(CONCAT(ngram1P11::token, 'C'), ngram1P12::token) as token, ngram1P11::date as date, ngram1P11::id as id, ngram1P11::pos as pos, ngram1P11::timeMillis as timeMillis, (ngram1P11::len + ngram1P12::len) as len;
ngram1X2S12 = JOIN ngram1P12 BY id, ngram1P13 BY id;
ngram1C2S12 = FOREACH ngram1X2S12 GENERATE CONCAT(CONCAT(ngram1P12::token, 'C'), ngram1P13::token) as token, ngram1P12::date as date, ngram1P12::id as id, ngram1P12::pos as pos, ngram1P12::timeMillis as timeMillis, (ngram1P12::len + ngram1P13::len) as len;
ngram1X2S13 = JOIN ngram1P13 BY id, ngram1P14 BY id;
ngram1C2S13 = FOREACH ngram1X2S13 GENERATE CONCAT(CONCAT(ngram1P13::token, 'C'), ngram1P14::token) as token, ngram1P13::date as date, ngram1P13::id as id, ngram1P13::pos as pos, ngram1P13::timeMillis as timeMillis, (ngram1P13::len + ngram1P14::len) as len;
ngram1X2S14 = JOIN ngram1P14 BY id, ngram1P15 BY id;
ngram1C2S14 = FOREACH ngram1X2S14 GENERATE CONCAT(CONCAT(ngram1P14::token, 'C'), ngram1P15::token) as token, ngram1P14::date as date, ngram1P14::id as id, ngram1P14::pos as pos, ngram1P14::timeMillis as timeMillis, (ngram1P14::len + ngram1P15::len) as len;
ngram1X2S15 = JOIN ngram1P15 BY id, ngram1P16 BY id;
ngram1C2S15 = FOREACH ngram1X2S15 GENERATE CONCAT(CONCAT(ngram1P15::token, 'C'), ngram1P16::token) as token, ngram1P15::date as date, ngram1P15::id as id, ngram1P15::pos as pos, ngram1P15::timeMillis as timeMillis, (ngram1P15::len + ngram1P16::len) as len;
ngram1X2S16 = JOIN ngram1P16 BY id, ngram1P17 BY id;
ngram1C2S16 = FOREACH ngram1X2S16 GENERATE CONCAT(CONCAT(ngram1P16::token, 'C'), ngram1P17::token) as token, ngram1P16::date as date, ngram1P16::id as id, ngram1P16::pos as pos, ngram1P16::timeMillis as timeMillis, (ngram1P16::len + ngram1P17::len) as len;
ngram1X2S17 = JOIN ngram1P17 BY id, ngram1P18 BY id;
ngram1C2S17 = FOREACH ngram1X2S17 GENERATE CONCAT(CONCAT(ngram1P17::token, 'C'), ngram1P18::token) as token, ngram1P17::date as date, ngram1P17::id as id, ngram1P17::pos as pos, ngram1P17::timeMillis as timeMillis, (ngram1P17::len + ngram1P18::len) as len;
ngram1X2S18 = JOIN ngram1P18 BY id, ngram1P19 BY id;
ngram1C2S18 = FOREACH ngram1X2S18 GENERATE CONCAT(CONCAT(ngram1P18::token, 'C'), ngram1P19::token) as token, ngram1P18::date as date, ngram1P18::id as id, ngram1P18::pos as pos, ngram1P18::timeMillis as timeMillis, (ngram1P18::len + ngram1P19::len) as len;
ngram1X2S19 = JOIN ngram1P19 BY id, ngram1P20 BY id;
ngram1C2S19 = FOREACH ngram1X2S19 GENERATE CONCAT(CONCAT(ngram1P19::token, 'C'), ngram1P20::token) as token, ngram1P19::date as date, ngram1P19::id as id, ngram1P19::pos as pos, ngram1P19::timeMillis as timeMillis, (ngram1P19::len + ngram1P20::len) as len;
ngram1X2S20 = JOIN ngram1P20 BY id, ngram1P21 BY id;
ngram1C2S20 = FOREACH ngram1X2S20 GENERATE CONCAT(CONCAT(ngram1P20::token, 'C'), ngram1P21::token) as token, ngram1P20::date as date, ngram1P20::id as id, ngram1P20::pos as pos, ngram1P20::timeMillis as timeMillis, (ngram1P20::len + ngram1P21::len) as len;
ngram1X2S21 = JOIN ngram1P21 BY id, ngram1P22 BY id;
ngram1C2S21 = FOREACH ngram1X2S21 GENERATE CONCAT(CONCAT(ngram1P21::token, 'C'), ngram1P22::token) as token, ngram1P21::date as date, ngram1P21::id as id, ngram1P21::pos as pos, ngram1P21::timeMillis as timeMillis, (ngram1P21::len + ngram1P22::len) as len;
ngram1X2S22 = JOIN ngram1P22 BY id, ngram1P23 BY id;
ngram1C2S22 = FOREACH ngram1X2S22 GENERATE CONCAT(CONCAT(ngram1P22::token, 'C'), ngram1P23::token) as token, ngram1P22::date as date, ngram1P22::id as id, ngram1P22::pos as pos, ngram1P22::timeMillis as timeMillis, (ngram1P22::len + ngram1P23::len) as len;
ngram1X2S23 = JOIN ngram1P23 BY id, ngram1P24 BY id;
ngram1C2S23 = FOREACH ngram1X2S23 GENERATE CONCAT(CONCAT(ngram1P23::token, 'C'), ngram1P24::token) as token, ngram1P23::date as date, ngram1P23::id as id, ngram1P23::pos as pos, ngram1P23::timeMillis as timeMillis, (ngram1P23::len + ngram1P24::len) as len;
ngram1X2S24 = JOIN ngram1P24 BY id, ngram1P25 BY id;
ngram1C2S24 = FOREACH ngram1X2S24 GENERATE CONCAT(CONCAT(ngram1P24::token, 'C'), ngram1P25::token) as token, ngram1P24::date as date, ngram1P24::id as id, ngram1P24::pos as pos, ngram1P24::timeMillis as timeMillis, (ngram1P24::len + ngram1P25::len) as len;
ngram1X2S25 = JOIN ngram1P25 BY id, ngram1P26 BY id;
ngram1C2S25 = FOREACH ngram1X2S25 GENERATE CONCAT(CONCAT(ngram1P25::token, 'C'), ngram1P26::token) as token, ngram1P25::date as date, ngram1P25::id as id, ngram1P25::pos as pos, ngram1P25::timeMillis as timeMillis, (ngram1P25::len + ngram1P26::len) as len;
ngram1X2S26 = JOIN ngram1P26 BY id, ngram1P27 BY id;
ngram1C2S26 = FOREACH ngram1X2S26 GENERATE CONCAT(CONCAT(ngram1P26::token, 'C'), ngram1P27::token) as token, ngram1P26::date as date, ngram1P26::id as id, ngram1P26::pos as pos, ngram1P26::timeMillis as timeMillis, (ngram1P26::len + ngram1P27::len) as len;
ngram1X2S27 = JOIN ngram1P27 BY id, ngram1P28 BY id;
ngram1C2S27 = FOREACH ngram1X2S27 GENERATE CONCAT(CONCAT(ngram1P27::token, 'C'), ngram1P28::token) as token, ngram1P27::date as date, ngram1P27::id as id, ngram1P27::pos as pos, ngram1P27::timeMillis as timeMillis, (ngram1P27::len + ngram1P28::len) as len;
ngram1X2S28 = JOIN ngram1P28 BY id, ngram1P29 BY id;
ngram1C2S28 = FOREACH ngram1X2S28 GENERATE CONCAT(CONCAT(ngram1P28::token, 'C'), ngram1P29::token) as token, ngram1P28::date as date, ngram1P28::id as id, ngram1P28::pos as pos, ngram1P28::timeMillis as timeMillis, (ngram1P28::len + ngram1P29::len) as len;
ngram1X2S29 = JOIN ngram1P29 BY id, ngram1P30 BY id;
ngram1C2S29 = FOREACH ngram1X2S29 GENERATE CONCAT(CONCAT(ngram1P29::token, 'C'), ngram1P30::token) as token, ngram1P29::date as date, ngram1P29::id as id, ngram1P29::pos as pos, ngram1P29::timeMillis as timeMillis, (ngram1P29::len + ngram1P30::len) as len;
ngram1X2S30 = JOIN ngram1P30 BY id, ngram1P31 BY id;
ngram1C2S30 = FOREACH ngram1X2S30 GENERATE CONCAT(CONCAT(ngram1P30::token, 'C'), ngram1P31::token) as token, ngram1P30::date as date, ngram1P30::id as id, ngram1P30::pos as pos, ngram1P30::timeMillis as timeMillis, (ngram1P30::len + ngram1P31::len) as len;
ngram1X2S31 = JOIN ngram1P31 BY id, ngram1P32 BY id;
ngram1C2S31 = FOREACH ngram1X2S31 GENERATE CONCAT(CONCAT(ngram1P31::token, 'C'), ngram1P32::token) as token, ngram1P31::date as date, ngram1P31::id as id, ngram1P31::pos as pos, ngram1P31::timeMillis as timeMillis, (ngram1P31::len + ngram1P32::len) as len;
ngram1X2S32 = JOIN ngram1P32 BY id, ngram1P33 BY id;
ngram1C2S32 = FOREACH ngram1X2S32 GENERATE CONCAT(CONCAT(ngram1P32::token, 'C'), ngram1P33::token) as token, ngram1P32::date as date, ngram1P32::id as id, ngram1P32::pos as pos, ngram1P32::timeMillis as timeMillis, (ngram1P32::len + ngram1P33::len) as len;
ngram1X2S33 = JOIN ngram1P33 BY id, ngram1P34 BY id;
ngram1C2S33 = FOREACH ngram1X2S33 GENERATE CONCAT(CONCAT(ngram1P33::token, 'C'), ngram1P34::token) as token, ngram1P33::date as date, ngram1P33::id as id, ngram1P33::pos as pos, ngram1P33::timeMillis as timeMillis, (ngram1P33::len + ngram1P34::len) as len;
ngram1X2S34 = JOIN ngram1P34 BY id, ngram1P35 BY id;
ngram1C2S34 = FOREACH ngram1X2S34 GENERATE CONCAT(CONCAT(ngram1P34::token, 'C'), ngram1P35::token) as token, ngram1P34::date as date, ngram1P34::id as id, ngram1P34::pos as pos, ngram1P34::timeMillis as timeMillis, (ngram1P34::len + ngram1P35::len) as len;
ngram1X2S35 = JOIN ngram1P35 BY id, ngram1P36 BY id;
ngram1C2S35 = FOREACH ngram1X2S35 GENERATE CONCAT(CONCAT(ngram1P35::token, 'C'), ngram1P36::token) as token, ngram1P35::date as date, ngram1P35::id as id, ngram1P35::pos as pos, ngram1P35::timeMillis as timeMillis, (ngram1P35::len + ngram1P36::len) as len;
ngram1X2S36 = JOIN ngram1P36 BY id, ngram1P37 BY id;
ngram1C2S36 = FOREACH ngram1X2S36 GENERATE CONCAT(CONCAT(ngram1P36::token, 'C'), ngram1P37::token) as token, ngram1P36::date as date, ngram1P36::id as id, ngram1P36::pos as pos, ngram1P36::timeMillis as timeMillis, (ngram1P36::len + ngram1P37::len) as len;
ngram1X2S37 = JOIN ngram1P37 BY id, ngram1P38 BY id;
ngram1C2S37 = FOREACH ngram1X2S37 GENERATE CONCAT(CONCAT(ngram1P37::token, 'C'), ngram1P38::token) as token, ngram1P37::date as date, ngram1P37::id as id, ngram1P37::pos as pos, ngram1P37::timeMillis as timeMillis, (ngram1P37::len + ngram1P38::len) as len;
ngram1X2S38 = JOIN ngram1P38 BY id, ngram1P39 BY id;
ngram1C2S38 = FOREACH ngram1X2S38 GENERATE CONCAT(CONCAT(ngram1P38::token, 'C'), ngram1P39::token) as token, ngram1P38::date as date, ngram1P38::id as id, ngram1P38::pos as pos, ngram1P38::timeMillis as timeMillis, (ngram1P38::len + ngram1P39::len) as len;
ngram1X2S39 = JOIN ngram1P39 BY id, ngram1P40 BY id;
ngram1C2S39 = FOREACH ngram1X2S39 GENERATE CONCAT(CONCAT(ngram1P39::token, 'C'), ngram1P40::token) as token, ngram1P39::date as date, ngram1P39::id as id, ngram1P39::pos as pos, ngram1P39::timeMillis as timeMillis, (ngram1P39::len + ngram1P40::len) as len;
ngram1X2S40 = JOIN ngram1P40 BY id, ngram1P41 BY id;
ngram1C2S40 = FOREACH ngram1X2S40 GENERATE CONCAT(CONCAT(ngram1P40::token, 'C'), ngram1P41::token) as token, ngram1P40::date as date, ngram1P40::id as id, ngram1P40::pos as pos, ngram1P40::timeMillis as timeMillis, (ngram1P40::len + ngram1P41::len) as len;
ngram1X2S41 = JOIN ngram1P41 BY id, ngram1P42 BY id;
ngram1C2S41 = FOREACH ngram1X2S41 GENERATE CONCAT(CONCAT(ngram1P41::token, 'C'), ngram1P42::token) as token, ngram1P41::date as date, ngram1P41::id as id, ngram1P41::pos as pos, ngram1P41::timeMillis as timeMillis, (ngram1P41::len + ngram1P42::len) as len;
ngram1X2S42 = JOIN ngram1P42 BY id, ngram1P43 BY id;
ngram1C2S42 = FOREACH ngram1X2S42 GENERATE CONCAT(CONCAT(ngram1P42::token, 'C'), ngram1P43::token) as token, ngram1P42::date as date, ngram1P42::id as id, ngram1P42::pos as pos, ngram1P42::timeMillis as timeMillis, (ngram1P42::len + ngram1P43::len) as len;
ngram1X2S43 = JOIN ngram1P43 BY id, ngram1P44 BY id;
ngram1C2S43 = FOREACH ngram1X2S43 GENERATE CONCAT(CONCAT(ngram1P43::token, 'C'), ngram1P44::token) as token, ngram1P43::date as date, ngram1P43::id as id, ngram1P43::pos as pos, ngram1P43::timeMillis as timeMillis, (ngram1P43::len + ngram1P44::len) as len;
ngram1X2S44 = JOIN ngram1P44 BY id, ngram1P45 BY id;
ngram1C2S44 = FOREACH ngram1X2S44 GENERATE CONCAT(CONCAT(ngram1P44::token, 'C'), ngram1P45::token) as token, ngram1P44::date as date, ngram1P44::id as id, ngram1P44::pos as pos, ngram1P44::timeMillis as timeMillis, (ngram1P44::len + ngram1P45::len) as len;
ngram1X2S45 = JOIN ngram1P45 BY id, ngram1P46 BY id;
ngram1C2S45 = FOREACH ngram1X2S45 GENERATE CONCAT(CONCAT(ngram1P45::token, 'C'), ngram1P46::token) as token, ngram1P45::date as date, ngram1P45::id as id, ngram1P45::pos as pos, ngram1P45::timeMillis as timeMillis, (ngram1P45::len + ngram1P46::len) as len;
ngram1X2S46 = JOIN ngram1P46 BY id, ngram1P47 BY id;
ngram1C2S46 = FOREACH ngram1X2S46 GENERATE CONCAT(CONCAT(ngram1P46::token, 'C'), ngram1P47::token) as token, ngram1P46::date as date, ngram1P46::id as id, ngram1P46::pos as pos, ngram1P46::timeMillis as timeMillis, (ngram1P46::len + ngram1P47::len) as len;
ngram1X2S47 = JOIN ngram1P47 BY id, ngram1P48 BY id;
ngram1C2S47 = FOREACH ngram1X2S47 GENERATE CONCAT(CONCAT(ngram1P47::token, 'C'), ngram1P48::token) as token, ngram1P47::date as date, ngram1P47::id as id, ngram1P47::pos as pos, ngram1P47::timeMillis as timeMillis, (ngram1P47::len + ngram1P48::len) as len;
ngram1X2S48 = JOIN ngram1P48 BY id, ngram1P49 BY id;
ngram1C2S48 = FOREACH ngram1X2S48 GENERATE CONCAT(CONCAT(ngram1P48::token, 'C'), ngram1P49::token) as token, ngram1P48::date as date, ngram1P48::id as id, ngram1P48::pos as pos, ngram1P48::timeMillis as timeMillis, (ngram1P48::len + ngram1P49::len) as len;
ngram1X2S49 = JOIN ngram1P49 BY id, ngram1P50 BY id;
ngram1C2S49 = FOREACH ngram1X2S49 GENERATE CONCAT(CONCAT(ngram1P49::token, 'C'), ngram1P50::token) as token, ngram1P49::date as date, ngram1P49::id as id, ngram1P49::pos as pos, ngram1P49::timeMillis as timeMillis, (ngram1P49::len + ngram1P50::len) as len;
ngram1X2S50 = JOIN ngram1P50 BY id, ngram1P51 BY id;
ngram1C2S50 = FOREACH ngram1X2S50 GENERATE CONCAT(CONCAT(ngram1P50::token, 'C'), ngram1P51::token) as token, ngram1P50::date as date, ngram1P50::id as id, ngram1P50::pos as pos, ngram1P50::timeMillis as timeMillis, (ngram1P50::len + ngram1P51::len) as len;
ngram1X2S51 = JOIN ngram1P51 BY id, ngram1P52 BY id;
ngram1C2S51 = FOREACH ngram1X2S51 GENERATE CONCAT(CONCAT(ngram1P51::token, 'C'), ngram1P52::token) as token, ngram1P51::date as date, ngram1P51::id as id, ngram1P51::pos as pos, ngram1P51::timeMillis as timeMillis, (ngram1P51::len + ngram1P52::len) as len;
ngram1X2S52 = JOIN ngram1P52 BY id, ngram1P53 BY id;
ngram1C2S52 = FOREACH ngram1X2S52 GENERATE CONCAT(CONCAT(ngram1P52::token, 'C'), ngram1P53::token) as token, ngram1P52::date as date, ngram1P52::id as id, ngram1P52::pos as pos, ngram1P52::timeMillis as timeMillis, (ngram1P52::len + ngram1P53::len) as len;
ngram1X2S53 = JOIN ngram1P53 BY id, ngram1P54 BY id;
ngram1C2S53 = FOREACH ngram1X2S53 GENERATE CONCAT(CONCAT(ngram1P53::token, 'C'), ngram1P54::token) as token, ngram1P53::date as date, ngram1P53::id as id, ngram1P53::pos as pos, ngram1P53::timeMillis as timeMillis, (ngram1P53::len + ngram1P54::len) as len;
ngram1X2S54 = JOIN ngram1P54 BY id, ngram1P55 BY id;
ngram1C2S54 = FOREACH ngram1X2S54 GENERATE CONCAT(CONCAT(ngram1P54::token, 'C'), ngram1P55::token) as token, ngram1P54::date as date, ngram1P54::id as id, ngram1P54::pos as pos, ngram1P54::timeMillis as timeMillis, (ngram1P54::len + ngram1P55::len) as len;
ngram1X2S55 = JOIN ngram1P55 BY id, ngram1P56 BY id;
ngram1C2S55 = FOREACH ngram1X2S55 GENERATE CONCAT(CONCAT(ngram1P55::token, 'C'), ngram1P56::token) as token, ngram1P55::date as date, ngram1P55::id as id, ngram1P55::pos as pos, ngram1P55::timeMillis as timeMillis, (ngram1P55::len + ngram1P56::len) as len;
ngram1X2S56 = JOIN ngram1P56 BY id, ngram1P57 BY id;
ngram1C2S56 = FOREACH ngram1X2S56 GENERATE CONCAT(CONCAT(ngram1P56::token, 'C'), ngram1P57::token) as token, ngram1P56::date as date, ngram1P56::id as id, ngram1P56::pos as pos, ngram1P56::timeMillis as timeMillis, (ngram1P56::len + ngram1P57::len) as len;
ngram1X2S57 = JOIN ngram1P57 BY id, ngram1P58 BY id;
ngram1C2S57 = FOREACH ngram1X2S57 GENERATE CONCAT(CONCAT(ngram1P57::token, 'C'), ngram1P58::token) as token, ngram1P57::date as date, ngram1P57::id as id, ngram1P57::pos as pos, ngram1P57::timeMillis as timeMillis, (ngram1P57::len + ngram1P58::len) as len;
ngram1X2S58 = JOIN ngram1P58 BY id, ngram1P59 BY id;
ngram1C2S58 = FOREACH ngram1X2S58 GENERATE CONCAT(CONCAT(ngram1P58::token, 'C'), ngram1P59::token) as token, ngram1P58::date as date, ngram1P58::id as id, ngram1P58::pos as pos, ngram1P58::timeMillis as timeMillis, (ngram1P58::len + ngram1P59::len) as len;
ngram1X2S59 = JOIN ngram1P59 BY id, ngram1P60 BY id;
ngram1C2S59 = FOREACH ngram1X2S59 GENERATE CONCAT(CONCAT(ngram1P59::token, 'C'), ngram1P60::token) as token, ngram1P59::date as date, ngram1P59::id as id, ngram1P59::pos as pos, ngram1P59::timeMillis as timeMillis, (ngram1P59::len + ngram1P60::len) as len;
ngram1X2S60 = JOIN ngram1P60 BY id, ngram1P61 BY id;
ngram1C2S60 = FOREACH ngram1X2S60 GENERATE CONCAT(CONCAT(ngram1P60::token, 'C'), ngram1P61::token) as token, ngram1P60::date as date, ngram1P60::id as id, ngram1P60::pos as pos, ngram1P60::timeMillis as timeMillis, (ngram1P60::len + ngram1P61::len) as len;
ngram1X2S61 = JOIN ngram1P61 BY id, ngram1P62 BY id;
ngram1C2S61 = FOREACH ngram1X2S61 GENERATE CONCAT(CONCAT(ngram1P61::token, 'C'), ngram1P62::token) as token, ngram1P61::date as date, ngram1P61::id as id, ngram1P61::pos as pos, ngram1P61::timeMillis as timeMillis, (ngram1P61::len + ngram1P62::len) as len;
ngram1X2S62 = JOIN ngram1P62 BY id, ngram1P63 BY id;
ngram1C2S62 = FOREACH ngram1X2S62 GENERATE CONCAT(CONCAT(ngram1P62::token, 'C'), ngram1P63::token) as token, ngram1P62::date as date, ngram1P62::id as id, ngram1P62::pos as pos, ngram1P62::timeMillis as timeMillis, (ngram1P62::len + ngram1P63::len) as len;
ngram1X2S63 = JOIN ngram1P63 BY id, ngram1P64 BY id;
ngram1C2S63 = FOREACH ngram1X2S63 GENERATE CONCAT(CONCAT(ngram1P63::token, 'C'), ngram1P64::token) as token, ngram1P63::date as date, ngram1P63::id as id, ngram1P63::pos as pos, ngram1P63::timeMillis as timeMillis, (ngram1P63::len + ngram1P64::len) as len;
ngram1X2S64 = JOIN ngram1P64 BY id, ngram1P65 BY id;
ngram1C2S64 = FOREACH ngram1X2S64 GENERATE CONCAT(CONCAT(ngram1P64::token, 'C'), ngram1P65::token) as token, ngram1P64::date as date, ngram1P64::id as id, ngram1P64::pos as pos, ngram1P64::timeMillis as timeMillis, (ngram1P64::len + ngram1P65::len) as len;
ngram1X2S65 = JOIN ngram1P65 BY id, ngram1P66 BY id;
ngram1C2S65 = FOREACH ngram1X2S65 GENERATE CONCAT(CONCAT(ngram1P65::token, 'C'), ngram1P66::token) as token, ngram1P65::date as date, ngram1P65::id as id, ngram1P65::pos as pos, ngram1P65::timeMillis as timeMillis, (ngram1P65::len + ngram1P66::len) as len;
ngram1X2S66 = JOIN ngram1P66 BY id, ngram1P67 BY id;
ngram1C2S66 = FOREACH ngram1X2S66 GENERATE CONCAT(CONCAT(ngram1P66::token, 'C'), ngram1P67::token) as token, ngram1P66::date as date, ngram1P66::id as id, ngram1P66::pos as pos, ngram1P66::timeMillis as timeMillis, (ngram1P66::len + ngram1P67::len) as len;
ngram1X2S67 = JOIN ngram1P67 BY id, ngram1P68 BY id;
ngram1C2S67 = FOREACH ngram1X2S67 GENERATE CONCAT(CONCAT(ngram1P67::token, 'C'), ngram1P68::token) as token, ngram1P67::date as date, ngram1P67::id as id, ngram1P67::pos as pos, ngram1P67::timeMillis as timeMillis, (ngram1P67::len + ngram1P68::len) as len;
ngram1X2S68 = JOIN ngram1P68 BY id, ngram1P69 BY id;
ngram1C2S68 = FOREACH ngram1X2S68 GENERATE CONCAT(CONCAT(ngram1P68::token, 'C'), ngram1P69::token) as token, ngram1P68::date as date, ngram1P68::id as id, ngram1P68::pos as pos, ngram1P68::timeMillis as timeMillis, (ngram1P68::len + ngram1P69::len) as len;
ngram2 = UNION 
  ngram1C2S0,
  ngram1C2S1,
  ngram1C2S2,
  ngram1C2S3,
  ngram1C2S4,
  ngram1C2S5,
  ngram1C2S6,
  ngram1C2S7,
  ngram1C2S8,
  ngram1C2S9,
  ngram1C2S10,
  ngram1C2S11,
  ngram1C2S12,
  ngram1C2S13,
  ngram1C2S14,
  ngram1C2S15,
  ngram1C2S16,
  ngram1C2S17,
  ngram1C2S18,
  ngram1C2S19,
  ngram1C2S20,
  ngram1C2S21,
  ngram1C2S22,
  ngram1C2S23,
  ngram1C2S24,
  ngram1C2S25,
  ngram1C2S26,
  ngram1C2S27,
  ngram1C2S28,
  ngram1C2S29,
  ngram1C2S30,
  ngram1C2S31,
  ngram1C2S32,
  ngram1C2S33,
  ngram1C2S34,
  ngram1C2S35,
  ngram1C2S36,
  ngram1C2S37,
  ngram1C2S38,
  ngram1C2S39,
  ngram1C2S40,
  ngram1C2S41,
  ngram1C2S42,
  ngram1C2S43,
  ngram1C2S44,
  ngram1C2S45,
  ngram1C2S46,
  ngram1C2S47,
  ngram1C2S48,
  ngram1C2S49,
  ngram1C2S50,
  ngram1C2S51,
  ngram1C2S52,
  ngram1C2S53,
  ngram1C2S54,
  ngram1C2S55,
  ngram1C2S56,
  ngram1C2S57,
  ngram1C2S58,
  ngram1C2S59,
  ngram1C2S60,
  ngram1C2S61,
  ngram1C2S62,
  ngram1C2S63,
  ngram1C2S64,
  ngram1C2S65,
  ngram1C2S66,
  ngram1C2S67,
  ngram1C2S68;
