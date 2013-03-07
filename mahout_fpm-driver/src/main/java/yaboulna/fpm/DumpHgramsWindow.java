package yaboulna.fpm;

import java.io.IOException;
import java.util.List;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.mahout.common.Pair;
import org.apache.mahout.fpm.pfpgrowth.convertors.string.TopKStringPatterns;
import org.apache.mahout.fpm.pfpgrowth.fpgrowth.FPGrowth;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

public class DumpHgramsWindow {

  public static String fpsToString(Pair<String, TopKStringPatterns> tokenPatterns) {
    StringBuilder sb = new StringBuilder(tokenPatterns.getFirst()+"\t");
    String sep = " | ";

    boolean worthy = false;
    for (Pair<List<String>, Long> pattern : tokenPatterns.getSecond().getPatterns()) {
      if(pattern.getFirst().size() == 1){
        continue;
      }
      worthy = true;
      sb.append(pattern.getFirst() + " = " + pattern.getSecond());
      sb.append(sep);
    }

    return (worthy?sb.toString():null);
  }

  public static void main(String[] args) throws IOException {
    Path path = new Path(args[0]);
    Configuration conf = new Configuration();
    FileSystem fs = FileSystem.get(path.toUri(), conf);
    for (FileStatus s : fs.listStatus(path)) {
      if (s.isDir()) {
        System.out.println("Skipping dir" + s.getPath());
        continue;
      }
      System.out.println("Dumping (" + s.getLen() + " bytes): " + s.getPath());
      try {
        List<Pair<String, TopKStringPatterns>> txt = FPGrowth.readFrequentPattern(conf, s.getPath());
        for (Pair<String, TopKStringPatterns> t : txt) {
          String toPrint = fpsToString(t);
          if(toPrint != null){
            System.out.println(toPrint);
          }
        }
      } catch (Exception ignored) {
        System.err.println(ignored.getMessage());
      }
    }
  }
}
