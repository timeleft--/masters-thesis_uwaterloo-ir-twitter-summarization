package ca.uwaterloo.yaboulna;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.PathFilter;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat;
import org.apache.hadoop.util.StringUtils;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.mahout.common.AbstractJob;
import org.apache.mahout.common.Parameters;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.twitter.corpus.data.CSVTweetInputFormat;

import edu.umd.cloud9.io.pair.PairOfWritables;

public final class TimeSortDriver extends AbstractJob implements Tool {
  
  private static final Logger LOG = LoggerFactory.getLogger(TimeSortDriver.class);
  private static final String TIME_SORT_PARAMS = "TSortParams";
 
  private TimeSortDriver() {
  }
  
  public static void main(String[] args) throws Exception {
    ToolRunner.run(new Configuration(), new TimeSortDriver(), args);
  }
  
  // WTF!! @Override
  public int run(String[] args) throws Exception {
    addInputOption();
    addOutputOption();
    addOption("encoding", "e", "(Optional) The file encoding.  Default value: UTF-8", "UTF-8");
    
    if (parseArguments(args) == null) {
      return -1;
    }
    
    Parameters params = new Parameters();
    
    String encoding = "UTF-8";
    if (hasOption("encoding")) {
      encoding = getOption("encoding");
    }
    params.set("encoding", encoding);
    
    Path inputDir = getInputPath();
    Path outputDir = getOutputPath();
    
    params.set("input", inputDir.toString());
    params.set("output", outputDir.toString());
    
    Configuration conf = new Configuration();
    // HadoopUtil.delete(conf, outputDir);
    FileSystem fs = FileSystem.get(conf);
    if (fs.exists(outputDir)) {
      throw new IllegalArgumentException("Output path already exists.. please delete it yourself: "
          + outputDir);
    }
    
    conf.set("io.serializations", "org.apache.hadoop.io.serializer.JavaSerialization,"
        + "org.apache.hadoop.io.serializer.WritableSerialization");
    
    conf.set(TIME_SORT_PARAMS, params.toString());
    
    conf.set("mapred.compress.map.output", "true");
    conf.set("mapred.output.compression.type", "BLOCK");
    
    // if(Boolean.parseBoolean(params.get(PFPGrowth.PSEUDO, "false"))){
    // conf.set("mapred.tasktracker.map.tasks.maximum", "3");
    // conf.set("mapred.tasktracker.reduce.tasks.maximum", "3");
    // conf.set("mapred.map.child.java.opts", "-Xmx777M");
    // conf.set("mapred.reduce.child.java.opts", "-Xmx777M");
    // conf.setInt("mapred.max.map.failures.percent", 0);
    // }
    conf.set("mapred.child.java.opts", "-XX:-UseGCOverheadLimit -XX:+HeapDumpOnOutOfMemoryError");
    
    Job job = new Job(conf, "Parallel timed counting running over input " + inputDir.toString());
    
    FileOutputFormat.setOutputPath(job, outputDir);
    // HadoopUtil.delete(conf, outPath);
    
    job.setJarByClass(TimeSortDriver.class);
    
    job.setOutputKeyClass(LongWritable.class);
    job.setOutputValueClass(PairOfWritables.class);
    
    // TODO: Partition the input on several jobs??
    for (FileStatus startStatus : fs.listStatus(inputDir)) {
      for (FileStatus endStatus : fs.listStatus(startStatus.getPath(),new PathFilter() {
        public boolean accept(Path p) {
          String name = p.getName();
          return !(name.startsWith(".")|| name.endsWith(".log"));
//Actually they don't          return p.getName().toLowerCase().endsWith(".csv");
        }
      })) {
        FileInputFormat.addInputPath(job, endStatus.getPath());
      }
    }
    
    job.setInputFormatClass(CSVTweetInputFormat.class);
    job.setMapperClass(TimeSortMapper.class);
    job.setCombinerClass(TimeSortReducer.class);
    job.setReducerClass(TimeSortReducer.class);
    job.setOutputFormatClass(SequenceFileOutputFormat.class);
    
    job.submit();
    
    boolean complete;
    do {
      Thread.sleep(5000);
      
      complete = job.isComplete();
      
      String report = job.getJobName()
          + ": map " + StringUtils.formatPercent(job.mapProgress(), 0)
          + " reduce " + StringUtils.formatPercent(job.reduceProgress(), 0)
          + " - Tracking: " + job.getTrackingURL();
      LOG.info(report);
      
    } while (!complete);
    
    if (!job.isSuccessful()) {
     throw new IllegalStateException("Job failed! Tracking: " + job.getTrackingURL());
    }
    
    return 0;
  }
}
