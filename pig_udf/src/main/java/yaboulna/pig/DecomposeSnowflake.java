package yaboulna.pig;

import java.io.IOException;
import java.util.Arrays;

import org.apache.pig.EvalFunc;
import org.apache.pig.data.DataType;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.apache.pig.impl.logicalLayer.schema.Schema;

public class DecomposeSnowflake extends EvalFunc<Tuple> {
  
  @Override
  public Tuple exec(Tuple input) throws IOException {
    if(input == null || input.isNull() || input.size() < 1 || input.isNull(0)){
      return null;
    }
    
    long sf = (Long) input.get(0);
    
    int idAtT =  (int) (sf & ((1<<22)-1)); // the first 22 bits
    
    long timestamp =  (sf >> 22) + ComposeSnowflake.TWEET_EPOCH_MAGIC_NUM;
    int uxTimestamp = (int) (timestamp / 1000);
    int ms = (int) (timestamp % 1000);
    
    int redisdues = (ms << 22) | idAtT;
    
    Tuple result = TupleFactory.getInstance().newTuple(2);
    result.set(0, uxTimestamp);
    result.set(1, redisdues);
    
    return result;
  }
  
  @Override
  public Schema outputSchema(Schema input) {
    Schema.FieldSchema uxTimeFS = new Schema.FieldSchema("uxTime", DataType.INTEGER);
    Schema.FieldSchema residuesFS = new Schema.FieldSchema("msIdAtT", DataType.INTEGER);
    
    Schema result = new Schema(Arrays.asList(uxTimeFS,residuesFS));
    
    return result;
  }
  
}
