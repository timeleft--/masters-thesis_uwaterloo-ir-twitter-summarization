#!/usr/bin/python
import sys

from optparse import OptionParser
parser = OptionParser()
parser.add_option("--root", help="The root of where the data is stored", default="")
parser.add_option("--len", help="The length of ngrams to count", default="_")
parser.add_option("--dry", help="Don't run the script, just print it out", action="store_true")
(args, remainder) = parser.parse_args()

printOnly=args.dry


if not printOnly:
    from org.apache.pig.scripting import *
    Pig.set("default_parallel", "50")


script = """
ngrams%(l)s = LOAD '%(root)sngrams/len%(l)s'  USING PigStorage('\\t') AS (id: long, timeMillis:long, date:chararray, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);
ngrams%(l)sPrj = FOREACH ngrams%(l)s GENERATE ngram, timeMillis, date; -- FOR PARTITIONING
-- ngrams%(l)sAll = GROUP ngrams%(l)sPrj ALL;
-- ngrams%(l)sAllCnt = FOREACH ngrams%(l)sAll GENERATE 'ALL' as ngram, COUNT($1) AS cnt;
ngrams%(l)sGrps = GROUP ngrams%(l)sPrj BY ngram;
ngrams%(l)sCnt = FOREACH ngrams%(l)sGrps GENERATE group AS ngram, COUNT($1) AS cnt;
--STORE (UNION ngrams%(l)sAllCnt,ngrams%(l)sCnt)

ngrams%(l)sPrj5minA = GROUP ngrams%(l)sPrj BY timeMillis/300000;
-- ngrams%(l)sAllCnt5min = FOREACH ngrams%(l)sPrj5minA GENERATE 'ALL' as ngram, FLATTEN($1.date) as date, (group*300000) as epochStartMillis , COUNT($1) as cnt;
---- Doesn't work, because of java.lang.ClassCastException: org.apache.pig.backend.hadoop.executionengine.physicalLayer.relationalOperators.POLimit cannot be cast to org.apache.pig.backend.hadoop.executionengine.physicalLayer.relationalOperators.POStore
---- ngrams%(l)sAllCnt5min = LIMIT ngrams%(l)sAllCnt5min 1;
--ngrams%(l)sAllCnt5min = DISTINCT ngrams%(l)sAllCnt5min;

ngrams%(l)sCnt5min = FOREACH ngrams%(l)sPrj5minA GENERATE $1.ngram as ngram, $1.date as date, (group*300000) as epochStartMillis , COUNT($1) as cnt; 

-- STORE (UNION ngrams%(l)sCnt5min, ngrams%(l)sAllCnt5min) 
""" % {"l":args.len, "root": args.root}

print(script)

if printOnly:
    sys.exit(0)

stat = Pig.compile(script).bind().run()

if stat.isSuccessful():
    print("Completed with success, outputs written:\n")
    for location in stat.getOutputLocations():
        print(location + " --> " +getNumberRecords(location) + " records\n")
else:
    print("Failed, with code: " + stat.getReturnCode() + " - Errors:\n ")
    for e in stat.getAllErrorMessages:
        print(e + "\n")
            
    sys.exit(1);
    
    
