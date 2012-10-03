package ca.uwaterloo.yaboulna;

import java.util.Arrays;
import java.util.Set;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.PathFilter;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.SortedMapWritable;
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

import com.google.common.collect.Sets;
import com.twitter.corpus.data.CSVTweetInputFormat;

public final class TimedCountsDriver extends AbstractJob implements Tool {
  
  private static final Logger LOG = LoggerFactory.getLogger(TimedCountsDriver.class);
  private static final String TIMED_PARALLEL_COUNTING_PARAMS = "TPCParams";
  
//Generated using:
 // cat 2011.topics.MB1-50.txt | grep title | tr ' ' '\n' | tr '[A-Z]' '[a-z]' | tr -dc
 // '[A-Za-z0-9\n]' | sed 's/.*/"&",/'
 public static Set<String> watchedTerms = Sets.newCopyOnWriteArraySet(Arrays.asList(
     "rt",
     
     "i",
     "love",
     "you",
     "hate",
     "my",
     "class",
     "education",
     
     "freedom",
     "speech",
     "blasphemie",
     "mohammed",
     "video",
     "embassy",
     "us",
     "islam",
     "#muslimrage",
     "muslim",
     "rage",
     "egypt",
     "libya",
     "jihadist",
     "jihad",
     
     "iphone",
     "iphone5",
     "ios",
     "ios6",
     "samsung",
     "galaxy",
     "s3",
     "siii",
     "maps",
     
     "mona",
     "eltahawy",
     
     "barack",
     "obama",
     "@barackobama",
     "romney",
     "mitt",
     "@mittromney",
     
     "bbc",
     "world",
     "service",
     "staff",
     "cuts",
     
     "2022",
     "fifa",
     "soccer",
     
     "haiti",
     "aristide",
     "return",
     
     "mexico",
     "drug",
     "war",
     
     "nist",
     "computer",
     "security",
     
     "nsa",
     
     "pakistan",
     "diplomat",
     "arrest",
     "murder",
     
     "phone",
     "hacking",
     "british",
     "politicians",
     
     "toyota",
     "recall",
     
     "egyptian",
     "protesters",
     "attack",
     "museum",
     
     "kubica",
     "crash",
     
     "assange",
     "nobel",
     "peace",
     "nomination",
     
     "oprah",
     "winfrey",
     "halfsister",
     // I manually added this
     "half", "sister",
     
     "release",
     "of",
     "the",
     "rite",
     
     "thorpe",
     "return",
     "in",
     "2012",
     "olympics",
     
     "release",
     "of",
     "known",
     "and",
     "unknown",
     
     "white",
     "stripes",
     "breakup",
     
     "william",
     "and",
     "kate",
     "fax",
     "savethedate",
     
     "cuomo",
     "budget",
     "cuts",
     
     "taco",
     "bell",
     "filling",
     "lawsuit",
     
     "emanuel",
     "residency",
     "court",
     "rulings",
     
     "healthcare",
     "law",
     "unconstitutional",
     
     "amtrak",
     "train",
     "service",
     
     "super",
     "bowl",
     "seats",
     
     "tsa",
     "airport",
     "screening",
     
     "us",
     "unemployment",
     
     "reduce",
     "energy",
     "consumption",
     
     "detroit",
     "auto",
     "show",
     
     "global",
     "warming",
     "and",
     "weather",
     
     "keith",
     "olbermann",
     "new",
     "job",
     
     "special",
     "olympics",
     "athletes",
     
     "state",
     "of",
     "the",
     "union",
     
     "and",
     "jobs",
     
     "dog",
     "whisperer",
     "cesar",
     "millans",
     "techniques",
     
     "msnbc",
     "rachel",
     "maddow",
     
     "sargent",
     "shriver",
     "tributes",
     
     "moscow",
     "airport",
     "bombing",
     
     "giffords",
     "recovery",
     
     "protests",
     "in",
     "jordan",
     
     "egyptian",
     "curfew",
     
     "beck",
     "attacks",
     "piven",
     
     "obama",
     "birth",
     "certificate",
     
     "holland",
     "iran",
     "envoy",
     "recall",
     
     "kucinich",
     "olive",
     "pit",
     "lawsuit",
     
     "white",
     "house",
     "spokesman",
     "replaced",
     
     "political",
     "campaigns",
     "and",
     "social",
     "media",
     
     "bottega",
     "veneta",
     
     "organic",
     "farming",
     "requirements",
     
     "egyptian",
     "evacuation",
     
     "carbon",
     "monoxide",
     "law",
     
     "war",
     "prisoners",
     "hatch",
     "act"));
  
  
  private TimedCountsDriver() {
  }
  
  public static void main(String[] args) throws Exception {
    ToolRunner.run(new Configuration(), new TimedCountsDriver(), args);
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
    
    conf.set(TIMED_PARALLEL_COUNTING_PARAMS, params.toString());
    
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
    
    job.setJarByClass(TimedCountsDriver.class);
    
    job.setOutputKeyClass(LongWritable.class);
    job.setOutputValueClass(SortedMapWritable.class);
    
    // TODO: Partition the input on several jobs??
    for (FileStatus startStatus : fs.listStatus(inputDir)) {
      for (FileStatus endStatus : fs.listStatus(startStatus.getPath(),new PathFilter() {
        public boolean accept(Path p) {
          return !p.getName().startsWith(".");
//Actually they don't          return p.getName().toLowerCase().endsWith(".csv");
        }
      })) {
        FileInputFormat.addInputPath(job, endStatus.getPath());
      }
    }
    
    job.setInputFormatClass(CSVTweetInputFormat.class);
    job.setMapperClass(TimedCountsMapper.class);
    job.setCombinerClass(TimedCountsReducer.class);
    job.setReducerClass(TimedCountsReducer.class);
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
