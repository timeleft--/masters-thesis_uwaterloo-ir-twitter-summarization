package yaboulna.pig;

import static org.junit.Assert.*;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.Iterator;

import org.apache.pig.backend.executionengine.ExecException;
import org.apache.pig.data.DataBag;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.junit.Before;
import org.junit.Test;

import ca.uwaterloo.twitter.TokenIteratorTest;

import com.google.common.collect.AbstractIterator;

public class TweetToknizerTest extends TokenIteratorTest {

  public static class TweetTokenizerWrapper extends AbstractIterator<String> {

    private DataBag output;
    private Iterator<Tuple> iter;

    public TweetTokenizerWrapper(String string) throws IOException {
      TweetTokenizer delegate = new TweetTokenizer();
      Tuple input = TupleFactory.getInstance().newTuple(1);
      input.set(0, string);
      output = delegate.exec(input);
      iter = output.iterator();
    }

    int posExpected = 0;

    @Override
    protected String computeNext() {
      if (iter.hasNext()) {
        try {
// return (String) iter.next().get(0);
          Tuple currTuple = (Tuple) iter.next();
          Tuple ngramTuple = (Tuple) currTuple.get(0);

          int posActual = (Integer) currTuple.get(3);
          int tweetLenActual = (Integer) currTuple.get(2);
          if (ngramTuple.size() == 1) {
            String ngramTupleStr = ngramTuple.toString();
            if (ngramTupleStr.contains("#") ) { //.matches("#[^#]+.*") ){ //This is not the symbol #
              assertEquals("Wrong pseudo-position", tweetLenActual, posActual);
            } else {
              assertEquals("Wrong position", posExpected++, posActual);
            }
            return (String) ngramTuple.get(0);
          } else {
            // TODO properly test bigrams and hashtag ngrams
            // for now, just emmit them so that I look at them
            System.out.println("NGRAM TUPLE: " + ngramTuple.toString());

// assertEquals("Wrong pseudo-position", posExpected - ngramTuple.size(), posActual);
            return computeNext();
          }
        } catch (ExecException e) {
          return "ExecException: " + e.getMessage();
        }
      } else {
        return endOfData();
      }
    }
  }

  @Before
  public void setUp() {
    targetClazz = TweetTokenizerWrapper.class;
  }

  @Test
  public void testHashTagRepeatedAtTheEnd() throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance("#hshtg1 #htag2 word1 word2 #hashtag3");
    assertEquals("hshtg1", target.next());
    assertEquals("htag2", target.next());
    assertEquals("word1", target.next());
    assertEquals("word2", target.next());
    assertEquals("hashtag3", target.next());
    assertEquals("#hshtg1", target.next());
    assertEquals("#htag2", target.next());
    assertEquals("#hashtag3", target.next());
    assertFalse(target.hasNext());
  }

  @Test
  public void testTooManyHashtags()
      throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance("#hshtg1 #htag2 #hashtag3 #hashtag4 #ht5");
    assertEquals("hshtg1", target.next());
    assertEquals("htag2", target.next());
    assertEquals("hashtag3", target.next());
    assertEquals("hashtag4", target.next());
    assertEquals("ht5", target.next());
    assertEquals("#hshtg1", target.next());
    assertEquals("#htag2", target.next());
    assertEquals("#hashtag3", target.next());
    assertEquals("#hashtag4", target.next());
    assertEquals("#ht5", target.next());
  }

  @Override
  public void testUrl() throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance(
        "http://youtube.com/dsdf33 OK www.wikipedia.com GOOD https://www.bank.com GOTO HTTP://WATCH.THIS www2012_conference");
    assertEquals("URL", target.next());
    assertEquals("ok", target.next());
    assertEquals("URL", target.next());
    assertEquals("good", target.next());
    assertEquals("URL", target.next());
    assertEquals("goto", target.next());
    assertEquals("URL", target.next());
    assertEquals("www2012_conference", target.next());
    assertFalse(target.hasNext());

  }

}
