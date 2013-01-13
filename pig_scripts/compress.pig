-- REGISTER file:///u2/yaboulnaga/VirtualBox VMs/precise-01/shared/yaboulna-udf-0.0.1-SNAPSHOT.jar; --../pig_udf/targe
tweets = LOAD 'file:///u2/yaboulnaga/precise-01_shared/lnk_spritzer_unsorted_csv/[^_]*/[^.]*[^g]' USING PigStorage('\t') AS (id:long, screenname:chararray, timestamp:long, tweet:chararray); 
nohead = FILTER tweets BY id is not null; 
STORE nohead INTO 'file:///u2/yaboulnaga/precise-01_shared/spritzer_2012-09-14_2013-01-11.bz';

