package yaboulna.fpm.postgresql;

import java.io.Closeable;
import java.io.IOException;
import java.sql.BatchUpdateException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Properties;

public class PerfMonKeyValueStore implements Closeable {

  protected static final String DEFAULT_DRIVER = "org.postgresql.Driver";
  protected static final String DEFAULT_CONNECTION_URL = "jdbc:postgresql://hops.cs.uwaterloo.ca:5433/";
  protected static final String DEFAULT_USER = "yaboulna";
  protected static final String DEFAULT_PASSWORD = "5#afraPG";
  protected static final String DEFAULT_DBNAME = "march";

  private final String monitoredClassName;
  private final String args;
  private final Connection conn;
  private final PreparedStatement insertStmt;
  private long batchCounter = 0;
  public int batchSizeToWrite = 105;

  public PerfMonKeyValueStore(String pMonitoredClassName, String pArgs) throws ClassNotFoundException, SQLException {
    monitoredClassName = pMonitoredClassName;
    args = pArgs;
    Class.forName(DEFAULT_DRIVER);

    String url = DEFAULT_CONNECTION_URL + DEFAULT_DBNAME;
    Properties props = new Properties();
    props.setProperty("user", DEFAULT_USER);// "uspritzer");
    props.setProperty("password", DEFAULT_PASSWORD); // "Spritz3rU");
// props.setProperty("ssl", "false");
// props.setProperty("prepareThreshold", "1");

    conn = DriverManager.getConnection(url, props);
    insertStmt = conn.prepareStatement(" INSERT INTO perf_mon VALUES('" + monitoredClassName + "', '" + args + "',?,?); ");

  }

  @Override
  public void close() throws IOException {
    try {
      try {
        insertStmt.executeBatch();
        insertStmt.close();
      } finally {
        conn.close();
      }
    } catch (SQLException e) {
      if(e instanceof BatchUpdateException){
        e = e.getNextException();
      }
      
      throw new IOException(e);
    }
  }

  public void storeKeyValue(String key, double value) throws SQLException {
    try{
    insertStmt.setString(1, key);
    insertStmt.setDouble(2, value);
    insertStmt.addBatch();
    if (++batchCounter % batchSizeToWrite == 0) {
      insertStmt.executeBatch();
      insertStmt.clearBatch();
      insertStmt.clearParameters();
    }
    }catch(BatchUpdateException e){
      throw e.getNextException();
    }
  }

  public long getNumStoredKeyValuePairs() {
    return batchCounter;
  }
}
