package yaboulna.pig;

import java.io.IOException;
import java.sql.DriverManager;
import java.sql.SQLException;

import org.apache.hadoop.mapreduce.InputFormat;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.pig.impl.util.Pair;
import org.apache.pig.parser.ParserException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * for pos in {1..70}
 * 
 */
public class ByPosStorage extends SQLStorage<Pair<Long, Byte>> {

  public static Logger LOG = LoggerFactory.getLogger(SQLStorage.class);


  public class ByPosReader extends SQLResultSetReader {

    
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
       
        sqlStrBuilder.append(projection);
       
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
    
    @Override
    public Pair<Long, Byte> getCurrentKey() throws IOException, InterruptedException {
      try {
        return new Pair<Long, Byte>(resultSet.getLong("id"),resultSet.getByte("pos"));
      } catch (SQLException e) {
        throw new IOException(e);
      }
    }
  }

  public class ByPosInputFormat extends SQLPartitionByDateInputFormat {

    @Override
    public ByPosReader createRecordReader(InputSplit split, TaskAttemptContext context)
        throws IOException, InterruptedException {

      return new ByPosReader();
    }

  }

  @Override
  public void setLocation(String location, Job job) throws IOException {
    super.setLocation(location, job);
  }

  @SuppressWarnings("rawtypes")
  @Override
  public InputFormat getInputFormat() throws IOException {
      return new ByPosInputFormat();
  }

  public ByPosStorage(String dbname, String schema) throws ClassNotFoundException, ParserException {
    super(dbname, schema);
  }

  @Override
  public String getNamespaceColName() {
    return "0"; //results in 0=0 in the where clause
  }
  
  @Override
  public int getNamespaceOffset() {
    return 0;
  }
  
  @Override
  public int getTailHiddenColumns() {
    return 0;
  }
}

