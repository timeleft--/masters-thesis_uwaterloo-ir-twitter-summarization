package ca.uwaterloo.yaboulna;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.SortedMapWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import ca.uwaterloo.twitter.TokenIterator.LatinTokenIterator;
import edu.umd.cloud9.io.pair.PairOfLongs;
import edu.umd.cloud9.io.pair.PairOfStrings;

public class TimedCountsMapper extends
    Mapper<PairOfLongs, PairOfStrings, LongWritable, SortedMapWritable> {
  
  private static final IntWritable ZERO = new IntWritable(0);
  private static final boolean COUNT_DOCUMENT_OCCURRENCES = true;
  private static final boolean REPEAT_HASHTAGS = false;
  
  @Override
  protected void map(PairOfLongs key, PairOfStrings input, Context context)
      throws IOException, InterruptedException {
    
    long timestamp = key.getRightElement();
    String inputStr = input.getRightElement();
    
    LatinTokenIterator items = new LatinTokenIterator(inputStr);
    items.setRepeatHashTag(REPEAT_HASHTAGS);
    
    // Text, IntWritable>
    SortedMapWritable countsMap = new SortedMapWritable();
    while (items.hasNext()) {
      Text item = new Text(items.next());
      if (!TimedCountsDriver.watchedTerms.contains(item.toString())) {
        continue;
      }
      
      if (countsMap.containsKey(item)) {
        if (COUNT_DOCUMENT_OCCURRENCES) {
          continue;
        }
      } else {
        countsMap.put(item, ZERO);
      }
      countsMap.put(item, new IntWritable(((IntWritable) countsMap.get(item)).get() + 1));
    }
    
    context.setStatus("Parallel Timed Counting Mapper: " + timestamp);
    context.write(new LongWritable(timestamp), countsMap);
  }
  
}
