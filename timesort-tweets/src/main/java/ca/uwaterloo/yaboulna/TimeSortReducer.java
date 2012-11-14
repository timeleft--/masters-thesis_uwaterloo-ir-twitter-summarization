package ca.uwaterloo.yaboulna;

import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.mapreduce.Reducer;

import edu.umd.cloud9.io.pair.PairOfLongs;
import edu.umd.cloud9.io.pair.PairOfStrings;
import edu.umd.cloud9.io.pair.PairOfWritables;

/**
 * sums up the item count and output the item and the count This can also be used as a local Combiner.
 * A simple summing reducer
 */
public class TimeSortReducer extends
    Reducer<LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>, LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>> {
  
  @Override
  protected void reduce(LongWritable key, Iterable<PairOfWritables<PairOfLongs, PairOfStrings>> values,
      Context context)
      throws IOException,
      InterruptedException {
    
    context.setStatus("Parallel Timed Counting Reducer :" + key);
    for (PairOfWritables<PairOfLongs, PairOfStrings> value : values) {
      
      context.write(key, value);
      
    }
  }
}