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

public class InsertIntoHivePartition extends EvalFunc<String> {
  
  private static String driverName = "org.apache.hive.jdbc.HiveDriver";
  // jdbs:hive "org.apache.hadoop.hive.jdbc.HiveDriver"; // this does't support concurrent clients
  
  // TODO read from a properties file
  private String serverURL = "jdbc:hive2://localhost:10000/default";
  private String serverUName = "yaboulna";
  private String serverPasswd = "53nhaN0rmal";
  
  @Override
  public String exec(Tuple input) throws IOException {
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
    String tempName = token + "_" +  year + "_" + month + "_" + day;
    File tempFile = File.createTempFile(tempName, ".csv");
    tempFile.deleteOnExit();
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
        if(!currUnixTime.equals(prevUnixTime) || !currIdAtT.equals(prevIdAtT)){
          
          Long docIdPair = (((long)currUnixTime) << 32) | (currIdAtT & ((1L<<32)-1));
          if(docIdPairsSeen.contains(docIdPair)){
            log.error("The bag is not ordered as we hoped! The (unixTime, docIdAt) pair ({0},{1}) " +
            		" appeared more than once in discontinuous regions.");
            continue;
          } 
          docIdPairsSeen.add(docIdPair);
        
          
          if(prevIdAtT != null && prevUnixTime != null){
            tempWr.append('\n');
          }
          tempWr.append((currUnixTime).toString()).append('\t')
            .append((currIdAtT).toString()).append('\t')
            .append((currPos).toString()); //.append('\n');
          
          
        } else {
          tempWr.append(","+currPos);
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
    
    String rcFilesPath = (String) input.get(2);
    Connection con = null;
    try {
      Class.forName(driverName);
      con = DriverManager.getConnection(serverURL, serverUName, serverPasswd);
      
      Statement stmt = con.createStatement();
      stmt.executeUpdate(" DROP TABLE IF EXISTS " + tempName);
      String tempCreateSQL =
          " CREATE TABLE  " + tempName
              + " (unixTime INT, msIdAtT INT, posArr ARRAY<TINYINT>) "
              + " ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\t' "
              + " COLLECTION ITEMS TERMINATED BY ',' "
              + " LINES TERMINATED BY '\\n' ";
              
      
      stmt.executeUpdate(tempCreateSQL);
      
      String tempLoadSQL =
          " LOAD DATA LOCAL INPATH '" + tempFile.getAbsolutePath() + "' INTO TABLE " + tempName;
      stmt.executeUpdate(tempLoadSQL);
      
      // TIMESTAMP is not good, it fails to be parsed (https://issues.apache.org/jira/browse/HIVE-2957)
      // "   SET hive.exec.compress.output=true; "
      // " SET io.seqfile.compression.type=BLOCK; -- NONE/RECORD/BLOCK (see below) "
      String createSQL =
          " CREATE EXTERNAL TABLE IF NOT EXISTS "
              + token
              + " (unixTime INT COMMENT 'Partition date interprets this in GMT-10', "
              + "  msIdAtT  INT COMMENT 'The 22 LSBs are the IdAtT and the 10 MSBs are mSecs', "
              + "  posArr   ARRAY<TINYINT> COMMENT 'Positions of occurrences within the document') "
              + " COMMENT 'This table is the posting list of the token (" + token + ")' "
              + " PARTITIONED BY (dt STRING) "
              + " ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.columnar.ColumnarSerDe' "
              + " STORED AS RCFILE "
              + " LOCATION '" + rcFilesPath + "' ";
      stmt.executeUpdate(createSQL);
      
      String loadSQL =
          " INSERT INTO TABLE " + token + " PARTITION (dt='" + dateStr + "') " 
//          		+ " SELECT unixTime, msIdAtT, array(pos) " 
              + " SELECT * "
          		+ " FROM " + tempName; 
//          		+ " GROUP BY unixTime, msIdAtT ";
      stmt.executeUpdate(loadSQL);
      
      stmt.executeUpdate(" DROP TABLE " + tempName);
      tempFile.delete();
      return null;
    } catch (Exception e) {
      log.error(e.getMessage(),e);
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
