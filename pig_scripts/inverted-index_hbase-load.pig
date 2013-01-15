REGISTER file:///nfs/vmshared/Code/thesis/pig_udf/target/yaboulna-udf-0.0.1-SNAPSHOT.jar; 
unigrams = LOAD 'hbase://tokenPos' USING yaboulna.pig.HBaseStorage('d:*', '-limit 50') AS (token: chararray, days: {(day: chararray, vers: {(id: long, pos:bytearray)})});
store unigrams into 'hdfs://precise-01:8020/user/younos/load_test' using PigStorage('\t');
