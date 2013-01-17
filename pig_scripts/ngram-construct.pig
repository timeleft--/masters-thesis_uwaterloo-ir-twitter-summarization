REGISTER file:///home/yaboulna/vmshared/Code/thesis/pig_udf/target/yaboulna-udf-0.0.1-SNAPSHOT.jar; 
-- hdfs://yaboulna222:8020/user/younos/
--spritzer_debug.bz
-- spritzer_2012-09-14_2013-01-11.bz
tweets = LOAD 'tweets_raw/split-300M/spritzer_2012-09-14_2013-01-11_csv/[^_.]*' USING PigStorage('\t') AS (id:long, screenname:chararray, timestamp:long, tweet:chararray); 
ngramPosBag = FOREACH tweets GENERATE id, FLATTEN(yaboulna.pig.DateFromSnowflake(id)) as (timeMillis, date), FLATTEN(yaboulna.pig.TweetTokenizer(tweet)) as (ngram, ngramLen, tweetLen,  positions);
ngramTokenizer = FOREACH ngramPosBag GENERATE ngram, ngramLen, id, tweetLen, date, timeMillis, FLATTEN(positions) as pos;
STORE ngramTokenizer into 'ngrams/ngramTokenizer' USING PigStorage('\t');

