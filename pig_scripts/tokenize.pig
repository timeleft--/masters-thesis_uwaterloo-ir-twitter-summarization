REGISTER $udf/yaboulna-udf-0.0.1-SNAPSHOT.jar; 
-- hdfs://yaboulna222:8020/user/younos/
--spritzer_debug.bz
-- spritzer_2012-09-14_2013-01-11.bz
tweets = LOAD CONCAT($dataRoot,'tweets_raw/spritzer_2012-09-14_2013-01-11.bz') USING PigStorage('\t') AS (id:long, screenname:chararray, timestamp:long, tweet:chararray); 
ngramTokenizer = FOREACH tweets GENERATE id, FLATTEN(yaboulna.pig.DateFromSnowflake(id)) as (timeMillis, date), FLATTEN(yaboulna.pig.TweetTokenizer(tweet)) as (ngram, ngramLen, tweetLen,  pos);
-- It's now a flat structure: ngramTokenizer = FOREACH ngramPosBag GENERATE ngram, ngramLen, id, tweetLen, date, timeMillis, FLATTEN(positions) as pos;
STORE ngramTokenizer into CONCAT($dataRoot,'ngrams/ngramTokenizer') USING PigStorage('\t');

