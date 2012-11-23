/**
 * 
 */
package yaboulna.pig;

import java.io.IOException;
import java.util.List;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.pig.EvalFunc;
import org.apache.pig.data.DataType;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.apache.pig.impl.logicalLayer.schema.Schema;

import ca.uwaterloo.twitter.TokenIterator.LatinTokenIterator;

import com.google.common.collect.Lists;

/**
 * @author yaboulna
 * 
 */
public class TweetTokenizer extends EvalFunc<Tuple> {
  
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
      
      // Count once later, now wer need to preserve bigrams
      // Set<String> resSet = Sets.newLinkedHashSet();
      List<String> resSet = Lists.newLinkedList();
      while (tokenIter.hasNext()) {
        resSet.add(tokenIter.next());
      }
      
      Tuple result = TupleFactory.getInstance().newTuple(resSet.size());
      int i = 0;
      for (String token : resSet) {
        result.set(i++, token);
      }
      
      return result;
      
    } catch (Exception e) {
      throw new IOException("Caught exception processing input row "
          + input.toDelimitedString("\t"), e);
    }
  }
  
  public Schema outputSchema(Schema input) {
    try {
      Schema.FieldSchema tokenFs = new Schema.FieldSchema("token",
          DataType.CHARARRAY);
      Schema tupleSchema = new Schema(tokenFs);
      
      Schema.FieldSchema tupleFs;
      tupleFs = new Schema.FieldSchema("tuple_of_tokens", tupleSchema,
          DataType.TUPLE);
      
      return new Schema(tupleFs);
    } catch (Exception e) {
      return null;
    }
  }
  
}
