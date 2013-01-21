package ca.uwaterloo.yaboulna;

import java.io.IOException;
import java.sql.BatchUpdateException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapreduce.Reducer;

import ca.uwaterloo.yaboulna.CSVNGramRecordReader.Record;
import edu.umd.cloud9.io.pair.PairOfIntLong;

/**
 * sums up the item count and output the item and the count This can also be used as a local Combiner.
 * A simple summing reducer
 */
public class InsertNGramsReducer extends
    Reducer<PairOfIntLong, Record, PairOfIntLong, Record> {

  protected void reduce(IntWritable keyIn, java.lang.Iterable<Record> valuesIn,
      org.apache.hadoop.mapreduce.Reducer<PairOfIntLong, Record, PairOfIntLong, Record>.Context ctxt)
      throws IOException, InterruptedException {
    ctxt.setStatus("Processing day: " + keyIn.get());
    try {
      Class.forName("org.postgresql.Driver");

      String url = "jdbc:postgresql://hops.cs.uwaterloo.ca:5433/spritzer";
      Properties props = new Properties();
      props.setProperty("user", "yaboulna");// "uspritzer");
      props.setProperty("password", "5#afraPG"); // "Spritz3rU");
// props.setProperty("ssl", "false");
      Connection conn = DriverManager.getConnection(url, props);

// conn.setAutoCommit(false);

      Statement stmt = conn.createStatement();
      try {
// String ngramTableName = "ngrams";
// String htagTableName = "htags";
        String ngramTableName = "ngrams_" + keyIn.get();
        String htagTableName = "htags_" + keyIn.get();

        // UNLOGGED
        stmt.execute("CREATE  TABLE "
            + ngramTableName
            + " ( id int8, timeMillis int8, date int4, ngram text[], ngramLen int2, tweetLen int2, position int2, pkey serial Primary key)");
// stmt.execute("CREATE INDEX " +ngramTableName+"_date ON " + ngramTableName +"(date)");

        // UNLOGGED
        stmt.execute("CREATE  TABLE "
            + htagTableName
            + " ( id int8, timeMillis int8, date int4, ngram text[], ngramLen int2, tweetLen int2, position int2, pkey serial Primary key)");
// stmt.execute("CREATE INDEX " +htagTableName+"_date ON " + htagTableName +"(date)");

        ctxt.setStatus("Created tables: " + ngramTableName + ", " + htagTableName);

        int count = 0;
        for (Record value : valuesIn) {
          String tablename;
          if (value.position == value.tweetLen) {
            // hashtag
            tablename = htagTableName;
          } else {
            tablename = ngramTableName;
          }
          stmt.addBatch("INSERT INTO " + tablename + " VALUES("
              + value.id + ","
              + value.timeMillis + ","
              + value.date + ","
              + toSQLArray(value.ngram) + ","
              + value.ngramLen + ","
              + value.tweetLen + ","
              + value.position
              + ")");
          if (++count > 1000) {
            count = 0;
            stmt.executeBatch();
            stmt.clearBatch();
// stmt.clearParameters();
            ctxt.setStatus("Excuted batch");
          }

          // but I'm afraid this will slow things down
// // as a side effect, we can also dump the db
// ctxt.write(keyIn, value);

        }
        stmt.executeBatch();
        ctxt.setStatus("Excuted last batch.. committing");
      } finally {
        stmt.close();
        if (!conn.getAutoCommit())
          conn.commit();
        conn.close();
      }
    } catch (BatchUpdateException e) {
      throw new IOException(e.getNextException());
    } catch (SQLException e) {
      throw new IOException(e);
    } catch (ClassNotFoundException e) {
      throw new IOException(e);
    }

  };

  StringBuilder sqlArrayBuilder = new StringBuilder("ARRAY[");
  private String toSQLArray(String[] ngram) {
    sqlArrayBuilder.setLength(6);
    sqlArrayBuilder.append('\'').append(ngram[0].trim()).append('\'');
    for (int i = 1; i < ngram.length; ++i) {
      sqlArrayBuilder.append(", '").append(ngram[i].trim()).append('\'');
    }
    sqlArrayBuilder.append(']');
    return sqlArrayBuilder.toString();
  }

  public static void main(String[] args) throws ClassNotFoundException, SQLException {
    InsertNGramsReducer obj = new InsertNGramsReducer();

    Class.forName("org.postgresql.Driver");

    String url = "jdbc:postgresql://hops.cs.uwaterloo.ca:5433/spritzer";
    Properties props = new Properties();
    props.setProperty("user", "yaboulna");
    props.setProperty("password", "5#afraPG");
// props.setProperty("ssl", "false");
    Connection conn = DriverManager.getConnection(url, props);

// conn.setAutoCommit(false);

    Statement stmt = conn.createStatement();
    try {
      stmt.execute("DROP TABLE test");
      stmt.execute("CREATE TABLE test(arr text[], pkey serial Primary key)");

      String[] ngrams = {"you", "your mother", "your dog"};
      stmt.addBatch("INSERT INTO test VALUES(" + obj.toSQLArray(ngrams) + ")");

      ResultSet ret = stmt.executeQuery("Select * from test");
      while (ret.next()) {
        System.out.println(ret.getArray(1));
      }

      String[] ngrams2 = {"me", "my father", "my cat"};
      stmt.addBatch("INSERT INTO test VALUES(" + obj.toSQLArray(ngrams2) + ")");

      ret = stmt.executeQuery("Select * from test");
      while (ret.next()) {
        System.out.println(ret.getArray(1));
      }
      try {
        stmt.executeBatch();
      } catch (BatchUpdateException e) {
        throw new SQLException(e.getNextException());
      }
      ret = stmt.executeQuery("Select * from test");
      while (ret.next()) {
        System.out.println(ret.getArray(1));
      }
      stmt.clearBatch();
    } finally {
      stmt.close();
      if (!conn.getAutoCommit())
        conn.commit();
      conn.close();
    }
  }
}