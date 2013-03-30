package yaboulna.fpm.postgresql;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.PrintStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.Set;
import java.util.concurrent.Callable;

import org.apache.mahout.common.Pair;

import com.google.common.base.Joiner;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

public class HgramTransactionIterator implements Iterator<Pair<List<String>, Long>> {

  public static class StreamPipe implements Callable<Void> {

    final InputStream followed;
    final PrintStream sink;

    public StreamPipe(InputStream foll, PrintStream sink) {
      this.followed = foll;
      this.sink = sink;
    }

    @Override
    public Void call() throws Exception {
      BufferedInputStream res = new BufferedInputStream(followed);
      try {
        int chInt;
        while ((chInt = res.read()) != -1) {
          char ch = (char) chInt;
          sink.print(ch);
        }
        sink.print("\n End of subprocess output/error... I hope you like it \n");

      } finally {
        sink.flush();
        res.close();
      }
      return null;
    }

  }

  private static final Long ONE = 1L;

  static final char TOKEN_DELIMETER = '|'; // must be a char
  static final char UNIGRAM_DELIMETER = ','; // must be a char

  static final Set<String> RETWEET_TOKENS = Sets.newHashSet("rt"); // ,"via");

  protected static final String DEFAULT_DRIVER = "org.postgresql.Driver";
  protected static final String DEFAULT_CONNECTION_URL = "jdbc:postgresql://hops.cs.uwaterloo.ca:5433/";
  protected static final String DEFAULT_USER = "yaboulna";
  protected static final String DEFAULT_PASSWORD = "5#afraPG";
  protected static final String DEFAULT_DBNAME = "march";
  protected static final boolean DEBUG_SQL = false;

  protected static final boolean DEFAULT_includeHashtags = true;
  protected static final boolean DEFAULT_EXLUDE_RETWEETS = false;
  protected static final boolean DEFAULT_PREVENT_REPEATED_HGRAMS_IN_TWEET = true;
  protected static final boolean DEFAULT_removeIdenticalTweets = true;

  protected static final int DEFAULT_minPerHourFreq = 1;
  protected static final int DEFAULT_minHoursInHistory = 3;

  final String url;
  final Properties props;
  private Connection conn = null;
  private PreparedStatement stmt = null;

  final boolean excludeRetweets;
  final boolean removeIdenticalTweets;
  final int maxHgramLen;

  final List<String> days;
  final long windowStartUx;
  final long windowEndUx;

  ResultSet transactions = null;
  Pair<List<String>, Long> nextKeyVal = null;
  StringBuilder strBld = new StringBuilder();
  StringBuilder posBld = new StringBuilder();

  long nRowsRead;

  private int currDayIx = 0;

  private int minPerHourFreq;

  private int minHoursInHistory;

  private boolean preventRepeatedHGramsInTweet;

  private boolean includeHashtags;

