package yaboulna.fpm;

import static org.mockito.Matchers.anyInt;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.io.File;
import java.io.IOException;
import java.util.Random;

import org.apache.mahout.math.map.OpenIntObjectHashMap;
import org.junit.Test;

public class CooccurDecodeTest {
  String inPath = "/Users/yia/fpm_out_debug/cooccurs_3600_1352224800";
  
  @Test
  public void testDecodeCooccurs() throws IOException{
    // mock the hashmap
    OpenIntObjectHashMap<String> decodeMap = mock(OpenIntObjectHashMap.class);
//    ArgumentCaptor<Integer> argument = ArgumentCaptor.forClass(Person.class);
//    2 verify(mock).doSomething(argument.capture());
//    3 assertEquals("John", argument.getValue().getName());
    Random rand =  new Random();
    when(decodeMap.get(anyInt())).thenReturn("item"+rand.nextInt());
    when(decodeMap.size()).thenReturn(100000);
    HgramsWindow.decodeCooccurs(new File(inPath), new File(inPath+".txt"),decodeMap);
  }
}
