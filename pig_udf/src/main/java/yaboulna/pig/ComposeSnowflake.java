package yaboulna.pig;

import java.io.IOException;

import org.apache.pig.EvalFunc;
import org.apache.pig.data.Tuple;

public class ComposeSnowflake extends EvalFunc<Long> {
  public static long TWEET_EPOCH_MAGIC_NUM = 1288834974657L;
  
  @Override
  public Long exec(Tuple input) throws IOException {
    if(input == null || input.isNull() || input.size() < 2 || input.isNull(0) || input.isNull(1)){
      return null;
    }
    
    long uxtime = (Integer) input.get(0);
    int residuals = (Integer) input.get(1);
    if(residuals == -1) {
      residuals = ((1<<22)-1); // Maximum residuals
    }
    long msecs =  residuals >>> 22;
    int idAtT = (((1<<22)-1) & residuals);
    return (((uxtime * 1000L + msecs) - TWEET_EPOCH_MAGIC_NUM) << 22) | (idAtT);
  }
  
}
