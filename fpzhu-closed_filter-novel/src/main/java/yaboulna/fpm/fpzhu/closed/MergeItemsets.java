package yaboulna.fpm.fpzhu.closed;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.apache.commons.io.filefilter.IOFileFilter;

import com.google.common.collect.Lists;

import cern.colt.bitvector.BitMatrix;
import cern.colt.bitvector.QuickBitVector;

public class MergeItemsets {

  public static final int AVERAGE_FREQUENT_ITEMSETS_PER_HOUR = 10000; // anecdotal not really calculated

  /**
   * @param args
   * @throws IOException 
   */
  public static void main(String[] args) throws IOException {
    File dataDir = new File(args[0]);
    if (!dataDir.exists()) {
      throw new IllegalArgumentException("Path doesn't exist: " + dataDir.getAbsolutePath());
    }

    List<File> novelFiles = (List<File>) FileUtils.listFiles(dataDir, new IOFileFilter() {

      public boolean accept(File dir, String name) {
        return name.startsWith("novel_");
      }

      public boolean accept(File file) {
        return accept(file, file.getName());
      }
    }, FileFilterUtils.trueFileFilter());
    
    for(File novF: novelFiles){
      File idfFile = new File(novF.getParentFile(), novF.getName().replaceFirst("novel_", "idf-tokens_"));
      if (!idfFile.exists()) {
        continue;
      }
      List<String> tokens = FileUtils.readLines(idfFile);
      
      List<QuickBitVector> termOccs = Lists.newLinkedList();
      
      FileReader novR = new FileReader(novF);
      try{
      int chInt;
      while((chInt = novR.read()) != -1){
        char ch = (char) chInt;
        
      }
//      termOccs.
      }finally{
        novR.close();
      }
    }

  }

}
