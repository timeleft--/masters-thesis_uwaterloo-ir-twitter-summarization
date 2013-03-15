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
  String decodedPath = "/Users/yia/fpm_out_debug/cooccurs_3600_1352206800.txt";

  //@Test
  public void verifyDecoded() throws IOException {
    BufferedReader fr = new BufferedReader(new FileReader(decodedPath));
    String[] items = new String[100000];
    int[] sums = new int[100000];
    String ln;
    int j=0;
    int cntItems = -1;
    while((ln=fr.readLine()) != null){
      String[] nums = ln.split("\\t");
      if(cntItems < 0 ){
        cntItems = nums.length-1;
      }
      int sum = 0;
      for(int i=1; i<nums.length; ++i){
        int n = Integer.parseInt(nums[i]);
        sums[5 + nums.length-1-(i-1)] += n;
        sum += n;
      }
      sums[5+ cntItems-1-j]+=sum;
      items[j] = nums[0];
      ++j;
    }
    for(int i=5;i<sums.length; ++i){
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
