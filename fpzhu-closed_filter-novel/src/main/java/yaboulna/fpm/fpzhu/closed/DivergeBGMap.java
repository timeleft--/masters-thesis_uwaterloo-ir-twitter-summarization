package yaboulna.fpm.fpzhu.closed;

import java.io.File;
import java.io.IOException;
import java.math.RoundingMode;
import java.util.Arrays;
import java.util.Collections;
import java.util.Formatter;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.comparator.NameFileComparator;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Charsets;
import com.google.common.base.Joiner;
import com.google.common.base.Splitter;
import com.google.common.collect.HashMultiset;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Multiset;
import com.google.common.collect.Multiset.Entry;
import com.google.common.collect.Multisets;
import com.google.common.collect.Sets;
import com.google.common.collect.Sets.SetView;
import com.google.common.io.Closer;
import com.google.common.io.Files;
import com.google.common.io.LineProcessor;
import com.google.common.math.DoubleMath;

public class DivergeBGMap {
  private final static Logger LOG = LoggerFactory.getLogger(DivergeBGMap.class);

  private static final Splitter comaSplitter = Splitter.on(',');
  static class ItemsetTabCountProcessor implements LineProcessor<Map<String, Integer>> {

    private static final String NUM_TWEETS_STR = "NUMTWEETS";

    public static final CopyOnWriteArraySet<String> NUM_TWEETS_KEY = Sets.newCopyOnWriteArraySet(Arrays
        .asList(NUM_TWEETS_STR));

// Builder<String, Integer> mapBuilder = ImmutableMap.builder();
    final Map<Set<String>, Integer> fpCntMap;
    final LinkedHashMap<Set<String>, LinkedList<Long>> fpDocIdsMap;
// Avoid copying this from one frame to another = Maps.newHashMapWithExpectedSize(4444444);

    public ItemsetTabCountProcessor(Map<Set<String>, Integer> fgCountMap,
        LinkedHashMap<Set<String>, LinkedList<Long>> fgIdsMap) {
      this.fpCntMap = fgCountMap;
      this.fpDocIdsMap = fgIdsMap;
    }

    @Override
    public boolean processLine(String line) throws IOException {
      int tabIx1 = 0;
      while (line.charAt(tabIx1) != '\t') {
        ++tabIx1;
      }
      String itemsetStr = (tabIx1 > 0 ? line.substring(0, tabIx1) : NUM_TWEETS_STR);

      int tabIx2 = tabIx1 + 1;
      while (tabIx2 < line.length() && line.charAt(tabIx2) != '\t') {
        ++tabIx2;
      }
      int count = DoubleMath.roundToInt(Double.parseDouble(line.substring(tabIx1 + 1, tabIx2)), RoundingMode.UP);

// mapBuilder.put(itemset, count);
      CopyOnWriteArraySet<String> itemset = Sets.newCopyOnWriteArraySet(comaSplitter.split(itemsetStr));
      fpCntMap.put(itemset, count);

      if (fpDocIdsMap != null) {
        String ids = (tabIx2 < line.length() ? line.substring(tabIx2 + 1) : "");
        if (ids.length() > 0) {

          LinkedList<Long> docIds = Lists.newLinkedList();
          fpDocIdsMap.put(itemset, docIds);
          for (String docid : comaSplitter.split(ids)) {
            docIds.add(Long.valueOf(docid));
          }
        }
      }

      return true;
    }
    @Override
    public Map<String, Integer> getResult() {
      return null; // fpCntMap avoid unneccesary copying.. am I thinking in C or R?? whatever!
    }
  }

  // max num of itemsets was 4434143 according to wc -l of the folder lcm_closed/4wk+1wk...1-abs672
  private static final int BG_MAX_NUM_ITEMSETS = 4444444;

  // max num of itemsets was 2688780 fp_3600_1352260800 in the folder lcm_closed/1hr+30min...1-abs5
  private static final int FG_MAX_NUM_ITEMSETS = 2700000;

