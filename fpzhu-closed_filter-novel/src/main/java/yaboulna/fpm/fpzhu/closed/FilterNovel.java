package yaboulna.fpm.fpzhu.closed;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.Writer;
import java.nio.channels.Channels;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.comparator.NameFileComparator;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.mahout.math.map.OpenObjectIntHashMap;
import org.slf4j.Logger;

import yaboulna.guava.Funnels;
import yaboulna.guava.Funnels.IntArrFunnel;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import com.google.common.hash.BloomFilter;

public class FilterNovel {
  private static final Logger LOG = org.slf4j.LoggerFactory.getLogger(FilterNovel.class);

  public static Set<Character> ignoredChars = Sets.newHashSet('(', ')', '#');
// public static Set<Character> tokenDelim = Sets.newHashSet(',',' ');
// public static Set<Character> lineDelim = Sets.newHashSet('\n');
// public static Set<Character> fieldDelim = Sets.newHashSet('\t');
// public static char lineDelim = '\n';
// public static char fieldDelim = '\t';
  public static Set<Character> delims = Sets.newHashSet('\n', '\t', ',', ' ');

  public static final int AVERAGE_FREQUENT_ITEMSETS_PER_HOUR = 10000; // anecdotal not really calculated

  public static void main(String[] args) throws IOException {
    File dataDir = new File(args[0]);
    if (!dataDir.exists()) {
      throw new IllegalArgumentException("Path doesn't exist: " + dataDir.getAbsolutePath());
    }

// TODO: Landmark window --> int numHistFiles = Integer.parseInt(args[2]);

    List<File> fpFiles = (List<File>) FileUtils.listFiles(dataDir, new IOFileFilter() {

      public boolean accept(File dir, String name) {
        return name.startsWith("fp_");
      }

      public boolean accept(File file) {
        return accept(file, file.getName());
      }
    }, FileFilterUtils.trueFileFilter());

    Collections.sort(fpFiles, NameFileComparator.NAME_COMPARATOR);

    // I don't think it is wise to hash tokens before passing them to bloom filter, because then the one hash function
    // used in this initial hashing will be the cause of a lot of undetected collisions..
// BloomFilter<Integer[]> historyBloom = BloomFilter.create(IntArrFunnel.INSTANCE, "10759413/1000")
// Integer tokenHash = murmur.hashString(token).asInt();
// HashFunction murmur = Hashing.murmur3_32();

    int expectedInsertions = AVERAGE_FREQUENT_ITEMSETS_PER_HOUR * fpFiles.size(); // FIXME: This assumes an epoch of 1hr
    BloomFilter<List<String>> historyBloom = BloomFilter.create(Funnels.StrListFunnel.INSTANCE, expectedInsertions);

    Set<String> itemSet = Sets.newHashSet();
    LinkedList<String> distinctSortedTokens = Lists.newLinkedList();

    StringBuilder tokenBuilder = new StringBuilder();
    OpenObjectIntHashMap<String> tokenDocFreq = new OpenObjectIntHashMap<String>();

    for (File fpF : fpFiles) {
//      File bloomFile = new File(fpF.getParentFile(), fpF.getName().replaceFirst("fp_", "bloom_"));
//      if (bloomFile.exists()) {
//        // TODO: read the bloom filter for the subwindow
//      }
      
      File novelFile = new File(fpF.getParentFile(), fpF.getName().replaceFirst("fp_", "novel_"));
      if(novelFile.exists()){
        //TODO: skip output that already exists
      }
      
      Writer novelWr = Channels.newWriter(FileUtils.openOutputStream(novelFile).getChannel(), "UTF-8");
      
      FileReader fpR = new FileReader(fpF);
      try {
        int chInt;
        while ((chInt = fpR.read()) != -1) {
          char ch = (char) chInt;
          if (ignoredChars.contains(ch)) {
            continue;
          } else if (delims.contains(ch)) {
            itemSet.add(tokenBuilder.toString());
            tokenBuilder.setLength(0);

            if (ch == '\t') {
              // End of itemset

              // read until the end of line: 10 is the ascii for \n
              while ((chInt = fpR.read()) != 10);
              // The frequency is misleading, because if we actually use it we will add the frequencies of all longer
              // itemsets to the tokenCounts of tokens in the shorter itemsets.. counts renamed to docFreq to show that.
// {
// ch = (char)chInt;
// tokenBuilder.append(ch);
// }
// int freq = Integer.parseInt(tokenBuilder.toString());
// tokenBuilder.setLength(0);

              for (String token : itemSet) {
                tokenDocFreq.put(token, tokenDocFreq.get(token) + 1); // freq);

                // Insertion sort of the itemset lexicographically
                int tokenIx = 0;
                for (String sortedToken : distinctSortedTokens) {
                  if (sortedToken.compareTo(token) > 0) {
                    break;
                  }
                  ++tokenIx;
                }
                distinctSortedTokens.add(tokenIx, token);
              }

              // See if this is a novel itemset
              if (!historyBloom.mightContain(distinctSortedTokens)) {
                // definitely a novel itemset
                novelWr.append(distinctSortedTokens.toString()).append('\n');
              }

              // Add the itemset to the bloom filter (only if it is novel? Abbadi's paper seems to insert it anyway)
              historyBloom.put(distinctSortedTokens);

              itemSet.clear();
              distinctSortedTokens.clear();
            }

          } else {
            tokenBuilder.append(ch);
          }
        }
      } finally {
        novelWr.flush();
        novelWr.close();
        fpR.close();
      }

    }
  }
}
