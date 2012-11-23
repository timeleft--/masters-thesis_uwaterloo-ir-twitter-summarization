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
public class SnowflakeTest {
  static int MASK22B = 4194303;
  
  static Long TEST_ID = 246421517250985985L;
  static int UXTIME = (int) (1347586442660L / 1000); // api reported: 1347586443000L
  static int MSECS = 660;
  static Integer IDATT = 131073 + (MSECS << 22); 
  
  @Test
  public void testDecomposeSnowflake() throws IOException {
    DecomposeSnowflake target = new DecomposeSnowflake();
    Tuple actual = target.exec(TupleFactory.getInstance().newTuple(TEST_ID));
    assertEquals(2, actual.size());
    assertEquals(UXTIME, actual.get(0));
    assertEquals(IDATT, actual.get(1));
  }
  
  @Test
  public void testTimeSnowFlake() throws IOException {
    ComposeSnowflake target = new ComposeSnowflake();
    Tuple input = TupleFactory.getInstance().newTuple(3);
    input.set(0, UXTIME);
//    input.set(1, MSECS);
    input.set(1, IDATT);
    Long actual = target.exec(input);
    assertEquals(TEST_ID, actual);
  }
  
  @Test
  public void testNull() throws IOException {
    ComposeSnowflake tC = new ComposeSnowflake();
    assertNull(tC.exec(null));
    assertNull(tC.exec(TupleFactory.getInstance().newTuple()));
    
    Tuple oneTuple = TupleFactory.getInstance().newTuple(2);
    assertNull(tC.exec(oneTuple));
    oneTuple.setNull(true);
    assertNull(tC.exec(oneTuple));
    oneTuple.set(0, null);
    oneTuple.set(1, 1);
    
    assertNull(tC.exec(oneTuple));
    oneTuple.set(0, 1);
    oneTuple.set(1, null);
    assertNull(tC.exec(oneTuple));
    tC = null;
    
    DecomposeSnowflake tD = new DecomposeSnowflake();
    assertNull(tD.exec(null));
    assertNull(tD.exec(TupleFactory.getInstance().newTuple()));
    
    oneTuple = TupleFactory.getInstance().newTuple(1);
    assertNull(tD.exec(oneTuple));
    oneTuple.setNull(true);
    assertNull(tD.exec(oneTuple));
    oneTuple.set(0, null);
    assertNull(tD.exec(oneTuple));
  }
}
