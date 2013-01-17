package yaboulna.pig;

import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.pig.backend.hadoop.executionengine.mapReduceLayer.PigSplit;

public class PigStorage extends org.apache.pig.builtin.PigStorage {
  
  public PigStorage() {
  }
  
  public PigStorage(String delimiter) {
    super(delimiter);
  }
  
  public PigStorage(String delimiter, String options) {
    super(delimiter, options);
  }
  
  /**
   * Skips the first recorcd whever it is assigned a reader (header)
   * FIXME: This works only in case of reading csv files from local disk and processing them 
   * directly.. didn't work even when I was compressing the csv files into gzipped ones
   */
  @Override
  public void prepareToRead(@SuppressWarnings("rawtypes") RecordReader reader, PigSplit split) {
    super.prepareToRead(reader, split);
//    try {
      // if (reader.nextKeyValue()) {
      // mLog.info("Skipped a record ===> " + reader.getCurrentValue());
      // }
    // } catch (IOException e) {
    // mLog.error(e.getMessage(), e);
    // } catch (InterruptedException e) {
    // mLog.error(e.getMessage(), e);
    // }
  }
  
}
