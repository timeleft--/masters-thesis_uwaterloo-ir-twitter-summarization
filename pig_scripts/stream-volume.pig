-- Loads the whole CSV including the header (failing to convert the "id" and "timestamp" strigs to longs)
-- Could do a FILTER, but the cost will be bigger than the "saving" due to records removal
tweets = LOAD 'file:///u2/yaboulnaga/data/twitter-tracked/spritzer_unsorted_csv/[^_]*/[^.]*[^g]' USING PigStorage('\t') AS (id:long, screenname:chararray, timestamp:long, tweet:chararray); --debug XOR spritzer_unsorted_csv
vol5minA = GROUP tweets BY timestamp/300000;
vol5minB = FOREACH vol5minA GENERATE group*300 as epochstart, COUNT(tweets) as volume; --tweets.timestamp
STORE vol5minB INTO 'file:///u2/yaboulnaga/data/twitter-tracked/spritzer_volume-5-min_csv' USING PigStorage('\t');
