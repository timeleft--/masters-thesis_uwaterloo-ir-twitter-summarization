package yaboulna.pig;

import static org.junit.Assert.*;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;

import org.apache.pig.backend.executionengine.ExecException;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.junit.Before;
import org.junit.Test;

import ca.uwaterloo.twitter.TokenIteratorTest;

import com.google.common.collect.AbstractIterator;

public class TweetToknizerTest extends TokenIteratorTest {
  
  public static class TweetTokenizerWrapper extends AbstractIterator<String> {
    
    private Tuple output;
    private int currIx = 0;
    
    public TweetTokenizerWrapper(String string) throws IOException {
      TweetTokenizer delegate = new TweetTokenizer();
      Tuple input = TupleFactory.getInstance().newTuple(1);
      input.set(0, string);
      output = delegate.exec(input);
    }
    
    @Override
    protected String computeNext() {
      if (currIx < output.size()) {
        try {
          return (String) output.get(currIx++);
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
        .newInstance("#hashtag1 #hashtag2 repeated");
    assertEquals("hashtag1", target.next());
    assertEquals("hashtag2", target.next());
    assertEquals("repeated", target.next());
    assertEquals("#hashtag1", target.next());
    assertEquals("#hashtag2", target.next());
    assertFalse(target.hasNext());
  }
  
}
