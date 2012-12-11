package yaboulna.pig;

import java.io.IOException;

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
   */
  @Override
  public void prepareToRead(RecordReader reader, PigSplit split) {
    super.prepareToRead(reader, split);
    try {
      if (reader.nextKeyValue()) {
        mLog.info("Skipped a record ===> " + reader.getCurrentValue());
      }
    } catch (IOException e) {
      mLog.error(e.getMessage(), e);
    } catch (InterruptedException e) {
      mLog.error(e.getMessage(), e);
    }
  }
  
}
