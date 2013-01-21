ngramTokenizer = LOAD 'ngrams/ngramTokenizer' USING PigStorage('\t') as (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);
ngram1 = FILTER ngramTokenizer BY ngramLen == 1;
SPLIT ngram1 INTO 
  ngram1P0 IF pos==0,
  ngram1P1 IF pos==1,
  ngram1P2 IF pos==2,
  ngram1P3 IF pos==3,
  ngram1P4 IF pos==4,
  ngram1P5 IF pos==5,
  ngram1P6 IF pos==6,
  ngram1P7 IF pos==7;
  
ngram1X2S0 = JOIN ngram1P0 BY id, ngram1P1 BY id;
ngram1C2S0 = FOREACH ngram1X2S0 GENERATE ngram1P0::id, ngram1P0::timeMillis, ngram1P0::date, (ngram1P0::ngram, ngram1P1::ngram)  as ngram, 2 as ngramLen, ngram1P0::tweetLen,  ngram1P0::pos; 

ngram1X2S1 = JOIN ngram1P1 BY id, ngram1P2 BY id;
ngram1C2S1 = FOREACH ngram1X2S1 GENERATE ngram1P1::id, ngram1P1::timeMillis, ngram1P1::date, (ngram1P1::ngram, ngram1P2::ngram)  as ngram, 2 as ngramLen, ngram1P1::tweetLen,  ngram1P1::pos; 

ngram1X2S2 = JOIN ngram1P2 BY id, ngram1P3 BY id;
ngram1C2S2 = FOREACH ngram1X2S2 GENERATE ngram1P2::id, ngram1P2::timeMillis, ngram1P2::date, (ngram1P2::ngram, ngram1P3::ngram)  as ngram, 2 as ngramLen, ngram1P2::tweetLen,  ngram1P2::pos; 

ngram1X2S3 = JOIN ngram1P3 BY id, ngram1P4 BY id;
ngram1C2S3 = FOREACH ngram1X2S3 GENERATE ngram1P3::id, ngram1P3::timeMillis, ngram1P3::date, (ngram1P3::ngram, ngram1P4::ngram)  as ngram, 2 as ngramLen, ngram1P3::tweetLen,  ngram1P3::pos; 

ngram1X2S4 = JOIN ngram1P4 BY id, ngram1P5 BY id;
ngram1C2S4 = FOREACH ngram1X2S4 GENERATE ngram1P4::id, ngram1P4::timeMillis, ngram1P4::date, (ngram1P4::ngram, ngram1P5::ngram)  as ngram, 2 as ngramLen, ngram1P4::tweetLen,  ngram1P4::pos; 

ngram1X2S5 = JOIN ngram1P5 BY id, ngram1P6 BY id;
ngram1C2S5 = FOREACH ngram1X2S5 GENERATE ngram1P5::id, ngram1P5::timeMillis, ngram1P5::date, (ngram1P5::ngram, ngram1P6::ngram)  as ngram, 2 as ngramLen, ngram1P5::tweetLen,  ngram1P5::pos; 

ngram1X2S6 = JOIN ngram1P6 BY id, ngram1P7 BY id;
ngram1C2S6 = FOREACH ngram1X2S6 GENERATE ngram1P6::id, ngram1P6::timeMillis, ngram1P6::date, (ngram1P6::ngram, ngram1P7::ngram)  as ngram, 2 as ngramLen, ngram1P6::tweetLen,  ngram1P6::pos; 

----------------------------------------------

ngram1X2S7 = JOIN ngram1P7 BY id, ngram1P1 BY id;
ngram1C2S7 = FOREACH ngram1X2S7 GENERATE ngram1P7::id, ngram1P7::timeMillis, ngram1P7::date, (ngram1P7::ngram, ngram1P8::ngram)  as ngram, 2 as ngramLen, ngram1P7::tweetLen,  ngram1P7::pos; 

ngram1X2S8 = JOIN ngram1P8 BY id, ngram1P2 BY id;
ngram1C2S8 = FOREACH ngram1X2S8 GENERATE ngram1P8::id, ngram1P8::timeMillis, ngram1P8::date, (ngram1P8::ngram, ngram1P9::ngram)  as ngram, 2 as ngramLen, ngram1P8::tweetLen,  ngram1P8::pos; 

ngram1X2S9 = JOIN ngram1P9 BY id, ngram1P3 BY id;
ngram1C2S9 = FOREACH ngram1X2S9 GENERATE ngram1P9::id, ngram1P9::timeMillis, ngram1P9::date, (ngram1P9::ngram, ngram1P10::ngram)  as ngram, 2 as ngramLen, ngram1P9::tweetLen,  ngram1P9::pos; 

ngram1X2S10 = JOIN ngram1P10 BY id, ngram1P4 BY id;
ngram1C2S10 = FOREACH ngram1X2S10 GENERATE ngram1P10::id, ngram1P10::timeMillis, ngram1P10::date, (ngram1P10::ngram, ngram1P11::ngram)  as ngram, 2 as ngramLen, ngram1P10::tweetLen,  ngram1P10::pos; 

ngram1X2S11 = JOIN ngram1P11 BY id, ngram1P5 BY id;
ngram1C2S11 = FOREACH ngram1X2S11 GENERATE ngram1P11::id, ngram1P11::timeMillis, ngram1P11::date, (ngram1P11::ngram, ngram1P12::ngram)  as ngram, 2 as ngramLen, ngram1P11::tweetLen,  ngram1P11::pos; 

ngram1X2S12 = JOIN ngram1P12 BY id, ngram1P6 BY id;
ngram1C2S12 = FOREACH ngram1X2S12 GENERATE ngram1P12::id, ngram1P12::timeMillis, ngram1P12::date, (ngram1P12::ngram, ngram1P13::ngram)  as ngram, 2 as ngramLen, ngram1P12::tweetLen,  ngram1P12::pos; 

ngram1X2S13 = JOIN ngram1P13 BY id, ngram1P7 BY id;
ngram1C2S13 = FOREACH ngram1X2S13 GENERATE ngram1P13::id, ngram1P13::timeMillis, ngram1P13::date, (ngram1P13::ngram, ngram1P14::ngram)  as ngram, 2 as ngramLen, ngram1P13::tweetLen,  ngram1P13::pos; 


ngram2 = UNION ngram1C2S0, ngram1C2S1, ngram1C2S2, ngram1C2S3, ngram1C2S4, ngram1C2S5, ngram1C2S6,
	ngram1C2S7, ngram1C2S8, ngram1C2S9, ngram1C2S10, ngram1C2S11, ngram1C2S12, ngram1C2S13;

store ngram2 INTO 'ngrams/bigramsS0-13' Using PigStorage('\t');