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
ngrams%(l)s = LOAD '%(root)sngrams/len%(l)s'  USING PigStorage('\\t') AS (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);
ngrams%(l)sPrj = FOREACH ngrams%(l)s GENERATE timeMillis, (ngram, date); -- FOR PARTITIONING

ngrams%(l)sPrj5minA = GROUP ngrams%(l)sPrj BY timeMillis/300000L;

ngrams%(l)sCnt5minB = FOREACH ngrams%(l)sPrj5minA GENERATE FLATTEN($1.$1) as (ngram_date:(ngram:chararray, date:int)), (group*300000L) as epochStartMillis , COUNT($1) as cnt; 
ngrams%(l)sCnt5min = FOREACH ngrams%(l)sCnt5minB GENERATE FLATTEN($0) as (ngram:chararray, date:int), epochStartMillis, cnt;
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
    
    
