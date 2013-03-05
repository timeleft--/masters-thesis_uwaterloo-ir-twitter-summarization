package yaboulna.fpm.postgresql;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.Set;

import org.apache.mahout.common.Pair;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

public class HgramTransactionIterator implements Iterator<Pair<List<String>, Long>> {

  private static final Long ONE = 1L;

  static final char TOKEN_DELIMETER = '|'; // must be a char
  static final char UNIGRAM_DELIMETER = ','; // must be a char

  static final Set<String> RETWEET_TOKENS = Sets.newHashSet("rt"); // ,"via");

  protected static final String DEFAULT_DRIVER = "org.postgresql.Driver";
  protected static final String DEFAULT_CONNECTION_URL = "jdbc:postgresql://hops.cs.uwaterloo.ca:5433/";
  protected static final String DEFAULT_USER = "yaboulna";
  protected static final String DEFAULT_PASSWORD = "5#afraPG";
  protected static final String DEFAULT_DBNAME = "full";

  final String url;
  final Properties props;
  private Connection conn = null;
  private PreparedStatement stmt = null;

  final boolean excludeRetweets;

  final int maxHgramLen;
  final String epochLen;
  
  final List<String> days;
  final long windowStartUx;
  final long windowEndUx;

  ResultSet transactions = null;
  Pair<List<String>, Long> nextKeyVal = null;
  StringBuilder strBld = new StringBuilder();
  long nRowsRead;

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx,String epochLen,
      int maxLen) throws ClassNotFoundException {
    this(days, windowStartUx, windowEndUx, epochLen, maxLen, DEFAULT_DBNAME, true,
        DEFAULT_DRIVER, DEFAULT_CONNECTION_URL, DEFAULT_USER, DEFAULT_PASSWORD);
  }

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx,String epochLen,
      int maxLen, String dbName) throws ClassNotFoundException {
    this(days, windowStartUx, windowEndUx,epochLen, maxLen, dbName, true,
        DEFAULT_DRIVER, DEFAULT_CONNECTION_URL, DEFAULT_USER, DEFAULT_PASSWORD);
  }

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx, String epochLen,
      int maxLen, String dbname, boolean excludeRetweets, String driverName, String urlPrefix,
      String username, String password) throws ClassNotFoundException {

    this.days = days;
    // I don't care about the sequence of tweets and thus there's no point of sorting days
    // Collections.sort(this.days);

    this.windowStartUx = windowStartUx;
    this.windowEndUx = windowEndUx;

    this.epochLen = epochLen;
    
    if (maxLen < 2 || maxLen > 2) {
      throw new UnsupportedOperationException(
          "Joining multiple tables and selecting only occurrences that aren't included in larger hgrams is too much work.. later when it proves really necessary! Right now there are usually nothing in the hgram tables of lengthes more than 2.. I don't know if it is caused by a bug or there really isn't any bigram with high enough propotion of the stream. Maybe what we need to do is to recalculate the proportion of 'Obama' after each len");
    }

    this.maxHgramLen = maxLen;

    this.excludeRetweets = excludeRetweets;

    Class.forName(driverName);

    url = urlPrefix + dbname;
    props = new Properties();
    props.setProperty("user", username);// "uspritzer");
    props.setProperty("password", password); // "Spritz3rU");
// props.setProperty("ssl", "false");
// props.setProperty("prepareThreshold", "1");

  }

  public void init() throws SQLException {
    if (transactions != null) {
      throw new UnsupportedOperationException("Already initialized");
    }

    if (stmt != null) {
      stmt.close();
    }

    if (conn != null) {
      conn.close();
    }

    conn = DriverManager.getConnection(url, props);

    
    String timeSql = " date in ('" + Joiner.on("', '").join(days) + "')"
        + " and timemillis >= (" + windowStartUx + " * 1000::INT8)"
        + " and timemillis < (" + windowEndUx + " * 1000::INT8) ";
    
    // TODO union all on date tables: I already have an index on the date column in all data bearing tables.. but
    // checking 24*70 tables for each day that is not within the range is a bit too much

    // TODO hgram_occ_" + maxHgramLen.. using the multiple inheritance capabilities of PostgreSQL
    String tablename = "hgram_occ";
    String sql = "select string_agg(ngram,?) from " + tablename + " where " + timeSql
        + " and ngramlen<=" + maxHgramLen
        + " group by id";
    stmt = conn.prepareStatement(sql);
    stmt.setString(1, "" + TOKEN_DELIMETER);

    // example sql: "select id,string_agg(ngram,'|') from hgram_occ_120917_2_1347904800_unextended group by id;"
    transactions = stmt.executeQuery();
    nRowsRead = 0;
  }

