package yaboulna.pig;

import java.io.IOException;
import java.util.regex.Pattern;

import org.apache.pig.EvalFunc;
import org.apache.pig.data.BagFactory;
import org.apache.pig.data.DataBag;
import org.apache.pig.data.DataType;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.apache.pig.impl.logicalLayer.FrontendException;
import org.apache.pig.impl.logicalLayer.schema.Schema;
import org.apache.pig.impl.logicalLayer.schema.Schema.FieldSchema;

public class TupleStrToBag extends EvalFunc<DataBag> {

  protected final Pattern commaSplit = Pattern.compile("\\,");

  @Override
  public DataBag exec(Tuple input) throws IOException {
    DataBag result = BagFactory.getInstance().newDefaultBag(); // DistinctBag???

    String inStr = (String) input.get(0);

    String[] unigrams = commaSplit.split(inStr);
    // remove the opening and closing paranthesis of the tuple string representation
    unigrams[0] = unigrams[0].substring(1);
    unigrams[unigrams.length - 1] = unigrams[unigrams.length - 1].substring(0,
        unigrams[unigrams.length - 1].length() - 1);

    for (String u : unigrams) {
      result.add(TupleFactory.getInstance().newTuple("(" + u.trim() + ")"));
    }

    return result;
  }

  @Override
  public Schema outputSchema(Schema input) {
    Schema result = null;
    try {
//     FieldSchema tupleSchema = new FieldSchema("unigramT", new Schema(new FieldSchema("unigramF",
//          DataType.CHARARRAY)), DataType.TUPLE);
      result = new Schema(new FieldSchema("unigramBag", new Schema(new FieldSchema("unigramF",
        DataType.CHARARRAY)), DataType.BAG));
    } catch (FrontendException e) {
      log.error(e.getMessage(), e);
    }
    return result;
  }
}
