#!/usr/bin/python
#from org.apache.pig.scripting import *


params = { 'ngramsPrevPath': 'ngrams/ngramsTokenizer' }

maxLength = 30
  
for i in range(maxLength-1):
    loadSchema = " USING PigStorage('\\t') AS (id: long, timeMillis:long, date:int, ngram:chararray, ngramLen:int, tweetLen:int,  pos:int); "
    
    ngramsLoad = " ngramsLen{l} = LOAD '$ngramsPrevPath' {0}".format(loadSchema, l=str(i+1))
    
    #unigramsLoad = " unigramsPos0 = LOAD 'unigrams/pos0' {0}".format(loadSchema)
    unigramsLoad = " "
    
    split = " SPLIT ngramsLen{l} INTO ngramsLen{l}Pos0 IF pos==0 ".format(l=str(i+1))
    
    #join[:70-i] = " ngramsLen{l}JoinPos".format(l=str(i+1))
    #contact[:70-i] = " ngramsLen{k}Pos".format(k=str(i+2))
    joinConcat = "-- join ngrams with unigrams then concat to generate longer ngrams"
    
    union = " ngramsLen{k} = UNION ngramsLen{k}Pos0 ".format(k=str(i+2))
    
    for x in range(1,maxLength-i):
        unigramsLoad += """
         unigramsPos{o} = LOAD 'unigrams/pos{o}' {0}""".format(loadSchema, o=str(70-x))
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
    
    store = " STORE ngramsLen{k} INTO 'ngrams/len{k}' USING PigStorage('\\t'); ".format(k= str(i+2))
    
    script = """ --- extending ngrams blindly 
     """ + ngramsLoad + """
     """ + unigramsLoad + """
     """ + split + """
     """ + joinConcat + """
     """ + union + """
     """ + store + """
     """
     
    print("Script iteration {0}: \n{1}\n").format(i,script)