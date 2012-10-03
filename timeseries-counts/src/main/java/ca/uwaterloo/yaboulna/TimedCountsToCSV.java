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

public class TimedCountsToCSV {
  private static final Logger LOG = LoggerFactory.getLogger(TimedCountsToCSV.class);
  
  /**
   * @param args
   * @throws IOException
   */
  public static void main(String[] args) throws IOException {
    dumpFrequentPatterns(args[0], args[1]);
  }
  
  public static void dumpFrequentPatterns(String seqPath, String outPath) throws IOException {
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
    
    @SuppressWarnings("unchecked")
    SequenceFileIterator<LongWritable, SortedMapWritable> iterator =
        (SequenceFileIterator<LongWritable, SortedMapWritable>)
        new SequenceFileIterable<LongWritable, SortedMapWritable>(
            inFile.getPath(), true, fs.getConf())
            .iterator();
    try {
      boolean headerPrinted = false;
      while (iterator.hasNext()) {
        Pair<LongWritable, SortedMapWritable> p = iterator.next();
        
        LongWritable timestamp = p.getFirst();
        SortedMapWritable countsMap = p.getSecond();
        
        if (!headerPrinted) {
          out.append("TIMESTAMP");
          for (WritableComparable term : countsMap.keySet()) {
            out.append("\t").append("\"" + term.toString() + "\"");
          }
          out.append("\n");
          headerPrinted = true;
        }
        
        if (countsMap.size() == 0) {
          LOG.error("No occurrences at time: ",
              timestamp.toString());
        } else {
          LOG.trace(timestamp.toString() + "\t" + countsMap.toString());
          
          out.append(timestamp.toString());
          for (WritableComparable term : countsMap.keySet()) {
            out.append("\t").append(countsMap.get(term).toString());
          }
          out.append("\n");
        }
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