// The counts will contain occurences in retweets, so I'd rather use the generateFlist 
//  public List<Pair<String,Long>> windowFList() throws SQLException{
//    Statement flistStmt = conn.createStatement();
//    
//    // TODO make sure that the windowEndUx is set so that the epochstartux of the last epoch is less than it
//    String timeSql = " epochstartux >= " +  windowStartUx +  " and epochstartux < " + windowEndUx;
//    
//    String sql = "select ngram,sum(cnt) from hgram_cnt_" + epochLen + maxHgramLen +" where " + timeSql 
//        + " group by ngram order by sum(cnt) desc; ";
//    ResultSet flistRs = flistStmt.executeQuery(sql);
//    
//    List<Pair<String,Long>> retVal = Lists.newLinkedList();
//    while(flistRs.next()){
//      retVal.add(new Pair<String, Long>(flistRs.getString(1),flistRs.getLong(2)));
//    }
//    return retVal;
//  }
  
  public void uninit() {
    try {
      if (transactions != null) {
        transactions.close();
      }
      if (stmt != null) {
        stmt.close();
      }
      if (conn != null) {
        conn.close();
      }
    } catch (SQLException ignored) {
    }
  }

  public boolean hasNext() {
    try {
      while (transactions.next()) {
        ++nRowsRead;
        
        char[] transChars = transactions.getString(1).toCharArray();

        List<String> hgramList = Lists.newLinkedList();

        boolean skipTransaction = false;
        int currUnigramStart = 0;
        for (int i = 0; i < transChars.length; ++i) {

          if (excludeRetweets &&
              (transChars[i] == UNIGRAM_DELIMETER ||
              transChars[i] == TOKEN_DELIMETER)) {

            String uni = strBld.substring(currUnigramStart);
            if (RETWEET_TOKENS.contains(uni)) {
              skipTransaction = true;
              break;
            }
            
            if(transChars[i] == UNIGRAM_DELIMETER) {
              currUnigramStart = strBld.length()+1;
            } else if(transChars[i] == TOKEN_DELIMETER) {
              currUnigramStart = 0;
            }
          }

          if (transChars[i] == TOKEN_DELIMETER) {
            String hgram = strBld.toString();
            strBld.setLength(0);
            hgramList.add(hgram);
          } else {
            strBld.append(transChars[i]);
          }

        }

        // last token  (makes sure strBld.setLength is called always)
        String hgram = strBld.toString();
        strBld.setLength(0);
        hgramList.add(hgram);
        
        if (skipTransaction) {
          continue;
        }
        
        nextKeyVal = new Pair<List<String>, Long>(hgramList, ONE);
        return true;
      }
      return false;
    } catch (SQLException e) {
      throw new RuntimeException(e);
    }
  }

  public Pair<List<String>, Long> next() {
    if (nextKeyVal == null) {
      hasNext();
    }
    Pair<List<String>, Long> retVal = nextKeyVal;
    nextKeyVal = null;
    return retVal;
  }

  public void remove() {
    throw new UnsupportedOperationException();
  }

  public long getRowsRead() {
    return nRowsRead;
  }

  
}
