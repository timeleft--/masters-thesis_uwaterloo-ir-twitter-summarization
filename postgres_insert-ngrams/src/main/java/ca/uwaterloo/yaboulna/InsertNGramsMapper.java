package ca.uwaterloo.yaboulna;

import org.apache.hadoop.mapreduce.Mapper;

import ca.uwaterloo.yaboulna.CSVNGramRecordReader.Record;
import edu.umd.cloud9.io.pair.PairOfIntLong;

public class InsertNGramsMapper extends
    Mapper<PairOfIntLong, Record, PairOfIntLong, Record> {

  // Just the default identity mapper

}
