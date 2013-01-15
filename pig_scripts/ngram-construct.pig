REGISTER file:///nfs/vmshared/Code/thesis/pig_udf/target/yaboulna-udf-0.0.1-SNAPSHOT.jar; 
-- hdfs://yaboulna222:8020/user/younos/
tweets = LOAD 'tweets_raw/spritzer_debug.bz' USING PigStorage('\t') AS (id:long, screenname:chararray, timestamp:long, tweet:chararray); -- spritzer_2012-09-14_2013-01-11.bz
tokenPosBag = FOREACH tweets GENERATE id, FLATTEN(yaboulna.pig.DateFromSnowflake(id)) as (timeMillis, date), FLATTEN(yaboulna.pig.TweetTokenizer(tweet)) as (token, postions);
ngram1 = FOREACH tokenPosBag GENERATE id, timeMillis, date, token, FLATTEN(positions) as pos, 1 as len;
