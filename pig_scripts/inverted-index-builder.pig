-- Builds an inverted index where each column is the posting list of a term (the name of the column)
-- Rows are timestamps, and a field names TIMESTAMP indicate what time these Tweets were created
-- In each cell we store an array of the last part of the TweetIds in which the column term occurred
-- There are more columns for statistics, such as total term count, average tweet length, tweet count

REGISTER /home/younos/shared/yaboulna-udf-0.0.1-SNAPSHOT.jar; --../pig_udf/target
-- file:///u2/yaboulnaga/data/twitter-tracked/debug/
tweets = LOAD '/user/younos/spritzer_debug/[^_]*/[^.]*[^g]' USING PigStorage('\t') AS (id:long, screenname:chararray, timestamp:long, tweet:chararray); --debug XOR spritzer_unsorted_csv
tokens = FOREACH tweets GENERATE FLATTEN(yaboulna.pig.DecomposeSnowflake(id)) as (unixTime, msIdAtT, year, month, day), FLATTEN(yaboulna.pig.TweetTokenizer(tweet)) as (token, pos);

-- This produces a list of positions for each document, fragmenting the records too much
-- tokenDocGrps = GROUP tokens BY (token, year, month, day, unixTime, msIdAtT);
-- positionBags = FOREACH tokenDocGrps GENERATE FLATTEN(group) as (token, year, month, day, unixTime, msIdAtT), tokens.pos as posBag;

-- This produces a posting list of (timestamp, docIDAtT, position) tuples
tokenTimeGrps = GROUP tokens BY (token, year, month, day); -- less fragmentation, unixTime);
storageResults = FOREACH tokenTimeGrps {
  t =  FOREACH tokens GENERATE unixTime, msIdAtT, pos;
  -- postingBags GENERATE FLATTEN(group) as (token, year, month, day), t; --FLATTEN(t) as (unixTime, msIdAtT, pos);
  GENERATE yaboulna.pig.InsertIntoHivePartition(group, t, '/user/younos/twitter-tracked/debug_inverted-index/'); 
};

-- Telling PIG that we are storing the records makes it get really worried, so we pretent to eval
-- STORE positionBags INTO 'file:///u2/yaboulnaga/data/twitter-tracked/spritzer_times-postings_csv' USING PigStorage('\t');
