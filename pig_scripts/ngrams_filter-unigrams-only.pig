ngramTokenizer = LOAD 'ngrams/ngramTokenizer' USING PigStorage('\t') as (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);
ngram1 = FILTER ngramTokenizer BY (ngramLen == 1 and pos < tweetLen);
STORE ngram1 INTO 'ngrams/unigrams' USING PigStorage('\t');