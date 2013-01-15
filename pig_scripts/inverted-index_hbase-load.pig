REGISTER file:///nfs/vmshared/Code/thesis/pig_udf/target/yaboulna-udf-0.0.1-SNAPSHOT.jar; 
unigramsStruct1 = LOAD 'hbase://tokenPos' USING yaboulna.pig.HBaseStorage('d:21221', '-limit 1000') AS (token: chararray, days: {(day: chararray, vers: {(id: long, pos:bytearray)})});
unigramsStruct2 = FOREACH unigramsStruct GENERATE token, FLATTEN(days); 
unigramsStruct3 = FOREACH unigramsStruct2 GENERATE token, day, FLATTEN(vers);
store unigramsStruct1 into 'hdfs://192.168.122.222:8020/user/younos/debug_load/unigramStruct1' using PigStorage('\t');
store unigramsStruct1 into 'hdfs://192.168.122.222:8020/user/younos/debug_load/unigramStruct2' using PigStorage('\t');
store unigramsStruct1 into 'hdfs://192.168.122.222:8020/user/younos/debug_load/unigramStruct3' using PigStorage('\t');
