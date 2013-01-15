package yaboulna.pig;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.Writer;
import java.nio.channels.Channels;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Iterator;
import java.util.Random;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.pig.EvalFunc;
import org.apache.pig.data.DataBag;
import org.apache.pig.data.Tuple;

import com.google.common.collect.Sets;
import com.google.common.hash.HashCode;
import com.google.common.hash.Hashing;

@Deprecated
public class InsertIntoHiveTokenTimedPos extends EvalFunc<Integer> {
  
  static final String LOCAL_TMP_BASE = "/home/younos/data/tmp";
  
  static final String HIVE_TOKENPOSS_TABLE_NAME = "token_timed_pos";
  
  static final String HASH_FUNCTION_NAME = "mur"; // short for murmur32";
  
  static final byte[] HBASE_HASH_FUNCTION_COLFAM = Bytes.toBytes(HASH_FUNCTION_NAME);
  static final String HBASE_REVER_HASH_TABLE = "rev_hash";

  static final String HBASE_HISTORY_TABLE = "hist";
  static final byte[] HBASE_VOLUME_COLFAM = Bytes.toBytes("vol");
  
  private static final boolean VOLUME_AS_DOCCOUNT = false;
  
  static final String hiveDriverName = "org.apache.hive.jdbc.HiveDriver";
  // jdbs:hive "org.apache.hadoop.hive.jdbc.HiveDriver"; // this does't support concurrent clients
  
  
  // TODO read from a properties file
  String serverURL = "jdbc:hive2://precise-hive:10000/default"; // 192.168.56.177
  String serverUName = "younos";
  String serverPasswd = "Passw0rt";
  String hbaseZookeeperQuorum = "precise-01";
  
  /**
   * Intention was to store the passed bag of timestamped document positions of occurrences of 
   * the token into a Hive column in the table "token_timed_pos", but Hive doesn't allow this.
   * The intention was to gather enough data for daily partitions so that they can be
   * stored as a Snappy compressed RCFile, which can be loaded using HiveColumnarLoader. This was to
   * work around the small file storage problem, caused by the fact that HDFS block size is large, and
   * that every IO request on the cloud costs money. However, the only thing possible was to
   * store the positions of occurrences in an HBase like format by repeating the key (token hash) 
   * in each record. This is fine size wise, but how about joins? This will require loading the 
   * occurrences of both tokens using a filter, then joining them. I don't know how bad is this. 
   * But anyway if this is what we'll do then why not use HBaseStorage from Pig directly and
   * get rid of the Hive mess?? Or should Hadoop be abandoned totally using OpenGraphLab instead??? 
   * 
   * Make sure that the table exists by running the following in hive:
   * 
   * <pre>
   *  CREATE EXTERNAL TABLE IF NOT EXISTS token_timed_pos
   *                (unixTime INT COMMENT 'Partition date interprets this in GMT-10', 
   *                 tokenHash INT COMMENT 'Hash of token (compact), reverse mapping stored in HBASE'
   *                 msIdAtT  INT COMMENT 'The 22 LSBs are the IdAtT and the 10 MSBs are mSecs', 
   *                 posArr   ARRAY&lt;TINYINT&gt; COMMENT 'Positions of occurrences within the document') 
   *                 COMMENT 'This table is the posting list of all tokens, unigrams or combined' 
   *                 PARTITIONED BY (dt STRING) 
   *                 ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.columnar.ColumnarSerDe' 
   *                 STORED AS RCFILE 
   *                 LOCATION '" + new Path(rcFilesPath, tableName).toUri().toString() + "' ";
   * </pre>
   * 
   * Also make sure to set the compression:
   * 
   * <pre>
   * SET hive.exec.compress.output=true
   * SET io.seqfile.compression.type=BLOCK; -- NONE/RECORD/BLOCK
   * SET mapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec
   * </pre>
   * 
   * Also disable stats until I fix the problem with derby DB EmbeddedDriver not being in the class
   * path: set hive.stats.autogather=false
   * 
   * @param <pre>
   *          input : Tuple of (group: (token: chararray,year: int,month: int,day: int), tokens:
   *          {(unixTime: int,msIdAtT: int,year: int,month: int,day: int,token: chararray,pos: int))
   *          </pre>
   * 
   */
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
    
    Integer volHist = getVolume(token, dateStr);
    if (volHist != null) {
      log.info("Partition dt=" + dateStr + " for token " + token
          + " already processed. Volume was " + volHist + " occurrences");
      return -7;
    }
    
    HashCode tokenHash = uniqueTokenHash(token);
    
    String tempName = "staging_" + tokenHash.toString() + "_" + year + "_" + month
        + "_" + day;
    
