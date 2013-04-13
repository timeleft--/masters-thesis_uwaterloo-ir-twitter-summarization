package yaboulna.fpm.fpzhu.closed;

import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.math.RoundingMode;
import java.nio.channels.Channels;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.commons.math3.stat.descriptive.rank.Percentile;

import cern.colt.bitvector.BitVector;
import cern.colt.bitvector.QuickBitVector;
import cern.colt.function.IntProcedure;

import com.google.common.base.CharMatcher;
import com.google.common.base.Charsets;
import com.google.common.base.Splitter;
import com.google.common.collect.BiMap;
import com.google.common.collect.HashBiMap;
import com.google.common.collect.HashMultiset;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Multiset;
import com.google.common.collect.Multiset.Entry;
import com.google.common.collect.Multisets;
import com.google.common.io.Files;
import com.google.common.io.LineProcessor;
import com.google.common.math.DoubleMath;
import com.google.common.primitives.Doubles;

public class MergeItemsets {

  public static class WeightedSumProc implements IntProcedure {

    private static final int MIN_OCCURRENCES_FOR_RESPECTING = 5;

    final int stopWordsThresh;

    double sum = 0;

    final LinkedHashMap<String, Integer> tokenFreq;
    final BiMap<Integer, String> ixToken;

    public WeightedSumProc(LinkedHashMap<String, Integer> tokenFreq, BiMap<Integer, String> ixToken, int stopWordsThresh) {
      this.tokenFreq = tokenFreq;
      this.ixToken = ixToken;
      this.stopWordsThresh = stopWordsThresh;
    }

    public boolean apply(int ix) {
      String token = ixToken.get(ix);
      int freq = tokenFreq.get(token);
      if (freq >= MIN_OCCURRENCES_FOR_RESPECTING && freq < stopWordsThresh) {
        sum += ix * 2.0 / ixToken.size();
      }
      return true;
    }

  }

  public static final int AVERAGE_FREQUENT_ITEMSETS_PER_HOUR = 10000; // anecdotal not really calculated
  private static final int BUCKETIX_BITS = 8;

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

