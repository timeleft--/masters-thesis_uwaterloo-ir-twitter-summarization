-- Builds an inverted index stored in HBase where each row is the posting list of a term (the row key)
-- Column keys are dates for individual days, partitioning data into several buckets.
-- The value is a byte array, where each byte is the position of an occurrence. 
-- The version a.k.a. TIMESTAMP stores the Tweet Id of the occurrence. 
-- The HBase table must have unlimited versions, the maximum is (2147483647 = 2^31 - 1 = Int Max). 
-- Note that -1 doesn't work regardless of (https://issues.apache.org/jira/browse/HBASE-379).
-- For Example: 
-- create 'tokenPos', {NAME => 'd', VERSIONS => 2147483647, SPLITS => ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'z'], DEFERRED_LOG_FLUSH => true} 
-- Performance should improve by creating splits explicitly (and don't forget to apply configs)
-- SPLITS => ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', ... etc etc] BUT.. how will I know how to split evenly 
-- No need to mess up with TTL, it's disabled by default (right?) {TTL => -1}
-- If the data turns out to be too much, consider using {COMPRESSION => 'SNAPPY'}. However this will
-- definitely attain a performance penalty (notice that this is not an archival database)  

-- set debug 'on'

REGISTER file:///nfs/vmshared/Code/thesis/pig_udf/target/yaboulna-udf-0.0.1-SNAPSHOT.jar; --../pig_udf/target
-- file:///u2/yaboulnaga/data/twitter-tracked/debug/
-- hdfs://precise-01:8020/user/younos/spritzer_debug/
-- file:///home/younos/spritzer_unsorted_csv
-- hdfs://precise-01:8020/user/younos/spritzer_121211/ 
tweets = LOAD 'hdfs://yaboulna222:8020/user/younos/tweets_raw/spritzer_2012-09-14_2013-01-11.bz' USING yaboulna.pig.PigStorage('\t') AS (id:long, screenname:chararray, timestamp:long, tweet:chararray); --debug XOR spritzer_unsorted_csv
tokenPosTuples = FOREACH tweets GENERATE id, FLATTEN(yaboulna.pig.DateFromSnowflake(id)) as (timeMillis, date), FLATTEN(yaboulna.pig.TweetTokenizer(tweet)) as (token, positions);
-- We don't need to write versions in order, as per: http://hbase.apache.org/book/versions.html#ftn.d352e3269
-- tokenPosOrdered = ORDER tokenPosTuples BY id; -- This assures that the versions will be input in ascending order 
tokenPosToStore = FOREACH tokenPosTuples GENERATE TOTUPLE(token, date, positions) as t, id; --Ordered

storageResults = STORE tokenPosToStore INTO 'hbase://tokenPos' USING yaboulna.pig.HBaseStorage('d:#', '-noWal');

