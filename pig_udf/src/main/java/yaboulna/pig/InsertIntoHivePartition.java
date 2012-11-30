package yaboulna.pig;

import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.nio.channels.Channels;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Iterator;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.apache.pig.EvalFunc;
import org.apache.pig.data.DataBag;
import org.apache.pig.data.Tuple;

import com.google.common.collect.Sets;

public class InsertIntoHivePartition extends EvalFunc<Integer> {
  
  String driverName = "org.apache.hive.jdbc.HiveDriver";
  // jdbs:hive "org.apache.hadoop.hive.jdbc.HiveDriver"; // this does't support concurrent clients
  
  // TODO read from a properties file
  String serverURL = "jdbc:hive2://precise-hive:10000/default"; // 192.168.56.177
  String serverUName = "younos";
  String serverPasswd = "Passw0rt";
  
  @Override
  public Integer exec(Tuple input) throws IOException {
    if (input == null || input.isNull() || input.size() < 3 || input.isNull(0) || input.isNull(1)
        || input.isNull(2)) {
      return null;
    }
    
    Tuple group = (Tuple) input.get(0);
    if (group.isNull() || group.size() < 4 || group.isNull(0) || group.isNull(1)
        || group.isNull(2) || group.isNull(3)) {
      return null;
    }
    String token = (String) group.get(0);
    Integer year = (Integer) group.get(1);
    Integer month = (Integer) group.get(2);
    Integer day = (Integer) group.get(3);
    
    DataBag docPosBag = (DataBag) input.get(1);
    String dateStr = year + "-" + month + "-" + day;
    String tempName = token + "_" + year + "_" + month + "_" + day;
    File tempFile = File.createTempFile(tempName, ".csv");
    // Leave it for debugging: tempFile.deleteOnExit();
    
    int sizeInBytes = 0;
    
    Writer tempWr = Channels.newWriter(FileUtils.openOutputStream(tempFile).getChannel(), "UTF-8");
    try {
      Iterator<Tuple> docPosIter = docPosBag.iterator();
      Integer prevUnixTime = null;
      Integer prevIdAtT = null;
      Set<Long> docIdPairsSeen = Sets.newHashSet();
      while (docPosIter.hasNext()) {
        Tuple docPos = docPosIter.next();
        if (docPos.isNull() || docPos.size() < 3 || docPos.isNull(0) || docPos.isNull(1)
            || docPos.isNull(2)) {
          continue;
        }
        
        Integer currUnixTime = (Integer) docPos.get(0);
        Integer currIdAtT = (Integer) docPos.get(1);
        Integer currPos = (Integer) docPos.get(2);
        
        // Relying on the tuples coming sorted in the bag is WRONG in general,
        // but even if the tuples are coming from the same document, and I made sure
        // they are emitted in order while tokenizing the documents??
        // I could create a HashMap and sort them in memory, but I'd rather take the shot
        if (!currUnixTime.equals(prevUnixTime) || !currIdAtT.equals(prevIdAtT)) {
          
          Long docIdPair = (((long) currUnixTime) << 32) | (currIdAtT & ((1L << 32) - 1));
          if (docIdPairsSeen.contains(docIdPair)) {
            log.error("The bag is not ordered as we hoped! The (unixTime, docIdAt) pair ({0},{1}) "
                +
                " appeared more than once in discontinuous regions.");
            continue;
          }
          docIdPairsSeen.add(docIdPair);
          
          if (prevIdAtT != null && prevUnixTime != null) {
            tempWr.append('\n');
          }
          tempWr.append((currUnixTime).toString()).append('\t')
              .append((currIdAtT).toString()).append('\t')
              .append((currPos).toString()); // .append('\n');
          
          sizeInBytes += (4 + 4 + 1);
          
        } else {
          tempWr.append("," + currPos);
          
          sizeInBytes += 1;
        }
        prevIdAtT = currIdAtT;
        prevUnixTime = currUnixTime;
      }
      tempWr.append('\n');
      // END of relying on the tuples being sorted in the bag
      
    } finally {
      tempWr.flush();
      tempWr.close();
    }
    
    // this will include the size of separators, there are lots of them
    // int sizeInBytes = tempFile.length();
    
    String rcFilesPath = (String) input.get(2);
    Connection con = null;
    try {
      Class.forName(driverName);
      con = DriverManager.getConnection(serverURL, serverUName, serverPasswd);
      
      Statement stmt = con.createStatement();

      // I thought the EXERNAL table has to be in HDFS but it seems it can be local.. woohoo!
//      Configuration conf = new Configuration();
//      Path hdfsTemp = new Path(conf.get("hadoop.temp.dir", "/tmp/hadoop-USER"), "staging/"
//          + tempName);
//      Path localTemp = new Path(FileUtils.toURLs(new File[] { tempFile })[0].toURI());
//      FileSystem fs = FileSystem.get(conf);
      ///////////////////////////////////////////////// staging table
      stmt.executeUpdate(" DROP TABLE IF EXISTS " + tempName);
      String tempCreateSQL =
          " CREATE EXTERNAL TABLE  " + tempName
              + " (unixTime INT, msIdAtT INT, posArr ARRAY<TINYINT>) "
              + " ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\t' "
              + " COLLECTION ITEMS TERMINATED BY ',' "
              + " LINES TERMINATED BY '\\n' "
              + " STORED AS TEXTFILE "
              + " LOCATION 'file://" + tempFile.getAbsolutePath() + "'";
      stmt.executeUpdate(tempCreateSQL);
  
      // Copying doesn't strictly need to be after creating the table.. I think it works now
//      fs.copyFromLocalFile(localTemp, hdfsTemp);
      
      // doesn't work through JDBC (what was I thinking)
      // stmt.executeUpdate(" hadoop dfs -put " + tempFile.getAbsolutePath() + " " + hdfsTemp);
      
      // A totally different approach (remove EXTERNAL) but causes an unsolvable error with YARN:
      /*
       * Error details: org.apache.hadoop.mapred.YarnChild.main(YarnChild.java:147) Caused by:
       * java.io.IOException: ERROR! at
       * yaboulna.pig.InsertIntoHivePartition.exec(InsertIntoHivePartition.java:194) at
       * yaboulna.pig.InsertIntoHivePartition.exec(InsertIntoHivePartition.java:1) at
       * org.apache.pig.backend
       * .hadoop.executionengine.physicalLayer.expressionOperators.POUserFunc.getNext
       * (POUserFunc.java:216) ... 16 more Caused by: java.sql.SQLException: Error while processing
       * statement: FAILED: SemanticException Line 1:24 Invalid path
       * ''/home/younos/data/tmp/yarn/nm/usercache/younos/appcache/application_1354225176116_0001/container_1354225176116_0001_01_000003/tmp/0_2012_9_134798085913086537990.csv'':
       * No files matching path
       * file:/home/younos/data/tmp/yarn/nm/usercache/younos/appcache/application_1354225176116_0001
       * /container_1354225176116_0001_01_000003/tmp/0_2012_9_134798085913086537990.csv at
       * org.apache.hive.jdbc.Utils.verifySuccess(Utils.java:157) at
       * org.apache.hive.jdbc.Utils.verifySuccessWithInfo(Utils.java:145) at
       * org.apache.hive.jdbc.HiveStatement.execute(HiveStatement.java:165) at
       * org.apache.hive.jdbc.HiveStatement.executeUpdate(HiveStatement.java:242) at
       * yaboulna.pig.InsertIntoHivePartition.exec(InsertIntoHivePartition.java:136) ... 18 more
       */
      
      // String tempLoadSQL =
      // " LOAD DATA LOCAL INPATH '" + tempFile.getAbsolutePath() + "' INTO TABLE " + tempName;
      // stmt.executeUpdate(tempLoadSQL);
      
      // ////////////////////////////// Actual table for the token's posting list
      
      String rowAndFileFormats = " ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.columnar.ColumnarSerDe' "
          + " STORED AS RCFILE ";
      String compression = "org.apache.hadoop.io.compress.SnappyCodec";
      
      if (sizeInBytes < 4 * FileUtils.ONE_MB) {
        // According to the paper presenting RCFiles this is the RecordBlock size at which the
        // RCFile format starts to be useful. Less than this is really too little for any
        // file format to be useful, and it doesn't even require splitting (which is not possible
        // for text files). TODO: Can we merely referencing the file created above?
        rowAndFileFormats = " ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\t' "
            + " COLLECTION ITEMS TERMINATED BY ',' "
            + " LINES TERMINATED BY '\\n' "
            + " STORED AS TEXTFILE ";
        compression = "org.apache.hadoop.io.compress.GzipCodec"; // works best with text format
        // according to http://www.adaltas.com/blog/2012/03/13/hdfs-hive-storage-format-compression/
      }
      
      // TIMESTAMP is not good, it fails to be parsed (https://issues.apache.org/jira/browse/HIVE-2957)
      // "   SET hive.exec.compress.output=true; "
      // " SET io.seqfile.compression.type=BLOCK; -- NONE/RECORD/BLOCK (see below) "
      String createSQL =
          " CREATE TABLE IF NOT EXISTS " //EXTERNAL
              + token
              + " (unixTime INT COMMENT 'Partition date interprets this in GMT-10', "
              + "  msIdAtT  INT COMMENT 'The 22 LSBs are the IdAtT and the 10 MSBs are mSecs', "
              + "  posArr   ARRAY<TINYINT> COMMENT 'Positions of occurrences within the document') "
              + " COMMENT 'This table is the posting list of the token (" + token + ")' "
              + " PARTITIONED BY (dt STRING) "
              + rowAndFileFormats
              + " LOCATION '" + rcFilesPath + "' ";
      stmt.executeUpdate(createSQL);
      
      // This is going to be ignored anyway.. a plunge in the code was needed to learn this
      // stmt.executeUpdate("SET mapred.output.dir=${mapred.temp}")
      
      // FIXME remove after fix the problem with derby DB EmbeddedDriver not being in the class path
      stmt.executeUpdate("set hive.stats.autogather=false");
      
      stmt.executeUpdate("SET hive.exec.compress.output=true");
      stmt.executeUpdate("SET mapred.output.compression.codec=" + compression);
      stmt.executeUpdate("SET io.seqfile.compression.type=BLOCK"); // NONE/RECORD
      
      String loadSQL =
          " INSERT INTO TABLE " + token + " PARTITION (dt='" + dateStr + "') "
              // + " SELECT unixTime, msIdAtT, array(pos) "
              + " SELECT * "
              + " FROM " + tempName;
      // + " GROUP BY unixTime, msIdAtT ";
      int result = stmt.executeUpdate(loadSQL);
      
      stmt.executeUpdate(" DROP TABLE " + tempName);
      tempFile.delete();
//      fs.delete(hdfsTemp, true);
      
      return result;
    } catch (Exception e) {
      log.error(e.getMessage(), e);
      throw new IOException("ERROR! ", e);
    } finally {
      try {
        if (con != null && !con.isClosed()) {
          con.close();
        }
      } catch (SQLException ignored) {
      }
    }
  }
  
}
