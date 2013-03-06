package yaboulna.fpm.postgresql;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.Set;

import org.apache.mahout.common.Pair;
import org.joda.time.MutableDateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

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

  protected static final int HISTORY_DAYS_COUNT = 7;

  final String url;
  final Properties props;
  private Connection conn = null;
  private PreparedStatement stmt = null;

  final boolean excludeRetweets;

  final int maxHgramLen;

  final List<String> days;
  final long windowStartUx;
  final long windowEndUx;

  ResultSet transactions = null;
  Pair<List<String>, Long> nextKeyVal = null;
  StringBuilder strBld = new StringBuilder();
  long nRowsRead;

  private int currDayIx = 0;

  protected static final DateTimeFormatter dateFmt = DateTimeFormat.forPattern("yyMMdd");

  private static final boolean DEBUG_SQL = false;

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx,
      int maxLen) throws ClassNotFoundException {
    this(days, windowStartUx, windowEndUx, maxLen, DEFAULT_DBNAME, true,
        DEFAULT_DRIVER, DEFAULT_CONNECTION_URL, DEFAULT_USER, DEFAULT_PASSWORD);
  }

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx,
      int maxLen, String dbName) throws ClassNotFoundException {
    this(days, windowStartUx, windowEndUx, maxLen, dbName, true,
        DEFAULT_DRIVER, DEFAULT_CONNECTION_URL, DEFAULT_USER, DEFAULT_PASSWORD);
  }

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx,
      int maxLen, String dbname, boolean excludeRetweets, String driverName, String urlPrefix,
      String username, String password) throws ClassNotFoundException {

    this.days = days;
// I don't care about the sequence of tweets but sorting for using days in window
    Collections.sort(this.days);

    this.windowStartUx = windowStartUx;
    this.windowEndUx = windowEndUx;

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

    nRowsRead = 0;
  }

  public Set<String> getTopicWords(int limit) throws SQLException {
    MutableDateTime windowDay1 = dateFmt.parseMutableDateTime(days.get(0));
    windowDay1.addDays(-HISTORY_DAYS_COUNT);

    Statement hiStmt = conn.createStatement();
    try {
      //  @formatter:off
    String hiSql =
          " with hist as (select c.*,CAST(c.cnt as float8)/CAST(v.totalcnt as float8) as prop "
        + "   from cnt_1hr1 c join volume_1hr1 v on c.epochstartmillis = v.epochstartmillis " 
        + "   where date >= " + dateFmt.print(windowDay1) + " and date <= " + days.get(days.size()-1)  
        + "     and c.epochstartmillis < " + (windowEndUx * 1000) + " ),"
        + " curr as (select c.*,v.totalcnt,CAST(c.cnt as float8)/CAST(v.totalcnt as float8)  as prop "
        + "   from cnt_1hr1 c join volume_1hr1 v on c.epochstartmillis = v.epochstartmillis " 
        + "   where date in ('" + Joiner.on("','").join(days) + "') "
        + "     and c.epochstartmillis >= (" + windowStartUx + " * 1000::INT8)"
        + "     and c.epochstartmillis < (" + windowEndUx + " * 1000::INT8) ) "
        + " select curr.ngramarr, " 
        + (DEBUG_SQL?" curr.epochstartmillis, avg(hist.prop) histmeanprop, stddev_pop(hist.prop) histdvprop, count(*) as appearances, ":"")
        + "     (min(curr.prop) - avg(hist.prop))/stddev_pop(hist.prop) as stdprop, min(curr.prop) * min(curr.totalcnt) as cnt "
        + "   from hist join curr on curr.ngramarr = hist.ngramarr " 
        + "   group by curr.ngramarr, curr.epochstartmillis having count(*) > 3 order by stdprop desc limit " + limit;
    //@formatter:on    

      ResultSet hiRs = hiStmt.executeQuery(hiSql);
      Set<String> retVal = Sets.newHashSet();
      while (hiRs.next()) {
        retVal.add(hiRs.getString(1));
      }
      return retVal;
    } finally {
      hiStmt.close();
    }
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
      if (transactions == null) {
        String timeSql = "date = '" + days.get(currDayIx) + "' "
            + " and timemillis >= (" + windowStartUx + " * 1000::INT8)"
            + " and timemillis < (" + windowEndUx + " * 1000::INT8) ";

        String tablename = "hgram_occ_" + days.get(currDayIx) + "_" + maxHgramLen;
        String sql = "select string_agg(ngram,?) from " + tablename + " where " + timeSql
            + " and ngramlen<=" + maxHgramLen
            + " group by id";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, "" + TOKEN_DELIMETER);

        // example sql: "select id,string_agg(ngram,'|') from hgram_occ_120917_2_1347904800_unextended group by id;"
        transactions = stmt.executeQuery();

      }
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
// FIXME: The rt token will not be "caught" if it were the last unigram in the tweet.. || i == transChars.length - 1)) {

            String uni = strBld.substring(currUnigramStart);
            if (RETWEET_TOKENS.contains(uni)) {
              skipTransaction = true;
              break;
            }

            if (transChars[i] == UNIGRAM_DELIMETER) {
              currUnigramStart = strBld.length() + 1;
            } else if (transChars[i] == TOKEN_DELIMETER) {
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

        // last token (makes sure strBld.setLength is called always)
        String hgram = strBld.toString();
        strBld.setLength(0);
        hgramList.add(hgram);

        if (skipTransaction) {
          continue;
        }

        nextKeyVal = new Pair<List<String>, Long>(hgramList, ONE);
        return true;
      }
      if (currDayIx < days.size() - 1) {
        transactions = null;
        ++currDayIx;
        return hasNext();
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
