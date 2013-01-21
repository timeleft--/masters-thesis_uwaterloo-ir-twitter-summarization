package ca.uwaterloo.yaboulna;

import java.io.IOException;
import java.sql.BatchUpdateException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.PathFilter;
import org.apache.hadoop.mapreduce.lib.input.CombineFileSplit;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import ca.uwaterloo.yaboulna.CSVNGramRecordReader.Record;

public class InsertFromHDFS  {
  private static Logger LOG = LoggerFactory.getLogger(InsertFromHDFS.class);
  
  public static void main(String[] args) throws IOException, InterruptedException {
    Path inputRoot = new Path(args[0]); //getInputPath();
    Path outputRoot = new Path(args[1]); //getOutputPath();
    
//    FileSystem fs = inputRoot.getFileSystem(new org.apache.hadoop.conf.Configuration())
    Configuration conf = new Configuration();
    FileSystem fs = FileSystem.get(conf);
//    File[] inputFiles = FileUtils.listFiles(FileUtils.toFile(inputRoot.toUri().toURL()),noHiddenOrLogs,noHiddenOrLogs).toArray(new File[0]);
//        FileUtils.listFiles(FileUtils.toFile(inputRoot.toUri().toURL()),
//        noHiddenOrLogs, noHiddenOrLogs).toArray(new File[0]);
//    Arrays.sort(inputFolders);
    
    if (fs.exists(outputRoot)) {
      throw new IllegalArgumentException(
          "Output path already exists.. please delete it yourself: "
              + outputRoot);
    }
    
    FileStatus[] inputStati = fs.listStatus(inputRoot,new PathFilter(){

      @Override
      public boolean accept(Path p) {
        String name = p.getName();
        return !(name.charAt(0) == '.' || name.charAt(0) == '_');
      }});
    
    Path[] inputPaths = new Path[inputStati.length];
    long[] lengths = new long[inputStati.length];
    for(int i=0; i< inputStati.length; ++i){
      inputPaths[i] = inputStati[i].getPath();
      lengths[i] = inputStati[i].getLen();
      if (LOG.isDebugEnabled())
        LOG.debug(i + ": Added path " + inputPaths[i]); // + " with length " + lengths[i]);
    }
    
    CombineFileSplit allFiles = new CombineFileSplit(inputPaths,lengths);
    CSVNGramRecordReader recordReader = new CSVNGramRecordReader();
    recordReader.initialize(allFiles, conf);
    
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
        
        
          LOG.info("Connected to database " + url);
        
        String ngramTableName = "ngrams";
        String htagTableName = "htags";
// String ngramTableName = "ngrams_" + keyIn.get();
// String htagTableName = "htags_" + keyIn.get();
//
// // UNLOGGED
// stmt.execute("CREATE  TABLE "
// + ngramTableName
// +
// " ( id int8, timeMillis int8, date int4, ngram text[], ngramLen int2, tweetLen int2, position int2, pkey serial Primary key)");
// // stmt.execute("CREATE INDEX " +ngramTableName+"_date ON " + ngramTableName +"(date)");
//
// // UNLOGGED
// stmt.execute("CREATE  TABLE "
// + htagTableName
// +
// " ( id int8, timeMillis int8, date int4, ngram text[], ngramLen int2, tweetLen int2, position int2, pkey serial Primary key)");
// // stmt.execute("CREATE INDEX " +htagTableName+"_date ON " + htagTableName +"(date)");
//
// ctxt.setStatus("Created tables: " + ngramTableName + ", " + htagTableName);

        int count = 0;
        while (recordReader.nextKeyValue()) {
          Record value  = recordReader.getCurrentValue();
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
              LOG.info("Executed batch with 1000 insertions, approximate progress: " + recordReader.getProgress());
          }

          // but I'm afraid this will slow things down
// // as a side effect, we can also dump the db


        }
        stmt.executeBatch();
        
          LOG.info("Executed final batch");
      } finally {
        stmt.close();
        if (!conn.getAutoCommit()){
          LOG.info("Autocommit off, committing");
          conn.commit();
        }
        conn.close();
        LOG.info("Closed connection to DB");
      }
    } catch (BatchUpdateException e) {
      throw new IOException(e.getNextException());
    } catch (SQLException e) {
      throw new IOException(e);
    } catch (ClassNotFoundException e) {
      throw new IOException(e);
    }

  }

  static StringBuilder sqlArrayBuilder = new StringBuilder("ARRAY[");
  static String toSQLArray(String[] ngram) {
    sqlArrayBuilder.setLength(6);
    sqlArrayBuilder.append('\'').append(ngram[0].trim()).append('\'');
    for (int i = 1; i < ngram.length; ++i) {
      sqlArrayBuilder.append(", '").append(ngram[i].trim()).append('\'');
    }
    sqlArrayBuilder.append(']');
    return sqlArrayBuilder.toString();
  }

}