  private Set<String> topicUnigrams = null;

// private static final String HGRAM_OPENING = "("; // " <, ";
//
// private static final String HGRAM_CLOSING = ")"; // " ,>";

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx,
      int maxLen) throws ClassNotFoundException {
    this(days, windowStartUx, windowEndUx, maxLen, DEFAULT_removeIdenticalTweets,
        DEFAULT_minPerHourFreq, DEFAULT_minHoursInHistory, DEFAULT_includeHashtags,
        DEFAULT_DBNAME, DEFAULT_EXLUDE_RETWEETS, DEFAULT_PREVENT_REPEATED_HGRAMS_IN_TWEET,
        DEFAULT_DRIVER, DEFAULT_CONNECTION_URL, DEFAULT_USER, DEFAULT_PASSWORD);
  }

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx,
      int maxLen, String dbName) throws ClassNotFoundException {
    this(days, windowStartUx, windowEndUx, maxLen, DEFAULT_removeIdenticalTweets,
        DEFAULT_minPerHourFreq, DEFAULT_minHoursInHistory, DEFAULT_includeHashtags,
        dbName, DEFAULT_EXLUDE_RETWEETS, DEFAULT_PREVENT_REPEATED_HGRAMS_IN_TWEET,
        DEFAULT_DRIVER, DEFAULT_CONNECTION_URL, DEFAULT_USER, DEFAULT_PASSWORD);
  }

  public HgramTransactionIterator(List<String> days, long windowStartUx, long windowEndUx,
      int maxLen, boolean removeIdenticalTweets,
      int minPerHourFreq, int minHoursInHistory, boolean includeHashtags,
      String dbname, boolean excludeRetweets, boolean preventRepeatedHGramsInTweet,
      String driverName, String urlPrefix,
      String username, String password) throws ClassNotFoundException {

    this.days = days;
// I don't care about the sequence of tweets but sorting for using days in window
    Collections.sort(this.days);

    this.windowStartUx = windowStartUx;
    this.windowEndUx = windowEndUx;

// if (maxLen < 2 || maxLen > 2) {
// throw new UnsupportedOperationException(
// "Joining multiple tables and selecting only occurrences that aren't included in larger ograms is too much work.. later when it proves really necessary! Right now there are usually nothing in the ogram tables of lengthes more than 2.. I don't know if it is caused by a bug or there really isn't any bigram with high enough propotion of the stream. Maybe what we need to do is to recalculate the proportion of 'Obama' after each len");
// }

    this.maxHgramLen = maxLen;

    this.minPerHourFreq = minPerHourFreq;
    this.minHoursInHistory = minHoursInHistory;

    this.removeIdenticalTweets = removeIdenticalTweets;
    this.excludeRetweets = excludeRetweets;

    this.includeHashtags = includeHashtags;

    this.preventRepeatedHGramsInTweet = preventRepeatedHGramsInTweet;

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

  public int getAbsSupport(double suppPct) throws SQLException {
    int retVal = 5;
    
    Statement suppStmt = conn.createStatement();
    try{
//    @formatter:off
      String suppSql = ""
          + "\n SELECT floor(" + suppPct + " * sum(totalCnt/10.0)) " //10 is avg(tweetLen)
          + "\n FROM volume_1hr1 " //TODONOT: use the ogram_vol. NOT: number of Tweets remain the same
          + "\n WHERE date IN (" + Joiner.on(",").join(days) + ") "
          + "\n   AND epochstartmillis >= (" + windowStartUx + " * 1000::INT8)"
          + "\n   AND epochstartmillis < (" + windowEndUx + " * 1000::INT8)"
          + "\n ";
//    @formatter:on
      
      ResultSet suppRs = suppStmt.executeQuery(suppSql);
      if(suppRs.next()){
        retVal = suppRs.getInt(1); 
      }
      if(suppRs.next()){
        throw new AssertionError();
      }
    }finally{
      suppStmt.close();
    }
    return retVal;
  }

  public Set<String> getTopicWords(int limit, String historyDay1) throws SQLException {

    Statement hiStmt = conn.createStatement();
    try {
      //  @formatter:off
    String hiSql = "("
        + "\n with hist as (select c.ngram, " 
        + "\n     min(c.epochstartmillis) as firstseen, max(c.epochstartmillis) as lastseen,count(*) as appearances, " 
        + "\n     avg(CAST(c.cnt as float8)/CAST(v.totalcnt as float8)) as meanprop, "
        + "\n     stddev_pop(CAST(c.cnt as float8)/CAST(v.totalcnt as float8)) as dvprop " 
        + "\n   from cnt_1hr1 c join volume_1hr1 v on c.epochstartmillis = v.epochstartmillis " 
        + "\n   where cnt >= " + minPerHourFreq + " * (" + (windowEndUx - windowStartUx) +" / 3600.0) and " 
        + "\n     v.date >= " + historyDay1 + " and v.date <= " + days.get(0)
        + "\n     and c.epochstartmillis < (floor(" + windowStartUx + "/3600)*3600 * 1000::INT8)" 
        + "\n    group by c.ngram having count(*) >= " + minHoursInHistory + " * (3600.0 / " + (windowEndUx - windowStartUx) +") ),"
        + "\n curr as (select c.ngram, " 
        + "\n        CAST(sum(c.cnt) as float8)/CAST(sum(v.totalcnt) as float8)  as prop "
        + "\n   from cnt_1hr1 c join volume_1hr1 v on c.epochstartmillis = v.epochstartmillis " 
        + "\n   where cnt >= " + minPerHourFreq + " * (" + (windowEndUx - windowStartUx) +" / 3600.0) and" 
        + "\n     v.date in (" + Joiner.on(",").join(days) + ") "
        + "\n     and c.epochstartmillis >= (floor(" + windowStartUx + "/3600)*3600 * 1000::INT8)"
        + "\n     and (c.epochstartmillis < (floor(" + windowEndUx + "/3600)*3600 * 1000::INT8) or (" + (windowEndUx - windowStartUx) + " < 3600 ))" 
        + "\n   group by c.ngram) "
        + "\n select substring(curr.ngram FROM 2 for char_length(curr.ngram) - 2), CASE WHEN hist.dvprop > 0 THEN " 
        + "\n     ( (curr.prop - hist.meanprop) /hist.dvprop) * " 
        + "\n              ( 1 - (((" + windowStartUx + " * 1000::FLOAT8) - hist.lastseen) / ((" + windowStartUx + " * 1000::FLOAT8) - hist.firstseen)) )"
        + "\n    ELSE -1 END  as durwtstdprop "
        + "\n   from hist join curr on curr.ngram = hist.ngram "
// hour of day fashla:        + "\n    and (curr.epochstartmillis%(24*3600000))/3600000 = (hist.epochstartmillis%(24*3600000))/3600000 "
        + "\n   order by durwtstdprop desc " 
        + "\n   limit " + limit // Limit already set according to epoch length
        + "\n)";
    //@formatter:on

// Luck made me discover that the "novel" ograms are mostly spam.. except "once you go black"
// String timeSql = "date in (" + Joiner.on(',').join(days) + ")"
// + " and epochstartux >= floor(" + windowStartUx + "/3600)*3600 "
// + " and (epochstartux < floor(" + windowEndUx + "/3600)*3600 or ("
// + (windowEndUx - windowStartUx) + " < 3600 ))";
//  @formatter:off
//      String tablename = "ogram_cnt_1hr" + maxHgramLen;
//      String novelSql = "("
//          + "\n with history as (select ngram, count(*) as appearances "
//          + "\n   from " + tablename
//          + "\n   where cnt >= " + minPerHourFreq + " * (" + (windowEndUx - windowStartUx)
//          + "/ 3600.0) and "
//          + "\n     date >= " + historyDay1 + " and date <= " + days.get(0)
//          + "\n     and epochstartux < (floor(" + windowStartUx + "/3600)*3600) "
//          + "\n    group by ngram having count(*) >= " + minHoursInHistory + " * (3600.0 / "
//          + (windowEndUx - windowStartUx) + "))"
//          + "\n select DISTINCT  c.ngram  as ngram, h.appearances as durwtstdprop "
//          + "\n from " + tablename + " c left join history h on c.ngram = h.ngram "
//          + "\n where h.ngram is null and " + timeSql
//          // + "\n       and ngramlen = " + maxHgramLen
//          + "\n       and c.cnt >= " + minPerHourFreq + " * (" + (windowEndUx - windowStartUx)
//          + "/ 3600.0)"
//          + "\n )";
//    @formatter:on   
      ResultSet hiRs = hiStmt.executeQuery(hiSql);
// + "\n UNION ALL \n" // ALL because dupliactes will be elimated in the set anyway DUPLICATES?
// + novelSql);

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

        String tablename;
        if (maxHgramLen == 1) {
          tablename = "ngrams1";
        } else {
          tablename = "ogram_occ_" + days.get(currDayIx) + "_" + maxHgramLen;
        }
// The need for DISTINCT ON (id,pos).. we do need it but for a tiny fraction where
// the data isn't "clean".. that is multiple occurrences appear in the same id,pos
// select count(*) from ogram_occ_121106_2 where ngramlen=2;
// count
// ----------
// 19766647
// (1 row)
// select * from ogram_occ_121106_2 where (id,pos) in (select id,pos from ogram_occ_121106_2
// group by id,pos having count(*) > 1) order by id,pos;
// 266069533033394176 | 1352270894665 | 121106 | DEJAR,DE | 2 | 10 | 7
// 266069533033394176 | 1352270894665 | 121106 | DEJAR | 1 | 10 | 7
// 266069533033394176 | 1352270894665 | 121106 | SONREÍR | 1 | 10 | 9
// 266069533033394176 | 1352270894665 | 121106 | SONREÍR | 1 | 10 | 9
// (1450 ROWS) -> divide that number by 2 (at least) to get the number of faulty locations
// 750 out of 19 million, I don't think it's a big deal

        // DISTINCT FOR DEDUPE of spam tweets
        String dedupe = "";
        if (removeIdenticalTweets) {
          dedupe = "DISTINCT";
        }
        String sql;
        if (includeHashtags) {
          sql = "with tokens as (select id,htag as ngram from hashtags where " + timeSql
              + " UNION ALL "
              + " select id,ngram from " + tablename + " where "
              + timeSql
              + " and ngramlen <= " + maxHgramLen + ")"
              + " select " + dedupe + " string_agg(ngram,?) from tokens "
              + " group by id";
        } else {
          sql = "select " + dedupe + " string_agg(ngram,?) from " + tablename + " where "
              + timeSql
              + " and ngramlen <= " + maxHgramLen
              + " group by id";
        }
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, "" + TOKEN_DELIMETER);

        // example sql: "select id,string_agg(ngram,'|') from ogram_occ_120917_2_1347904800_unextended group by id;"
        transactions = stmt.executeQuery();

      }
      while (transactions.next()) {
        ++nRowsRead;

        char[] transChars = transactions.getString(1).toCharArray();

        Collection<String> ogramList;
        if (preventRepeatedHGramsInTweet) {
          ogramList = Sets.newHashSet();
        } else {
          ogramList = Lists.newLinkedList();
        }

        boolean skipTransaction = (topicUnigrams != null);
        int currUnigramStart = 1;

        for (int i = 0; i < transChars.length; ++i) {
          boolean lastIter = i == transChars.length - 1;
          if ((excludeRetweets || (topicUnigrams != null)) &&
              (transChars[i] == UNIGRAM_DELIMETER ||
                  transChars[i] == TOKEN_DELIMETER ||
              lastIter)) {

            String uni = strBld.substring(currUnigramStart,
                // to skip the closing paranthesis, note that || transChars[i] == ')' --> lastIter
                strBld.length() - (transChars[i] == TOKEN_DELIMETER ? 1 : 0));

            if (excludeRetweets && RETWEET_TOKENS.contains(uni)) {
              skipTransaction = true;
              break;
            }

            if ((topicUnigrams != null) && topicUnigrams.contains(uni)) {
              skipTransaction = false;
            }

            if (transChars[i] == UNIGRAM_DELIMETER) {
              currUnigramStart = strBld.length() + 1;
            } else if (transChars[i] == TOKEN_DELIMETER) {
              currUnigramStart = 1; // to skip the opening paranthesis
            }
          }

          if (transChars[i] == TOKEN_DELIMETER) {
            String ogram = strBld.toString();
            strBld.setLength(0);

// ogramList.add(HGRAM_OPENING + ogram + HGRAM_CLOSING);
            ogramList.add(ogram);

          } else {
            strBld.append(transChars[i]);
          }
        }

        // last token
        String ogram = strBld.toString();
        strBld.setLength(0);

// ogramList.add(HGRAM_OPENING + ogram + HGRAM_CLOSING);
        ogramList.add(ogram);

        if (skipTransaction) {
          continue;
        }

        if (preventRepeatedHGramsInTweet) {
          ogramList = ImmutableList.copyOf(ogramList);
        }

        nextKeyVal = new Pair<List<String>, Long>((List<String>) ogramList, ONE);
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

  public void setTopicUnigrams(Set<String> topicUnigrams) {
    this.topicUnigrams = topicUnigrams;
  }

}
