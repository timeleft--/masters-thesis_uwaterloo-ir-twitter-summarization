/**
 * 
 */
package yaboulna.pig;

import java.io.IOException;
import java.util.Set;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.pig.EvalFunc;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;

import ca.uwaterloo.twitter.TokenIterator.LatinTokenIterator;

import com.google.common.collect.Sets;

/**
 * @author yaboulna
 * 
 */
public class TweetTokenizer extends EvalFunc<Tuple> {
  
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
  public Tuple exec(Tuple input) throws IOException {
    if (input == null || input.size() == 0)
      return null;
    try {
      String tweet = StringEscapeUtils.unescapeJava((String) input.get(0));
      
      LatinTokenIterator tokenIter = new LatinTokenIterator(tweet);
      tokenIter.setRepeatHashTag(true);
      tokenIter.setRepeatedHashTagAtTheEnd(true);
      
      Set<String> resSet = Sets.newHashSet();
      while(tokenIter.hasNext()){
    	  resSet.add(tokenIter.next());
      }
      
      Tuple result = TupleFactory.getInstance().newTuple(resSet.size());
      int i=0;
      for(String token: resSet){
    	  result.set(i++, token);
      }
      
      return result;
      
    } catch (Exception e) {
      throw new IOException("Caught exception processing input row " + input.toDelimitedString("\t"), e);
    }
  }
  
}
