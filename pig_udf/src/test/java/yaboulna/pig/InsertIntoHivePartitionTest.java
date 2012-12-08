package yaboulna.pig;


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
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
  
  private static final String TEST_TOKEN = "123test_Token#Habal@FelGabal456";
  
  private Tuple input;
  private Tuple group;
  private List<Tuple> postingsList;
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
    // hdfs://scspc400.cs.uwaterloo.ca:8020/user/yaboulna
    // file:///u2/yaboulnaga/data
    // /user/yaboulna
    input.set(2, "/user/yaboulna"
        + "/twitter-tracked/debug_hive/");
    
    target = new InsertIntoHivePartition();
  }
  
  @Test
  public void goodDataTest() throws IOException, ClassNotFoundException, SQLException {
    
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
    
    
    ///////////////////////////
    
    Tuple rec2 = TupleFactory.getInstance().newTuple(3);
    rec2.set(0, 1);
    rec2.set(1, 5);
    rec2.set(2, 6);
    postingsList.add(rec2);
    
    ///////////////////////////
    
    Tuple rec3 = TupleFactory.getInstance().newTuple(3);
    rec3.set(0, 7);
    rec3.set(1, 8);
    rec3.set(2, 9);
    postingsList.add(rec3);
    
    //////////////////////////
    group.set(0, TEST_TOKEN);
    group.set(1, 2012);
    group.set(2, 11);
    group.set(3, 22);
    
    target.exec(input);
    
    ////////////////////////////
    Connection con = null;
    try {
      Class.forName(InsertIntoHivePartition.driverName);
      con = DriverManager.getConnection(target.serverURL, target.serverUName, target.serverPasswd);
      Statement stmt = con.createStatement();
      ResultSet res = stmt.executeQuery("SELECT * FROM "+TEST_TOKEN);
      
      String expectedArr, actualArr; //java.sql.Array is not supported by the JDBC driver
      
      assertTrue(res.next());
      assertEquals(1,res.getInt(1));
      assertEquals(2,res.getInt(2));
      actualArr = res.getString(3);
//      expectedArr = con.createArrayOf("INT", new Integer[] {3,4});
      expectedArr = Arrays.asList(3,4).toString();
      assertEquals(expectedArr,actualArr);
      
      assertTrue(res.next());
      assertEquals(1,res.getInt(1));
      assertEquals(5,res.getInt(2));
//      expectedArr = con.createArrayOf("INT", new Integer[] {6});
      expectedArr = Arrays.asList(6).toString();
      actualArr = res.getString(3);
      assertEquals(expectedArr,actualArr);
      
      assertTrue(res.next());
      assertEquals(7,res.getInt(1));
      assertEquals(8,res.getInt(2));
//      expectedArr = con.createArrayOf("INT", new Integer[] {9});
      expectedArr = Arrays.asList(9).toString();
      actualArr = res.getString(3);
      assertEquals(expectedArr,actualArr);
      
      // FAILS because the resultset just keeps moving ahead looping on itself
//    assertFalse(res.next());      
      ///isLast()isAfterLast() are also not supported
//      while(res.next()){
//        System.err.println(res.getInt(1)+"\t"+res.getInt(2)+"\t"+res.getString(3));
//      }
      
      stmt.executeUpdate("DROP TABLE " + TEST_TOKEN);
      
    }finally{
      if(con!=null && !con.isClosed()){
        con.close();
      }
    }
  }
  
  @Test
  public void testUniqueHash() throws IOException {
    target.uniqueTokenHash(TEST_TOKEN);
  }
  
}