    for (File novF : novelFiles) {
      File idfFile = new File(novF.getParentFile(), novF.getName().replaceFirst("novel_", "freq-tokens_"));
      if (!idfFile.exists()) {
        continue;
      }

      LinkedHashMap<String, Integer> tokenFreq = Files.readLines(idfFile, Charsets.UTF_8,
          new LineProcessor<LinkedHashMap<String, Integer>>() {

            LinkedHashMap<String, Integer> result = Maps.newLinkedHashMap();

            Splitter splitter = Splitter.on('\t'); // .omitEmptyStrings().trimResults();

            public boolean processLine(String line) throws IOException {
              String[] parts = new String[2];
              int i = 0;
              for (String part : splitter.split(line)) {
                parts[i++] = part;
              }
              result.put(parts[1], Integer.parseInt(parts[0]));
              return true;
            }

            public LinkedHashMap<String, Integer> getResult() {
              return result;
            }
          });

      Percentile stopWordsThreshPctl = new Percentile();
      double pct = 99;
      double[] freqArr =Doubles.toArray(tokenFreq.values());
//      for(int f = 0; f< (freqArr.length)/2; ++f){
//        double temp = freqArr[f];
//        freqArr[f] = freqArr[freqArr.length - 1 - f];
//        freqArr[freqArr.length - 1 - f] = temp;
//      }
      int stopWordsThresh = (int)stopWordsThreshPctl.evaluate(freqArr,pct);
      while(stopWordsThresh < WeightedSumProc.MIN_OCCURRENCES_FOR_RESPECTING && pct < 100){
        pct += 1;
        stopWordsThresh = (int)stopWordsThreshPctl.evaluate(freqArr,pct);
      }
      if(pct == 100){
        stopWordsThresh = (int) (freqArr[0] + 1);
      }
      freqArr = null;
      
      final BiMap<String, Integer> tokenIx = HashBiMap.create(tokenFreq.size());
      int ix = 0;
      for (String token : tokenFreq.keySet()) {
        tokenIx.put(token, ix++);
      }
      final int numTokens = ix;

      BiMap<Integer, String> ixToken = tokenIx.inverse();

      final ArrayList<Multiset.Entry<List<String>>> itemsetCounts = Lists
          .newArrayListWithExpectedSize(FilterNovel.AVERAGE_FREQUENT_ITEMSETS_PER_HOUR);

      final Map<List<String>, Integer> itemsetIndex = Maps.newHashMap();

      List<long[]> termOccs = Files.readLines(novF, Charsets.UTF_8,
          new LineProcessor<List<long[]>>() {
            int itemsetix = 0;
            List<long[]> result = Lists
                .newArrayListWithExpectedSize(FilterNovel.AVERAGE_FREQUENT_ITEMSETS_PER_HOUR);

            Splitter tabSplitter = Splitter.on('\t'); // .omitEmptyStrings().trimResults();

            Splitter listSplitter = Splitter.on(CharMatcher.anyOf("[,]")).omitEmptyStrings().trimResults();

            public boolean processLine(String line) throws IOException {
              long[] bitVector = QuickBitVector.makeBitVector(numTokens, 1);

              Iterable<String> fields = tabSplitter.split(line);
              String itemsetStr = Iterables.get(fields, 1);
              Integer count = Integer.parseInt(Iterables.get(fields, 0));

              List<String> itemset = Lists.newCopyOnWriteArrayList(listSplitter.split(itemsetStr));

              itemsetCounts.add(itemsetix, Multisets.<List<String>> immutableEntry(itemset, count));
              itemsetIndex.put(itemset, itemsetix);

              for (String token : itemset) {
                QuickBitVector.set(bitVector, tokenIx.get(token));
              }

              result.add(itemsetix, bitVector);

              ++itemsetix;

              return true;
            }

            public List<long[]> getResult() {
              return result;
            }
          });

      List<Integer>[][] buckets = new List[(int) Math.ceil(1.0 * numTokens / BUCKETIX_BITS)][(1 << BUCKETIX_BITS)];
      for (int itemsetIx = 0; itemsetIx < itemsetCounts.size(); ++itemsetIx) {
        long[] itemsetmask = termOccs.get(itemsetIx);

// int[] arrBucks = new int[numTokens / BUCKETIX_BITS];

        for (int i = 0; i < numTokens; i += BUCKETIX_BITS) {
          // depending on whether numTokens is divisible by BUCKETIX_BITS, up to BUCKETIX_BITS-1 tokens might not be
          // compared, but no problem since MSB is very freq tokens like stop words

          int bcx = (int) QuickBitVector.getLongFromTo(itemsetmask, i, i + BUCKETIX_BITS - 1);
          if (bcx == 0) {
            continue;
          }
          if (buckets[i / BUCKETIX_BITS][bcx] == null) {
            buckets[i / BUCKETIX_BITS][bcx] = Lists.newArrayList(); // how much memory am I wasting??
          }
          buckets[i / BUCKETIX_BITS][bcx].add(itemsetIx);

// arrBucks[i / BUCKETIX_BITS] = bcx;
        }
      }
      
      int[][] similarity = new int[termOccs.size()][termOccs.size()];

      File bucketsFile = new File(novF.getParentFile(), novF.getName().replaceFirst("novel_", "buckets_"));
      Writer bucketsWr = Channels
          .newWriter(FileUtils.openOutputStream(bucketsFile).getChannel(), Charsets.UTF_8.name());
      try {
        

        for (int j = 0; j < buckets.length; ++j) {
          for (int k = 0; k < buckets[j].length; ++k) {
            bucketsWr.append(">>>  " + j + " " + k + "\n");
            if (buckets[j][k] == null) {
              continue;
            }
            Multiset<List<String>> mergeCands = HashMultiset.create(buckets[j][k].size());
            for (int p = 0; p < buckets[j][k].size(); ++p) {
              Multiset.Entry<List<String>> mergeCand1 = itemsetCounts.get(buckets[j][k].get(p));
              mergeCands.add(mergeCand1.getElement(),mergeCand1.getCount());
            }
            mergeCands = Multisets.copyHighestCountFirst(mergeCands);

            bucketsWr.append(mergeCands + "\n");
            int q = 0;
            for (Multiset.Entry<List<String>> mc1 : mergeCands.entrySet()) {
              int mc1Ix = itemsetIndex.get(mc1.getElement());
              BitVector mc1Mask = new BitVector(termOccs.get(mc1Ix), numTokens);

              Iterable<Entry<List<String>>> notHigherFreq = Iterables.skip(mergeCands.entrySet(), ++q);

              for (Multiset.Entry<List<String>> mc2 : notHigherFreq) {
                int mc2Ix = itemsetIndex.get(mc2.getElement());
                if (similarity[mc1Ix][mc2Ix] != 0) {
                  continue; // already calculated
                }

                BitVector mc2Mask = new BitVector(termOccs.get(mc2Ix), numTokens);

                BitVector similar = mc2Mask.copy();
                similar.and(mc1Mask);

                if (similar.equals(mc1Mask)) {
                  // mc1 totally inclded within mc2 (it has to be this way because mc1 is more frequent)
                }

                WeightedSumProc addingProcedure = new WeightedSumProc(tokenFreq, ixToken,stopWordsThresh);
                similar.forEachIndexFromToInState(0, numTokens-1, true, addingProcedure);

                BitVector dissimilar = mc2Mask.copy();
                dissimilar.xor(mc1Mask);
                WeightedSumProc subtractingProc = new WeightedSumProc(tokenFreq, ixToken,stopWordsThresh);
                dissimilar.forEachIndexFromToInState(0, numTokens-1, true, subtractingProc);

                similarity[mc1Ix][mc2Ix] = DoubleMath.roundToInt(addingProcedure.sum - subtractingProc.sum,
                    RoundingMode.HALF_UP);
              }
            }
          }
        }
      } finally {
        bucketsWr.flush();
        bucketsWr.close();
      }
      
      File similarityFile = new File(novF.getParentFile(), novF.getName().replaceFirst("novel_", "similarity_"));
      Writer similarityWr = Channels
          .newWriter(FileUtils.openOutputStream(similarityFile).getChannel(), Charsets.UTF_8.name());
      File selFile = new File(novF.getParentFile(), novF.getName().replaceFirst("novel_", "sel_"));
      Writer selWr = Channels
          .newWriter(FileUtils.openOutputStream(selFile).getChannel(), Charsets.UTF_8.name());
      try {
        for(int p = 0; p<itemsetCounts.size(); ++p){
          Multiset.Entry<List<String>> mergeCand1 = itemsetCounts.get(p);
          similarityWr.append(">>>" + mergeCand1 + "\n");
//          FIXME: continue from here: selWr.append(mergeCand1.getCount()+"\t";
          for(int q=0; q<itemsetCounts.size(); ++q){
            if(similarity[p][q] != 0){
              Multiset.Entry<List<String>> mergeCand2 = itemsetCounts.get(q);
              similarityWr.append(similarity[p][q] + "\t" + mergeCand2 + "\n");
            }
          }
        }
        
      } finally {
        selWr.flush();
        selWr.close();
        similarityWr.flush();
        similarityWr.close();
      }
    }

  }
}
