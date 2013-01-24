package yaboulna.pig;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.mapreduce.InputFormat;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.OutputCommitter;
import org.apache.hadoop.mapreduce.OutputFormat;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.RecordWriter;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.db.DBWritable;
import org.apache.pig.Expression;
import org.apache.pig.LoadFunc;
import org.apache.pig.LoadMetadata;
import org.apache.pig.LoadPushDown;
import org.apache.pig.ResourceSchema;
import org.apache.pig.ResourceSchema.ResourceFieldSchema;
import org.apache.pig.ResourceStatistics;
import org.apache.pig.StoreFuncInterface;
import org.apache.pig.backend.hadoop.executionengine.mapReduceLayer.PigSplit;
import org.apache.pig.data.Tuple;
import org.apache.pig.impl.logicalLayer.FrontendException;
import org.apache.pig.impl.util.UDFContext;
import org.apache.pig.impl.util.Utils;
import org.apache.pig.parser.ParserException;
import org.joda.time.DateTime;
import org.joda.time.Days;
import org.joda.time.MutableDateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

public abstract class SQLStorage extends LoadFunc
    implements
    StoreFuncInterface,
    LoadPushDown,
    LoadMetadata {

  public static class WhereClauseSplit extends InputSplit {

    String[] splitWhereClause;
    long avgLen;

    public WhereClauseSplit(String where, long avgLen) {
      splitWhereClause = new String[]{where};
      this.avgLen = avgLen;
    }

    @Override
    public long getLength() throws IOException, InterruptedException {
      return avgLen;
    }

    @Override
    public String[] getLocations() throws IOException, InterruptedException {
      return splitWhereClause;
    }

  }
  public enum Warnings {
    NONZERO_SQL_RETCODE, STMT_NOT_NULL_REINIT, CONN_NOT_NULL_REINIT, SCHEMA_NAMES_NOT_MATCHING, NON_CONTIGOUS_PARTITION
    // RESULTSET_NOT_NULL_REINIT,
  };

  protected static final String DEFAULT_SCHEMA_SELECTOR = "ngramsCnt";
  protected static final Map<String, String> SCHEMA_MAP = Maps.newHashMap();
// static {
// SCHEMA_MAP
// .put(
// "ngramsPos",
// "id: long, timeMillis: long, date: int, ngram: map[chararray], ngramLen: int, tweetLen: int,  pos: int");
// }
  protected static final String DEFAULT_DRIVER = "org.postgresql.Driver";
  protected static final String DEFAULT_CONNECTION_URL = "jdbc:postgresql://hops.cs.uwaterloo.ca:5433/spritzer";
  protected static final String DEFAULT_USER = "yaboulna";
  protected static final String DEFAULT_PASSWORD = "5#afraPG";
  protected static final int DEFAULT_BATCH_SIZE = 1000;
  private static final long DEFAULT_NUMRECS_PER_CHUNK = 10000;

// protected static Logger LOG = LoggerFactory.getLogger(PostgreSQLStorage.class);

  // Not inforced since we are partitioning by date to guarantee that no tweet will be split between two partitions
  protected long minNumRecordsPerChunk = DEFAULT_NUMRECS_PER_CHUNK;

  protected String tableName;
  protected Connection conn = null;
  protected Statement stmt = null;
  protected String projection = "*";
  protected String partitionWhereClause = "";

  protected String schemaSelector = null;
  protected ResourceSchema parsedSchema = null;
  protected String url;
  protected Properties props;
  protected int pendingBatchCount = 0;
  protected int batchSizeForCommit = DEFAULT_BATCH_SIZE;
  protected String udfcSignature;
  protected RecordReader<Long, DBWritable> reader;

  protected StringBuilder sqlStrBuilder = new StringBuilder();

  public SQLStorage() throws ClassNotFoundException, ParserException {
    Class.forName(DEFAULT_DRIVER);

    url = DEFAULT_CONNECTION_URL;
    props = new Properties();
    props.setProperty("user", DEFAULT_USER);// "uspritzer");
    props.setProperty("password", DEFAULT_PASSWORD); // "Spritz3rU");
// props.setProperty("ssl", "false");

  }

  @Override
  public ResourceSchema getSchema(String location, Job job) throws IOException {
    // TODO get the schema of the actual table from DB
    if (parsedSchema == null) {
      loadSchema();
    }
    return parsedSchema;
  }

  @Override
  public ResourceStatistics getStatistics(String location, Job job) throws IOException {
    // Not used by pig
    return null;
  }

  @Override
  public String[] getPartitionKeys(String location, Job job) throws IOException {
    try {

      ResultSet rs = stmt.executeQuery("SELECT DISTINCT date FROM " + location + ";");
      List<String> result = Lists.newLinkedList();
      while (rs.next()) {
        result.add(rs.getString(1));
      }
      rs.close();
      stmt.close();
      stmt = null;
      return result.toArray(new String[0]);
    } catch (SQLException e) {
      throw new IOException(e);
    }
  }

  @Override
  public void setPartitionFilter(Expression partitionFilter) throws IOException {
    partitionWhereClause = partitionFilter.toString(); // or +=
  }

  @Override
  public List<OperatorSet> getFeatures() {
    return Arrays.asList(OperatorSet.PROJECTION);
  }

  @Override
  public RequiredFieldResponse pushProjection(RequiredFieldList requiredFieldList)
      throws FrontendException {
    RequiredFieldResponse result = new RequiredFieldResponse(true);
    StringBuilder proj = new StringBuilder();
    for (RequiredField f : requiredFieldList.getFields()) {
      proj.append(", ").append(f.getAlias());
    }
    projection = proj.substring(1);
    return result;
  }

  @Override
  public String relToAbsPathForStoreLocation(String location, Path curDir) throws IOException {
    return location;
  }

  public class DBStorageOutputFormat extends OutputFormat<NullWritable, NullWritable> {

    @Override
    public void checkOutputSpecs(JobContext context) throws IOException,
        InterruptedException {
      // IGNORE
    }

    @Override
    public OutputCommitter getOutputCommitter(TaskAttemptContext context)
        throws IOException, InterruptedException {
      return new OutputCommitter() {

        @Override
        public void abortTask(TaskAttemptContext context) throws IOException {
          cleanupOnFailure("", null);
        }

        @Override
        public void commitTask(TaskAttemptContext context) throws IOException {
// if(resultSet != null){
// resultSet.close();
// }
          if (stmt != null) {
            try {
              stmt.executeBatch();
              conn.commit();
              stmt.close();
              conn.close();
              stmt = null;
              conn = null;
            } catch (SQLException e) {
// LOG.error("stmt.close", e);
              throw new IOException("stmt.close JDBC Error", e);
            }
          }
        }

        @Override
        public boolean needsTaskCommit(TaskAttemptContext context)
            throws IOException {
          return true;
        }

        @Override
        public void cleanupJob(JobContext context) throws IOException {
          // IGNORE
        }

        @Override
        public void setupJob(JobContext context) throws IOException {
          // IGNORE
        }

        @Override
        public void setupTask(TaskAttemptContext context) throws IOException {
          // IGNORE
        }
      };
    }

    @Override
    public RecordWriter<NullWritable, NullWritable> getRecordWriter(
        TaskAttemptContext context) throws IOException, InterruptedException {
      // We don't use a record writer to write to database
      return new RecordWriter<NullWritable, NullWritable>() {
        @Override
        public void close(TaskAttemptContext context) {
          // Noop
        }
        @Override
        public void write(NullWritable k, NullWritable v) {
          // Noop
        }
      };
    }

  }
  @SuppressWarnings("rawtypes")
  @Override
  public OutputFormat getOutputFormat() throws IOException {
    return new DBStorageOutputFormat();
  }

  @Override
  public void setStoreLocation(String location, Job job) throws IOException {
    tableName = location;
    setSchemaSelector(location);
  }

  @Override
  public void setLocation(String location, Job job) throws IOException {

    tableName = location;
    setSchemaSelector(location);
  }

  protected void setSchemaSelector(String location) {
    schemaSelector = location;
    UDFContext udfc = UDFContext.getUDFContext();
    Properties p =
        udfc.getUDFProperties(this.getClass(), new String[]{udfcSignature});
    p.setProperty("schemaSelector", location);
  }

  @Override
  public void checkSchema(ResourceSchema s) throws IOException {
    // Checks that the table contains such column (warn on name and exception on type),
    // and that they come in the correct order
    if (parsedSchema == null) {
      loadSchema();
    }
    ResourceFieldSchema[] otherFields = s.getFields();
    ResourceFieldSchema[] ourFields = parsedSchema.getFields();
    if (otherFields.length > ourFields.length) {
      throw new IOException("Wrong number of fields.. DB table contains only " + ourFields.length);
    }
    for (int i = 0; i < otherFields.length; ++i) {
      if (!otherFields[i].getName().equals(ourFields[i].getName())) {
        warn("Non matching names - pig schema: " + otherFields[i].getName() + " , DB schema: "
            + ourFields[i].getName(), Warnings.SCHEMA_NAMES_NOT_MATCHING);
      }
      if (otherFields[i].getType() != ourFields[i].getType()) {
        throw new IOException("Non matching types in schema field ( " + i + ") - pig type: " +
            otherFields[i].getType() + ", DB type: " + ourFields[i].getType());
      }
    }

  }

  @Override
  public void putNext(Tuple t) throws IOException {

    sqlStrBuilder.setLength(0);
    sqlStrBuilder.append(" INSERT INTO " + tableName + " VALUES ("
        + toQuotedStr(t.get(0)));
    for (int i = 1; i < t.size(); ++i) {
      sqlStrBuilder.append(", ").append(toQuotedStr(t.get(i)));
    }
    sqlStrBuilder.append(");");

    try {
      stmt.addBatch(sqlStrBuilder.toString());
      if (++pendingBatchCount == batchSizeForCommit) {
        pendingBatchCount = 0;
        int[] retCodes = stmt.executeBatch();
        for (int rc : retCodes) {
          if (rc != 0) {
            warn("Non-Zero return code: " + rc, Warnings.NONZERO_SQL_RETCODE);
          }
        }
        stmt.clearBatch();
      }
    } catch (SQLException e) {
      throw new IOException(e);
    }
  }

  protected String toQuotedStr(Object object) {
    String result = object.toString();
    if (object instanceof String) { // DataType.findType(field)
      result = "'" + result + "'";
    }
    return result;
  }

  @Override
  public void setStoreFuncUDFContextSignature(String signature) {
    udfcSignature = signature;
  }

  protected void loadSchema() throws ParserException {
    // Get the schema string from the UDFContext object.
    if (schemaSelector == null) {
      UDFContext udfc = UDFContext.getUDFContext();
      Properties p =
          udfc.getUDFProperties(this.getClass(), new String[]{udfcSignature});
      schemaSelector = p
          .getProperty("schemaSelector", DEFAULT_SCHEMA_SELECTOR);
      // TODO when generalizing: if schemaSelectpr == null throw exception
    }
    parsedSchema = new ResourceSchema(Utils.getSchemaFromString(SCHEMA_MAP.get(schemaSelector)));
  }

  @Override
  public void cleanupOnFailure(String location, Job job) throws IOException {
    try {
// if(resultSet != null){
// resultSet.close();
// }
      if (stmt != null) {
        stmt.close();
        stmt = null;
      }
      if (conn != null) {
        conn.rollback();
        conn.close();
        conn = null;
      }
    } catch (SQLException sqe) {
      throw new IOException(sqe);
    }
  }

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Override
  public void prepareToRead(RecordReader reader, PigSplit split) throws IOException {
// if (resultSet != null) {
// warn("Result set not null and prepare to read is called. Closing.",
// Warnings.RESULTSET_NOT_NULL_REINIT);
// resultSet.close();
// }
    prepare();
    this.reader = reader;

  }

  @SuppressWarnings("rawtypes")
  @Override
  public void prepareToWrite(RecordWriter writer) throws IOException {
    prepare();
  }

  protected void prepare() throws IOException {
    try {
      if (stmt != null) {
        int[] pendingBatchResults = stmt.executeBatch();
        warn("PrepareToWrite called while stmt is not null. Executed pending batches ("
            + pendingBatchResults.length + ")", Warnings.STMT_NOT_NULL_REINIT);
// LOG.warn( );
        stmt = null;
      }
      if (conn != null) {
        conn.commit();
        warn("PrepareToWrote called while conn is not null. Commited",
            Warnings.CONN_NOT_NULL_REINIT);
// LOG.warn();
        conn = null;
      }
      loadSchema();
      conn = DriverManager.getConnection(url, props);
      stmt = conn.createStatement();
    } catch (SQLException e) {
      throw new IOException(e);
    }

  }
  @Override
  public Tuple getNext() throws IOException {
    try {
      if (reader.nextKeyValue()) {
// reader.getCurrentKey()
        Tuple value = (Tuple) reader.getCurrentValue();
        return value;
      } else {
        return null;
      }
    } catch (InterruptedException e) {
      throw new IOException(e);
    }

  }

  protected static final DateTimeFormatter dateFmt = DateTimeFormat.forPattern("yyMMdd");
  public abstract class SQLPartitionByDateInputFormat extends InputFormat<Long, Tuple> {

    protected final MutableDateTime date = new MutableDateTime();

    @Override
    public List<InputSplit> getSplits(JobContext context) throws IOException, InterruptedException {

      ResultSet results = null;
      try {
        results = stmt
            .executeQuery(" SELECT COUNT(*), COUNT(DISTINCT date), MIN(date), MAX(date) FROM "
                + tableName
                + (partitionWhereClause.isEmpty() ? "; " : " WHERE " + partitionWhereClause + " ;"));
        results.next();

        long countRecs = results.getLong(1);
        long countDates = results.getLong(2);

        long avgLen = countRecs / countDates;

// use this if you exchange date by pkey
// long chunks = context.getConfiguration().getInt("mapred.map.tasks", 1);
// long chunkSize = (count / chunks);
// if (chunkSize < minNumRecordsPerChunk) {
// if (count > chunkSize) {
// chunkSize = minNumRecordsPerChunk;
// chunks = count / chunkSize;
// } else {
// chunkSize = count;
// chunks = 1;
// }
// }

        long min = results.getLong(3);
        long max = results.getLong(4);

        results.close();
        stmt.close();
        stmt = null;

        List<InputSplit> splits = new ArrayList<InputSplit>();

        // The pkey blind split that guarantees equal chunk, but nothing about the chunk boundaries
// // Split the rows into n-number of chunks and adjust the last chunk
// // accordingly
// for (int i = 0; i < chunks; i++) {
// DBInputSplit split;
//
// if ((i + 1) == chunks)
// split = new DBInputSplit(i * chunkSize, count);
// else
// split = new DBInputSplit(i * chunkSize, (i * chunkSize)
// + chunkSize);
//
// splits.add(split);
// }
        DateTime minDate = dateFmt.parseDateTime("" + min);
        DateTime maxDate = dateFmt.parseDateTime("" + max);
        int daysDiff = Days.daysBetween(minDate, maxDate).getDays(); // .toDateMidnight()

        if (countDates != daysDiff + 1) {
          warn("Some dates are missing in the partition " + partitionWhereClause
              + " and thus some jobs will have empty input", Warnings.NON_CONTIGOUS_PARTITION);
        }

        date.setDate(minDate);
        for (int i = 0; i <= daysDiff; ++i) {
          splits.add(new WhereClauseSplit(" date = " + dateFmt.print(date), avgLen));
          date.addDays(1);
        }

        return splits;
      } catch (SQLException e) {
        throw new IOException("Got SQLException", e);
      } finally {
        try {
          if (results != null) {
            results.close();
          }
        } catch (SQLException e1) {
        }
        try {
          if (stmt != null) {
            stmt.close();
          }
        } catch (SQLException e1) {
        }
      }
    }
  }
}
