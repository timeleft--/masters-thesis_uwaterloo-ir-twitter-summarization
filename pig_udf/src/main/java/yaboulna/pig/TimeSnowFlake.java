package yaboulna.pig;

import java.io.IOException;

import org.apache.pig.EvalFunc;
import org.apache.pig.data.Tuple;

public class TimeSnowFlake extends EvalFunc<Long> {
  public static long TWEET_EPOCH_MAGIC_NUM = 1288834974657L;
  
  @Override
  public Long exec(Tuple input) throws IOException {
    long uxtime = (Integer) input.get(0);
    int residuals = (Integer) input.get(1);
    long msecs =  residuals >>> 22;
    int idAtT = (((1<<22)-1) & residuals);
    return (((uxtime * 1000L + msecs) - TWEET_EPOCH_MAGIC_NUM) << 22) | (idAtT);
  }
  
}
