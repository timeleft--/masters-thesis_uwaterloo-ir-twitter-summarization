package ca.uwaterloo.yaboulna;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.SortedMapWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.mapreduce.Reducer;

/**
 * sums up the item count and output the item and the count This can also be used as a local Combiner.
 * A simple summing reducer
 */
public class TimedCountsReducer extends
    Reducer<LongWritable, SortedMapWritable, LongWritable, SortedMapWritable> {
  
  private static final IntWritable ZERO = new IntWritable(0);
  
  @Override
  protected void reduce(LongWritable key, Iterable<SortedMapWritable> values,
      Context context)
      throws IOException,
      InterruptedException {
    
    SortedMapWritable sumMap = new SortedMapWritable();
    
    for(String watched: TimedCountsDriver.watchedTerms){
      sumMap.put(new Text(watched), ZERO);
    }
    
    for (SortedMapWritable value : values) {
      context.setStatus("Parallel Timed Counting Reducer :" + key);
      for (WritableComparable term : value.keySet()) {
        int current = 0;
        if(sumMap.containsKey(term)){
          current = ((IntWritable) sumMap.get(term)).get();
        }
        sumMap.put(
            term,
            new IntWritable(current
                + ((IntWritable) value.get(term)).get()));
      }
    }
    context.setStatus("Parallel Counting Reducer: " + key + " => " + sumMap.values());
    context.write(key, sumMap);
  }
}