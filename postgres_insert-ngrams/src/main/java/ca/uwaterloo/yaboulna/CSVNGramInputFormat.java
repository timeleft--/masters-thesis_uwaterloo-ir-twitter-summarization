package ca.uwaterloo.yaboulna;

import java.io.IOException;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.input.CombineFileInputFormat;

import ca.uwaterloo.yaboulna.CSVNGramRecordReader.Record;

public class CSVNGramInputFormat extends CombineFileInputFormat<IntWritable, Record>  {
  
  @Override
  public RecordReader<IntWritable, Record> createRecordReader(InputSplit split, TaskAttemptContext context)
      throws IOException {
    return new CSVNGramRecordReader();
  }
  
  @Override
  protected boolean isSplitable(JobContext context, Path file) {
    return false;
  }
  
}
