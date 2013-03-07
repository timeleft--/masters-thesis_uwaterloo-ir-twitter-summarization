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
import org.joda.time.DateMidnight;
import org.joda.time.DateTimeZone;
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
  protected static final boolean DEBUG_SQL = false;
  protected static final boolean DEFAULT_EXLUDE_RETWEETS = false;

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


  private static final String HGRAM_OPENING = "{"; // " <, ";

  private static final String HGRAM_CLOSING = "}"; // " ,>";

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx,
      int maxLen) throws ClassNotFoundException {
    this(days, windowStartUx, windowEndUx, maxLen, DEFAULT_DBNAME, true,
        DEFAULT_DRIVER, DEFAULT_CONNECTION_URL, DEFAULT_USER, DEFAULT_PASSWORD);
  }

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx,
      int maxLen, String dbName) throws ClassNotFoundException {
    this(days, windowStartUx, windowEndUx, maxLen, dbName, DEFAULT_EXLUDE_RETWEETS,
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

  public Set<String> getTopicWords(int limit, String historyDay1) throws SQLException {
    
    Statement hiStmt = conn.createStatement();
    try {
      // TODO: 5 should be substituted by support variable, and 3 by something as min appearances
      //  @formatter:off
    String hiSql = "("
        + "\n with hist as (select c.ngramarr, " 
        + "\n     min(c.epochstartmillis) as firstseen, max(c.epochstartmillis) as lastseen,count(*) as appearances, " 
        + "\n     avg(CAST(c.cnt as float8)/CAST(v.totalcnt as float8)) as meanprop, "
        + "\n     stddev_pop(CAST(c.cnt as float8)/CAST(v.totalcnt as float8)) as dvprop " 
        + "\n   from cnt_1hr1 c join volume_1hr1 v on c.epochstartmillis = v.epochstartmillis " 
        + "\n   where cnt >= 5 and " 
        + "\n     date >= " + historyDay1 + " and date <= " + days.get(0)
        + "\n     and c.epochstartmillis < (floor(" + windowStartUx + "/3600)*3600 * 1000::INT8)" 
        + "\n    group by c.ngramarr having count(*) >= 3),"
        + "\n curr as (select c.ngramarr, " 
        + "\n        CAST(sum(c.cnt) as float8)/CAST(sum(v.totalcnt) as float8)  as prop "
        + "\n   from cnt_1hr1 c join volume_1hr1 v on c.epochstartmillis = v.epochstartmillis " 
        + "\n   where cnt >= 5 and" 
        + "\n     date in (" + Joiner.on(",").join(days) + ") "
        + "\n     and c.epochstartmillis >= (floor(" + windowStartUx + "/3600)*3600 * 1000::INT8)"
        + "\n     and (c.epochstartmillis < (floor(" + windowEndUx + "/3600)*3600 * 1000::INT8) or (" + (windowEndUx - windowStartUx) + " < 3600 ))" 
        + "\n   group by c.ngramarr) "
        + "\n select CAST(curr.ngramarr AS text)," 
        + "\n     ( (curr.prop - hist.meanprop) /hist.dvprop) * " 
        + "\n              ( 1 - (((" + windowStartUx + " * 1000::FLOAT8) - hist.lastseen) / ((" + windowStartUx + " * 1000::FLOAT8) - hist.firstseen)) )"
        + "\n           as durwtstdprop"
        + "\n   from hist join curr on curr.ngramarr = hist.ngramarr "
// hour of day fashla:        + "\n    and (curr.epochstartmillis%(24*3600000))/3600000 = (hist.epochstartmillis%(24*3600000))/3600000 "
        + "\n   order by durwtstdprop desc " 
        + "\n   limit " + limit 
        + "\n)";
    //@formatter:on    

      for (String day : days) {
        String timeSql = "date = " + day + " "
            + " and epochstartux >= floor(" + windowStartUx + "/3600)*3600 "
            + " and (epochstartux < floor(" + windowEndUx + "/3600)*3600 or (" + (windowEndUx - windowStartUx) + " < 3600 ))";

        String tablename = "hgram_cnt_1hr" + maxHgramLen + "_" + day;
        String novelSql = "select DISTINCT '{' || ngram || '}' as ngramarr, 0 as durwtstdprop from " + tablename + " where " + timeSql
            + " and ngramlen = " + maxHgramLen;
        
        hiSql += "\n UNION ALL \n" // ALL because dupliactes will be elimated in the set anyway DUPLICATES?
            + novelSql;
      
      }
      
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
        String timeSql = "date = " + days.get(currDayIx) + " "
            + " and timemillis >= (" + windowStartUx + " * 1000::INT8)"
            + " and timemillis < (" + windowEndUx + " * 1000::INT8) ";

        String tablename = "hgram_occ_" + days.get(currDayIx) + "_" + maxHgramLen;
        
// The need for DISTINCT ON (id,pos).. we do need it but for a tiny fraction where
// the data isn't "clean".. that is multiple occurrences appear in the same id,pos        
//select count(*) from hgram_occ_121106_2 where ngramlen=2;
//  count   
//----------
// 19766647
//(1 row)
//select * from hgram_occ_121106_2 where (id,pos) in (select id,pos from hgram_occ_121106_2
//        group by id,pos having count(*) > 1) order by id,pos;
//        266069533033394176 | 1352270894665 | 121106 | DEJAR,DE                    |        2 |       10 |   7
//        266069533033394176 | 1352270894665 | 121106 | DEJAR                       |        1 |       10 |   7
//        266069533033394176 | 1352270894665 | 121106 | SONREÍR                     |        1 |       10 |   9
//        266069533033394176 | 1352270894665 | 121106 | SONREÍR                     |        1 |       10 |   9
//       (1450 ROWS) -> divide that number by 2 (at least) to get the number of faulty locations 
// 750 out of 19 million, I don't think it's a big deal

        //DISTINCT FOR DEDUPE of spam tweets
        String sql = "select DISTINCT string_agg(ngram,?) from " + tablename + " where " + timeSql
            + " and ngramlen <= " + maxHgramLen
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

          if (excludeRetweets && // TODO if not find the rest of the tweet in the buffer and increase its support by 1
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
            hgramList.add(HGRAM_OPENING + hgram + HGRAM_CLOSING);
          } else {
            strBld.append(transChars[i]);
          }

        }

        // last token (makes sure strBld.setLength is called always)
        String hgram = strBld.toString();
        strBld.setLength(0);
        hgramList.add(HGRAM_OPENING + hgram + HGRAM_CLOSING);

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
