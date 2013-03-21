package yaboulna.fpm.fpzhu.closed;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.Writer;
import java.nio.channels.Channels;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.comparator.NameFileComparator;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.apache.commons.io.filefilter.IOFileFilter;
import org.slf4j.Logger;

import yaboulna.guava.Funnels;

import com.google.common.collect.HashMultiset;
import com.google.common.collect.ImmutableMultiset;
import com.google.common.collect.Lists;
import com.google.common.collect.Multiset;
import com.google.common.collect.Multisets;
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

  private static final double DEFAULT_FPP = 1e-4;

  public static void main(String[] args) throws IOException {
    File dataDir = new File(args[0]);
    if (!dataDir.exists()) {
      throw new IllegalArgumentException("Path doesn't exist: " + dataDir.getAbsolutePath());
    }

// TODO: Landmark window --> int numHistFiles = Integer.parseInt(args[2]);

    // TODO pass false positive probability
    double fpp = DEFAULT_FPP;

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

    BloomFilter<List<String>> historyBloom = BloomFilter
        .create(Funnels.StrListFunnel.INSTANCE, expectedInsertions, fpp);

    Set<String> itemSet = Sets.newHashSet();
    LinkedList<String> distinctSortedTokens = Lists.newLinkedList();

    StringBuilder tokenBuilder = new StringBuilder();
    Multiset<String> tokens = HashMultiset.create();

    for (File fpF : fpFiles) {
// File bloomFile = new File(fpF.getParentFile(), fpF.getName().replaceFirst("fp_", "bloom_"));
// if (bloomFile.exists()) {
// // TODO: read the bloom filter for the subwindow
// }

      File novelFile = new File(fpF.getParentFile(), fpF.getName().replaceFirst("fp_", "novel_"));
      if (novelFile.exists()) {
        // TODO: skip output that already exists
      }

      Writer novelWr = Channels.newWriter(FileUtils.openOutputStream(novelFile).getChannel(), "UTF-8");

      FileReader fpR = new FileReader(fpF);
      int totalFps = 0;
      int skippedFp = 0;
      // TODO: read the first line containing the empty set (number of transactions) to skip it or to know the number
      try {
        int chInt;
        while ((chInt = fpR.read()) != -1) {
          char ch = (char) chInt;
          if (ignoredChars.contains(ch)) {
            continue;
          } else if (delims.contains(ch)) {
            if (tokenBuilder.length() > 0) {
              itemSet.add(tokenBuilder.toString());
              tokenBuilder.setLength(0);
            } // else: the first line or the end of each itemset ending with an hgram
            if (ch == '\t') {
              // End of itemset
              ++totalFps;
              while ((chInt = fpR.read()) != -1) {
                ch = (char) chInt;
                if (ch == '\n')
                  break;
                tokenBuilder.append(ch);
              }
              int freq = Integer.parseInt(tokenBuilder.toString());
              tokenBuilder.setLength(0);

              for (String token : itemSet) {
                // TODO: This is actually the doc freq before dedupe, will this work well as an approximation?
                // The frequency is misleading, because if we actually use it we will add the frequencies of all longer
                // itemsets to the tokenCounts of tokens in the shorter itemsets.. counts renamed to docFreq to show that.
                tokens.add(token); // freq);

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
                novelWr.append(freq + "\t").append(distinctSortedTokens.toString()).append('\n');
              } else {
                ++skippedFp;
                if (skippedFp % 100 == 0 && LOG.isDebugEnabled())
                  LOG.debug(distinctSortedTokens.toString());
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

      ImmutableMultiset<String> freqSortedTokens = Multisets.copyHighestCountFirst(tokens);

      File idfFile = new File(fpF.getParentFile(), fpF.getName().replaceFirst("fp_", "idf-tokens_"));
      if (idfFile.exists()) {
        // TODO: what to do??
      }
      Writer idfWr = Channels.newWriter(FileUtils.openOutputStream(idfFile).getChannel(), "UTF-8");
      try {
//        idfWr.append("NUM_TOKENS\t"+freqSortedTokens.size()).append('\n');
        for (Multiset.Entry<String> tokenCount : freqSortedTokens.entrySet()) {
          idfWr.append(tokenCount.getCount() + "\t").append(tokenCount.getElement()).append('\n');
        }
      } finally {
        idfWr.flush();
        idfWr.close();
      }
      tokens.clear();

      LOG.info("Done processing file {} of {} lines", fpF.getAbsolutePath(), totalFps);
      LOG.info("Number of skipped itemsets: {} . Thus included: {} ", skippedFp, totalFps - skippedFp);
    }
  }
}
