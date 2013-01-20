-- REGISTER file:///u2/yaboulnaga/VirtualBox VMs/precise-01/shared/yaboulna-udf-0.0.1-SNAPSHOT.jar; --../pig_udf/targe
data = LOAD 'ngrams/ngramTokenizer/[^._]*[^g]' USING PigStorage('\t'); -- AS (id:long, screenname:chararray, timestamp:long, tweet:chararray); 
-- nonull = FILTER data BY id is not null; 
STORE data INTO 'ngrams/ngramTokenizer.bz';

