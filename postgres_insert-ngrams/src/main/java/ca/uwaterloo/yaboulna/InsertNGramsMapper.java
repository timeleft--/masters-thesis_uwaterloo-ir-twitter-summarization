package ca.uwaterloo.yaboulna;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.Mapper;

import ca.uwaterloo.yaboulna.CSVNGramRecordReader.Record;

public class InsertNGramsMapper extends
    Mapper<IntWritable, Record, IntWritable, Record> {

  
  private static final IntWritable DUMMY = new IntWritable(-1);

  // Just the default identity mapper
protected void map(IntWritable key, Record value, org.apache.hadoop.mapreduce.Mapper<IntWritable,Record,IntWritable,Record>.Context context) throws java.io.IOException ,InterruptedException {
 context.write(DUMMY, value);  
};
}
