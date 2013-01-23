#!/usr/bin/python
import sys
#from org.apache.pig.scripting import *
#Pig.set("default_parallel", "50")

sample = "" #"sample-0.01/"
printOnly=True

scriptStr = """
ngramTokenizer = LOAD 'ngrams/ngramTokenizer' USING PigStorage('\\t') as (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int);"""
if sample:
	scriptStr += """
	ngramTokenizer = SAMPLE ngramTokenizer 0.01; """
scriptStr += """
SPLIT ngramTokenizer INTO
	ngrams1 IF (pos < tweetLen) AND ngramLen == 1,
	ngrams2 IF  (pos < tweetLen) AND ngramLen == 2,
	hashtags IF (pos == tweetLen),
	unknown OTHERWISE;
STORE ngrams1 INTO '{root}ngrams/len1' {storeFunc};
STORE ngrams2 INTO '{root}ngrams/len2Tokenizer' {storeFunc};
STORE hashtags INTO '{root}hashtags/powersets' {storeFunc};
SPLIT ngrams1 INTO unigramsPos0 IF pos == 0""".format(storeFunc= " USING PigStorage('\\t') ", root=sample)
store = "STORE unigramsPos0 INTO '{root}unigrams/pos0' {storeFunc};".format(storeFunc= " USING PigStorage('\\t') ", root=sample)

for i in range(70):
	scriptStr += """,
		unigramsPos{p} IF pos == {p}""".format(p=str(i+1))
	store += """
	STORE  unigramsPos{p} INTO '{root}unigrams/pos{p}' {storeFunc};""".format(p=str(i+1),storeFunc= " USING PigStorage('\\t') ", root=sample)
	
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
	

	