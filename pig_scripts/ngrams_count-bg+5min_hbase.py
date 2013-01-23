#!/usr/bin/python
import sys

from optparse import OptionParser
parser = OptionParser()
parser.add_option("--root", help="The root of where the data is stored", default="")
parser.add_option("--dry", help="Don't run the script, just print it out", action="store_true")
(args, remainder) = parser.parse_args()

printOnly=args.dry


if not printOnly:
    from org.apache.pig.scripting import *
    Pig.set("default_parallel", "50")


script = """
ngrams%(l)s = LOAD '%(root)sngrams/len%(l)s'  USING PigStorage('\\t') AS (id: long, timeMillis:long, date:chararray, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);
ngrams%(l)sPrj = FOREACH ngrams%(l)s GENERATE ngram, timeMillis; --, date; FOR PARTITIONING
ngrams%(l)sAll = GROUP ngrams%(l)sPrj ALL;
--minMaxDate =  FOREACH ngrams%(l)sAll GENERATE MIN($1.date) as minDate, MAX($1.date) as maxDate;
ngrams%(l)sAllCnt = FOREACH ngrams%(l)sAll GENERATE 'ALL' as ngram, COUNT($1) AS cnt;
ngrams%(l)sGrps = GROUP ngrams%(l)sPrj BY ngram;
ngrams%(l)sCnts = FOREACH ngrams%(l)sGrps GENERATE group AS ngram, COUNT($1) AS cnt;
STORE (UNION ngrams%(l)sCnts, ngrams%(l)sAllCnt) INTO 'ngramCnts' USING org.apache.pig.backend.hadoop.hbase.HBaseStorage(
-- CONCAT('c:', CONTACT(minMaxDate.minDate, CONCAT('-', CONCAT(minMaxDate.maxDate)))));
    'c:BG'); -- Back Ground Model
ngrams%(l)sALLCnt5min = FOREACH (GROUP ngrams%(l)sPrj BY timeMillis/300000) GENERATE 'ALL' as ngram, TOMAP(group*300, COUNT($1)); --, $1.date as date (FOR PARTITIONING)
ngrams%(l)sCnts5min = FOREACH ngrams%(l)sGrps {
    ngram5min = FOREACH (GROUP ngrams%(l)sPrj BY timeMillis/300000) GENERATE $1.ngram as ngram, TOMAP(group*300, COUNT($1)); --, $1.date as date (FOR PARTITIONING)
    GENERATE ngram5min;
}
STORE (UNION ngrams%(l)sCnts5min, ngrams%(l)sAllCnt5min) INTO 'ngramCnts' USING org.apache.pig.backend.hadoop.hbase.HBaseStorage(
 'c:*');
""" % {"l":"_", "root": args.root}

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
    
    
