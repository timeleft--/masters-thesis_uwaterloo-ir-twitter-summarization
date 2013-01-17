ngram2Grps = GROUP ngram2 by token;
ngram2Cnts = FOREACH ngram2Grps GENERATE group as token, COUNT(ngram2) as cnt;
ngram1Grps = GROUP ngram1 by token;  
ngram1Cnts = FOREACH ngram1Grps GENERATE group as token, COUNT(ngram1) as cnt;
ngram2Prob0 = COGROUP ngram1Cnts by token, ngram2Cnts by token.$0;
ngram2Prob1 = COGROUP ngram1Cnts by token, ngram2Cnts by token.$1;  
ngram2Prob = JOIN ngram2Prob0 by group, ngram2Prob1 by group;
ngram2Freqs = FOREACH ngram2Prob GENERATE FLATTEN(ngram2Prob0::ngram1Cnts) as (ngram1Token, ngram1Cnt), ngram2Prob0::ngram2Cnts as ngram2A, ngram2Prob1::ngram2Cnts as ngram2B;
ngram2Eq1A = FOREACH ngram2Freqs { 
	eq1 = FOREACH ngram2A GENERATE token, (1.0 * cnt / ngram2Freqs.ngram1Cnt) as condProb; 
	GENERATE FLATTEN(eq1);   
}
ngram2Eq1B = FOREACH ngram2Freqs { 
	eq1 = FOREACH ngram2B GENERATE token, (1.0 * cnt / ngram2Freqs.ngram1Cnt) as condProb; 
	GENERATE FLATTEN(eq1);   
}       
ngram2Eq1 = UNION ngram2Eq1A, ngram2Eq1B;
                     
numTokensTotal = SUM(ngram1Cnts::cnt);

