#!/usr/bin/python
import sys
import string
from optparse import OptionParser
parser = OptionParser()
parser.add_option("--root", help="The root of where the data is stored", default="")
parser.add_option("--dry", help="Don't run the script, just print it out", action="store_true")
(args, remainder) = parser.parse_args()

printOnly=args.dry

if not printOnly:
	from org.apache.pig.scripting import Pig
	Pig.set("default_parallel", "50")


scriptStr =  Formatter.format("""
ngramTokenizer = LOAD '{root}ngrams/ngramTokenizer' USING PigStorage('\\t') as (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);""",root=args.root)
scriptStr += """
SPLIT ngramTokenizer INTO
	ngrams1 IF (pos < tweetLen) AND ngramLen == 1,
	ngrams2 IF  (pos < tweetLen) AND ngramLen == 2,
	hashtags IF (pos == tweetLen),
	unknown OTHERWISE;
STORE ngrams1 INTO '{root}ngrams/len1' {storeFunc};
STORE ngrams2 INTO '{root}ngrams/len2Tokenizer' {storeFunc};
STORE hashtags INTO '{root}hashtags/powersets' {storeFunc};
SPLIT ngrams1 INTO unigramsPos0 IF pos == 0""".format(storeFunc= " USING PigStorage('\\t') ", root=args.root)
store = "STORE unigramsPos0 INTO '{root}unigrams/pos0' {storeFunc};".format(storeFunc= " USING PigStorage('\\t') ", root=args.root)

for i in range(70):
	scriptStr += """,
		unigramsPos{p} IF pos == {p}""".format(p=str(i+1))
	store += """
	STORE  unigramsPos{p} INTO '{root}unigrams/pos{p}' {storeFunc};""".format(p=str(i+1),storeFunc= " USING PigStorage('\\t') ", root=args.root)
	
scriptStr += """;
 """ + store

print(scriptStr)

if printOnly:
	sys.exit()
	
script = Pig.compile(scriptStr)
bound = script.bind()
stat = bound.run()

print("Script returned in " + stat.getDuration())

if stat.isSuccessful():
	print("Completed with success, outputs written:\n")
	for location in stat.getOutputLocations():
		print(location + " --> " +getNumberRecords(location) + " records\n")
else:
	print("Failed, with code: " + stat.getReturnCode() + " - Errors:\n ")
	for e in stat.getAllErrorMessages:
		print(e + "\n")
	

	