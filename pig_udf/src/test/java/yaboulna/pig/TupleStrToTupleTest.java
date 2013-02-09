package yaboulna.pig;

import static org.junit.Assert.assertEquals;

import java.io.IOException;

import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.junit.Test;

public class TupleStrToTupleTest {

  @Test
  public void testOkFormat() throws IOException {
    TupleStrToTuple target = new TupleStrToTuple();
    Tuple actual = target.exec(TupleFactory.getInstance().newTuple(
        "(unigram0, unigram1, unigram2)"));
    assertEquals(3, actual.size());
    for(int i=0; i<actual.size(); ++i){
     assertEquals("unigram"+i, actual.get(i));
    }
  }
}
