#!/usr/bin/python
import sys

from optparse import OptionParser
parser = OptionParser()
parser.add_option("--root", help="The root of where the data is stored", default="")
parser.add_option("--udf", help="The path to where UDF jars are stored", default="")
parser.add_option("--db", help="The name of the DB from which ByPos tables are read", default="sample-0.01")
parser.add_option("--dry", help="Don't run the script, just print it out", action="store_true")
parser.add_option("--len", help="The length of the compound unigrams being extended (by the unigram after)", type="int")
(args, remainder) = parser.parse_args()

printOnly=args.dry

if not printOnly:
    from org.apache.pig.scripting import Pig
    Pig.set("default_parallel", "50")

unigramSchema  = """yaboulna.pig.ByPosStorage('%(dbname)s', 
      'id: long, timeMillis:long, date:int, ngram:tuple(ugram:chararray), ngramLen:int, tweetLen:int,  pos:int'); 
""" % {"dbname": args.db}
         
compgramSchema = """ PigStorage('\\t') as 
    (id: long, timeMillis:long, date:int, ngram:tuple(%(tupleSchema)s), ngramLen:int, tweetLen:int,  pos:int); 
    """ %  {"tupleSchema": "ugram1:chararray,ugram2:chararray"} #TODO dynamic with length

# Load the compound ngrams of length up to len (arg)
scriptStr = """ 
REGISTER %(udf)syaboulna-udf-0.0.1-SNAPSHOT.jar;
--- extending ngrams that are positively associated according to YuleQ  
compUgrams = LOAD '%(root)scompgrams/len%(l)s/$day.csv' USING %(funcSchema)s
""" % {"root": args.root, "funcSchema": compgramSchema, "l": args.len, "udf": args.udf}

# split it by position
split = " SPLIT  compUgrams INTO compUgramsP0 IF pos == 0 "

storeSplits = """ STORE compUgramsP0 INTO '%(root)sbypos/compgrams%(l)s/pos0/$day' USING PigStorage('\\t');
""" % {"root": args.root, "l": args.len}

joinConcat = "-- join ngrams with unigrams then concat to generate longer ngrams"
union = " compBigrams = UNION compBigramsP0 "

maxPos = 70
numIters = maxPos-args.len+1+1 # +1 beause range stops 1 before the last number, +1 because join is for prev iter
for n in range(1,numIters):
    
    #join of previous iteration
    joinConcat += """
        unigramsP%(o)s = LOAD 'unigramsP%(o)s' USING %(funcSchema)s
        unigramsP%(o)s = FILTER  unigramsP%(o)s BY date==$day;
        bigramsJoinP%(u)s = JOIN compUgramsP%(u)s BY id, unigramsP%(o)s BY id;
        compBigramsP%(u)s = FOREACH bigramsJoinP%(u)s GENERATE 
            bigramsJoinP%(u)s::id as id, 
            bigramsJoinP%(u)s::timeMillis as timeMillis, 
            bigramsJoinP%(u)s::date as date, 
            TOTUPLE(flatten(bigramsJoinP%(u)s::ngram), flatten(unigramsP%(o)s::ngram))  as ngram, 
            %(k)s as ngramLen, 
            bigramsJoinP%(u)s::tweetLen as tweetLen, 
            bigramsJoinP%(u)s::pos as pos; 
        """% {"funcSchema": unigramSchema, "o":str((n-1)+args.len), "root": args.root, 
               "u": str(n-1), "k": str(args.len+1)}
        
    if(n<numIters-1):
        split += """,
        compUgramsP%(p)s IF pos==%(p)s"""% {"p":str(n)}
    
        storeSplits += """ STORE compUgramsP%(p)s INTO '%(root)sbypos/compgrams%(l)s/pos%(p)s/$day' USING PigStorage('\\t');
        """ % {"root": args.root, "p": str(n), "l": args.len}
        
        union += """,
        compBigramsP%(p)s"""% {"p":str(n)}
        
        
# The need to account for maxPos-args.len+1 even though pos starts at 0 because
# the loop above created splits which can be extended by 1         
split += ", compUgramsP%(p)s IF pos==%(p)s;" % {"p":str(maxPos-args.len+1)}

storeSplits += """ STORE compUgramsP%(p)s INTO '%(root)sbypos/compgrams%(l)s/pos%(p)s/$day' USING PigStorage('\\t');
    """ % {"root": args.root, "p": str(maxPos-args.len+1), "l": args.len}
    
# joincconcat already well terminated

union +=  ";"

storeBigrams = " STORE compBigrams INTO '%(root)sngrams/comp%(k)s/$day' USING PigStorage('\\t'); "% {"k": str(args.len+1), "root": args.root}
       
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

params = []
for d in [121110, 130103]: #, 121016, 121206, 121210, 120925, 121223, 121205, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116, 121106, 121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219]:
    params.append({"day":str(d)})

print("params: " + str(params))
    
bound = script.bind(params)
stat = bound.run()

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
    
    