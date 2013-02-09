package yaboulna.pig;

import java.io.IOException;
import java.util.regex.Pattern;

import org.apache.pig.EvalFunc;
import org.apache.pig.backend.executionengine.ExecException;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;

public class TupleStrToTuple extends EvalFunc<Tuple> {

  protected final static Pattern commaSplit = Pattern.compile("\\,");

  
  public static Tuple readTupleFromStr(String inStr) throws ExecException{
    
    String[] unigrams = commaSplit.split(inStr);
    
    Tuple result = TupleFactory.getInstance().newTuple(unigrams.length);
    
    // remove the opening and closing paranthesis of the tuple string representation
    unigrams[0] = unigrams[0].substring(1);
    unigrams[unigrams.length - 1] = unigrams[unigrams.length - 1].substring(0,
        unigrams[unigrams.length - 1].length() - 1);

    int i=0;
    for (String u : unigrams) {
      result.set(i++, u.trim());
    }
    
    return result;
  }
  
  @Override
  public Tuple exec(Tuple input) throws IOException {
    

    String inStr = (String) input.get(0);

    

    return readTupleFromStr(inStr);
  }

//  @Override
//  public Schema outputSchema(Schema input) {
//    Schema result = null;
//    try {
////     FieldSchema tupleSchema = new FieldSchema("unigramT", new Schema(new FieldSchema("unigramF",
////          DataType.CHARARRAY)), DataType.TUPLE);
//      result = new Schema(new FieldSchema("unigramBag", new Schema(new FieldSchema("unigramF",
//        DataType.CHARARRAY)), DataType.BAG));
//    } catch (FrontendException e) {
//      log.error(e.getMessage(), e);
//    }
//    return result;
//  }
}
