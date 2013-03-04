package yaboulna.fpm.postgresql;

import java.sql.Connection;
import java.sql.DriverManager;
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

  private static final Set<String> RETWEET_TOKENS = Sets.newHashSet("rt"); // ,"via");

  protected static final String DEFAULT_DRIVER = "org.postgresql.Driver";
  protected static final String DEFAULT_CONNECTION_URL = "jdbc:postgresql://hops.cs.uwaterloo.ca:5433/";
  protected static final String DEFAULT_USER = "yaboulna";
  protected static final String DEFAULT_PASSWORD = "5#afraPG";
  protected static final String DEFAULT_DBNAME = "full";

  final String url;
  final Properties props;
  private Connection conn = null;
  private Statement stmt = null;

  final boolean excludeRetweets;
  final int maxHgramLen;
  final List<String> days;
  final long windowStartUx;
  final long windowEndUx;
  
  ResultSet transactions = null;
  Pair<List<String>, Long> nextKeyVal = null;

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx,
      int maxLen) throws ClassNotFoundException {
    this(days, windowStartUx, windowEndUx, maxLen, DEFAULT_DBNAME, true,
        DEFAULT_DRIVER, DEFAULT_CONNECTION_URL, DEFAULT_USER, DEFAULT_PASSWORD);
  }

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx,
      int maxLen, String dbname, boolean excludeRetweets, String driverName, String urlPrefix,
      String username, String password) throws ClassNotFoundException {
    this.days = days;
    // I don't care about the sequence of tweets and thus there's no point of sorting days  
    //Collections.sort(this.days);
    
    this.windowStartUx = windowStartUx;
    this.windowEndUx = windowEndUx;
    
    if(maxLen < 2 || maxLen > 2){
      throw new UnsupportedOperationException("Joining multiple tables and selecting only occurrences that aren't included in larger hgrams is too much work.. later when it proves really necessary! Right now there are usually nothing in the hgram tables of lengthes more than 2.. I don't know if it is caused by a bug or there really isn't any bigram with high enough propotion of the stream. Maybe what we need to do is to recalculate the proportion of 'Obama' after each len");
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


    StringBuilder joinBld = new StringBuilder("hgram_occ_2");
    //TODO select from different lengthes, and also select positions and prevent total inclusion of shorter in the longer
//    for(int l=maxHgramLen; l>2; --l){
//      String tablename = "hgram_occ_DAY_" + l; 
//      joinBld.append(tablename).append( " right outer join ")
//    }

    String timeSql = "date in ('" + Joiner.on("', '").join(days) + "')"
        + " and timemillis >= (" + windowStartUx + " * 1000::INT8)"
        + " and timemillis < (" + windowEndUx + " * 1000::INT8) ";
    
    String sql = "select array_agg(ngram) from " + joinBld.toString() + " where " + timeSql  + " group by id;";
     
    // example sql: "select id,string_agg(ngram,'+') from hgram_occ_120917_2_1347904800_unextended group by id;"
    stmt = conn.createStatement();

    transactions = stmt.executeQuery(sql);
  }

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
        char[] transChars = transactions.getString(1).toCharArray();

        List<String> hgramList = Lists.newLinkedList();

        boolean skipTransaction = false;
        for (int i = 0; i < transChars.length; ++i) {
          if (transChars[i] == TOKEN_DELIMETER) {
            String hgram = strBld.toString();
            strBld.setLength(0);

            if (excludeRetweets && RETWEET_TOKENS.contains(hgram)) {
              skipTransaction = true;
              break;
            } else {
              hgramList.add(hgram);
            }
          } else {
            strBld.append(transChars[i]);
          }
        }

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
    return nextKeyVal;
  }

  public void remove() {
    throw new UnsupportedOperationException();
  }

}
