set default_parallel 50;
REGISTER $udf/yaboulna*.jar;
ngrams2 = LOAD '$root/ngrams/len2Tokenizer'  USING PigStorage('\t') AS (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);
ngrams2CntMillis = FOREACH ngrams2 GENERATE ngram as ngram, date as date, timeMillis as epochStartMillis, 1 as cnt; 

    ngrams2Prj5minA = FOREACH ngrams2CntMillis GENERATE epochStartMillis/300000L as epochStartMillisA, (ngram, date) as ngramDate, cnt as cnt;
    
    ngrams2Grps5minA = GROUP ngrams2Prj5minA BY (epochStartMillisA, ngramDate);
    
    ngrams2Cnt5min = FOREACH ngrams2Grps5minA GENERATE FLATTEN(group.ngramDate) as (ngram, date), (group.epochStartMillisA * 300000L) as epochStartMillis, (int)SUM($1.cnt) as cnt;
    
    --It's already ordered
    --orderCnts = ORDER ngrams2Cnt5min BY epochStartMillis;
    
    --STORE ngrams2Cnt5min INTO  'cnt_5min/ngrams2' USING PigStorage('\t');
    --STORE ngrams2Cnt5min INTO  'cnt_5min/2' USING yaboulna.pig.NGramsCountStorage();
    
    
    ngrams2Prj1hrA = FOREACH ngrams2Cnt5min GENERATE epochStartMillis/3600000L as epochStartMillisA, (ngram, date) as ngramDate, cnt as cnt;
    
    ngrams2Grps1hrA = GROUP ngrams2Prj1hrA BY (epochStartMillisA, ngramDate);
    
    ngrams2Cnt1hr = FOREACH ngrams2Grps1hrA GENERATE FLATTEN(group.ngramDate) as (ngram, date), (group.epochStartMillisA * 3600000L) as epochStartMillis, (int)SUM($1.cnt) as cnt;
    
    --It's already ordered
    --orderCnts = ORDER ngrams2Cnt1hr BY epochStartMillis;
    
    --STORE ngrams2Cnt1hr INTO  'cnt_1hr/ngrams2' USING PigStorage('\t');
    --STORE ngrams2Cnt1hr INTO  'cnt_1hr/2' USING yaboulna.pig.NGramsCountStorage();
    
    
    ngrams2Prj1dayA = FOREACH ngrams2Cnt1hr GENERATE epochStartMillis/86400000L as epochStartMillisA, (ngram, date) as ngramDate, cnt as cnt;
    
    ngrams2Grps1dayA = GROUP ngrams2Prj1dayA BY (epochStartMillisA, ngramDate);
    
    ngrams2Cnt1day = FOREACH ngrams2Grps1dayA GENERATE FLATTEN(group.ngramDate) as (ngram, date), (group.epochStartMillisA * 86400000L) as epochStartMillis, (int)SUM($1.cnt) as cnt;
    
    --It's already ordered
    --orderCnts = ORDER ngrams2Cnt1day BY epochStartMillis;
    
    --STORE ngrams2Cnt1day INTO  'cnt_1day/ngrams2' USING PigStorage('\t');
    --STORE ngrams2Cnt1day INTO  'cnt_1day/2' USING yaboulna.pig.NGramsCountStorage();
    
---------- finished counting now the calculations ----
--desc2Cnt1day = ORDER ngrams2Cnt1day BY cnt DESC;
epochs2Cnt1hrGrp = GROUP ngrams2Cnt1day by (epochStartMillis, date);
epochs2Cnt1hrSum = FOREACH  epochs2Cnt1hrGrp GENERATE FLATTEN(group) as (epochStartMillis,  date), SUM($1.cnt) as cnt;

ngrams2Flattened1hr = FOREACH ngrams2Cnt1hr GENERATE ngram, FLATTEN(yaboulna.pig.TupleStrToBag(ngram)) as comp, date, epochStartMillis, cnt;

ngrams1Cnts1hr = LOAD '$root/cnt_1hr/ngrams1' USING PigStorage('\t') AS (ngram: chararray, date: int, epochStartMillis: long, cnt: int);
--ngrams1Flattened1hr = FOREACH --- OR Make the UDF return unigrams in brackets
cnt1_2Join = JOIN ngrams1Cnts1hr by (ngram, epochStartMillis), ngrams2Flattened1hr by (comp, epochStartMillis);


prob2g1NoVol = FOREACH cnt1_2Join GENERATE ngrams2Flattened1hr::ngram as ngram2, ngrams1Cnts1hr::ngram as ngram1, ngrams2Flattened1hr::date as date, ngrams2Flattened1hr::epochStartMillis as epochStartMillis,  (1.0 * ngrams2Flattened1hr::cnt / ngrams1Cnts1hr::cnt) as condProb, ngrams1Cnts1hr::cnt as unigramCnt;
prob2g1Vol = JOIN prob2g1NoVol by epochStartMillis, epochs2Cnt1hrSum by epochStartMillis;
prob2g1Unsorted = FOREACH prob2g1Vol GENERATE prob2g1NoVol::ngram2 as ngram2, prob2g1NoVol::ngram1 as ngram1, prob2g1NoVol::date as date, prob2g1NoVol::epochStartMillis as epochStartMillis, prob2g1NoVol::condProb as condProb,  (1.0 * prob2g1NoVol::unigramCnt / epochs2Cnt1hrSum::cnt) as unigramProb, epochs2Cnt1hrSum::cnt as volume;

prob2g1 = ORDER prob2g1Unsorted BY epochStartMillis ASC, unigramProb DESC; 

STORE prob2g1 INTO '$root/prob/ngram2g1' USING PigStorage('\t');

prob2g1Grps = GROUP prob2g1 BY (ngram2, ngram1);
prob2g1Avg = FOREACH prob2g1Grps GENERATE FLATTEN(group) as (ngram2, ngram1), AVG($1.condProb) as avgCondProb; 

STORE prob2g1Avg INTO '$root/prob/ngram2g1Avg' USING PigStorage('\t');

prob2g1Days = GROUP prob2g1 BY (ngram2, ngram1, date);
prob2g1Daily = FOREACH prob2g1Days GENERATE FLATTEN(group) as (ngram2, ngram1, date), AVG($1.condProb) as dailyAvgCondProb;

STORE prob2g1Daily INTO '$root/prob/ngram2g1Daily' USING PigStorage('\t');

-- either proceed by calculating the rest of the contingency table 





 
