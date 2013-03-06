package yaboulna.fpm;

import java.io.IOException;
import java.util.List;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.mahout.common.Pair;
import org.apache.mahout.fpm.pfpgrowth.convertors.string.TopKStringPatterns;
import org.apache.mahout.fpm.pfpgrowth.fpgrowth.FPGrowth;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

public class DumpHgramsWindow {
  
  public static String fpsToString(List<Pair<List<String>,Long>> frequentPatterns) {
    StringBuilder sb = new StringBuilder();
    String sep = " | ";
    
    for (Pair<List<String>,Long> pattern : frequentPatterns) {
      sb.append(pattern.getFirst() + " = " + pattern.getSecond());
      sb.append(sep);
    }
    
    return sb.toString();
  }
  
  public static void main(String[] args) throws IOException {
    Path path = new Path(args[0]);
    Configuration conf = new Configuration();
    FileSystem fs = FileSystem.get(path.toUri(), conf);
    List<Pair<String, TopKStringPatterns>> txt = FPGrowth.readFrequentPattern(conf, path);
    for(Pair<String, TopKStringPatterns> t: txt){
      System.out.println(t.getFirst() + "\t" + fpsToString(t.getSecond().getPatterns()));
    }
  }
}
