package yaboulna.pig;

import java.io.IOException;
import java.util.Iterator;
import java.util.Set;

import org.apache.pig.data.DataBag;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.junit.Test;
import static org.junit.Assert.*;

import com.google.common.collect.Sets;

public class TupleStrToBagTest {

  @Test
  public void testOkFormat() throws IOException{
    TupleStrToBag target = new TupleStrToBag();
    DataBag actual = target.exec(TupleFactory.getInstance().newTuple("(unigram1, unigram2, unigram2)"));
    Set<String> expected = Sets.newHashSet("(unigram1)", "(unigram2)", "(unigram2)");
    Iterator<Tuple> iter = actual.iterator();
    while(iter.hasNext()){
      Tuple actualT = iter.next();
      assertEquals(1, actualT.size());
      assertTrue(expected.contains((String)actualT.get(0)));
    }
    assertFalse(iter.hasNext());
  }
}
