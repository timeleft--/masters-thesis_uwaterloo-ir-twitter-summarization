ngramTokenizer = LOAD 'ngrams/ngramTokenizer' USING PigStorage('\t') as (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);
ngram1 = FILTER ngramTokenizer BY ngramLen == 1;
SPLIT ngram1 INTO 
  ngram1P0 IF pos==0,
  ngram1P1 IF pos==1;
  
ngram1X2S0 = JOIN ngram1P0 BY id, ngram1P1 BY id;
ngram1C2S0 = FOREACH ngram1X2S0 GENERATE (ngram1P0::token, ngram1P1::token) as token, ngram1P0::date as date, ngram1P0::id as id, ngram1P0::pos as pos, ngram1P0::timeMillis as timeMillis, (ngram1P0::len + ngram1P1::len) as len;

store ngram1C2S0 INTO 'ngrams/bigramsP0' Using PigStorage('\t');