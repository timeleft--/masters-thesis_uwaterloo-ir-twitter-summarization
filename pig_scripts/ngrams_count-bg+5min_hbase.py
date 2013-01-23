#!/usr/bin/python
import sys

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--root", help="The root of where the data is stored")
parser.add_argument("--dry", help="Don't run the script, just print it out", action="store_true")
args = parser.parse_args()

printOnly=args.dry


if not printOnly:
    from org.apache.pig.scripting import *
    Pig.set("default_parallel", "50")


script = """
ngrams{l} = LOAD '{root}ngrams/len{l}'  USING PigStorage('\\t') AS (id: long, timeMillis:long, date:chararray, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);
ngrams{l}Prj = FOREACH ngrams{l} GENERATE ngram, timeMillis; --, date; FOR PARTITIONING
ngrams{l}All = GROUP ngrams{l}Prj ALL;
--minMaxDate =  FOREACH ngrams{l}All GENERATE MIN($1.date) as minDate, MAX($1.date) as maxDate;
ngrams{l}AllCnt = FOREACH ngrams{l}All GENERATE 'ALL' as ngram, COUNT($1) AS cnt;
ngrams{l}Grps = GROUP ngrams{l}Prj BY ngram;
ngrams{l}Cnts = FOREACH ngrams{l}Grps GENERATE group AS ngram, COUNT($1) AS cnt;
STORE (UNION ngrams{l}Cnts, ngrams{l}AllCnt) INTO 'ngramCnts' USING org.apache.pig.backend.hadoop.hbase.HBaseStorage(
-- CONCAT('c:', CONTACT(minMaxDate.minDate, CONCAT('-', CONCAT(minMaxDate.maxDate)))));
    'c:BG'); -- Back Ground Model
ngrams{l}ALLCnt5min = FOREACH (GROUP ngrams{l}Prj BY timeMillis/300000) GENERATE 'ALL' as ngram, TOMAP(group*300, COUNT($1)); --, $1.date as date (FOR PARTITIONING)
ngrams{l}Cnts5min = FOREACH ngrams{l}Grps {{
    ngram5min = FOREACH (GROUP ngrams{l}Prj BY timeMillis/300000) GENERATE $1.ngram as ngram, TOMAP(group*300, COUNT($1)); --, $1.date as date (FOR PARTITIONING)
    GENERATE ngram5min;
}}
STORE (UNION ngrams{l}Cnts5min, ngrams{l}AllCnt5min) INTO 'ngramCnts' USING org.apache.pig.backend.hadoop.hbase.HBaseStorage(
 'c:*');
""".format(l='_', root=args.root)

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
    
    
