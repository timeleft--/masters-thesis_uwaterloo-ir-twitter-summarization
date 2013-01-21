package ca.uwaterloo.yaboulna;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.util.regex.Pattern;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.input.CombineFileSplit;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import ca.uwaterloo.yaboulna.CSVNGramRecordReader.Record;

public class CSVNGramRecordReader extends RecordReader<IntWritable, Record> {
  private static final Pattern commaSplit = Pattern.compile(",");
  private static final Logger LOG = LoggerFactory.getLogger(CSVNGramRecordReader.class);
  private static final Pattern tabSplit = Pattern.compile("\\t");

  public static class Record implements Writable {

    // id, FLATTEN(yaboulna.pig.DateFromSnowflake(id)) as (timeMillis, date),
// FLATTEN(yaboulna.pig.TweetTokenizer(tweet)) as (ngram, ngramLen, tweetLen, positions);
    long id;
    long timeMillis;
    int date;
    String[] ngram;
    int ngramLen;
    int tweetLen;
    int position;

    @Override
    public void readFields(DataInput datain) throws IOException {
      id = datain.readLong();
      timeMillis = datain.readLong();
      date = datain.readInt();
      ngram = commaSplit.split(datain.readUTF());
      ngram[0] = ngram[0].substring(1); // the opening bracket
      ngram[ngram.length - 1] = ngram[ngram.length - 1].substring(0, ngram[ngram.length - 1].length() - 1); // closing bracket
      ngramLen = datain.readInt();
      tweetLen = datain.readInt();
      position = datain.readInt();
    }

    @Override
    public void write(DataOutput dataout) throws IOException {
      dataout.writeLong(id);
      dataout.writeLong(timeMillis);
      dataout.writeInt(date);

      StringBuilder ngramsBuilder = new StringBuilder("(");
      ngramsBuilder.append(ngram[0]);
      for (int i = 1; i < ngram.length; ++i) {
        ngramsBuilder.append(", ").append(ngram[i]);
      }
      ngramsBuilder.append(")");
      dataout.writeUTF(ngramsBuilder.toString());
//      dataout.write... TODO: can I just serialize the array?

      dataout.writeInt(ngramLen);
      dataout.writeInt(tweetLen);
      dataout.writeInt(position);
    }

    public static Record read(DataInput in) throws IOException {
      Record ret = new Record();
      ret.readFields(in);
      return ret;
    }
  }

  private FSDataInputStream reader;
  // private TaskAttemptContext context;
  private IntWritable myKey;
  private Record myValue;

  private Configuration conf;

  private int currFile = 0;

  private FileSystem fs;
  private CombineFileSplit split;


  private boolean openNextFile() throws IOException {
    if (reader != null) {
      reader.close();
    }
    if (currFile >= split.getNumPaths()) {
      return false;
    }
    Path p = split.getPath(currFile++);
    LOG.info("Opening path: {}, qualified: {}", p, fs.makeQualified(p));
    reader = fs.open(fs.makeQualified(p));
// No header in these files reader.readLine();
    return true;
  }

  @SuppressWarnings("deprecation")
  @Override
  public boolean nextKeyValue() throws IOException, InterruptedException {
    myKey = null;
    myValue = null;
    String line;
    while ((line = reader.readLine()) == null) {
      if (!openNextFile()) {
        return false;
      }
    }

    String[] fields = tabSplit.split(line);
    if (fields.length < 7) {
      return nextKeyValue();
    }
    try {
      Record rec = new Record();

      rec.id = Long.parseLong(fields[0]);
      rec.timeMillis = Long.parseLong(fields[1]);
      rec.date = Integer.parseInt(fields[2]);
      rec.ngram = commaSplit.split(fields[3]);

      rec.ngram[0] = rec.ngram[0].substring(1); // the opening bracket
      rec.ngram[rec.ngram.length - 1] = rec.ngram[rec.ngram.length - 1].substring(0,
          rec.ngram[rec.ngram.length - 1].length() - 1); // closing bracket

      rec.ngramLen = Integer.parseInt(fields[4]);
      rec.tweetLen = Integer.parseInt(fields[5]);
      rec.position = Integer.parseInt(fields[6]);

      myKey = new IntWritable(rec.date);

      myValue = rec;

      return true;

    } catch (Exception ex) {
      LOG.error(ex.getMessage(), ex);
      return nextKeyValue();
    }

  }

  @Override
  public void initialize(InputSplit pSplit, TaskAttemptContext pContext) throws IOException,
      InterruptedException {
    initialize(pSplit, pContext.getConfiguration());
  }

  public void initialize(InputSplit pSplit, Configuration pConf) throws IOException,
      InterruptedException {
    split = ((CombineFileSplit) pSplit);
    conf = pConf;
    fs = FileSystem.get(conf);
    openNextFile();
  }

  @Override
  public IntWritable getCurrentKey() throws IOException, InterruptedException {
    return myKey;
  }

  @Override
  public Record getCurrentValue() throws IOException, InterruptedException {
    return myValue;
  }

  @Override
  public float getProgress() throws IOException, InterruptedException {
    return 1.0f * currFile / split.getNumPaths();
  }

  @Override
  public void close() throws IOException {
    if (reader != null) {
      reader.close();
    }
  }
}
