package yaboulna.pig;

import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapreduce.Partitioner;
import org.apache.pig.impl.io.PigNullableWritable;

public class DatePartitioner extends Partitioner<PigNullableWritable, Writable> {

  @Override
  public int getPartition(PigNullableWritable key, Writable value, int numPartitions) {
    // What will be passed in the key and what will be passed in the value?? I have no idea and can't find out. DUH!
    return 0;
  }

}
