package yaboulna.pig;

import java.io.IOException;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

import org.apache.hadoop.mapreduce.InputFormat;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.pig.data.DataType;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.apache.pig.parser.ParserException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * CREATE UNLOGGED TABLE cnt (namespace VARCHAR(10), ngram text, date int4, epochStartMillis int8, cnt int4, pkey serial
 * Primary key);
 * CREATE INDEX cnt_date ON cnt(date);
 * CREATE INDEX cnt_namespace ON cnt USING hash (namespace);
 */
public class NGramsCountStorage extends SQLStorage {

  public static Logger LOG = LoggerFactory.getLogger(SQLStorage.class);

  private static final String TABLE_NAME = "cnt";

  static {
    SCHEMA_MAP.put(TABLE_NAME, "ngram: chararray, date: int, epochStartMillis: long, cnt: int");
  }

  public class NGramsCountRecordReader extends RecordReader<Long, Tuple> {

    private static final int NAMESPACE_OFFSET = 2;
    ResultSet resultSet;
    ResultSetMetaData resultMetadata;
    long expectedLen;
    Statement rrStmt;

    @Override
    public void initialize(InputSplit split, TaskAttemptContext context) throws IOException,
        InterruptedException {
      try {
        if (conn == null) {
          conn = DriverManager.getConnection(url, props);
        }
        rrStmt = conn.createStatement();

        expectedLen = split.getLength();

        sqlStrBuilder.setLength(0);
        sqlStrBuilder.append(" SELECT ").append(projection);
        if (!"*".equals(projection)) {
          sqlStrBuilder.append(", pkey ");
        }
        sqlStrBuilder.append(" FROM ").append(tableName)
            .append(" WHERE namespace =").append(toQuotedStr(bitmapNamespace)).append(" AND ")
            .append(split.getLocations()[0]);
        // at the moment this is redundant, but it wouldn't hurt to have it in case partitioning changes
        if (!partitionWhereClause.isEmpty()) {
          sqlStrBuilder.append(" AND ").append(partitionWhereClause);
        }
        sqlStrBuilder.append(";");

        String sqlStr = sqlStrBuilder.toString();
        LOG.info("Executing SQL: " + sqlStr);
        resultSet = rrStmt.executeQuery(sqlStr);
        resultMetadata = resultSet.getMetaData();
      } catch (SQLException e) {
        throw new IOException(e);
      }

    }

    @Override
    public boolean nextKeyValue() throws IOException, InterruptedException {
      try {
        return resultSet.next();
      } catch (SQLException e) {
        throw new IOException(e);
      }
    }

    @Override
    public Long getCurrentKey() throws IOException, InterruptedException {
      try {
        return resultSet.getLong("pkey");
      } catch (SQLException e) {
        throw new IOException(e);
      }
    }

    @Override
    public Tuple getCurrentValue() throws IOException, InterruptedException {
      try {
        int tupleSize = resultMetadata.getColumnCount() - NAMESPACE_OFFSET;
        Tuple result = TupleFactory.getInstance().newTuple(tupleSize);

        for (int i = 0; i < tupleSize; ++i) {
          int j = i+NAMESPACE_OFFSET;
          switch (parsedSchema.getFields()[i].getType()) {
            
// case DataType.NULL:
// result.set(i,resultSet.getNull(j, java.sql.Types.VARCHAR);
// break;
            
            case DataType.BOOLEAN :
              result.set(i, resultSet.getBoolean(j));
              break;

            case DataType.INTEGER :
              result.set(i, resultSet.getInt(j));
              break;

            case DataType.LONG :
              result.set(i, resultSet.getLong(j));
              break;

            case DataType.FLOAT :
              result.set(i, resultSet.getFloat(j));
              break;

            case DataType.DOUBLE :
              result.set(i, resultSet.getDouble(j));
              break;

            case DataType.BYTEARRAY :
              result.set(i, resultSet.getBytes(j));
              break;

            case DataType.CHARARRAY :
              result.set(i, resultSet.getString(j));
              break;

            case DataType.BYTE :
              result.set(i, resultSet.getByte(j));
              break;

            case DataType.MAP :
            case DataType.TUPLE :
            case DataType.BAG :
              throw new RuntimeException("Cannot store a non-flat tuple "
                  + "using DbStorage");

            default :
              throw new RuntimeException("Unknown datatype");

          }
        }
        return result;
      } catch (SQLException e) {
        throw new IOException(e);
      }
    }

    @Override
    public float getProgress() throws IOException, InterruptedException {
      try {
        return 1.0f * resultSet.getRow() / expectedLen;
      } catch (SQLException e) {
        throw new IOException(e);
      }
    }

    @Override
    public void close() throws IOException {
      try {
        if (LOG.isDebugEnabled())
          LOG.debug("Closing resultset and statement of recordreader");

        if (resultSet != null) {
          resultSet.close();
        }
        if (rrStmt != null) {
          if (!conn.getAutoCommit())
            rrStmt.close();
          rrStmt = null;
        }
      } catch (SQLException e) {
        throw new IOException(e);
      }
    }

  }

  public class NGramsCountsInputFormat extends SQLPartitionByDateInputFormat {

    @Override
    public NGramsCountRecordReader createRecordReader(InputSplit split, TaskAttemptContext context)
        throws IOException, InterruptedException {

      return new NGramsCountRecordReader();
    }

  }

  @SuppressWarnings("rawtypes")
  @Override
  public InputFormat getInputFormat() throws IOException {
    if (schemaSelector.startsWith(TABLE_NAME)) {
      return new NGramsCountsInputFormat();
    } else {
      throw new UnsupportedOperationException(
          "Only the NGRamsCount Table is supported at the moment, schemaSelector: "
              + schemaSelector + " - tableName: "
              + tableName + " - namespace: " + bitmapNamespace);
    }
  }

  public NGramsCountStorage(String dbname) throws ClassNotFoundException, ParserException {
    super(dbname);
  }

}
