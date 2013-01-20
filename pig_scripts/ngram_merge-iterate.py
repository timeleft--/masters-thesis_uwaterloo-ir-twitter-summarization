#!/usr/bin/python
from org.apache.pig.scripting import *
import string

params = { 'unigramsPath': 'ngrams/ngramTokenizer', 'ngramPrevPath': 'ngrams/ngramTokenizer' }

  
for i in range(70):
    splitStr = """ 
    SPLIT ngramPrev INTO ngramPrevPos0 IF pos==0
    """
    for x in range(1,70-i):
        splitStr += """
            , ngramPrevPos%(p) IF pos==%p
        """ % { 'p':str(x) }
    splitStr += ';'
    splitTemplate = string.Template() 

    out = 'ngrams/iter' + str(i)
    
    