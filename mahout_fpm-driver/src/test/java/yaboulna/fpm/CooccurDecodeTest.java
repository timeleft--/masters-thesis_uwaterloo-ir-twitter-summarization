package yaboulna.fpm;

import static org.mockito.Matchers.anyInt;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Random;

import org.apache.mahout.math.map.OpenIntObjectHashMap;
import org.junit.Test;

public class CooccurDecodeTest {
  String codedPath = "/Users/yia/fpm_out_debug/cooccurs_3600_1352224800";
  String decodedPath = "/Users/yia/fpm_out_debug/cooccurs_3600_1352199600_2.txt"; //cooccurs_3600_1352206800.txt";

  public static void main(String[] args) throws IOException {
    CooccurDecodeTest test = new CooccurDecodeTest();
    test.verifyDecoded();
  }
  
  //@Test
  public void verifyDecoded() throws IOException {
     BufferedReader fr = new BufferedReader(new FileReader(decodedPath));
    String[] items = null;
    int[] sums = null;
    String ln;
    int j=0;
    int cntItems = -1;
    while((ln=fr.readLine()) != null){
      String[] nums = ln.split("\\t");
      if(cntItems < 0 ){
        cntItems = nums.length-1;
        items = new String[cntItems];
        sums = new int[cntItems];
      }
      int rowsum = 0;
      for(int i=1; i<nums.length; ++i){
        int n = Integer.parseInt(nums[i]);
        if((i-1+5) != j && (i-1+5) < sums.length)
          sums[(i-1+5)] += n;
        rowsum += n;
      }
      sums[j] += rowsum;
      items[j] = nums[0];
      ++j;
    }
    for(int i=0;i<sums.length; ++i){
      if((items[i] == null && sums[i] != 0)
          || (items[i] != null && sums[i] == 0)){
        throw new ArrayIndexOutOfBoundsException("Not the same number of rows as colums");
      } else if((items[i] == null && sums[i] == 0)){
        break;
      }
      System.out.println(items[i]+"="+sums[i]);
    }

    fr.close();
  }
// @Test
  public void testDecodeCooccurs() throws IOException {
    // mock the hashmap
    OpenIntObjectHashMap<String> decodeMap = mock(OpenIntObjectHashMap.class);
// ArgumentCaptor<Integer> argument = ArgumentCaptor.forClass(Person.class);
// 2 verify(mock).doSomething(argument.capture());
// 3 assertEquals("John", argument.getValue().getName());
    Random rand = new Random();
    when(decodeMap.get(anyInt())).thenReturn("item" + rand.nextInt());
    when(decodeMap.size()).thenReturn(100000);
    HgramsWindow.decodeCooccurs(new File(codedPath), new File(codedPath + ".txt"), decodeMap);
  }
}
