package ca.uwaterloo.yaboulna;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.PathFilter;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat;
import org.apache.hadoop.util.StringUtils;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import ca.uwaterloo.yaboulna.CSVNGramRecordReader.Record;

public final class InsertNgramsDriver extends Configured implements Tool {
  
  private static final Logger LOG = LoggerFactory.getLogger(InsertNgramsDriver.class);
//  private static final String InsertNGrams_PARAMS = "InserNGramsParams";
  
  private InsertNgramsDriver() {
  }
  
  public static void main(String[] args) throws Exception {
    ToolRunner.run(new Configuration(), new InsertNgramsDriver(), args);
  }
  
//  IOFileFilter noHiddenOrLogs = new IOFileFilter() {
//    public boolean accept(File dir, String name) {
//      return !(name.charAt(0) == '.' || name.charAt(0) == '_'); // || name.endsWith(".log"));
//    }
//    
//    public boolean accept(File file) {
//      return accept(file.getParentFile(), file.getName());
//    }
//  };
  
  // WTF!! @Override
  public int run(String[] args) throws Exception {
//    addInputOption();
//    addOutputOption();
//    addOption("encoding", "e", "(Optional) The file encoding.  Default value: UTF-8", "UTF-8");
//    
//    if (parseArguments(args) == null) {
//      return -1;
//    }
    
    Path inputRoot = new Path(args[0]); //getInputPath();
    Path outputRoot = new Path(args[1]); //getOutputPath();
    
    Configuration conf = new Configuration();
    FileSystem fs = FileSystem.get(conf);
//    File[] inputFiles = FileUtils.listFiles(FileUtils.toFile(inputRoot.toUri().toURL()),noHiddenOrLogs,noHiddenOrLogs).toArray(new File[0]);
//        FileUtils.listFiles(FileUtils.toFile(inputRoot.toUri().toURL()),
//        noHiddenOrLogs, noHiddenOrLogs).toArray(new File[0]);
//    Arrays.sort(inputFolders);
    
    if (fs.exists(outputRoot)) {
      throw new IllegalArgumentException(
          "Output path already exists.. please delete it yourself: "
              + outputRoot);
    }
    
     FileStatus[] inputStati = fs.listStatus(inputRoot,new PathFilter(){

      @Override
      public boolean accept(Path p) {
        String name = p.getName();
        return !(name.charAt(0) == '.' || name.charAt(0) == '_');
      }});
     
    Job[] jobArr = new Job[inputStati.length];
    int j = 0;
    for (FileStatus inputStatus : inputStati) {
//      Parameters params = new Parameters();
//      String encoding = "UTF-8";
//      if (hasOption("encoding")) {
//        encoding = getOption("encoding");
//      }
//      params.set("encoding", encoding);
//      params.set("input", inputStatus.toString());
//      params.set("output", outputP.toString());
//    conf.set(InsertNGrams_PARAMS, params.toString());
      
      
      conf.set("io.serializations", "org.apache.hadoop.io.serializer.JavaSerialization,"
          + "org.apache.hadoop.io.serializer.WritableSerialization");
      
      
      conf.set("mapred.compress.map.output", "true");
      conf.set("mapred.output.compression.type", "BLOCK");
      
      conf.set("mapred.child.java.opts", "-XX:-UseGCOverheadLimit -XX:+HeapDumpOnOutOfMemoryError");
      
      Job job = new Job(conf, "Parallel time sort and ngram inster running over input "
          + inputStatus.toString());
      jobArr[j++] = job;

      FileOutputFormat.setOutputPath(job, outputRoot);
      // HadoopUtil.delete(conf, outPath);
      
      job.setJarByClass(InsertNgramsDriver.class);
      
      job.setOutputKeyClass(IntWritable.class);
      job.setOutputValueClass(Record.class);
      
       FileInputFormat.addInputPath(job, inputStatus.getPath());
      
      job.setInputFormatClass(CSVNGramInputFormat.class);
      job.setMapperClass(InsertNGramsMapper.class);
      job.setCombinerClass(Reducer.class);
      job.setReducerClass(InsertNGramsReducer.class);
      job.setOutputFormatClass(SequenceFileOutputFormat.class);
      
      job.submit();
    }
    
    boolean allCompleted;
    do {
      Thread.sleep(10000);
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
