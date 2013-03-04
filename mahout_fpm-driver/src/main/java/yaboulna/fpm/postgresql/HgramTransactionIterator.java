package yaboulna.fpm.postgresql;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

  private static final String TOKEN_DELIMETER = "|"; // must be a char

  private static final Set<String> RETWEET_TOKENS = Sets.newHashSet("rt"); // ,"via");

  protected static final String DEFAULT_DRIVER = "org.postgresql.Driver";
  protected static final String DEFAULT_CONNECTION_URL = "jdbc:postgresql://hops.cs.uwaterloo.ca:5433/";
  protected static final String DEFAULT_USER = "yaboulna";
  protected static final String DEFAULT_PASSWORD = "5#afraPG";

  final String url;
  final Properties props;
  private Connection conn = null;
  private PreparedStatement stmt = null;

  final boolean excludeRetweets;
  final String timeSql;
  final int maxHgramLen;

  ResultSet transactions = null;
  Pair<List<String>, Long> nextKeyVal = null;
  StringBuilder strBld = new StringBuilder();

  public HgramTransactionIterator(List<String> dates, long windowStartUx, long windowEndUx,
      int maxLen, String dbname, boolean excludeRetweets, String driverName, String urlPrefix,
      String username, String password) throws ClassNotFoundException {
    this.timeSql = "date in ('" + Joiner.on("', '").join(dates) + "')"
        + " and timemillis >= (" + windowStartUx + " * 1000::INT8)"
        + " and timemillis < (" + windowEndUx + " * 1000::INT8) ";

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
      throw new UnsupportedOperationException("Alread initialized");
    }

    if (stmt != null) {
      stmt.close();
    }

    if (conn != null) {
      conn.close();
    }

    conn = DriverManager.getConnection(url, props);

    // TODO union all 
    // example sql: "select id,string_agg(ngram,'+') from hgram_occ_120917_2_1347904800_unextended group by id;"
    String tablename = "hgram_occ_" + maxHgramLen;
    String sql = "select string_agg(ngram,?) from " + tablename + " where " + timeSql
        + " and ngramlen=" + maxHgramLen
        + " group by id";
    stmt = conn.prepareStatement(sql);
    stmt.setString(1, TOKEN_DELIMETER);

    transactions = stmt.executeQuery();
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