  private static final double CLOSED_CONFIDENCE_THRESHOLD = 0.05; // upper bound
  private static final double HIGH_CONFIDENCE_THRESHOLD = 0.05; // lower bound

  private static final double ITEMSET_SIMILARITY_GOOD_THRESHOLD = 0.8; // Cosine similarity
  private static final double ITEMSET_SIMILARITY_PROMISING_THRESHOLD = 0.33; // Jaccard similarity
  private static final double ITEMSET_SIMILARITY_BAD_THRESHOLD = 0.1; // Cosine or Jaccard similariy

  private static final double DOCID_SIMILARITY_GOOD_THRESHOLD = 0.75; // Jaccard similarity

  private static final double KLDIVERGENCE_MIN = 10; // this is multiplied by frequency not prob

  /**
   * @param args
   * @throws IOException
   */
  public static void main(String[] args) throws IOException {
    File bgDir = new File(args[0]);
    if (!bgDir.exists()) {
      throw new IllegalArgumentException("Path doesn't exist: " + bgDir.getAbsolutePath());
    }

    File fgDir = new File(args[1]);
    if (!fgDir.exists()) {
      throw new IllegalArgumentException("Path doesn't exist: " + fgDir.getAbsolutePath());
    }

    int histLenSecs = 4 * 7 * 24 * 3600;
    if (args.length > 2) {
      histLenSecs = Integer.parseInt(args[2]);
    }

    String novelPfx = "novel_";
    if (args.length > 3) {
      novelPfx = args[3];
    }

    String selectionPfx = "sel_";

    // FIXME: if there are any .out files, this will cause an error now... skip them
    List<File> fgFiles = (List<File>) FileUtils.listFiles(fgDir, FileFilterUtils.prefixFileFilter("fp_"),
        FileFilterUtils.trueFileFilter());
    Collections.sort(fgFiles, NameFileComparator.NAME_COMPARATOR);
    Map<Set<String>, Integer> fgCountMap = Maps.newHashMapWithExpectedSize(FG_MAX_NUM_ITEMSETS);
    LinkedHashMap<Set<String>, LinkedList<Long>> fgIdsMap = Maps.newLinkedHashMap();

    List<File> bgFiles = (List<File>) FileUtils.listFiles(bgDir, FileFilterUtils.prefixFileFilter("fp_"),
        FileFilterUtils.trueFileFilter());
    Collections.sort(bgFiles, NameFileComparator.NAME_COMPARATOR);
    long loadedBgStartUx = -1;
    Map<Set<String>, Integer> bgCountMap = Maps.newHashMapWithExpectedSize(BG_MAX_NUM_ITEMSETS);
    Map<String, Double> bgIDFMap = Maps.newHashMapWithExpectedSize(BG_MAX_NUM_ITEMSETS / 10);

    Splitter underscoreSplit = Splitter.on('_');

    for (File fgF : fgFiles) {
      long windowStartUx = Long.parseLong(Iterables.get(underscoreSplit.split(fgF.getName()), 2));
      long idealBgStartUx = windowStartUx - histLenSecs;

      // Load the appropriate background file
      for (int b = 0; b < bgFiles.size(); ++b) {
        long bgFileWinStart = Long.parseLong(Iterables.get(underscoreSplit.split(bgFiles.get(b).getName()), 2));
        long nextBgFileWinStart = Long.MAX_VALUE;
        if (b < bgFiles.size() - 1) {
          nextBgFileWinStart = Long.parseLong(Iterables.get(underscoreSplit.split(bgFiles.get(b + 1).getName()), 2));
        }
        if (b == bgFiles.size() - 1 || (idealBgStartUx >= bgFileWinStart && idealBgStartUx < nextBgFileWinStart)) {
          if (loadedBgStartUx != bgFileWinStart) {
            LOG.info("Loading background freqs from {}", bgFiles.get(b));
            loadedBgStartUx = bgFileWinStart;
            bgCountMap.clear();
            bgIDFMap.clear();
            Files.readLines(bgFiles.get(b), Charsets.UTF_8, new ItemsetTabCountProcessor(bgCountMap, null));
            LOG.info("Loaded background freqs - num itemsets: {} ", bgCountMap.size());
          }
          break;
        }
      }

      fgCountMap.clear();
      fgIdsMap.clear();
      LOG.info("Loading foreground freqs from {}", fgF);
      Files.readLines(fgF, Charsets.UTF_8, new ItemsetTabCountProcessor(fgCountMap, fgIdsMap));
      LOG.info("Loaded foreground freqs - num itemsets: {}", fgCountMap.size());

      final double bgNumTweets = bgCountMap.get(ItemsetTabCountProcessor.NUM_TWEETS_KEY);
      final double fgNumTweets = fgCountMap.get(ItemsetTabCountProcessor.NUM_TWEETS_KEY);
      final double bgFgLogP = Math.log((bgNumTweets + fgCountMap.size()) / (fgNumTweets + fgCountMap.size()));

      final File novelFile = new File(fgF.getParentFile(), fgF.getName().replaceFirst("fp_", novelPfx)); // "novel_"));
      if (novelFile.exists()) {
        // TODO: skip output that already exists
      }

      final File selFile = new File(fgF.getParentFile(), fgF.getName().replaceFirst("fp_", selectionPfx));

      LinkedList<Set<String>> mergeCandidates = Lists.newLinkedList();
      Multiset<String> mergedItemset = HashMultiset.create();
      Set<Long> grandUionDocId = Sets.newHashSet();
      Set<Long> grandIntersDocId = Sets.newHashSet();
      LinkedList<Long> unionDocId;
      Set<Long> intersDocId;
      unionDocId = Lists.newLinkedList();
      intersDocId = Sets.newHashSet();

      LinkedList<Set<String>> prevItemsets = Lists.newLinkedList();
      Map<Set<String>,Double> parentlessAndLong = Maps.newHashMap();

      Closer novelClose = Closer.create();
      try {
        Formatter highPrecFormat = novelClose.register(new Formatter(novelFile, Charsets.UTF_8.name()));
// final Writer novelWr = novelClose.register(Channels.newWriter(FileUtils.openOutputStream(novelFile)
// .getChannel(), Charsets.UTF_8.name()));

        Formatter selectionFormat = novelClose.register(new Formatter(selFile, Charsets.UTF_8.name()));

        int counter = 0;
        for (Set<String> itemset : fgCountMap.keySet()) {
          
          double fgFreq = fgCountMap.get(itemset) + 1;
// double fgLogP = Math.log(fgFreq / fgNumTweets);

          Integer bgCount = bgCountMap.get(itemset);
          if (bgCount == null)
            bgCount = 1;
// bgLogP = 2 * fgLogP; // so that the final result will be the abs(fpLogP)
// } else {
// bgLogP = Math.log(bgCount / bgNumTweets);
// }

          double klDiver = fgFreq * (Math.log(fgFreq / bgCount) + bgFgLogP);
// novelWr.append(itemset).append('\t').append(Doubles. String.format(klDiver)).append('\n');
          highPrecFormat.format(itemset + "\t%.15f\t%s\n", klDiver,
              (fgIdsMap.containsKey(itemset) ? fgIdsMap.get(itemset) : ""));

          //////////////////////////////////////////////
          
          if (++counter % 10000 == 0) {
            LOG.info("Processed {} itemsets. Last one: {}", counter, itemset + "=" + klDiver);
          }
          
          //////////////////////////////////////////////
          
          if (itemset.size() == 1) {
            prevItemsets.addLast(itemset);
          } else if (klDiver > KLDIVERGENCE_MIN) {
            LinkedList<Long> iDocIds = fgIdsMap.get(itemset);
            if (iDocIds == null || iDocIds.isEmpty()) {
              prevItemsets.addLast(itemset);
              continue;
            }

            Double itemsetNorm = null;
            mergeCandidates.clear();

            Set<String> parentItemset = null;
            Iterator<Set<String>> prevIter = prevItemsets.descendingIterator();
            double maxConfidence = -1.0; // if there is no parent, then this is the first from these items
            while (prevIter.hasNext()) { // there are more than one parent: && !foundParent
              Set<String> pis = prevIter.next();

              SetView<String> interset = Sets.intersection(pis, itemset);
              if (pis.size() == interset.size()) {
                // one of the parent itemset (in the closed patterns lattice)

                mergeCandidates.add(pis);
                if (parentItemset == null) {
                  // first parent to encounter will be have the lowest support, thus gives highest confidence
                  double pisFreq = fgCountMap.get(pis);
                  maxConfidence = fgCountMap.get(itemset) / pisFreq;
                }
                parentItemset = pis;
                if (maxConfidence >= HIGH_CONFIDENCE_THRESHOLD) {
                  break;
                }
              } else {
                // Itemset similiarity starts by a lightweight Jaccard Similarity similiarity,
                // then if it is promising then the cosine similarity is calculated with IDF weights
                SetView<String> isPisUnion = Sets.union(pis, itemset);
                double isPisSim = interset.size() * 1.0 / isPisUnion.size();
                if (isPisSim >= ITEMSET_SIMILARITY_PROMISING_THRESHOLD) {
                  double pisNorm = 0;
                  double itemsetNormTemp = 0;
                  for (String interItem : isPisUnion) {
                    // IDF weights
                    Double idf = bgIDFMap.get(interItem);
                    if (idf == null) {
                      Integer bgCnt = bgCountMap.get(Sets.newCopyOnWriteArraySet(Arrays.asList(interItem)));
                      if (bgCnt == null) {
                        bgCnt = 0;
                      }
                      idf = Math.log(bgNumTweets / (1 + bgCnt));
                      idf *= idf;
                      bgIDFMap.put(interItem, idf);
                    }

                    if (interset.contains(interItem)) {
                      isPisSim += idf; // * idf;
                      pisNorm += idf; // * idf;
                      if (itemsetNorm == null) {
                        itemsetNormTemp += idf; // * idf;
                      }
                    } else if (pis.contains(interItem)) {
                      pisNorm += idf; // * idf;
                    } else if (itemsetNorm == null && itemset.contains(interItem)) {
                      itemsetNormTemp += idf; // * idf;
                    }

                  }
                  if (itemsetNorm == null) {
                    itemsetNorm = Math.sqrt(itemsetNormTemp);
                  }
                  isPisSim /= Math.sqrt(pisNorm) * itemsetNorm;
                  if (isPisSim >= ITEMSET_SIMILARITY_GOOD_THRESHOLD) {
                    mergeCandidates.add(pis);
                  }
                }
                if (parentItemset != null && isPisSim < ITEMSET_SIMILARITY_BAD_THRESHOLD) {
                  // TODO: could this also work without checking foundParent OR is it losing anything
                  if (LOG.isTraceEnabled())
                    LOG.trace("Decided there won't be any more candidates for itemset {} when we encountered {}.",
                        itemset, pis);
                  break; // the cluster of itemsets from these items is consumed
                }
              }
            }
            
            //Add to previous for next iterations to access it, regardless if it will get merged or not.. it can 
            prevItemsets.add(itemset);

            mergedItemset.clear();

            grandUionDocId.clear();
            grandIntersDocId.clear();

            if (parentItemset == null) {
              parentlessAndLong.put(itemset,klDiver);
              continue;
            } else if (maxConfidence < CLOSED_CONFIDENCE_THRESHOLD) {
              for (Set<String> cand : mergeCandidates) {
                LinkedList<Long> candDocIds = fgIdsMap.get(cand);

                if (parentItemset == cand) {
                  // TODONE: why do we add parent to candidates while it'd be impossible for maxCof to be both
                  // < closed threshold AND >= docIdSimilarity
// unionDocId = candDocIds;
// intersDocId = iDocIds;
                  continue;
                } else {
                  unionDocId.clear();
                  intersDocId.clear();

                  if (candDocIds == null || candDocIds.isEmpty()) {
                    LOG.warn("Using a file with truncated inverted indexes");
                    continue;
                  }

                  // Intersection and union calculation (depends on that docIds are sorted)
                  // TODO: use a variation of this measure that calculates the time period covered by each itemset
                  // TODO: prefix filter ppjoin

                  Iterator<Long> iDidIter = iDocIds.iterator();
                  Iterator<Long> candDidIter = candDocIds.iterator();
                  long iDid = iDidIter.next(), candDid = candDidIter.next();
                  while (iDidIter.hasNext() && candDidIter.hasNext()) {
                    if (iDid == candDid) {
                      intersDocId.add(iDid);
                      unionDocId.add(iDid);
                      iDid = iDidIter.next();
                      candDid = candDidIter.next();
                    } else if (iDid < candDid) {
                      unionDocId.add(iDid);
                      iDid = iDidIter.next();
                    } else {
                      unionDocId.add(candDid);
                      candDid = candDidIter.next();
                    }
                  }
                  Iterator<Long> remainingIter;
                  if (iDidIter.hasNext()) {
                    remainingIter = iDidIter;
                  } else {
                    remainingIter = candDidIter;
                  }
                  while (remainingIter.hasNext()) {
                    unionDocId.add(remainingIter.next());
                  }
                }
                // Similarity checking: jaccard similarity
                double docIdSim = intersDocId.size() * 1.0 / unionDocId.size();
                if (docIdSim >= DOCID_SIMILARITY_GOOD_THRESHOLD) {

                  mergedItemset.addAll(Sets.union(itemset, cand));

                  // add the union and intersection to grand ones
                  grandUionDocId.addAll(unionDocId);
                  grandIntersDocId = Sets.intersection(grandIntersDocId, intersDocId);

                }
              }
              maxConfidence = grandUionDocId.size() * 1.0 / fgIdsMap.get(parentItemset).size();
            }

            if (maxConfidence >= HIGH_CONFIDENCE_THRESHOLD) {
              // write out the itemset (orig or merged) into selection file(s),
              // because it is high confidence either from the beginning or after merging
              if (mergedItemset.isEmpty()) {
                mergedItemset.addAll(itemset);
              } else {
                klDiver = grandUionDocId.size();
                bgCount = bgCountMap.get(mergedItemset.elementSet());
                if (bgCount == null)
                  bgCount = 1;

                klDiver *= (Math.log(grandUionDocId.size() / bgCount) + bgFgLogP);
                
//                mergedItemset =  Multisets.copyHighestCountFirst(mergedItemset);
              }
              selectionFormat.out().append(printMultiset(mergedItemset));
              selectionFormat.format("\t%.15f\t%.15f\t%.15f\t",
                  maxConfidence,
                  klDiver,
                  maxConfidence * klDiver);
              if(grandUionDocId.isEmpty()){
                selectionFormat.out().append(iDocIds.toString().substring(1));
              } else {
                selectionFormat.out().append(grandIntersDocId.toString().substring(1))
                  .append(Sets.difference(grandUionDocId,grandIntersDocId).toString().substring(1));
              }
              selectionFormat.out().append("\n");   
            }

            if(mergedItemset.isEmpty()){
              parentlessAndLong.put(itemset,klDiver);
            } else {
              parentlessAndLong.remove(parentItemset);
            }
          }
        }
        for( java.util.Map.Entry<Set<String>, Double> e:parentlessAndLong.entrySet()){
          mergedItemset.addAll(e.getKey());
          selectionFormat.out().append(printMultiset(mergedItemset));
          selectionFormat.format("\t%.15f\t%.15f\t%.15f\t",
              -1,
              e.getValue(),
              -1);
          selectionFormat.out().append(fgIdsMap.get(e.getKey()).toString().substring(1));
        }
      } finally {
        novelClose.close();
      }
    }

  }

  private static CharSequence printMultiset(Multiset<String> mset) {
    String[] ret = new String[mset.entrySet().size()];
    int i=0;
    for(Entry<String> e: mset.entrySet()){
      ret[i++] = e.getCount() + ":" + e.getElement();
    }
    Arrays.sort(ret);
    return Joiner.on(",").join(ret);
  }
}
