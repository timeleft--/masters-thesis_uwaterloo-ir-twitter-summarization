ngramngramizer = LOAD 'ngrams/ngramngramizer' USING PigStorage('\t') as (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);
ngram1 = FILTER ngramngramizer BY ngramLen == 1;
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
  ngram1P10 IF pos=10; --OTHERWISE;
 
ngram1X2S0 = JOIN ngram1P0 BY id, ngram1P1 BY id;
ngram1C2S0 = FOREACH ngram1X2S0 GENERATE (ngram1P0::ngram, ngram1P1::ngram) as ngram, ngram1P0::date as date, ngram1P0::id as id, ngram1P0::pos as pos, ngram1P0::timeMillis as timeMillis, (ngram1P0::ngramLen + ngram1P1::ngramLen) as ngramLen, ngram1P0::tweetLen as tweetLen;
ngram1X2S1 = JOIN ngram1P1 BY id, ngram1P2 BY id;
ngram1C2S1 = FOREACH ngram1X2S1 GENERATE (ngram1P1::ngram, ngram1P2::ngram) as ngram, ngram1P1::date as date, ngram1P1::id as id, ngram1P1::pos as pos, ngram1P1::timeMillis as timeMillis, (ngram1P1::ngramLen + ngram1P2::ngramLen) as ngramLen, ngram1P0::tweetLen as tweetLen;
ngram1X2S2 = JOIN ngram1P2 BY id, ngram1P3 BY id;
ngram1C2S2 = FOREACH ngram1X2S2 GENERATE (ngram1P2::ngram, ngram1P3::ngram) as ngram, ngram1P2::date as date, ngram1P2::id as id, ngram1P2::pos as pos, ngram1P2::timeMillis as timeMillis, (ngram1P2::ngramLen + ngram1P3::ngramLen) as ngramLen, ngram1P0::tweetLen as tweetLen;
ngram1X2S3 = JOIN ngram1P3 BY id, ngram1P4 BY id;
ngram1C2S3 = FOREACH ngram1X2S3 GENERATE (ngram1P3::ngram, ngram1P4::ngram) as ngram, ngram1P3::date as date, ngram1P3::id as id, ngram1P3::pos as pos, ngram1P3::timeMillis as timeMillis, (ngram1P3::ngramLen + ngram1P4::ngramLen) as ngramLen, ngram1P0::tweetLen as tweetLen;
ngram1X2S4 = JOIN ngram1P4 BY id, ngram1P5 BY id;
ngram1C2S4 = FOREACH ngram1X2S4 GENERATE (ngram1P4::ngram, ngram1P5::ngram) as ngram, ngram1P4::date as date, ngram1P4::id as id, ngram1P4::pos as pos, ngram1P4::timeMillis as timeMillis, (ngram1P4::ngramLen + ngram1P5::ngramLen) as ngramLen, ngram1P0::tweetLen as tweetLen;
ngram1X2S5 = JOIN ngram1P5 BY id, ngram1P6 BY id;
ngram1C2S5 = FOREACH ngram1X2S5 GENERATE (ngram1P5::ngram, ngram1P6::ngram) as ngram, ngram1P5::date as date, ngram1P5::id as id, ngram1P5::pos as pos, ngram1P5::timeMillis as timeMillis, (ngram1P5::ngramLen + ngram1P6::ngramLen) as ngramLen, ngram1P0::tweetLen as tweetLen;
ngram1X2S6 = JOIN ngram1P6 BY id, ngram1P7 BY id;
ngram1C2S6 = FOREACH ngram1X2S6 GENERATE (ngram1P6::ngram, ngram1P7::ngram) as ngram, ngram1P6::date as date, ngram1P6::id as id, ngram1P6::pos as pos, ngram1P6::timeMillis as timeMillis, (ngram1P6::ngramLen + ngram1P7::ngramLen) as ngramLen, ngram1P0::tweetLen as tweetLen;
ngram1X2S7 = JOIN ngram1P7 BY id, ngram1P8 BY id;
ngram1C2S7 = FOREACH ngram1X2S7 GENERATE (ngram1P7::ngram, ngram1P8::ngram) as ngram, ngram1P7::date as date, ngram1P7::id as id, ngram1P7::pos as pos, ngram1P7::timeMillis as timeMillis, (ngram1P7::ngramLen + ngram1P8::ngramLen) as ngramLen, ngram1P0::tweetLen as tweetLen;
ngram1X2S8 = JOIN ngram1P8 BY id, ngram1P9 BY id;
ngram1C2S8 = FOREACH ngram1X2S8 GENERATE (ngram1P8::ngram, ngram1P9::ngram) as ngram, ngram1P8::date as date, ngram1P8::id as id, ngram1P8::pos as pos, ngram1P8::timeMillis as timeMillis, (ngram1P8::ngramLen + ngram1P9::ngramLen) as ngramLen, ngram1P0::tweetLen as tweetLen;
ngram1X2S9 = JOIN ngram1P9 BY id, ngram1P10 BY id;
ngram1C2S9 = FOREACH ngram1X2S9 GENERATE (ngram1P9::ngram, ngram1P10::ngram) as ngram, ngram1P9::date as date, ngram1P9::id as id, ngram1P9::pos as pos, ngram1P9::timeMillis as timeMillis, (ngram1P9::ngramLen + ngram1P10::ngramLen) as ngramLen, ngram1P0::tweetLen as tweetLen;

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
  ngram1C2S9;
  
store ngram2 INTO 'ngrams/bigramsOldVer' Using PigStorage('\t');