    // This file causes errors.. maybe it doesn't even get created
    // The error in hive log says that it is an Invalid path
    // File tempFile = File.createTempFile(tempName, ".csv");
    // ////////////////////////////////
    // Instead use task Id (but will this also get annihilated as soon as the task is over?)
    // Configuration conf = new Configuration();
    // The working dir is the home of the user not really a task attempt safe dir
    // FileSystem fs = FileSystem.get(conf);
    // fs.getWorkingDirectory()
    // //////////////
    // Instead use a file in the user space, using the task ID.
    // conf.get("mapreduce.task.attempt.id")) is null
    // TODO: get the TaskAttemptID from the TaskAttemptContext
    File tempDir = FileUtils.getFile(LOCAL_TMP_BASE,
        this.getClass().getName() + "_" + tempName + "_" + new Random().nextInt());
    
    File tempFile = FileUtils.getFile(tempDir, tempName + ".csv");
    
    log.info("Temp file for token " + token + ": " + tempFile.getAbsolutePath());
    
    // Leave it for debugging: tempFile.deleteOnExit();
    
    int volume = 0;
    FileOutputStream tempOs = FileUtils.openOutputStream(tempFile);
    Writer tempWr = Channels.newWriter(tempOs.getChannel(), "UTF-8");
    
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
        
