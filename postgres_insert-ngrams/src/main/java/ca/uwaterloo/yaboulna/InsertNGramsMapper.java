package ca.uwaterloo.yaboulna;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.Mapper;

import ca.uwaterloo.yaboulna.CSVNGramRecordReader.Record;

public class InsertNGramsMapper extends
    Mapper<IntWritable, Record, IntWritable, Record> {

  // Just the default identity mapper

}
