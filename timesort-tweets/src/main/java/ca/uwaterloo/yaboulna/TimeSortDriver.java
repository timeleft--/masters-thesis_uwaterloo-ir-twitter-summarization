package ca.uwaterloo.yaboulna;

import java.io.File;
import java.util.Arrays;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
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
  
  IOFileFilter noHiddenOrLogs = new IOFileFilter() {
    public boolean accept(File dir, String name) {
      return !(name.startsWith(".") || name.endsWith(".log"));
    }
    
    public boolean accept(File file) {
      return accept(file.getParentFile(), file.getName());
    }
  };
  
  // WTF!! @Override
  public int run(String[] args) throws Exception {
    addInputOption();
    addOutputOption();
    addOption("encoding", "e", "(Optional) The file encoding.  Default value: UTF-8", "UTF-8");
    
    if (parseArguments(args) == null) {
      return -1;
    }
    
    Path inputRoot = getInputPath();
    Path outputRoot = getOutputPath();
    
    File[] inputFolders = FileUtils.toFile(inputRoot.toUri().toURL()).listFiles();
//        FileUtils.listFiles(FileUtils.toFile(inputRoot.toUri().toURL()),
//        noHiddenOrLogs, noHiddenOrLogs).toArray(new File[0]);
    Arrays.sort(inputFolders);
    Job[] jobArr = new Job[inputFolders.length];
    int j = 0;
    for (File inputF : inputFolders) {
      Parameters params = new Parameters();
      
      String encoding = "UTF-8";
      if (hasOption("encoding")) {
        encoding = getOption("encoding");
      }
      params.set("encoding", encoding);
      
      Path outputP = new Path(outputRoot, inputF.getName());
      
      params.set("input", inputF.toURI().toString());
      params.set("output", outputP.toString());
      
      Configuration conf = new Configuration();
      // HadoopUtil.delete(conf, outputDir);
      FileSystem fs = FileSystem.get(conf);
      if (fs.exists(outputP)) {
        throw new IllegalArgumentException(
            "Output path already exists.. please delete it yourself: "
                + outputP);
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
      
      Job job = new Job(conf, "Parallel time sort running over input "
          + inputF.toURI().toString());
      jobArr[j++] = job;
      
      FileOutputFormat.setOutputPath(job, outputP);
      // HadoopUtil.delete(conf, outPath);
      
      job.setJarByClass(TimeSortDriver.class);
      
      job.setOutputKeyClass(LongWritable.class);
      job.setOutputValueClass(PairOfWritables.class);
      
      for (File tweetsFile : FileUtils.listFiles(inputF, noHiddenOrLogs, noHiddenOrLogs)) {
        FileInputFormat.addInputPath(job, new Path(tweetsFile.toURI()));
      }
      
      job.setInputFormatClass(CSVTweetInputFormat.class);
      job.setMapperClass(TimeSortMapper.class);
      job.setCombinerClass(TimeSortReducer.class);
      job.setReducerClass(TimeSortReducer.class);
      job.setOutputFormatClass(SequenceFileOutputFormat.class);
      
      job.submit();
    }
    
    boolean allCompleted;
    do {
      Thread.sleep(1000);
      allCompleted = true;
      for (j = 0; j < jobArr.length; ++j) {
        if (jobArr[j] == null) {
          continue;
        }
        boolean complete = jobArr[j].isComplete();
        allCompleted &= complete;
        if (!complete) {
          String report =
              (j + " (" + jobArr[j].getJobName() + "): map "
                  + StringUtils.formatPercent(jobArr[j].mapProgress(), 0) +
                  " reduce " +
                  StringUtils.formatPercent(jobArr[j].reduceProgress(), 0) + " - Tracking: " + jobArr[j]
                  .getTrackingURL());
          LOG.info(report);
        }
      }
    } while (!allCompleted);
    
    boolean allSuccess = true;
    for (j = 0; j < jobArr.length; ++j) {
      if (jobArr[j] == null) {
        continue;
      }
      boolean success = jobArr[j].isSuccessful();
      allSuccess &= success;
      if (!success) {
        String report =
            (j + " (" + jobArr[j].getJobName() + "): FAILED - Tracking: " + jobArr[j]
                .getTrackingURL());
        LOG.info(report);
      }
    }
    if (!allSuccess) {
      throw new IllegalStateException("Job failed!");
    }
    
    return 0;
  }
}
