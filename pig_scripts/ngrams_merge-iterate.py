#!/usr/bin/python
import sys
#from org.apache.pig.scripting import *
#Pig.set("default_parallel", "50")

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--root", help="The root of where the data is stored")
parser.add_argument("--maxLength", help="The maximum length of ngrams. CAUTION! This should be set to the maximum Tweet length", type=int, default=71)
parser.add_argument("--dry", help="Don't run the script, just print it out", action="store_true")
args = parser.parse_args()

printOnly=args.dry

maxLength = args.maxLength #140 characters limit -> at most 71 tokens, of length 1 each

params = { "ngramsPrevPath": "ngrams/len1" }
  
for i in range(maxLength-1):
    funcSchema = " USING PigStorage('\\t') AS (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int) "
    
    ngramsLoad = " ngramsLen{l} = LOAD '{root}$ngramsPrevPath' {0};".format(funcSchema, l=str(i+1), root=args.root)
    
    #unigramsLoad = " unigramsPos0 = LOAD '{root}unigrams/pos0' {0};".format(funcSchema, root=args.root)
    unigramsLoad = " "
    
    split = " SPLIT ngramsLen{l} INTO ngramsLen{l}Pos0 IF pos==0 ".format(l=str(i+1))
    
    #join[:70-i] = " ngramsLen{l}JoinPos".format(l=str(i+1))
    #contact[:70-i] = " ngramsLen{k}Pos".format(k=str(i+2))
    joinConcat = "-- join ngrams with unigrams then concat to generate longer ngrams"
    
    union = " ngramsLen{k} = UNION ngramsLen{k}Pos0 ".format(k=str(i+2))
    
    for x in range(1,maxLength-i):
        unigramsLoad += """
         unigramsPos{o} = LOAD '{root}unigrams/pos{o}' {0};""".format(funcSchema, o=str(70-x), root=args.root)
        split += """,
             ngramsLen{l}Pos{p} IF pos=={p}""".format(p=str(x), l=str(i+1))
        joinConcat += """
        ngramsLen{l}JoinPos{u} = JOIN ngramsLen{l}Pos{u} BY id, unigramsPos{a} BY id;
        ngramsLen{k}Pos{u} = FOREACH ngramsLen{l}JoinPos{u} GENERATE 
            ngramsLen{l}Pos{u}::id as id, 
            ngramsLen{l}Pos{u}::timeMillis as timeMillis, 
            ngramsLen{l}Pos{u}::date as date, 
            (FLATTEN(ngramsLen{l}Pos{u}::ngram), FLATTEN(unigramsPos{a}::ngram))  as ngram, 
            {k} as ngramLen, 
            ngramsLen{l}Pos{u}::tweetLen as tweetLen, 
            ngramsLen{l}Pos{u}::pos as pos; 
        """.format(a=str(x+i), u=str(x-1), l=str(i+1), k=str(i+2))
        union += """,
            ngramsLen{k}Pos{p}""".format(p=str(x),k=str(i+2)) 
        
    split += ";"
    union += ";"
    
    storePath = "ngrams/len{k}".format(k= str(i+2))
    store = " STORE ngramsLen{k} INTO '{root}{0}' USING PigStorage('\\t'); ".format(storePath, k=str(i+2), root=args.root)
    
    scriptStr = """ --- extending ngrams blindly 
     """ + ngramsLoad + """
     """ + unigramsLoad + """
     """ + split + """
     """ + joinConcat + """
     """ + union + """
     """ + store + """
     """
    
     
    print("Script iteration {0}: \n{1}\n").format(i,scriptStr)
    
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
#        ngramLen{k}Cnt = {cnt}; 
#        STORE ngramLen{k}Cnt INTO '{root}ngrams/len{k}_cnt' USING PigStorage('\\t');
#        """.format(k=str(i+2), cnt=ngramCurrCnt), root=args.root).bind().run()
        
    
    
    params = { "ngramsPrevPath": storePath }