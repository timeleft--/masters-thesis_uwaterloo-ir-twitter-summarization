package yaboulna.fpm.postgresql;

import static org.junit.Assert.*;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;

import org.apache.mahout.common.Pair;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.base.Joiner;

public class HgramTransactionsIterTest {

  HgramTransactionIterator target;
  private Connection con;
  private Statement stmt;
  private ResultSet expected;

  @Before
  public void setup() throws ClassNotFoundException, SQLException {
    target = new HgramTransactionIterator(Arrays.asList("121105"), 1352152800L, 1352152800L + 3600,
        2, "sample-0.01");
    target.init();
    
    con = DriverManager.getConnection(target.url, target.props);
    stmt = con.createStatement();
    expected = stmt
        .executeQuery("select string_agg(ngram,'|') from hgram_occ_121105_2 "
            
            + " where timemillis >= (1352152800 * 1000::INT8) and timemillis < ((1352152800 + 3600) * 1000::INT8) "
            + " group by id; ");
    
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
  //TODO: get all from target.RETWEET_TOKENS, not only "rt"
  static final Pattern retweetPattern = Pattern.compile("(^|" +delimClass + ")"
      + "rt" + "($|" + delimClass + ")");
  
  @Test
  public void testNoHasNextCallExlcludeRetweets() throws SQLException{
    int nrow = 0;
    while(expected.next()){
      ++nrow;
      String expTweet = expected.getString(1);
      if(retweetPattern.matcher(expTweet).find()){ 
        continue;
      }
      
      Pair<List<String>, Long> actual = target.next();
      if(actual == null){
        fail("Less rows in actual than expected");
      }
      assertEquals(expTweet, Joiner.on(HgramTransactionIterator.TOKEN_DELIMETER).join(actual.getFirst()));
    }
    assertEquals(nrow, target.getRowsRead());
    assertFalse("More rows in actual than expected",target.hasNext());
  }
}
