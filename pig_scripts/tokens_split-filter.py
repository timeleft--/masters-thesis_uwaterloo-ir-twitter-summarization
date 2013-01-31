#!/usr/bin/python
import sys

from optparse import OptionParser
parser = OptionParser()
parser.add_option("--root", help="The root of where the data is stored", default="")
parser.add_option("--dry", help="Don't run the script, just print it out", action="store_true")
(args, remainder) = parser.parse_args()

printOnly=args.dry

if not printOnly:
	from org.apache.pig.scripting import Pig
	Pig.set("default_parallel", "50")


scriptStr =  """
ngramTokenizer = LOAD '%(root)sngrams/ngramTokenizer' USING PigStorage('\\t') as (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);""" % {"root": args.root}
scriptStr += """
SPLIT ngramTokenizer INTO
	ngrams1 IF (pos < tweetLen) AND ngramLen == 1,
	ngrams2 IF  (pos < tweetLen) AND ngramLen == 2,
	hashtags IF (pos == tweetLen),
	unknown OTHERWISE;
	
ng1db = FOREACH ngrams1 GENERATE ngramLen, id, timeMillis, date, ngram, tweetLen, pos; 
ng2db = FOREACH ngrams2 GENERATE ngramLen, id, timeMillis, date, ngram, tweetLen, pos;
htagdb = FOREACH hashtags GENERATE ngramLen, id, timeMillis, date, ngram, tweetLen, pos;

STORE ng1db INTO '%(root)sdb/ngrams1' %(storeFunc)s;
STORE ng2db INTO '%(root)sdb/ngrams2' %(storeFunc)s;
STORE htagdb INTO '%(root)sdb/htags_powersets' %(storeFunc)s;

STORE unknown INTO '%(root)sdebug/split/unknown';

SPLIT ng1db INTO unigramsPos0 IF pos == 0""" % {"storeFunc": " USING PigStorage('\\t') ", "root": args.root}
store = "STORE unigramsPos0 INTO '%(root)sunigrams/pos0' %(storeFunc)s;" % {"storeFunc": " USING PigStorage('\\t') ", "root": args.root}

for i in range(70):
	scriptStr += """,
		unigramsPos%(p)s IF pos == %(p)s""" % {"p": str(i+1)}
	store += """
	STORE  unigramsPos%(p)s INTO '%(root)sunigrams/pos%(p)s' %(storeFunc)s;""" % {"p": str(i+1),"storeFunc": " USING PigStorage('\\t') ", "root": args.root}
	
scriptStr += """;
 """ + store

print(scriptStr)

if printOnly:
	sys.exit()
	
script = Pig.compile(scriptStr)
bound = script.bind()
stat = bound.runSingle()

print("Script returned in " + stat.getDuration())

if stat.isSuccessful():
	print("Completed with success, outputs written:\n")
	for location in stat.getOutputLocations():
		print(location + " --> " +getNumberRecords(location) + " records\n")
else:
	print("Failed, with code: " + stat.getReturnCode() + " - Errors:\n ")
	for e in stat.getAllErrorMessages:
		print(e + "\n")
	

	