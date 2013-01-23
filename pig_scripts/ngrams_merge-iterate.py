#!/usr/bin/python
import sys

from optparse import OptionParser
parser = OptionParser()
parser.add_option("--root", help="The root of where the data is stored", default="")
parser.add_option("--maxLength", help="The maximum length of ngrams. CAUTION! This should be set to the maximum Tweet length", type="int", default=71)
parser.add_option("--dry", help="Don't run the script, just print it out", action="store_true")
(args, remainder) = parser.parse_args()

printOnly=args.dry


if not printOnly:
    from org.apache.pig.scripting import *
    Pig.set("default_parallel", "50")


maxLength = args.maxLength #140 characters limit -> at most 71 tokens, of length 1 each

params = { "ngramsPrevPath": "ngrams/len1" }
  
for i in range(maxLength-1):
    funcSchema = " USING PigStorage('\\t') AS (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int) "
    
    ngramsLoad = " ngramsLen%(l)s = LOAD '%(root)s$ngramsPrevPath' %(funcSchema)s;"% {"funcSchema": funcSchema, "l": str(i+1), "root": args.root}
    
    #unigramsLoad = " unigramsPos0 = LOAD '%(root)sunigrams/pos0' %(funcSchema)s;"% {"funcSchema": funcSchema, "root": args.root}
    unigramsLoad = " "
    
    split = " SPLIT ngramsLen%(l)s INTO ngramsLen%(l)sPos0 IF pos==0 "% {"l": str(i+1)}
    
    #join[:70-i] = " ngramsLen%(l)sJoinPos"% {"l": str(i+1)}
    #contact[:70-i] = " ngramsLen%(k)sPos"% {"k": str(i+2)}
    joinConcat = "-- join ngrams with unigrams then concat to generate longer ngrams"
    
    if i <maxLength-2:
        union = " ngramsLen%(k)s = UNION ngramsLen%(k)sPos0 "% {"k": str(i+2)}
    else: 
        union = " ngramsLen%(k)s = ngramsLen%(k)sPos0 "% {"k": str(i+2)}
    
    for x in range(1,maxLength-i):
        unigramsLoad += """
         unigramsPos%(o)s = LOAD '%(root)sunigrams/pos%(o)s' %(funcSchema)s;"""% {"funcSchema": funcSchema, "o":str(70-x), "root": args.root}
        split += """,
             ngramsLen%(l)sPos%(p)s IF pos==%(p)s"""% {"p":str(x), "l": str(i+1)}
        joinConcat += """
        ngramsLen%(l)sJoinPos%(u)s = JOIN ngramsLen%(l)sPos%(u)s BY id, unigramsPos%(a)s BY id;
        ngramsLen%(k)sPos%(u)s = FOREACH ngramsLen%(l)sJoinPos%(u)s GENERATE 
            ngramsLen%(l)sPos%(u)s::id as id, 
            ngramsLen%(l)sPos%(u)s::timeMillis as timeMillis, 
            ngramsLen%(l)sPos%(u)s::date as date, 
            (FLATTEN(ngramsLen%(l)sPos%(u)s::ngram), FLATTEN(unigramsPos%(a)s::ngram))  as ngram, 
            %(k)s as ngramLen, 
            ngramsLen%(l)sPos%(u)s::tweetLen as tweetLen, 
            ngramsLen%(l)sPos%(u)s::pos as pos; 
        """% {"a": str(x+i), "u": str(x-1), "l": str(i+1), "k": str(i+2)}
        
        if x < maxLength-i-1:
            union += """,
                ngramsLen%(k)sPos%(p)s"""% {"p":str(x),"k": str(i+2)}
        
    split += ";"
    union += ";"
    
    storePath = "ngrams/len%(k)s"% {"k": str(i+2)}
    store = " STORE ngramsLen%(k)s INTO '%(root)s%(path)s' USING PigStorage('\\t'); "% {"path": storePath, "k": str(i+2), "root": args.root}
    
    scriptStr = """ --- extending ngrams blindly 
     """ + ngramsLoad + """
     """ + unigramsLoad + """
     """ + split + """
     """ + joinConcat + """
     """ + union + """
     """ + store + """
     """
    
     
    print("Script iteration %(iter)s: \n%(script)s\n")% {"iter":i,"script":scriptStr}
    
    if printOnly:
        continue
    
    script = Pig.compile(scriptStr)
    
    bound = script.bind(params)
    
    stats = bound.run()
    
    print("Script returned in " + stat.getDuration())

    if stat.isSuccessful():
        print("Completed with success, outputs written:\n")
        for location in stat.getOutputLocations():
            print(location + " --> " +getNumberRecords(location) + " records\n")
    else:
        print("Failed, with code: " + stat.getReturnCode() + " - Errors:\n ")
        for e in stat.getAllErrorMessages:
            print(e + "\n")
            
        sys.exit(1);

# This is clever but I am afraid to rely on it then get surprised    
#   ngramCurrCnt = getNumberRecords(storePath);
#    Pig.compile("""
#        ngramLen%(k)sCnt = %(cnt)s; 
#        STORE ngramLen%(k)sCnt INTO '%(root)sngrams/len%(k)s_cnt' USING PigStorage('\\t');
#        """% {"k": str(i+2), cnt=ngramCurrCnt), "root": args.root}).bind().run()
        
    
    
    params = { "ngramsPrevPath": storePath }