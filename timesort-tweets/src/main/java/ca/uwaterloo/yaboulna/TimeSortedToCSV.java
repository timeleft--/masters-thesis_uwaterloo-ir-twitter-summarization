package ca.uwaterloo.yaboulna;

import java.io.File;
import java.io.IOException;
import java.io.PrintStream;

import org.apache.commons.io.FileUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.PathFilter;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.SortedMapWritable;
import org.apache.hadoop.io.WritableComparable;
import org.apache.mahout.common.Pair;
import org.apache.mahout.common.iterator.sequencefile.SequenceFileIterable;
import org.apache.mahout.common.iterator.sequencefile.SequenceFileIterator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import edu.umd.cloud9.io.pair.PairOfLongs;
import edu.umd.cloud9.io.pair.PairOfStrings;
import edu.umd.cloud9.io.pair.PairOfWritables;

public class TimeSortedToCSV {
  private static final Logger LOG = LoggerFactory.getLogger(TimeSortedToCSV.class);
  
  /**
   * @param args
   * @throws IOException
   */
  public static void main(String[] args) throws IOException {
    dumpSequenceFile(args[0], args[1]);
  }
  
  public static void dumpSequenceFile(String seqPath, String outPath) throws IOException {
    FileSystem fs = FileSystem.get(new Configuration());
    Path inPath = new Path(seqPath);
    if (!fs.exists(inPath)) {
      System.err.println("Error: " + inPath + " does not exist!");
      System.exit(-1);
    }
    FileStatus inFile = fs.listStatus(inPath, new PathFilter() {
      
      public boolean accept(Path p) {
        return p.getName().matches("part.*");
      }
      
    })[0];
    
    PrintStream out = new PrintStream(FileUtils.openOutputStream(new File(
        outPath + File.separator + "start" + File.separator + "end" /* + ".csv" */)), true, "UTF-8");
    out.append("TIMESTAMP\tNUMTWEETS\n");
    
    @SuppressWarnings("unchecked")
    SequenceFileIterator<LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>> iterator =
        (SequenceFileIterator<LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>>)
        new SequenceFileIterable<LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>>(
            inFile.getPath(), true, fs.getConf())
            .iterator();
    
    try {
      long currentTime = -1;
      long currentCount = 0;
      while (iterator.hasNext()) {
        Pair<LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>> p = iterator.next();
        
        LongWritable timestamp = p.getFirst();
//        PairOfWritables<PairOfLongs, PairOfStrings> tweet = p.getSecond();
//        
//        if (tweet == null) {
//          LOG.error("Null tweet at time: ", timestamp.toString());
//        } else {
//          LOG.trace(timestamp.toString() + "\t" + tweet.getRightElement().toString());
//        }
        
        if(timestamp.get() != currentTime){
          if(currentCount > 0){
            out.append(currentTime + "\t" + currentCount + "\n");
          }
          currentCount = 0;
          currentTime = timestamp.get();
        }
        
        ++currentCount;
        
      }
      
      if(currentCount > 0){
        out.append(currentTime + "\t" + currentCount + "\n");
      }
      
    } catch (Exception ex) {
      LOG.error(ex.getMessage(), ex);
    } finally {
      out.flush();
      out.close();
      iterator.close();
    }
  }
}
