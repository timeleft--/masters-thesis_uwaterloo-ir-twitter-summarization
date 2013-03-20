package yaboulna.guava;

import java.nio.charset.Charset;
import java.util.List;

import com.google.common.hash.Funnel;
import com.google.common.hash.PrimitiveSink;

public class Funnels {
  public enum IntArrFunnel implements Funnel<Integer[]> {
    INSTANCE;

    public void funnel(Integer[] arr, PrimitiveSink into) {
      for (Integer i : arr) {
        into.putInt(i);
      }
    }

  }
  
  public enum StrListFunnel implements Funnel<List<String>>{
    INSTANCE;
    
    Charset chset = Charset.forName("UTF-8");
    
    public void funnel(List<String> funneled, PrimitiveSink into) {
      for(String s: funneled){
        into.putString(s, chset);
      }
      
    }
    
  }
}
