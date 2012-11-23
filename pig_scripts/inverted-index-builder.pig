-- Builds an inverted index where each column is the posting list of a term (the name of the column)
-- Rows are timestamps, and a field names TIMESTAMP indicate what time these Tweets were created
-- In each cell we store an array of the last part of the TweetIds in which the column term occurred
-- There are more columns for statistics, such as total term count, average tweet length, tweet count

REGISTER ../pig_udf/target/yaboulna-udf-0.0.1-SNAPSHOT.jar;
tweets = LOAD 'file:///u2/yaboulnaga/data/twitter-tracked/debug/[^_]*/[^.]*[^g]' USING PigStorage('\t') AS (id:long, screenname:chararray, timestamp:long, tweet:chararray); --debug XOR spritzer_unsorted_csv
tokens = FOREACH tweets GENERATE FLATTEN(yaboulna.pig.DecomposeSnowflake(id)), yaboulna.pig.TweetTokenizer(tweet) as tokenArr;
