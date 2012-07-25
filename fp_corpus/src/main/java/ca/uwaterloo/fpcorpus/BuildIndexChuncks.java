package ca.uwaterloo.fpcorpus;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.math.stat.descriptive.SummaryStatistics;
import org.apache.hadoop.fs.Path;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.store.LockObtainFailedException;
import org.apache.mahout.fpm.pfpgrowth.PFPGrowth;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import ca.uwaterloo.twitter.ItemSetIndexBuilder;

public class BuildIndexChuncks {
  private static final Logger LOG = LoggerFactory
      .getLogger(BuildIndexChuncks.class);
  private static final boolean DONOT_REPLACE = true;
  
  /**
   * @param args
   * @throws ParseException
   * @throws IOException
   * @throws NoSuchAlgorithmException
   * @throws LockObtainFailedException
   * @throws CorruptIndexException
   */
  public static void main(String[] args) throws CorruptIndexException,
      LockObtainFailedException, NoSuchAlgorithmException, IOException,
      ParseException {
    
    File inDir = new File(args[0]);
    File outDir = new File(args[1]);
    int dayStart = Integer.parseInt(args[2]);
    int dayEnd = Integer.parseInt(args[3]);
    
    for (int i = dayStart; i <= dayEnd; ++i) {
      final int dayNum = i;
      File dayOut = new File(outDir, "d" + i);
      for (File dayIn : inDir.listFiles(new FilenameFilter() {
        
        public boolean accept(File dir, String name) {
          return name.endsWith("_day" + dayNum);
        }
      })) {
        
        for (File intervalStartIn : dayIn.listFiles()) {
          
          File inervalEndIn = intervalStartIn.listFiles()[0];
          long windowSize = Long.parseLong(inervalEndIn.getName())
              - Long.parseLong(intervalStartIn.getName());
          File intervalOut = new File(dayOut, "w" + windowSize);
          intervalOut = new File(intervalOut,
              intervalStartIn.getName());
          
          intervalOut = new File(intervalOut, inervalEndIn.getName());
          
          Path freqPattsPath = new Path(inervalEndIn.toURI()
              .toString() + "/" + PFPGrowth.FREQUENT_PATTERNS);
          
          if (intervalOut.exists() && DONOT_REPLACE) {
            continue;
          }
          
          LOG.info("Indexing {} to {}", freqPattsPath, intervalOut.getAbsolutePath());
          ItemSetIndexBuilder builder = new ItemSetIndexBuilder();
          Map<String, SummaryStatistics> stats = builder.buildIndex(
              freqPattsPath, new File(intervalOut, "index"),
              Long.parseLong(intervalStartIn.getName()),
              Long.parseLong(inervalEndIn.getName()), null);
          
          for (String key : stats.keySet()) {
            FileUtils.writeStringToFile(new File(new File(
                intervalOut, "stats"), key), stats.get(key)
                .toString());
          }
        }
        
      }
    }
    
  }
  
}
