ngramTokenizer = LOAD 'ngrams/ngramTokenizer' USING PigStorage('\t') as (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);
ngram1 = FILTER ngramTokenizer BY ngramLen == 1;
SPLIT ngram1 INTO 
  ngram1P0 IF pos==0,
  ngram1P1 IF pos==1,
  ngram1P2 IF pos==2,
  ngram1P3 IF pos==3;
  
ngram1X2S0 = JOIN ngram1P0 BY id, ngram1P1 BY id;
ngram1C2S0 = FOREACH ngram1X2S0 GENERATE ngram1P0::id, ngram1P0::timeMillis, ngram1P0::date, (ngram1P0::ngram, ngram1P1::ngram)  as ngram, 2 as ngramLen, ngram1P0::tweetLen,  ngram1P0::pos; 

ngram1X2S1 = JOIN ngram1P1 BY id, ngram1P2 BY id;
ngram1C2S1 = FOREACH ngram1X2S1 GENERATE ngram1P1::id, ngram1P1::timeMillis, ngram1P1::date, (ngram1P1::ngram, ngram1P2::ngram)  as ngram, 2 as ngramLen, ngram1P1::tweetLen,  ngram1P1::pos; 

ngram1X2S2 = JOIN ngram1P2 BY id, ngram1P3 BY id;
ngram1C2S3 = FOREACH ngram1X2S2 GENERATE ngram1P2::id, ngram1P2::timeMillis, ngram1P2::date, (ngram1P2::ngram, ngram1P3::ngram)  as ngram, 2 as ngramLen, ngram1P2::tweetLen,  ngram1P2::pos; 

store ngram1C2S0 INTO 'ngrams/bigramsP0' Using PigStorage('\t');