        // Relying on the tuples coming sorted in the bag because I had sorted
        // it before passing it along.. this is a Data Gaurantee according to
        // http://pig.apache.org/docs/r0.8.1/piglatin_ref2.htm
        if (!currUnixTime.equals(prevUnixTime) || !currIdAtT.equals(prevIdAtT)) {
          
          Long docIdPair = (((long) currUnixTime) << 32) | (currIdAtT & ((1L << 32) - 1));
          if (docIdPairsSeen.contains(docIdPair)) {
            log.error(String.format(
                "The bag is not ordered as we hoped! The (unixTime, docIdAt) pair (" + currUnixTime
                    + ", " + currIdAtT + ") " +
                    " appeared more than once in discontinuous regions."));
            continue;
          }
          docIdPairsSeen.add(docIdPair);
          
          if (prevIdAtT != null && prevUnixTime != null) {
            tempWr.append('\n');
          }
          tempWr.append((currUnixTime).toString()).append('\t')
              .append(Integer.toString(tokenHash.asInt())).append('\t')
              .append((currIdAtT).toString()).append('\t')
              .append((currPos).toString()); // .append('\n');
          
          ++volume;
        } else {
          tempWr.append("," + currPos);
          
          if (VOLUME_AS_DOCCOUNT) {
            // this is still part of the same document
          } else {
            ++volume;
          }
        }
        prevIdAtT = currIdAtT;
        prevUnixTime = currUnixTime;
      }
      tempWr.append('\n');
      // END of relying on the tuples being sorted in the bag
      
    } finally {
      if (tempWr != null) {
        tempWr.flush();
        tempWr.close();
      }
      if (tempOs != null) {
        tempOs.flush();
        tempOs.close();
      }
    }
    
    Connection con = null;
    try {
      Class.forName(hiveDriverName);
      con = DriverManager.getConnection(serverURL, serverUName, serverPasswd);
      
      Statement stmt = con.createStatement();
      
      // I thought the EXERNAL table has to be in HDFS but it seems it can be local.. woohoo!
      // Path hdfsTemp = new Path(conf.get("hadoop.temp.dir", "/tmp/hadoop-USER"), "staging/"
      // + tempName);
      // Path localTemp = new Path(FileUtils.toURLs(new File[] { tempFile })[0].toURI());
      // FileSystem fs = FileSystem.get(conf);
      // /////////////////////////////////////////////// staging table
      stmt.executeUpdate(" DROP TABLE IF EXISTS " + tempName);
      String tempCreateSQL =
          " CREATE TABLE  " + tempName
              + " (unixTime INT, tokenHash INT, msIdAtT INT, posArr ARRAY<TINYINT>) "
              + " ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\t' "
              + " COLLECTION ITEMS TERMINATED BY ',' "
              + " LINES TERMINATED BY '\\n' "
              + " STORED AS TEXTFILE ";
      // EXTERNAL+ " LOCATION 'file://" + tempDir.getAbsolutePath() + "'";
      stmt.executeUpdate(tempCreateSQL);
      
      // Copying doesn't strictly need to be after creating the table.. I think it works now
      // fs.copyFromLocalFile(localTemp, hdfsTemp);
      
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
      
      String tempLoadSQL =
          " LOAD DATA LOCAL INPATH 'file://" + tempFile.getAbsolutePath() + "' INTO TABLE "
              + tempName;
      stmt.executeUpdate(tempLoadSQL);
      
      // ////////////////////////////// Actual table for the token's posting list
      String loadSQL =
          " INSERT INTO TABLE " + HIVE_TOKENPOSS_TABLE_NAME + " PARTITION (dt='" + dateStr + "') "
              // + " SELECT unixTime, msIdAtT, array(pos) "
              + " SELECT * "
              + " FROM " + tempName;

      int result = stmt.executeUpdate(loadSQL);
      
      if (result >= 0) {
        markProcessed(token, dateStr, volume);
      }
      
      stmt.executeUpdate(" DROP TABLE " + tempName);
      
      tempFile.delete();
      FileUtils.deleteDirectory(tempDir);
      // fs.delete(hdfsTemp, true);
      
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
  
  public static Integer getVolume(String token, String dateStr) throws IOException {
    // You need a configuration object to tell the client where to connect.
    // When you create a HBaseConfiguration, it reads in whatever you've set
    // into your hbase-site.xml and in hbase-default.xml, as long as these can
    // be found on the CLASSPATH
    Configuration config = HBaseConfiguration.create();
    
    // This instantiates an HTable object that connects you to
    // the "myLittleHBaseTable" table.
    HTable table = new HTable(config, HBASE_HISTORY_TABLE);
    
    Get g = new Get(Bytes.toBytes(token));
    Result r = table.get(g);
    
    // Minimizing checks
    // if(r.isEmpty()){
    // return null;
    // } else {
    byte[] volBytes = r.getValue(HBASE_VOLUME_COLFAM, Bytes.toBytes(dateStr));
    if (volBytes != null) {
      return Bytes.toInt(volBytes);
    } else {
      return null;
    }
  }
  
  private void markProcessed(String token, String dateStr, int volume) throws IOException {
    // You need a configuration object to tell the client where to connect.
    // When you create a HBaseConfiguration, it reads in whatever you've set
    // into your hbase-site.xml and in hbase-default.xml, as long as these can
    // be found on the CLASSPATH
    Configuration config = HBaseConfiguration.create();
    
    // This instantiates an HTable object that connects you to
    // the "myLittleHBaseTable" table.
    HTable table = new HTable(config, HBASE_HISTORY_TABLE);
    
    byte[] row = Bytes.toBytes(token);
    byte[] qualifier = Bytes.toBytes(dateStr);
    Put p = new Put(row);
    p.add(HBASE_VOLUME_COLFAM, qualifier, Bytes.toBytes(volume));
    
    // no need for extra checks
    // if (!table.checkAndPut(row, HASH_FUNCTION_COLFAM, qualifier, null, p)) {
    // log.error(arg0)
    // return tokenHash;
    // }
    
    table.put(p);
  }
  
  /**
   * Avoid invalid table names by using the hash of the hash value of the token Makes sure that this
   * hash doesn't collide with any other token by looking into HBase
   * 
   * @param token
   * @param dateStr
   * @return murmur32 hash that doesn't collide
   * @throws IOException
   */
  public HashCode uniqueTokenHash(String token) throws IOException {
    
    byte[] value = Bytes.toBytes(token);
    
    // You need a configuration object to tell the client where to connect.
    // When you create a HBaseConfiguration, it reads in whatever you've set
    // into your hbase-site.xml and in hbase-default.xml, as long as these can
    // be found on the CLASSPATH
    Configuration config = HBaseConfiguration.create();
    
    // This instantiates an HTable object that connects you to
    // the "myLittleHBaseTable" table.
    HTable table = new HTable(config, HBASE_REVER_HASH_TABLE);
    
    StringBuilder hashInput = new StringBuilder();
    for (int i = 1; true; ++i) {
      // avoid collisions by hashing repetitions of the token
      hashInput.setLength(0);
      for (int j = 0; j < i; ++j) {
        hashInput.append(token);
      }
      
      HashCode tokenHash = Hashing.murmur3_32().hashString(hashInput.toString());
      String tokenHashStr = tokenHash.toString();
      // I can't risk havingt the negative sign which is an invalid character .asInt();
      // This still contains - (byte is still unsigned, and I didn't upcast it)
      // Arrays.toString(.asBytes());
      // tokenHash = tokenHash.replaceAll("[\\[\\]]", "");
      // tokenHash = tokenHash.replaceAll(", ", "_");
      
      // To add to a row, use Put. A Put constructor takes the name of the row
      // you want to insert into as a byte array. In HBase, the Bytes class has
      // utility for converting all kinds of java types to byte arrays. In the
      // below, we are converting the String "myLittleRow" into a byte array to
      // use as a row key for our update. Once you have a Put instance, you can
      // adorn it by setting the names of columns you want to update on the row,
      // the timestamp to use in your update, etc.If no timestamp, the server
      // applies current time to the edits.
      byte[] row = Bytes.toBytes(tokenHashStr);
      byte[] qualifier = Bytes.toBytes((byte) i);
      Put p = new Put(row);
      
      // To set the value you'd like to update in the row 'myLittleRow', specify
      // the column family, column qualifier, and value of the table cell you'd
      // like to update. The column family must already exist in your table
      // schema. The qualifier can be anything. All must be specified as byte
      // arrays as hbase is all about byte arrays. Lets pretend the table
      // 'myLittleHBaseTable' was created with a family 'myLittleFamily'.
      p.add(HBASE_HASH_FUNCTION_COLFAM, qualifier,
          value);
      
      // Once you've adorned your Put instance with all the updates you want to
      // make, to commit it do the following (The HTable#put method takes the
      // Put instance you've been building and pushes the changes you made into
      // hbase)
      if (table.checkAndPut(row, HBASE_HASH_FUNCTION_COLFAM, qualifier, null, p)) {
        return tokenHash;
      }
    }
  }
}