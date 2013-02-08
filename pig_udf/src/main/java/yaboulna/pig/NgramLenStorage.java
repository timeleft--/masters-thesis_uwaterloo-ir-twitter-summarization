package yaboulna.pig;

import java.io.IOException;
import java.sql.DriverManager;
import java.sql.SQLException;

import org.apache.hadoop.mapreduce.InputFormat;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.pig.data.DataType;
import org.apache.pig.parser.ParserException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * for epoch in (5min, 1hr, 1day, 1week, 1month)
 * do
 * CREATE UNLOGGED TABLE cnt_${epoch} (ngramLen int2, ngram text, date int4, epochStartMillis int8, cnt int4, pkey
 * serial
 * Primary key);
 * CREATE INDEX cnt_${epoch}_date ON cnt_${epoch}(date);
 * CREATE INDEX cnt_${epoch}_ngramLen ON cnt_${epoch}(ngramLen);
 * done
 * # HASH IS EXTREMELY SLOW: CREATE INDEX cnt_namespace ON cnt USING hash (namespace);
 */
public class NgramLenStorage extends SQLStorage<Long> {

  public NgramLenStorage(String dbname, String schema) throws ClassNotFoundException,
      ParserException {
    super(dbname, schema);
  }
  
  public static Logger LOG = LoggerFactory.getLogger(SQLStorage.class);

  private static final String NAMESPACE_COLNAME = "ngramLen";


  public class NgramLenReader extends SQLResultSetReader {

//    ResultSet resultSet;
//    ResultSetMetaData resultMetadata;
//    long expectedLen;
//    Statement rrStmt;

    public NgramLenReader() {
      fieldTypes.put(namespaceColName.toLowerCase(), DataType.INTEGER);
      fieldTypes.put("pkey".toLowerCase(), DataType.LONG);

    }
    
    @Override
    public void initialize(InputSplit split, TaskAttemptContext context) throws IOException,
        InterruptedException {
      try {
        if (conn == null) {
          conn = DriverManager.getConnection(url, props);
        }
        rrStmt = conn.createStatement();
        rrStmt.setFetchSize(DEFAULT_FETCH_SIZE);
        // Connection.setReadOnly(true) but the connection is shared with writer.. so nah

        expectedLen = split.getLength();

        sqlStrBuilder.setLength(0);
        sqlStrBuilder.append(" SELECT ");
        if (!"*".equals(projection)) {
          sqlStrBuilder.append(namespaceColName + ", ").append(projection).append(", pkey ");
        } else {
          sqlStrBuilder.append(projection);
        }
        sqlStrBuilder.append(" FROM ").append(tableName);
        startWhereClause(sqlStrBuilder);
        sqlStrBuilder.append(" AND ").append(split.getLocations()[0]).append(";");

        String sqlStr = sqlStrBuilder.toString();
        LOG.info("Executing SQL: " + sqlStr);
        resultSet = rrStmt.executeQuery(sqlStr);
        resultMetadata = resultSet.getMetaData();

        loadSchema();
        for (int i = 0; i < parsedSchema.getFields().length; ++i) {
          fieldTypes.put(parsedSchema.getFields()[i].getName().toLowerCase(),
              parsedSchema.getFields()[i].getType());
        }

      } catch (SQLException e) {
        throw new IOException(e);
      }

    }

//    @Override
//    public boolean nextKeyValue() throws IOException, InterruptedException {
//      try {
//        return resultSet.next();
//      } catch (SQLException e) {
//        throw new IOException(e);
//      }
//    }

    @Override
    public Long getCurrentKey() throws IOException, InterruptedException {
      try {
        return resultSet.getLong("pkey");
      } catch (SQLException e) {
        throw new IOException(e);
      }
    }

//    @Override
//    public Tuple getCurrentValue() throws IOException, InterruptedException {
//      try {
//        int tupleSize = resultMetadata.getColumnCount() - namespaceOffset;
//        Tuple result = TupleFactory.getInstance().newTuple(tupleSize);
//
//        for (int i = 0; i < tupleSize; ++i) {
//          int j = i + namespaceOffset;
//          String colName = resultMetadata.getColumnName(j);
//          switch (fieldTypes.get(colName)) {
//
//// case DataType.NULL:
//// result.set(i,resultSet.getNull(j, java.sql.Types.VARCHAR);
//// break;
//
//            case DataType.BOOLEAN :
//              result.set(i, resultSet.getBoolean(j));
//              break;
//
//            case DataType.INTEGER :
//              result.set(i, resultSet.getInt(j));
//              break;
//
//            case DataType.LONG :
//              result.set(i, resultSet.getLong(j));
//              break;
//
//            case DataType.FLOAT :
//              result.set(i, resultSet.getFloat(j));
//              break;
//
//            case DataType.DOUBLE :
//              result.set(i, resultSet.getDouble(j));
//              break;
//
//            case DataType.BYTEARRAY :
//              result.set(i, resultSet.getBytes(j));
//              break;
//
//            case DataType.CHARARRAY :
//              result.set(i, resultSet.getString(j));
//              break;
//
//            case DataType.BYTE :
//              result.set(i, resultSet.getByte(j));
//              break;
//
//            case DataType.MAP :
//            case DataType.TUPLE :
//            case DataType.BAG :
//              throw new RuntimeException("Cannot store a non-flat tuple "
//                  + "using DbStorage");
//
//            default :
//              throw new RuntimeException("Unknown datatype");
//
//          }
//        }
//        return result;
//      } catch (SQLException e) {
//        throw new IOException(e);
//      }
//    }
//    @Override
//    public float getProgress() throws IOException, InterruptedException {
//      try {
//        return 1.0f * resultSet.getRow() / expectedLen;
//      } catch (SQLException e) {
//        throw new IOException(e);
//      }
//    }
//
//    @Override
//    public void close() throws IOException {
//      try {
//        if (LOG.isDebugEnabled())
//          LOG.debug("Closing resultset and statement of recordreader");
//
//        if (resultSet != null) {
//          resultSet.close();
//        }
//        if (rrStmt != null) {
//          if (!conn.getAutoCommit())
//            rrStmt.close();
//          rrStmt = null;
//        }
//      } catch (SQLException e) {
//        throw new IOException(e);
//      }
//    }

  }

  public class NGramsCountsInputFormat extends SQLPartitionByDateInputFormat {

    @Override
    public NgramLenReader createRecordReader(InputSplit split, TaskAttemptContext context)
        throws IOException, InterruptedException {

      return new NgramLenReader();
    }

  }

  @Override
  public void setLocation(String location, Job job) throws IOException {
    super.setLocation(location, job);
  }

  @SuppressWarnings("rawtypes")
  @Override
  public InputFormat getInputFormat() throws IOException {
      return new NGramsCountsInputFormat();
  }

  @Override
  public String getNamespaceColName() {
    return NAMESPACE_COLNAME;
  }
  @Override
  public int getNamespaceOffset() {
    return 1; //ngramlen
  }
  @Override
  public int getTailHiddenColumns() {
    return 1; //pkey
  }

}
