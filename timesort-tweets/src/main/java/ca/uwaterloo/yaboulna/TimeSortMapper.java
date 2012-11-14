package ca.uwaterloo.yaboulna;

import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.mapreduce.Mapper;

import edu.umd.cloud9.io.pair.PairOfLongs;
import edu.umd.cloud9.io.pair.PairOfStrings;
import edu.umd.cloud9.io.pair.PairOfWritables;

public class TimeSortMapper extends
    Mapper<PairOfLongs, PairOfStrings, LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>> {
  
 
  @Override
  protected void map(PairOfLongs key, PairOfStrings input, Context context)
      throws IOException, InterruptedException {
    
    long timestamp = key.getRightElement();
    context.setStatus("Parallel Timed Counting Mapper: " + timestamp);
    context.write(new LongWritable(timestamp), new PairOfWritables<PairOfLongs, PairOfStrings>(key,input));
  }
  
}
