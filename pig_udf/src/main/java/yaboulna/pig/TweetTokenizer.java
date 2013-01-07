/**
 * 
 */
package yaboulna.pig;

import java.io.IOException;
import java.util.Arrays;
import java.util.LinkedHashMap;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.pig.EvalFunc;
import org.apache.pig.data.BagFactory;
import org.apache.pig.data.DataBag;
import org.apache.pig.data.DataByteArray;
import org.apache.pig.data.DataType;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.apache.pig.impl.logicalLayer.schema.Schema;

import ca.uwaterloo.twitter.TokenIterator.LatinTokenIterator;

import com.google.common.collect.Maps;

/**
 * @author yaboulna
 * 
 */
public class TweetTokenizer extends EvalFunc<DataBag> {
  
  /*
   * (non-Javadoc)
   * 
   * @see org.apache.pig.EvalFunc#exec(org.apache.pig.data.Tuple)
   */
  
  @Override
  public DataBag exec(Tuple input) throws IOException {
    if (input == null || input.isNull() || input.size() < 1 || input.isNull(0)) {
      return null;
    }
    try {
      String tweet = StringEscapeUtils.unescapeJava((String) input.get(0));
      
      LatinTokenIterator tokenIter = new LatinTokenIterator(tweet);
      tokenIter.setRepeatHashTag(true);
      tokenIter.setRepeatedHashTagAtTheEnd(true);
      
      
      // This will overflow for anything over 127, make sure to interpret it properly
      byte[] pos = new byte[] {0};
      
      LinkedHashMap<String, DataByteArray> resMap = Maps.newLinkedHashMap();
      while (tokenIter.hasNext()) {
        String token = tokenIter.next();
        DataByteArray tokenPosList = resMap.get(token);
        if (tokenPosList == null) {
          tokenPosList = new DataByteArray();
          resMap.put(token, tokenPosList);
        }
        tokenPosList.append(pos);
        ++pos[0];
      }
      
      Tuple[] resArr = new Tuple[resMap.size()];
      int i=0;
      for (String token : resMap.keySet()) {
        DataByteArray tokenPosList = resMap.get(token);
        Tuple tokenTuple = TupleFactory.getInstance().newTuple(2);
        tokenTuple.set(0, token);
        tokenTuple.set(1, (tokenPosList));
        resArr[i++] = tokenTuple;
      }
      
      DataBag result = BagFactory.getInstance().newDefaultBag(Arrays.asList(resArr));
      
      return result;
      
    } catch (Exception e) {
      throw new IOException("Caught exception processing input row "
          + input.toDelimitedString("\t"), e);
    }
  }
  
  public Schema outputSchema(Schema input) {
    try {
      Schema.FieldSchema tokenFs = new Schema.FieldSchema("token", DataType.CHARARRAY);
      Schema.FieldSchema posFS = new Schema.FieldSchema("positions", DataType.BYTEARRAY);
      // cannot be handled by FOREACH DataType.BYTE);
      
      Schema tupleSchema = new Schema(Arrays.asList(tokenFs, posFS));
      
      Schema.FieldSchema tupleFs = new Schema.FieldSchema("tuple_of_token-pos", tupleSchema,
          DataType.TUPLE);
      
      Schema bagSchema = new Schema(tupleFs);
      // bagSchema.setTwoLevelAccessRequired(true);
      Schema.FieldSchema bagFs = new Schema.FieldSchema(
          "bag_of_token-pos_tuples", bagSchema, DataType.BAG);
      
      return new Schema(bagFs);
    } catch (Exception e) {
      return null;
    }
  }
  
}
