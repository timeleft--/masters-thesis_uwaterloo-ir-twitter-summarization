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

ngram2 = UNION ngram1C2S0, ngram1C2S1, ngram1C2S2, ngram1C2S3, ngram1C2S4, ngram1C2S5, ngram1C2S6;

store ngram2 INTO 'ngrams/bigramsS0-6' Using PigStorage('\t');