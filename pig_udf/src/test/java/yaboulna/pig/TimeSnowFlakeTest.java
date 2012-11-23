package yaboulna.pig;

import static org.junit.Assert.*;

import java.io.IOException;

import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.junit.Test;

/**
 * @author yaboulna
 * 
 */
public class TimeSnowFlakeTest {
  static int MASK22B = 4194303;
  
  static Long TEST_ID = 246421517250985985L;
  static int UXTIME = (int) (1347586442660L / 1000); // api reported: 1347586443000L
  static int MSECS = 660;
  static Integer IDATT = 131073 + (MSECS << 22); 
  
  @Test
  public void testUntimeSnowFlake() throws IOException {
    UntimeSnowFlake target = new UntimeSnowFlake();
    Integer actual = target.exec(TupleFactory.getInstance().newTuple(TEST_ID));
    assertEquals(IDATT, actual);
  }
  
  @Test
  public void testTimeSnowFlake() throws IOException {
    TimeSnowFlake target = new TimeSnowFlake();
    Tuple input = TupleFactory.getInstance().newTuple(3);
    input.set(0, UXTIME);
//    input.set(1, MSECS);
    input.set(1, IDATT);
    Long actual = target.exec(input);
    assertEquals(TEST_ID, actual);
  }
}
