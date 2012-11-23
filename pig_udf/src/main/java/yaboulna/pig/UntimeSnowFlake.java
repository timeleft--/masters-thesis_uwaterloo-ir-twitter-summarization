package yaboulna.pig;

import java.io.IOException;

import org.apache.pig.EvalFunc;
import org.apache.pig.data.Tuple;

public class UntimeSnowFlake extends EvalFunc<Integer> {
  
  @Override
  public Integer exec(Tuple input) throws IOException {
    long sf = (Long) input.get(0);
    int idAtT =  (int) (sf & ((1<<22)-1)); // the first 22 bits
    long timestamp =  (sf >> 22) + TimeSnowFlake.TWEET_EPOCH_MAGIC_NUM;
    int ms = (int) (timestamp % 1000);
    return (ms << 22) | idAtT; 
  }
  
}
