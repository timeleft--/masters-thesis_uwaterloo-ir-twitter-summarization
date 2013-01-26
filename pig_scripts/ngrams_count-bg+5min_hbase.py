#!/usr/bin/python
import sys

from optparse import OptionParser
parser = OptionParser()
parser.add_option("--udf", help="The path to where UDF jars are stored", default="")
parser.add_option("--root", help="The root of where the data is stored", default="")
parser.add_option("--storeParams", help="Parameters to pass to the DB store function", default="")
parser.add_option("--len", help="The length of ngrams to count", default="_")
parser.add_option("--dry", help="Don't run the script, just print it out", action="store_true")
(args, remainder) = parser.parse_args()

printOnly=args.dry


if not printOnly:
    from org.apache.pig.scripting import Pig
    Pig.set("default_parallel", "50")


script = """
REGISTER %(udf)syaboulna-udf-0.0.1-SNAPSHOT.jar;
ngrams%(l)s = LOAD '%(root)sngrams/len%(l)s'  USING PigStorage('\\t') AS (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);
ngrams%(l)sCntMillis = FOREACH ngrams%(l)s GENERATE ngram as ngram, date as date, timeMillis as epochStartMillis, 1 as cnt; 
""" % {"l":args.len, "root": args.root, "udf": args.udf}

prevCntsName = "ngrams%(l)sCntMillis" % {"l": args.len}
intervalName = {'300000L':'5min', '12L':'1hr', '24L':'1day', '7L':'1week', '30L':'1month'}
intervalAcc = 1
for interval in ['300000L', '12L', '24L', '7L', '30L']:
    
    intervalAcc *= long(interval)
    
    replaceMap = {"l":args.len, "root": args.root, "name": intervalName[interval], "epoch":intervalAcc, "prevCnts": prevCntsName, "storeParams": args.storeParams}
    
    script += """
    ngrams%(l)sPrj%(name)sA = FOREACH %(prevCnts)s GENERATE epochStartMillis/%(epoch)sL as epochStartMillisA, (ngram, date) as ngramDate, cnt as cnt;
    
    ngrams%(l)sGrps%(name)sA = GROUP ngrams%(l)sPrj%(name)sA BY (epochStartMillisA, ngramDate);
    
    ngrams%(l)sCnt%(name)s = FOREACH ngrams%(l)sGrps%(name)sA GENERATE FLATTEN(group.ngramDate) as (ngram, date), (group.epochStartMillisA * %(epoch)sL) as epochStartMillis, (int)SUM($1.cnt) as cnt;
    
    --It's already ordered
    --orderCnts = ORDER ngrams%(l)sCnt%(name)s BY epochStartMillis;
    
    --STORE ngrams%(l)sCnt%(name)s INTO  '%(root)scnt_%(name)s/ngrams%(l)s' USING PigStorage('\\t');
    STORE ngrams%(l)sCnt%(name)s INTO  'cnt_%(name)s/%(l)s' USING yaboulna.pig.NGramsCountStorage(%(storeParams)s);
    
    """ % replaceMap;
    
    prevCntsName = "ngrams%(l)sCnt%(name)s"% {"l":args.len, "name": intervalName[interval]}

"""    
    --TODONOT Store totals (in the same table for simplicity, hoping that namespaces will work well) 
    all%(l)sCnt%(name)sGrp = GROUP ngrams%(l)sCnt%(name)s ALL;
    all%(l)sCnt%(name)s = FOREACH all%(l)sCnt%(name)sGrp GENERATE 'ALL' as ngram, (int)MAX($1.date) as date, MAX($1.epochStartMillis) as epochStartMillis, (int)SUM($1.cnt) as cnt;

    --STORE all%(l)sCnt%(name)s INTO  '%(root)scnt_%(name)s/ngrams%(l)sTotal' USING PigStorage('\\t');
    STORE  all%(l)sCnt%(name)s INTO  'cnt_%(name)s/-%(l)s' USING yaboulna.pig.NGramsCountStorage(%(storeParams)s);
    """
#script += ABOVE % replaceMap;

print(script)

if printOnly:
    sys.exit(0)

stat = Pig.compile(script).bind().runSingle()
        

    
    
