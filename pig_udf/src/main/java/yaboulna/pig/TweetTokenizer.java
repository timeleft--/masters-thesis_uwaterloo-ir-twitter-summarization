/**
 * 
 */
package yaboulna.pig;

import java.io.IOException;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.pig.EvalFunc;
import org.apache.pig.data.Tuple;

import ca.uwaterloo.twitter.TokenIterator.LatinTokenIterator;

/**
 * @author yaboulna
 * 
 */
public class TweetTokenizer extends EvalFunc<String> {
  
  /**
   * 
   */
  public TweetTokenizer() {
  }
  
  /*
   * (non-Javadoc)
   * 
   * @see org.apache.pig.EvalFunc#exec(org.apache.pig.data.Tuple)
   */

  @Override
  public String exec(Tuple input) throws IOException {
    if (input == null || input.size() == 0)
      return null;
    try {
      String tweet = StringEscapeUtils.unescapeJava((String) input.get(0));
      LatinTokenIterator tokenIter = new LatinTokenIterator(tweet);
      tokenIter.setRepeatHashTag(true);
      tokenIter.setRepeatedHashTagAtTheEnd(true);
    } catch (Exception e) {
      throw new IOException("Caught exception processing input row " + input.toDelimitedString("\t"), e);
    }
  }
  
}
