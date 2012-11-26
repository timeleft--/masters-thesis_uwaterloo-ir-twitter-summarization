package yaboulna.pig;

import java.io.IOException;
import java.util.List;

import org.apache.pig.backend.executionengine.ExecException;
import org.apache.pig.data.BagFactory;
import org.apache.pig.data.DataBag;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.Lists;

public class InsertIntoHivePartitionTest {
  
  private Tuple input;
  private Tuple group;
  private List<Tuple>  postingsList;
  private DataBag postingsBag;
  private InsertIntoHivePartition target;
  
  @Before
  public void setUp() throws ExecException {
    input = TupleFactory.getInstance().newTuple(3);
    group = TupleFactory.getInstance().newTuple(4);
    
    postingsList = Lists.newLinkedList();
    postingsBag = BagFactory.getInstance().newDefaultBag(postingsList);
    
    input.set(0, group);
    input.set(1, postingsBag);
    input.set(2, "file:///u2/yaboulnaga/data/twitter-tracked/debug_hive/");
    
    target = new InsertIntoHivePartition();
  }
  
  @Test
  public void goodDataTest() throws IOException{
    
    Tuple rec0 = TupleFactory.getInstance().newTuple(3);
    rec0.set(0, 1);
    rec0.set(1, 2);
    rec0.set(2, 3);
    postingsList.add(rec0);
    
    Tuple rec1 = TupleFactory.getInstance().newTuple(3);
    rec1.set(0, 1);
    rec1.set(1, 2);
    rec1.set(2, 4);
    postingsList.add(rec1);
    
    Tuple rec2 = TupleFactory.getInstance().newTuple(3);
    rec2.set(0, 1);
    rec2.set(1, 5);
    rec2.set(2, 6);
    postingsList.add(rec2);
    
    Tuple rec3 = TupleFactory.getInstance().newTuple(3);
    rec3.set(0, 7);
    rec3.set(1, 8);
    rec3.set(2, 9);
    postingsList.add(rec3);
    
    group.set(0, "test");
    group.set(1, 2012);
    group.set(2, 11);
    group.set(3, 22);
    
    target.exec(input);
  }
}
