#!/usr/bin/python
import sys
import string
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

posPerIter = 8
for startPos in range(0,64+1,posPerIter):
    dbstorage  = """yaboulna.pig.ByPosStorage('%(dbname)s', 
      'id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int'); 
""" % {"dbname": args.db}
         
    compgramSchema = """ PigStorage('\\t') as 
    (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int); 
    """ # %  {"tupleSchema": "ugram1:chararray,ugram2:chararray"} #TODO dynamic with length

    # Load the compound ngrams of length up to len (arg)
    scriptStr = """ 
REGISTER %(udf)syaboulna-udf-0.0.1-SNAPSHOT.jar;
--- extending ngrams that are positively associated according to YuleQ  
compUgrams = LOAD '%(root)scompgrams/len%(l)s/$day.csv' USING %(funcSchema)s
""" % {"root": args.root, "funcSchema": compgramSchema, "l": args.len, "udf": args.udf}

    # split it by position
    split = " SPLIT  compUgrams INTO compUgramsP%(p)s IF pos == %(p)s " % {"p":startPos}

    storeSplits = ""

    joinConcat = "-- join ngrams with unigrams then concat to generate longer ngrams"
    union = " compBigrams = UNION afterBigramsP%(p)s " % {"p":startPos}

    maxPos = 70
    maxIter = startPos + posPerIter  
    if(maxIter >= maxPos):
        maxIter = maxPos + 1 # +1 beause range stops 1 before the last number
                          
    for n in range(startPos,maxIter):
    
        #join with the unigram coming before (extend to the left)
        if(n<=(maxPos - args.len)):
        #only unigrams at positions less that args.len needs to be loaded
            if(n<startPos+args.len):
                joinConcat += """
            
            unigramsP%(n)s = LOAD 'unigramsP%(n)s' USING %(funcSchema)s
            unigramsP%(n)s = FILTER  unigramsP%(n)s BY date==$day;""" % {"funcSchema": dbstorage, 
                                                                         #"root": args.root,
                                                                         "n":str(n)} 
            
            joinConcat += """
        
        beforeJoinP%(n)s = JOIN compUgramsP%(m)s BY id, unigramsP%(n)s BY id;
        beforeBigramsP%(n)s = FOREACH beforeJoinP%(n)s GENERATE 
            compUgramsP%(m)s::id as id, 
            compUgramsP%(m)s::timeMillis as timeMillis, 
            compUgramsP%(m)s::date as date, 
            TOTUPLE(unigramsP%(n)s::ngram, compUgramsP%(m)s::ngram)  as ngram, 
            %(k)s as ngramLen, 
            compUgramsP%(m)s::tweetLen as tweetLen, 
            compUgramsP%(m)s::pos as pos; 
        """% { "m":str(n+1), # "root": args.root, 
               "n": str(n), "k": str(args.len+1)}    
         
            union += """,
        beforeBigramsP%(n)s"""% {"n":str(n)}
 
    
        # join with the unigram coming after (extend to the right)
        if(n<=maxPos-args.len):
            joinConcat += """
        
        unigramsP%(o)s = LOAD 'unigramsP%(o)s' USING %(funcSchema)s
        unigramsP%(o)s = FILTER  unigramsP%(o)s BY date==$day;
        
        afterJoinP%(n)s = JOIN compUgramsP%(n)s BY id, unigramsP%(o)s BY id;
        afterBigramsP%(n)s = FOREACH afterJoinP%(n)s GENERATE 
            compUgramsP%(n)s::id as id, 
            compUgramsP%(n)s::timeMillis as timeMillis, 
            compUgramsP%(n)s::date as date, 
            TOTUPLE(compUgramsP%(n)s::ngram, unigramsP%(o)s::ngram)  as ngram, 
            %(k)s as ngramLen, 
            compUgramsP%(n)s::tweetLen as tweetLen, 
            compUgramsP%(n)s::pos as pos; 
        """% {"funcSchema": dbstorage, "o":str((n)+args.len), # "root": args.root, 
               "n": str(n), "k": str(args.len+1)}
        
            if(n>startPos):
                union += """,
        afterBigramsP%(n)s"""% {"n":str(n)}
    
        if(n<=maxPos-args.len):
            if(n>startPos):
                split += """,
            compUgramsP%(p)s IF pos==%(p)s"""% {"p":str(n)}
    
            storeSplits += """ 
        STORE compUgramsP%(p)s INTO '%(root)sbypos/compgrams%(l)s/pos%(p)s/$day' USING PigStorage('\\t');
        """ % {"root": args.root, "p": str(n), "l": args.len}
        
       
        
    
        
        
    #
    if(maxIter< maxPos):
        split += ", compUgramsP%(p)s IF pos==%(p)s"% {"p":str(maxIter)};
    
    split += ";"
    storeSplits += ";"
    
    # joincconcat already well terminated

    union +=  ";"

    #storeBigrams = " STORE compBigrams INTO '%(root)sngrams/comp%(k)s/$day' USING PigStorage('\\t'); "% {"k": str(args.len+1), "root": args.root}
    storeBigrams = " STORE compBigrams INTO 'compgrams%(k)s_$day' USING %(funcSchema)s "% {"k": str(args.len+1),
                                                                                           "funcSchema": dbstorage}
       
    scriptStr += """ set debug 'on'
    set mapreduce.jobtracker.staging.root.dir '/home/yaboulna/tmp/mapred_staging'
      
     """ + split + """
    
     """ + joinConcat + """
     """ + union + """
     """ + storeBigrams + """
     """
     #The splits will be small files, which will be problematic later on
     #""" + storeSplits + """ 
     # Done in config file: set mapred.child.java.opts '-Djava.io.tmpdir=/home/yaboulna/tmp'    

    scriptTemplate = string.Template(scriptStr)

    for d in [120913]: #,  120914,  120925,  120926,  121003,  121008,  121010,  121016,  121020,  121026,  121027,  121028,  121029,  121030,  121103,  121104,  121105,  121106,  121108,  121110,  121114,  121116,  121122,  121123,  121125,  121126,  121128,  121205,  121206,  121210,  121212,  121214,  121217,  121222,  121223,  130103,  130104]:
    #[121110, 130103, 121016, 121206, 121210, 120925, 121223, 121205, 130104, 121108, 121214, 121030, 120930, 121123, 121125, 121027, 121105, 121116, 121106, 121222, 121026, 121028, 120926, 121008, 121104, 121103, 121122, 121114, 121231, 120914, 121120, 121119, 121029, 121215, 121013, 121220, 121212, 121111, 121217, 130101, 121226, 121127, 121128, 121124, 121229, 121020, 120913, 121121, 121007, 121010, 121203, 121207, 121218, 130102, 121025, 120920, 120929, 121009, 121126, 121021, 121002, 121201, 120918, 120919, 120927, 121012, 120924, 120928, 121024, 121209, 121115, 121112, 121227, 121101, 121113, 121211, 121204, 120921, 121224, 121130, 121208, 120922, 121230, 121001, 121006, 121031, 121015, 121129, 121014, 121003, 121117, 121118, 121213, 121107, 121109, 121004, 121019, 121022, 121017, 121023, 121216, 121225, 121102, 121202, 121018, 121005, 121011, 120917, 121221, 121228, 120923, 121219]:
        print("++++++++++++++++ Running for the Day %(day)s +++++++++++++++++++++++++++") % {"day":str(d)}
        print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        dayScript = scriptTemplate.substitute(day=str(d))

        print(dayScript)    

        if printOnly:
            continue

        script = Pig.compile(dayScript)
        bound = script.bind()
        #try: Unitil I'm sure it runs fine, then I'll let it roll to another ady if one day has something wrong in it
        stat = bound.runSingle()
    #except:
    #    print("Exception while processing day %(day)s: %(err)s" % {"day": str(d), "err": sys.exc_info()[0]})

    
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
    
    