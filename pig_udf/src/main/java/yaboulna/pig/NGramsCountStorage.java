package yaboulna.pig;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.hadoop.mapreduce.InputFormat;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.pig.data.DataType;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.apache.pig.parser.ParserException;

public class NGramsCountStorage extends SQLStorage {
  private static final String TABLE_NAME = "ngramsCnt";

  static {
    SCHEMA_MAP.put(TABLE_NAME, "ngram: chararray, epochStartMillis: long, date: int, cnt: int");
  }

  public class NGramsCountRecordReader extends RecordReader<Long, Tuple> {

    ResultSet resultSet;
    ResultSetMetaData resultMetadata;
    long expectedLen;

    @Override
    public void initialize(InputSplit split, TaskAttemptContext context) throws IOException,
        InterruptedException {
      try {
        expectedLen = split.getLength();

        sqlStrBuilder.setLength(0);
        sqlStrBuilder.append(" SELECT ").append(projection);
        if (!"*".equals(projection)) {
          sqlStrBuilder.append(", pkey ");
        }
        sqlStrBuilder.append(" FROM ").append(tableName)
            .append(" WHERE ").append(split.getLocations()[0]);
        if (!partitionWhereClause.isEmpty()) {
          sqlStrBuilder.append(" AND ").append(partitionWhereClause);
        }
        sqlStrBuilder.append(";");

        resultSet = stmt.executeQuery(sqlStrBuilder.toString());
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
        int tupleSize = resultMetadata.getColumnCount() - 1;
        Tuple result = TupleFactory.getInstance().newTuple(tupleSize);

        for (int i = 0; i < tupleSize; ++i) {
          switch (parsedSchema.getFields()[i].getType()) {
// case DataType.NULL:
// result.set(i,resultSet.getNull(i, java.sql.Types.VARCHAR);
// break;

            case DataType.BOOLEAN :
              result.set(i, resultSet.getBoolean(i));
              break;

            case DataType.INTEGER :
              result.set(i, resultSet.getInt(i));
              break;

            case DataType.LONG :
              result.set(i, resultSet.getLong(i));
              break;

            case DataType.FLOAT :
              result.set(i, resultSet.getFloat(i));
              break;

            case DataType.DOUBLE :
              result.set(i, resultSet.getDouble(i));
              break;

            case DataType.BYTEARRAY :
              result.set(i, resultSet.getBytes(i));
              break;

            case DataType.CHARARRAY :
              result.set(i, resultSet.getString(i));
              break;

            case DataType.BYTE :
              result.set(i, resultSet.getByte(i));
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
        if (resultSet != null) {
          resultSet.close();
        }
        if (stmt != null) {
          stmt.close();
          stmt = null;
        }
      } catch (SQLException e) {
        throw new IOException(e);
      }
    }

  }

  public static class ModuloSplit extends InputSplit {

    final long len;
    final String[] splitWhereClause;

    public ModuloSplit(int i, int chunks, long chunkSize) {
      len = chunkSize;
      splitWhereClause = new String[]{" pkey % " + chunks + " == " + i + " "};
    }

    @Override
    public long getLength() throws IOException, InterruptedException {
      return len;
    }

    @Override
    public String[] getLocations() throws IOException, InterruptedException {
      return splitWhereClause;
    }

  }

  public class NGramsCountsInputFormat extends InputFormat<Long, Tuple> {

    @Override
    public List<InputSplit> getSplits(JobContext context) throws IOException, InterruptedException {

      ResultSet results = null;
      try {
        results = stmt.executeQuery("SELECT COUNT(*) FROM " + tableName);
        results.next();

        long count = results.getLong(1);
        int chunks = context.getConfiguration().getInt("mapred.map.tasks", 1);
        long chunkSize = (count / chunks);

        results.close();
        stmt.close();
        stmt = null;

        List<InputSplit> splits = new ArrayList<InputSplit>();

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
        for (int i = 0; i < chunks; i++) {
          splits.add(new ModuloSplit(i, chunks, chunkSize));
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

    @Override
    public NGramsCountRecordReader createRecordReader(InputSplit split, TaskAttemptContext context)
        throws IOException, InterruptedException {

      return new NGramsCountRecordReader();
    }

  }

  public NGramsCountStorage() throws ClassNotFoundException, ParserException {
    super();
  }

  @SuppressWarnings("rawtypes")
  @Override
  public InputFormat getInputFormat() throws IOException {
    if (TABLE_NAME.equals(schemaSelector)) {
      return new NGramsCountsInputFormat();
    } else {
      throw new UnsupportedOperationException(
          "Only the NGRamsCount Table is supported at the moment");
    }
  }

}
