package yaboulna.fpm.postgresql;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.fail;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.io.Writer;
import java.nio.channels.Channels;
import java.nio.charset.Charset;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.regex.Pattern;

import org.apache.mahout.common.Pair;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.base.Joiner;

public class HgramTransactionsIterTest {

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
        sink.print("\n End of subprocess output... I hope you like it \n");

      } finally {
        sink.flush();
        res.close();
      }
      return null;
    }

  }

  HgramTransactionIterator target;
  private Connection con;
  private Statement stmt;
  private ResultSet expected;

  @Before
  public void setup() throws ClassNotFoundException, SQLException {
    target = new HgramTransactionIterator(Arrays.asList("121105", "121106"), 1352192400L, 1352199600L,
        2, "sample-0.01");
    target.init();

    con = DriverManager.getConnection(target.url, target.props);
    stmt = con.createStatement();

  }

  @After
  public void tearDown() throws SQLException {
    target.uninit();

    if (expected != null) {
      expected.close();
    }

    if (stmt != null) {
      stmt.close();
    }

    if (con != null) {
      con.close();
    }
  }

  static final String delimClass = "[\\" + HgramTransactionIterator.TOKEN_DELIMETER
      + "\\" + HgramTransactionIterator.UNIGRAM_DELIMETER + "]";
  // TODO: get all from target.RETWEET_TOKENS, not only "rt"
  static final Pattern retweetPattern = Pattern.compile("(^|" + delimClass + ")"
      + "rt" + delimClass);
  private static final char EOF = '\u001a';
// FIXME when the "rt" can be caught even if the last unigram: "($|" + delimClass + ")");

// @Test
  public void testNoHasNextCallExlcludeRetweets() throws SQLException {
    String sqlTemplate = "(select string_agg(ngram,'|') as tokenized from hgram_occ_DAY_2 "
        + " where timemillis >= (1352192400 * 1000::INT8) and timemillis < (1352199600 * 1000::INT8) "
        + " group by id) "; // having string_agg(ngram,'|') !~ '(^|[\\|\\,])rt([\\|\\,]|$)'; ");
    expected = stmt
        .executeQuery(sqlTemplate.replace("DAY", "121105") + " UNION ALL " + sqlTemplate.replace("DAY", "121106"));

    int nrow = 0;
    while (expected.next()) {
      ++nrow;
      String expTweet = expected.getString(1);
      if (retweetPattern.matcher(expTweet).find()) {
        continue;
      }

      Pair<List<String>, Long> actual = target.next();
      if (actual == null) {
        fail("Less rows in actual than expected");
      }
      assertEquals(expTweet, Joiner.on(HgramTransactionIterator.TOKEN_DELIMETER).join(actual.getFirst()));
    }
// assertEquals(nrow, target.getRowsRead());
    assertFalse("More rows in actual than expected", target.hasNext());
  }

// // @Test
// public void testTopicWords() throws SQLException{
// Set<String> features = target.getTopicWords(2000);
// assertEquals(10000, features.size());
// }

  @Test
  public void testPlumbing() throws IOException {

    Runtime rt = Runtime.getRuntime();
    Process proc = rt
        .exec("/u2/yaboulnaga/Dropbox/fim/fimi/fp-zhu/test_plumbing /dev/stdin"); // /u2/yaboulnaga/Dropbox/fim/fimi/dataset/kosarak.dat");

    ExecutorService executor = Executors.newFixedThreadPool(2);

    StreamPipe outPipe = new StreamPipe(proc.getInputStream(), System.out);
    Future<Void> outFut = executor.submit(outPipe);

    StreamPipe errPipe = new StreamPipe(proc.getErrorStream(), System.err);
    Future<Void> errFut = executor.submit(errPipe);

    PrintStream feeder = new PrintStream(new BufferedOutputStream(proc.getOutputStream()), true, "US-ASCII");

    feeder.print("1 2 3 4 5 6 7 8 9 10\n");
    
    // feeder.print(Long.MAX_VALUE + "\n"); //expected: 18446744073709551615 actual: -1
    feeder.print(Integer.MAX_VALUE + "\n"); // 2147483647 both expected and actual

    // TODO: Can we make use of the negative numbers to indicate (to ourselves) what heads are interesting

    // Emitate EOF
    // This is unnecessary.. uncomment to see it is uneffective feeder.print(EOF);
    // Not really necessary but not harmful, autoflush is already set! feeder.flush();
    feeder.close();

    try {
      errFut.get();
      outFut.get();
    } catch (InterruptedException e) {
      e.printStackTrace();
    } catch (ExecutionException e) {
      e.printStackTrace();
    }

    executor.shutdown();

  }
}
