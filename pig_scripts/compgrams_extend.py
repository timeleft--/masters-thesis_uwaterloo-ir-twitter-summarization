#!/usr/bin/python
import sys

from optparse import OptionParser
parser = OptionParser()
parser.add_option("--root", help="The root of where the data is stored", default="")
parser.add_option("--dry", help="Don't run the script, just print it out", action="store_true")
parser.add_option("--len", help="The length of the compound unigrams being extended (by the unigram after)", type="int")
(args, remainder) = parser.parse_args()

printOnly=args.dry

if not printOnly:
    from org.apache.pig.scripting import Pig
    Pig.set("default_parallel", "50")

rawSchema =  " PigStorage('\\t') as (id: long, timeMillis:long, date:int, ngram:tuple(%(tupleSchema)s), ngramLen:int, tweetLen:int,  pos:int) "
unigramSchema  = rawSchema % { "tupleSchema": "ugram:chararray" }
compgramSchema = rawSchema % { "tupleSchema": "ugram1:chararray,ugram2:chararray"} #TODO dynamic with length

# Load the compound ngrams of length up to len (arg)
scriptStr = """ --- extending ngrams that are positively associated according to YuleQ  
compUgrams = LOAD '%(root)scompgrams/len%(l)s' USING %(funcSchema)s;
""" % {"root": args.root, "funcSchema": compgramSchema, "l": args.len}

# split it by position
split = " SPLIT  compUgrams INTO compUgramsP0 IF pos == 0 "

storeSplits = """ STORE compUgramsP0 INTO '%(root)sbypos/compgrams%(l)s/pos0' USING PigStorage('\\t');
""" % {"root": args.root, "l": args.len}

joinConcat = "-- join ngrams with unigrams then concat to generate longer ngrams"
union = " compBigrams = UNION compBigramsP0 "

maxPos = 70
numIters = maxPos-args.len+1+1 # +1 beause range stops 1 before the last number, +1 because join is for prev iter
for n in range(1,numIters):
    
    #join of previous iteration
    joinConcat += """
        unigramsP%(o)s = LOAD '%(root)sbypos/unigrams/pos%(o)s' %(funcSchema)s;
        bigramsJoinP%(u)s = JOIN compUgramsP%(u)s BY id, unigramsP%(o)s BY id;
        compBigramsP%(u)s = FOREACH bigramsJoinP%(u)s GENERATE 
            bigramsJoinP%(u)s::id as id, 
            bigramsJoinP%(u)s::timeMillis as timeMillis, 
            bigramsJoinP%(u)s::date as date, 
            (FLATTEN(bigramsJoinP%(u)s::ngram), FLATTEN(unigramsP%(o)s::ngram))  as ngram, 
            %(k)s as ngramLen, 
            bigramsJoinP%(u)s::tweetLen as tweetLen, 
            bigramsJoinP%(u)s::pos as pos; 
        """% {"funcSchema": unigramSchema, "o":str((n-1)+args.len), "root": args.root, 
               "u": str(n-1), "k": str(args.len+1)}
        
    if(n<numIters-1):
        split += """,
        compUgramsP%(p)s IF pos==%(p)s"""% {"p":str(n)}
    
        storeSplits += """ STORE compUgramsP%(p)s INTO '%(root)sbypos/compgrams%(l)s/pos%(p)s' USING PigStorage('\\t');
        """ % {"root": args.root, "p": str(n), "l": args.len}
        
        union += """,
        compBigramsP%(p)s"""% {"p":str(n)}
        
        
# The need to account for maxPos-args.len+1 even though pos starts at 0 because
# the loop above created splits which can be extended by 1         
split += ", compUgramsP%(p)s IF pos==%(p)s;" % {"p":str(maxPos-args.len+1)}

storeSplits += """ STORE compUgramsP%(p)s INTO '%(root)sbypos/compgrams%(l)s/pos%(p)s' USING PigStorage('\\t');
    """ % {"root": args.root, "p": str(maxPos-args.len+1), "l": args.len}
    
# joincconcat already well terminated

union +=  ";"

storeBigrams = " STORE compBigrams INTO '%(root)sngrams/comp%(k)s' USING PigStorage('\\t'); "% {"k": str(args.len+1), "root": args.root}
       
scriptStr += """ 
     """ + split + """
     """ + storeSplits + """
     """ + joinConcat + """
     """ + union + """
     """ + storeBigrams + """
     """
     
print(scriptStr)

if printOnly:
    sys.exit()
    
script = Pig.compile(scriptStr)
bound = script.bind()
stat = bound.runSingle()

""" stat methods described in the documentation are all not there.. 
print("Script returned in " + stat.getDuration())

if stat.isSuccessful():
    print("Completed with success, outputs written:\n")
    for location in stat.getOutputLocations():
        print(location + " --> " +getNumberRecords(location) + " records\n")
else:
    print("Failed, with code: " + stat.getReturnCode() + " - Errors:\n ")
    for e in stat.getAllErrorMessages:
        print(e + "\n")
    
"""
    
    