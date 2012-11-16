package ca.uwaterloo.yaboulna;

import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.util.Arrays;
import java.util.Collection;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.mahout.common.Pair;
import org.apache.mahout.common.iterator.sequencefile.SequenceFileIterable;
import org.apache.mahout.common.iterator.sequencefile.SequenceFileIterator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import edu.umd.cloud9.io.pair.PairOfLongs;
import edu.umd.cloud9.io.pair.PairOfStrings;
import edu.umd.cloud9.io.pair.PairOfWritables;

public class TimeSortedToCSV {
  private static final Logger LOG = LoggerFactory
      .getLogger(TimeSortedToCSV.class);
  
  /**
   * @param args
   * @throws IOException
   */
  public static void main(String[] args) throws IOException {
    dumpSequenceFile(args[0], args[1]);
  }
  
  @SuppressWarnings("unchecked")
  public static void dumpSequenceFile(String seqRoot, String outRoot)
      throws IOException {
    FileSystem fs = FileSystem.get(new Configuration());
    
    // Path inPath = new Path(seqPath);
    // if (!fs.exists(inPath)) {
    // System.err.println("Error: " + inPath + " does not exist!");
    // System.exit(-1);
    // }
    // FileStatus inFile = fs.listStatus(inPath, new PathFilter() {
    //
    // public boolean accept(Path p) {
    // return p.getName().matches("part.*");
    // }
    //
    // })[0];
    
    IOFileFilter noHidderOrLogsFilter = new IOFileFilter() {
      
      public boolean accept(File dir, String name) {
        return !(name.startsWith("_") || name.endsWith("logs"));
      }
      
      public boolean accept(File file) {
        return accept(file.getParentFile(), file.getName());
      }
    };
    
    IOFileFilter partFFilter = new IOFileFilter() {
      
      public boolean accept(File dir, String name) {
        return name.startsWith("part");
      }
      
      public boolean accept(File file) {
        return accept(file.getParentFile(), file.getName());
      }
    };
    
    File[] seqFiles = FileUtils.listFiles(new File(seqRoot),
        partFFilter, noHidderOrLogsFilter).toArray(new File[0]);
    
    Arrays.sort(seqFiles);
    
    PrintStream out = new PrintStream(FileUtils.openOutputStream(new File(
        outRoot + "tweet-counts.csv")), true, "UTF-8");
    out.append("TIMESTAMP\tNUMTWEETS\n");
    long currentTime = -1;
    long currentCount = 0;
    try {
      for (File seqFile : seqFiles) {
        // PrintStream out = new
        // PrintStream(FileUtils.openOutputStream(new File(
        // outRoot + File.separator +
        // seqFile.getParentFile().getParentFile().getName()
        // + File.separator + seqFile.getParentFile().getName() /* +
        // ".csv" */)), true, "UTF-8");
        // out.append("TIMESTAMP\tNUMTWEETS\n");
        // long currentTime = -1;
        // long currentCount = 0;
        // try{
        @SuppressWarnings("unchecked")
        SequenceFileIterator<LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>> iterator = (SequenceFileIterator<LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>>) new SequenceFileIterable<LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>>(
            new Path(seqFile.toURI()), true, fs.getConf())
            .iterator();
        try {
          if (iterator.hasNext()) {
            currentTime = iterator.next().getFirst().get();
            iterator = (SequenceFileIterator<LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>>) new SequenceFileIterable<LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>>(
                new Path(seqFile.toURI()), true, fs.getConf())
                .iterator();
          }
          
          while (iterator.hasNext()) {
            Pair<LongWritable, PairOfWritables<PairOfLongs, PairOfStrings>> p = iterator.next();
            
            long timestamp = p.getFirst().get();
            // PairOfWritables<PairOfLongs, PairOfStrings> tweet =
            // p.getSecond();
            //
            // if (tweet == null) {
            // LOG.error("Null tweet at time: ",
            // timestamp.toString());
            // } else {
            // LOG.trace(timestamp.toString() + "\t" +
            // tweet.getRightElement().toString());
            // }
            
            if (timestamp > currentTime) {
              do {
                out.append(currentTime + "\t" + currentCount
                    + "\n");
                currentCount = 0;
                currentTime += 1000;
              } while (currentTime != timestamp);
            } else if (timestamp < currentTime) {
              LOG.error(timestamp + " < " + currentTime);
              continue;
            }
            
            ++currentCount;
            
          }
          
        } catch (Exception ex) {
          LOG.error(ex.getMessage(), ex);
        } finally {
          // out.flush();
          // out.close();
          iterator.close();
        }
      }
      
      out.append(currentTime + "\t" + currentCount);// + "\n");
      
    } catch (Exception ex) {
      LOG.error(ex.getMessage(), ex);
    } finally {
      out.flush();
      out.close();
    }
  }
}
