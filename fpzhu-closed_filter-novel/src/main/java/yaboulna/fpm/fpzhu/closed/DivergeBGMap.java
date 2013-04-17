package yaboulna.fpm.fpzhu.closed;

import java.io.File;
import java.io.IOException;
import java.math.RoundingMode;
import java.text.SimpleDateFormat;
import java.util.AbstractMap;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
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
import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.log4j.Appender;
import org.apache.log4j.FileAppender;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Charsets;
import com.google.common.base.Splitter;
import com.google.common.collect.HashMultiset;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Multiset;
import com.google.common.collect.Multiset.Entry;
import com.google.common.collect.Sets;
import com.google.common.io.Closer;
import com.google.common.io.Files;
import com.google.common.io.LineProcessor;
import com.google.common.math.DoubleMath;

public class DivergeBGMap {
  private final static Logger LOG = LoggerFactory.getLogger(DivergeBGMap.class);
  static SimpleDateFormat logFileNameFmt = new SimpleDateFormat("MMdd-HHmmss");
  static {
    org.apache.log4j.Logger rootLogger = org.apache.log4j.Logger.getRootLogger();
    @SuppressWarnings("unchecked")
    Enumeration<Appender> appenders = rootLogger.getAllAppenders();
    while (appenders.hasMoreElements()) {
      Appender fileAppender = (Appender) appenders.nextElement();
      if (fileAppender instanceof FileAppender) {
        ((FileAppender) fileAppender).setFile(logFileNameFmt.format(new Date()) + "_" +
            ((FileAppender) fileAppender).getFile());
        ((FileAppender) fileAppender).activateOptions();
      }
    }
  }

  private static final Splitter comaSplitter = Splitter.on(',');
  static class ItemsetTabCountProcessor implements LineProcessor<Map<String, Integer>> {

    private static final String NUM_TWEETS_STR = "NUMTWEETS";

    public static final CopyOnWriteArraySet<String> NUM_TWEETS_KEY = Sets.newCopyOnWriteArraySet(Arrays
        .asList(NUM_TWEETS_STR));

// Builder<String, Integer> mapBuilder = ImmutableMap.builder();
    final Map<Set<String>, Integer> fpCntMap;
    final LinkedHashMap<Set<String>, LinkedList<Long>> fpDocIdsMap;
// Avoid copying this from one frame to another = Maps.newHashMapWithExpectedSize(4444444);
    boolean skipOneCharSets = true;

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

      String ids = (tabIx2 < line.length() ? line.substring(tabIx2 + 1) : "");

// mapBuilder.put(itemset, count);
      CopyOnWriteArraySet<String> itemset = Sets.newCopyOnWriteArraySet(comaSplitter.split(itemsetStr));

      if (skipOneCharSets && // itemset.size() > 1 &&
          ((itemsetStr.length() - (itemset.size() - 1)) * 1.0 / itemset.size()) < 2) {
// if (LOG.isTraceEnabled())
// LOG.trace("Filtering out itemset {} with average item length of {}, appearing in docs: "
// + ids.substring(0, Math.min(ids.length(), 189)), itemset, "[less than 2]");
        return true;
      }

      fpCntMap.put(itemset, count);

      if (fpDocIdsMap != null) {

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
  private static final double HIGH_CONFIDENCE_THRESHOLD = 0.125; // lower bound

  private static final double ITEMSET_SIMILARITY_JACCARD_GOOD_THRESHOLD = 0.8; // Jaccard similarity
  private static final double ITEMSET_SIMILARITY_COSINE_GOOD_THRESHOLD = 0.66; // Cosine similarity
  private static final double ITEMSET_SIMILARITY_PROMISING_THRESHOLD = 0.33; // Jaccard similarity
  private static final int ITEMSET_SIMILARITY_PPJOIN_MIN_LENGTH = 3;
  private static final double ITEMSET_SIMILARITY_BAD_THRESHOLD = 0.1; // Cosine or Jaccard similariy

  private static final double DOCID_SIMILARITY_GOOD_THRESHOLD = 0.75; // Overlap similarity

  private static final double KLDIVERGENCE_MIN = 0; // this is multiplied by frequency not prob

  private static final int MAX_LOOKBACK_FOR_PARENT = 1000;

  private static final boolean RESEARCH_MODE = true;

  private static final boolean QUALITY_APPRECIATE_LARGE_ALLIANCES = false;

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

    boolean stopMatchingLimitedBufferSize = true;
    boolean stopMatchingParentFSimLow = true;
    boolean avoidFormingNewAllianceIfPossible = true;
    boolean ppJoin = true;
    boolean idfFromBG = true;
    boolean entropyFromBg = true;
    boolean growAlliancesAcrossEpochs = false;
    boolean filterLowKLD = false;
    boolean fallBackToItemsKLD = false;
    if (args.length > 2) {
      stopMatchingLimitedBufferSize = args[2].contains("Buff");
      stopMatchingParentFSimLow = args[2].contains("SimLow");
      avoidFormingNewAllianceIfPossible = args[2].contains("AvoidNew");
      ppJoin = args[2].contains("Ppj");
      idfFromBG = args[2].contains("IdfBg");
      entropyFromBg = args[2].contains("EntBg");
      growAlliancesAcrossEpochs = args[2].contains("Grow");
      filterLowKLD = args[2].contains("FLKld");
      fallBackToItemsKLD = args[2].contains("ITKld");
    }

    LOG.info("stopMatchingLimitedBufferSize: " + stopMatchingLimitedBufferSize);
    LOG.info("stopMatchingParentFSimLow: " + stopMatchingParentFSimLow);
    LOG.info("avoidFormingNewAllianceIfPossible: " + avoidFormingNewAllianceIfPossible);
    LOG.info("ppJoin: " + ppJoin);
    LOG.info("idfFromBG: " + idfFromBG);
    LOG.info("entropyFromBg: " + entropyFromBg);
    LOG.info("growAlliancesAcrossEpochs: " + growAlliancesAcrossEpochs);
    LOG.info("filterLowKLD: " + filterLowKLD);
    LOG.info("fallBackToItemsKLD: " + fallBackToItemsKLD);

    int histLenSecs = 4 * 7 * 24 * 3600;
    if (args.length > 3) {
      histLenSecs = Integer.parseInt(args[3]);
    }

    int absMaxDiff = 100;
    // TODO arg

    String novelPfx = "novel_";
// if (args.length > 3) {
// novelPfx = args[3];
// }

    String selectionPfx = "sel_";

    String options;
    if (args.length > 2) {
      options = args[2];
      if (args[2].contains("Kld")) {
        options += "_KLD" + KLDIVERGENCE_MIN;
      }
    } else {
      options = "Buff-SimLow-AvoidNew-Ppj-IdfBg-EntBg";
    }
    novelPfx += options + "_";
    selectionPfx += options + "_";

    // FIXMED: if there are any .out files, this will cause an error now... skip them
    IOFileFilter fpNotOutFilter = new IOFileFilter() {

      @Override
      public boolean accept(File dir, String name) {
        return name.startsWith("fp_") && !name.endsWith(".out");
      }

      @Override
      public boolean accept(File file) {
        return accept(file.getParentFile(), file.getName());
      }
    };
    List<File> fgFiles = (List<File>) FileUtils.listFiles(fgDir, fpNotOutFilter,
        FileFilterUtils.trueFileFilter());
    Collections.sort(fgFiles, NameFileComparator.NAME_COMPARATOR);
    Map<Set<String>, Integer> fgCountMap = Maps.newHashMapWithExpectedSize(FG_MAX_NUM_ITEMSETS);
    LinkedHashMap<Set<String>, LinkedList<Long>> fgIdsMap = Maps.newLinkedHashMap();

    List<File> bgFiles = (List<File>) FileUtils.listFiles(bgDir, fpNotOutFilter,
        FileFilterUtils.trueFileFilter());
    Collections.sort(bgFiles, NameFileComparator.NAME_COMPARATOR);
    long loadedBgStartUx = -1;
    Map<Set<String>, Integer> bgCountMap = Maps.newHashMapWithExpectedSize(BG_MAX_NUM_ITEMSETS);
    Map<String, Double> bgIDFMap = Maps.newHashMapWithExpectedSize(BG_MAX_NUM_ITEMSETS / 10);

    Splitter underscoreSplit = Splitter.on('_');

    Map<Set<String>, java.util.Map.Entry<Multiset<String>, Set<Long>>> growingAlliances = Maps.newHashMap();
    Map<Set<String>, Set<String>> itemsetParentMap = Maps.newHashMap();
    Map<Set<String>, Set<Set<String>>> allianceTransitive = Maps.newHashMap();
    Map<Set<String>, Double> unalliedItemsets = Maps.newHashMap();
    Map<Set<String>, Double> confidentItemsets = Maps.newHashMap();
    Set<String> preAllocatedSet1 = Sets.newHashSet();
    Set<String> preAllocatedSet2 = Sets.newHashSet();
    LinkedList<Set<String>> mergeCandidates = Lists.newLinkedList();
    // Multiset<String> mergedItemset = HashMultiset.create();
    // Set<Long> grandUionDocId = Sets.newHashSet();
    // Set<Long> grandIntersDocId = Sets.newHashSet();
    // LinkedList<Long> unionDocId;
    // Set<Long> intersDocId;
    // unionDocId = Lists.newLinkedList();
    // intersDocId = Sets.newHashSet();

    Map<String, Double> kldCache = Maps.newHashMapWithExpectedSize(BG_MAX_NUM_ITEMSETS / 10);

    LinkedList<Set<String>> prevItemsets = Lists.newLinkedList();

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
            if (idfFromBG) {
              bgIDFMap.clear();
            }
            Files.readLines(bgFiles.get(b), Charsets.UTF_8, new ItemsetTabCountProcessor(bgCountMap, null));
            LOG.info("Loaded background freqs - num itemsets: {} ", bgCountMap.size());
          }
          break;
        }
      }

      double hrsPerEpoch = Long.parseLong(Iterables.get(underscoreSplit.split(fgF.getName()), 1)) / 3600;
      if (!growAlliancesAcrossEpochs) {
        growingAlliances.clear();
        allianceTransitive.clear();
        itemsetParentMap.clear();
        fgCountMap.clear();
        fgIdsMap.clear();
      }
      unalliedItemsets.clear();
      confidentItemsets.clear();
      mergeCandidates.clear();
      prevItemsets.clear();
      kldCache.clear();
      if (!idfFromBG) {
        bgIDFMap.clear();
      }

      LOG.info("Loading foreground freqs from {}", fgF);
      Files.readLines(fgF, Charsets.UTF_8, new ItemsetTabCountProcessor(fgCountMap, fgIdsMap));
      LOG.info("Loaded foreground freqs - num itemsets: {}", fgCountMap.size());

      if (fgCountMap.size() == 0) {
        continue;
      }

      final double bgNumTweets = bgCountMap.get(ItemsetTabCountProcessor.NUM_TWEETS_KEY);
      final double fgNumTweets = fgCountMap.get(ItemsetTabCountProcessor.NUM_TWEETS_KEY);
      final double bgFgLogP = Math.log((bgNumTweets + fgCountMap.size()) / (fgNumTweets + fgCountMap.size()));

      final File novelFile = new File(fgF.getParentFile(), fgF.getName().replaceFirst("fp_", novelPfx)); // "novel_"));
      if (novelFile.exists()) {
        // TODO: skip output that already exists
      }

      final File selFile = new File(fgF.getParentFile(), fgF.getName().replaceFirst("fp_", selectionPfx));

      Closer novelClose = Closer.create();
      try {
        Formatter highPrecFormat = novelClose.register(new Formatter(novelFile, Charsets.UTF_8.name()));

        Formatter selectionFormat = novelClose.register(new Formatter(selFile, Charsets.UTF_8.name()));

        int counter = 0;
        for (Set<String> itemset : fgCountMap.keySet()) {

          double fgFreq = fgCountMap.get(itemset) + 1.0;

          Integer bgCount = bgCountMap.get(itemset);
          double klDiver = Double.MIN_VALUE;
          if (bgCount == null) {
            if (!fallBackToItemsKLD) {
              bgCount = 1;
            } else {
              klDiver = calcComponentsKLDiver(itemset, fgFreq, bgCountMap, fgCountMap, bgFgLogP, kldCache);
            }
          }
          if (bgCount != null) {
            klDiver = fgFreq * (Math.log(fgFreq / bgCount) + bgFgLogP);
          }

          if (!filterLowKLD || klDiver > KLDIVERGENCE_MIN) {
            highPrecFormat.format(itemset + "\t%.15f\t%s\n", klDiver,
                (fgIdsMap.containsKey(itemset) ? fgIdsMap.get(itemset) : ""));
          }
          // ////////////////////////////////////////////

          if (++counter % 10000 == 0) {
            LOG.info("Processed {} itemsets. Last one: {}", counter, itemset + "=" + klDiver);
          }

          // ////////////////////////////////////////////

          if (itemset.size() == 1) {
            prevItemsets.addLast(itemset);
          } else if (!filterLowKLD || klDiver > KLDIVERGENCE_MIN) {
            LinkedList<Long> iDocIds = fgIdsMap.get(itemset);
            if (iDocIds == null || iDocIds.isEmpty()) {
              LOG.warn("Using a foreground file with truncated docids. No docids for itemset: " + iDocIds);
              prevItemsets.addLast(itemset);
              continue;
            }

            if (LOG.isTraceEnabled())
              LOG.trace(itemset.toString() + iDocIds.size()  + " docids: " + iDocIds);

            Double itemsetNorm = null;
            mergeCandidates.clear();

            Set<String> parentItemset = null;
            Iterator<Set<String>> prevIter = prevItemsets.descendingIterator();
            double maxConfidence = -1.0; // if there is no parent, then this is the first from these items
            boolean allied = false;

            int lookBackRecords = 0;

            while (prevIter.hasNext()) { // there are more than one parent: && !foundParent
              Set<String> pis = prevIter.next();

              Set<String> interset;
              Set<String> isPisUnion;

              if (!ppJoin || pis.size() < ITEMSET_SIMILARITY_PPJOIN_MIN_LENGTH
                  || itemset.size() < ITEMSET_SIMILARITY_PPJOIN_MIN_LENGTH) {
                interset = Sets.intersection(itemset, pis);
                isPisUnion = Sets.union(itemset, pis);
              } else {

// if (pis.size() < ITEMSET_SIMILARITY_PROMISING_THRESHOLD * itemset.size()) {
// continue;
// }

                interset = preAllocatedSet1;
                isPisUnion = preAllocatedSet2;

                interset.clear();
                isPisUnion.clear();

                int minOverlap = (int) Math
                    .ceil((ITEMSET_SIMILARITY_PROMISING_THRESHOLD / (1.0 + ITEMSET_SIMILARITY_PROMISING_THRESHOLD))
                        * (pis.size() + itemset.size()));
                int maxDiff = Math.min(pis.size(), itemset.size()) - minOverlap;
                int currDiff = 0;
                // TODONE: prefix filter ppjoin; using an adaptation to get maxAllDiffPos
// int allDiffPfxLen = 0;
// int maxAllDiffPfxIs = (int) (itemset.size()
// - Math.ceil(ITEMSET_SIMILARITY_PROMISING_THRESHOLD * itemset.size()) + 1);
// int maxAllDiffPfxP = (int) (pis.size() - Math.ceil(ITEMSET_SIMILARITY_PROMISING_THRESHOLD * pis.size()) + 1);
// int maxAllDiffPfx = Math.min(maxAllDiffPfxP, maxAllDiffPfxIs);

                Iterator<String> iIter = itemset.iterator();
                Iterator<String> pIter = pis.iterator();
                String iStr = iIter.next();
                String pStr = pIter.next();

                Iterator<String> remIter = null;
                String remStr = null;

// int allDiffPfxIncrement = 1;
                while (currDiff <= maxDiff) {  // allDiffPfxLen <= maxAllDiffPfx
                  int comparison = iStr.compareTo(pStr);
                  if (comparison == 0) {
                    interset.add(iStr);
                    isPisUnion.add(iStr);
                    if (!iIter.hasNext() && !pIter.hasNext()) {
                      break;
                    }
                    if (iIter.hasNext()) {
                      iStr = iIter.next();
                    } else {
                      remIter = pIter;
                      remStr = pStr;
                      break;
                    }
                    if (pIter.hasNext()) {
                      pStr = pIter.next();
                    } else {
                      remIter = iIter;
                      remStr = iStr;
                      break;
                    }
// allDiffPfxIncrement = 0;
                  } else if (comparison < 0) {
                    ++currDiff;
                    isPisUnion.add(iStr);
                    if (iIter.hasNext()) {
                      iStr = iIter.next();
                    } else {
                      remIter = pIter;
                      remStr = pStr;
                      break;
                    }
// allDiffPfxLen += allDiffPfxIncrement;
                  } else {
                    ++currDiff;
                    isPisUnion.add(pStr);
                    if (pIter.hasNext()) {
                      pStr = pIter.next();
                    } else {
                      remIter = iIter;
                      remStr = iStr;
                      break;
                    }
// allDiffPfxLen += allDiffPfxIncrement;
                  }
                }

                if (currDiff > maxDiff) {// allDiffPfxLen > maxAllDiffPfx) {
                  continue;
                }

                while (remIter != null) {
                  isPisUnion.add(remStr);
                  if (remIter.hasNext()) {
                    remStr = remIter.next();
                  } else {
                    break;
                  }
                }
              }

              if (Math.min(pis.size(), itemset.size()) == interset.size()) { // TODONE: can the parent (shorter) come
// after?
                // one of the parent itemset (in the closed patterns lattice)

                mergeCandidates.add(pis);
                if (pis.size() < itemset.size()) {
                  if (parentItemset == null) {
                    parentItemset = pis;
                    // first parent to encounter will be have the lowest support, thus gives highest confidence
                    double pisFreq = fgCountMap.get(pis);
                    maxConfidence = fgCountMap.get(itemset) / pisFreq;
                    if (LOG.isTraceEnabled())
                      LOG.trace("{} found parent {}, with confidence: " + maxConfidence, itemset, pis);
                  } else {
                    if (LOG.isTraceEnabled())
                      LOG.trace("{} found another parent {}, with confidence: " + fgCountMap.get(itemset).doubleValue()
                          / fgCountMap.get(pis).doubleValue(), itemset, pis);
                  }
                } else {
                  if (LOG.isTraceEnabled())
                    LOG.trace("{} is NOT longer that its 'parent' {}, with confidence: "
                        + fgCountMap.get(itemset).doubleValue()
                        / fgCountMap.get(pis).doubleValue(), itemset, pis);
                }
// if (maxConfidence >= HIGH_CONFIDENCE_THRESHOLD) {
// // it will get printed without alliances.. oh, it doesn't need alliance
// allied = true;
// break;
// }
              } else {

                // Itemset similiarity starts by a lightweight Jaccard Similarity similiarity,
                // then if it is promising then the cosine similarity is calculated with IDF weights

                double isPisSim = interset.size() * 1.0 / isPisUnion.size();
                if (isPisSim >= ITEMSET_SIMILARITY_PROMISING_THRESHOLD) {
                  String simMeasure;
                  if (isPisSim < ITEMSET_SIMILARITY_JACCARD_GOOD_THRESHOLD) {
                    double pisNorm = 0;
                    double itemsetNormTemp = 0;
                    // calculate the cosine similarity only if the jaccard similarity isn't enough
                    isPisSim = 0;
                    for (String interItem : isPisUnion) {
                      // IDF weights
                      Double idf = bgIDFMap.get(interItem);
                      if (idf == null) {
// Is this faster, or that:ImmutableSet.of(interItem) ?
                        if (idfFromBG) {
                          Integer bgCnt = bgCountMap.get(Collections.singleton(interItem));
                          if (bgCnt == null) {
                            bgCnt = 0;
                          }
                          idf = Math.log(bgNumTweets / (1.0 + bgCnt));
                        } else {
                          Integer fgCnt = fgCountMap.get(Collections.singleton(interItem));
                          if (fgCnt == null) {
                            fgCnt = 0;
                          }
                          idf = Math.log(fgNumTweets / (1.0 + fgCnt));
                        }
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
                    simMeasure = "Cosine";
                  } else {
                    simMeasure = "Jaccard";
                  }
                  if (isPisSim >= ITEMSET_SIMILARITY_COSINE_GOOD_THRESHOLD) {
                    mergeCandidates.add(pis);
                    if (LOG.isTraceEnabled())
                      LOG.trace("{} " + simMeasure + " {} = " + isPisSim, itemset, pis);
                  }
                }

                if ((stopMatchingParentFSimLow && parentItemset != null &&
                    isPisSim < ITEMSET_SIMILARITY_BAD_THRESHOLD)
                    || (stopMatchingLimitedBufferSize && ++lookBackRecords > MAX_LOOKBACK_FOR_PARENT)) {
                  // TODONE: could this also work without checking foundParent -> NO, very few alliances happen
                  // TODO: are we losing anything by breaking on the first bad similarity
// if (LOG.isTraceEnabled())
// LOG.trace("Decided there won't be any more candidates for itemset {} when we encountered {}.",
// itemset, pis);
                  break; // the cluster of itemsets from these items is consumed
                }
              }
            }

            // Add to previous for next iterations to access it, regardless if it will get merged or not.. it can
            prevItemsets.addLast(itemset);

// mergedItemset.clear();

// grandUionDocId.clear();
// grandIntersDocId.clear();

// if (parentItemset == null) {
// unalliedItemsets.put(itemset, klDiver);
// continue;
// } else { // if (maxConfidence < CLOSED_CONFIDENCE_THRESHOLD) {
            if (parentItemset != null) {
              itemsetParentMap.put(itemset, parentItemset);
            }

            double maxDiffCnt = Math.min(absMaxDiff * hrsPerEpoch, // hard max number of diff tweets to allow a merger
                Math.max(0.9, // so that maxDiffCnt of 0 enters the loop
                    Math.floor((1 - DOCID_SIMILARITY_GOOD_THRESHOLD) * iDocIds.size())));

            Set<String> theOnlyOneIllMerge = null;
            int theOnlyOnesDifference = Integer.MIN_VALUE;
            if (growAlliancesAcrossEpochs && allianceTransitive.containsKey(itemset)) {
              mergeCandidates.addAll(allianceTransitive.get(itemset));
            }

            if (LOG.isTraceEnabled())
              LOG.trace(itemset.toString() + iDocIds.size()  + " merge candidates: " + mergeCandidates);

            int bestUnofficialCandidateDiff = Integer.MAX_VALUE;
            Set<String> bestUnofficialCandidate = null;
            for (Set<String> cand : mergeCandidates) {
              LinkedList<Long> candDocIds = fgIdsMap.get(cand);
              int differentDocs = 0;
              if (parentItemset == cand) {
                // the (true) parent will necessarily be present in all documents of itemset
                differentDocs = candDocIds.size() - iDocIds.size();
              } else {
// unionDocId.clear();
// intersDocId.clear();

                if (candDocIds == null || candDocIds.isEmpty()) {
                  LOG.warn("Using a file with truncated inverted indexes");
                  continue;
                }

                // Intersection and union calculation (depends on that docIds are sorted)
                // TODO: use a variation of this measure that calculates the time period covered by each itemset
                // TODONE: overlap of intersection with the current itemset's docids

                Iterator<Long> iDidIter = iDocIds.iterator();
                Iterator<Long> candDidIter = candDocIds.iterator();
                long iDid = iDidIter.next(), candDid = candDidIter.next();
                while (differentDocs <= maxDiffCnt) {
                  if (iDid == candDid) {
// intersDocId.add(iDid);
// unionDocId.add(iDid);
                    if (iDidIter.hasNext()) {
                      iDid = iDidIter.next();
                    } else {
                      iDid = -1;
                      break;
                    }
                    if (candDidIter.hasNext()) {
                      candDid = candDidIter.next();
                    } else {
                      break;
                    }
                  } else if (iDid < candDid) {
// unionDocId.add(iDid);
                    ++differentDocs;
                    if (iDidIter.hasNext()) {
                      iDid = iDidIter.next();
                    } else {
                      iDid = -1;
                      break;
                    }
                  } else {
// unionDocId.add(candDid);
                    if (candDidIter.hasNext()) {
                      candDid = candDidIter.next();
                    } else {
                      break;
                    }
                  }
                }
                while (iDid > 0 && differentDocs <= maxDiffCnt) {
                  ++differentDocs;
                  if (iDidIter.hasNext()) {
                    iDid = iDidIter.next();
                  } else {
                    iDid = -1;
                    break;
                  }
                }
              }

// Iterator<Long> remainingIter;
// if (iDidIter.hasNext()) {
// remainingIter = iDidIter;
// } else {
// remainingIter = candDidIter;
// }
// while (remainingIter.hasNext()) {
// unionDocId.add(remainingIter.next());
// }
// }
// // Similarity checking: jaccard similarity
// double docIdSim = intersDocId.size() * 1.0 / iDocIds.size(); //unionDocId.size();
// if (docIdSim >= DOCID_SIMILARITY_GOOD_THRESHOLD) {
//
// mergedItemset.addAll(Sets.union(itemset, cand));
//
// // add the union and intersection to grand ones
// grandUionDocId.addAll(unionDocId);
// grandIntersDocId = Sets.intersection(grandIntersDocId, intersDocId);
//
// }
              // If similar enough, attach to the merge candidate and put both in pending queue
              if (differentDocs <= maxDiffCnt) {
                // Try and join and existing alliance
                Set<String> bestAllianceHead = cand;

                Set<Set<String>> candidateTransHeads = allianceTransitive.get(cand);
                // what did the candidate do wrong to ignore it if it doesn't have earlier allies?
// if(candidateTransHeads == null){
// candidateTransHeads = allianceTransitive.get(itemset);
// } else {
//
// }
                int currentBestDifference = differentDocs;
                if (candidateTransHeads != null) {
                  if (LOG.isTraceEnabled())
                    LOG.trace(itemset.toString() + iDocIds.size()  + " offered more merge options {} through candidate {}", candidateTransHeads, //.toString() + fgIdsMap.get(candidateTransHeads).size(),
                        cand);

                  for (Set<String> exitingAllianceHead : candidateTransHeads) {
                    int existingHeadNonOverlap = 0;
                    Iterator<Long> iDidIter = iDocIds.iterator();
                    Iterator<Long> existingDidIter = fgIdsMap.get(exitingAllianceHead).iterator();
                    long iDid = iDidIter.next(), existingDid = existingDidIter.next();
                    while (existingHeadNonOverlap <= maxDiffCnt) {
                      if (iDid == existingDid) {
                        // intersDocId.add(iDid);
                        // unionDocId.add(iDid);
                        if (iDidIter.hasNext()) {
                          iDid = iDidIter.next();
                        } else {
                          iDid = -1;
                          break;
                        }
                        if (existingDidIter.hasNext()) {
                          existingDid = existingDidIter.next();
                        } else {
                          break;
                        }
                      } else if (iDid < existingDid) {
                        // unionDocId.add(iDid);
                        ++existingHeadNonOverlap;
                        if (iDidIter.hasNext()) {
                          iDid = iDidIter.next();
                        } else {
                          iDid = -1;
                          break;
                        }

                      } else {
                        // unionDocId.add(candDid);
                        if (existingDidIter.hasNext()) {
                          existingDid = existingDidIter.next();
                        } else {
                          break;
                        }
                      }
                    }

                    while (iDid > 0 && existingHeadNonOverlap <= maxDiffCnt) {
                      ++existingHeadNonOverlap;
                      if (iDidIter.hasNext()) {
                        iDid = iDidIter.next();
                      } else {
                        iDid = -1;
                        break;
                      }
                    }

                    if (existingHeadNonOverlap <= maxDiffCnt &&
                        ((avoidFormingNewAllianceIfPossible && bestAllianceHead == cand)
                        || (exitingAllianceHead.size() < bestAllianceHead.size()
                        || existingHeadNonOverlap < currentBestDifference))) {
                      // or equals prefers existing allinaces to forming new ones

                      currentBestDifference = existingHeadNonOverlap;
                      bestAllianceHead = exitingAllianceHead;

                    }
                  }
                }

                if ((theOnlyOneIllMerge == null || bestAllianceHead.size() < theOnlyOneIllMerge.size())
                    || (currentBestDifference < theOnlyOnesDifference)) {

                  theOnlyOneIllMerge = bestAllianceHead;
                  theOnlyOnesDifference = currentBestDifference;
                }
              } else if (LOG.isTraceEnabled()) {
                if (differentDocs < bestUnofficialCandidateDiff) {
                  bestUnofficialCandidateDiff = differentDocs;
                  bestUnofficialCandidate = cand;
                }
              }
            }

            if (theOnlyOneIllMerge != null) {
              if (LOG.isTraceEnabled())
                LOG.trace(itemset.toString() + iDocIds.size() + " overlaps in {} = {}% of its documents with the only one to merge with: "
                    + theOnlyOneIllMerge.toString() + fgIdsMap.get(theOnlyOneIllMerge).size() , (iDocIds.size() - theOnlyOnesDifference),
                    (iDocIds.size() - theOnlyOnesDifference) * 100.0 / iDocIds.size());
              // /////////// Store that you joined this alliance
              Set<Set<String>> transHeads = allianceTransitive.get(itemset);
              if (transHeads != null) {
                if (growAlliancesAcrossEpochs) {
                  if (transHeads.size() > 1) {
                    LOG.warn("There should be a maximum of one alliance per itemset.. why do we have these:"
                        + transHeads);
                  }
                  if (transHeads.contains(theOnlyOneIllMerge)) {
                    // jolly
                    if (LOG.isTraceEnabled())
                      LOG.trace(itemset.toString() + iDocIds.size() + " joining its only one {} in a continuing alliance: " + transHeads.toString() + fgIdsMap.get(transHeads).size() , 
                        theOnlyOneIllMerge.toString() + fgIdsMap.get(theOnlyOneIllMerge).size() );
                  } else {
                    // the new alliance will be better.. clear the one from earlier
                    allianceTransitive.remove(transHeads);
                    transHeads = null;
                  }
                } else {
                  LOG.warn("I thought we will never find a cluster (alliance) head from earlier, " +
                      "but the itemset {} already has {} while the current alleged onlyOneIllMerge is :"
                      + theOnlyOneIllMerge, itemset, transHeads);
                }
              }
              if (transHeads == null) {
                transHeads = Sets.newHashSet();
                allianceTransitive.put(itemset, transHeads);
              }
              // Cannot happen with the hard clusters (since the only one)
// if (transHeads.contains(theOnlyOneIllMerge)) {
// // // this itemset is already part of the alliance, in an earlier iteration
// continue;
// }
              transHeads.add(theOnlyOneIllMerge);

              java.util.Map.Entry<Multiset<String>, Set<Long>> alliedItemsets = growingAlliances
                  .get(theOnlyOneIllMerge);

              if (alliedItemsets == null) {
                // ////// Create a new alliance
                LinkedList<Long> theOnlyOnesDocIds = fgIdsMap.get(theOnlyOneIllMerge);
                alliedItemsets = new AbstractMap.SimpleEntry<Multiset<String>, Set<Long>>(
                    HashMultiset.create(theOnlyOneIllMerge), Sets.newHashSet(theOnlyOnesDocIds));
                growingAlliances.put(theOnlyOneIllMerge, alliedItemsets);
                if (!itemsetParentMap.containsKey(theOnlyOneIllMerge)) {
                  if (parentItemset != null && theOnlyOneIllMerge.size() > parentItemset.size()
                      && theOnlyOnesDocIds.size() < fgIdsMap.get(parentItemset).size()) {
                    itemsetParentMap.put(theOnlyOneIllMerge, parentItemset);
                  } else {
                    itemsetParentMap.put(theOnlyOneIllMerge, theOnlyOneIllMerge);
                  }
                }
                unalliedItemsets.remove(theOnlyOneIllMerge);
              }
              alliedItemsets.getKey().addAll(itemset);
              alliedItemsets.getValue().addAll(iDocIds);

              allied = true;
            } else if (!mergeCandidates.isEmpty()) {
              if (LOG.isTraceEnabled())
                LOG.trace(itemset.toString() + iDocIds.size()  + " no one to merge with, had only {} = {}% of overlap with its best candidate: " +
                    bestUnofficialCandidate.toString() + fgIdsMap.get(bestUnofficialCandidate).size(),
                    (iDocIds.size() - bestUnofficialCandidateDiff),
                    (iDocIds.size() - bestUnofficialCandidateDiff) * 100.0 / iDocIds.size());
            }

// maxConfidence = grandUionDocId.size() * 1.0 / fgIdsMap.get(parentItemset).size();

            if (maxConfidence >= HIGH_CONFIDENCE_THRESHOLD) {
              confidentItemsets.put(itemset, maxConfidence);
// // write out the itemset (orig or merged) into selection file(s),
// // because it is high confidence either from the beginning or after merging
// // This is originally a high confidence itemset, we didnt increase conf yet: if (mergedItemset.isEmpty()) {
// Multiset<String> mergedItemset = HashMultiset.create(itemset); // mergedItemset.addAll(itemset);
// // } else {
// // klDiver = grandUionDocId.size();
// // bgCount = bgCountMap.get(mergedItemset.elementSet());
// // if (bgCount == null)
// // bgCount = 1;
// //
// // klDiver *= (Math.log(grandUionDocId.size() * 1.0 / bgCount) + bgFgLogP);
// //
// // // mergedItemset = Multisets.copyHighestCountFirst(mergedItemset);
// // }
// selectionFormat.out().append(printMultiset(mergedItemset));
// selectionFormat.format("\t%.15f\t%.15f\t%.15f\t%d\t%.15f\t",
// maxConfidence,
// klDiver,
// maxConfidence * klDiver,
// iDocIds.size(),
// maxConfidence * iDocIds.size());
// // if (grandUionDocId.isEmpty()) {
// selectionFormat.out().append(iDocIds.toString().substring(1));
// // } else {
// // selectionFormat.out().append(grandIntersDocId.toString().substring(1))
// // .append(Sets.difference(grandUionDocId, grandIntersDocId).toString().substring(1));
// // }
// selectionFormat.out().append("\n");

              // TODO: are you sure about that?
              // The parent will be present in the final output within this itemset, so even if it
              // were pending alliance to get printed it can be removed now
              unalliedItemsets.remove(parentItemset);
            }

            if (!allied) {
              unalliedItemsets.put(itemset, klDiver);
            }
          }
        }

        for (java.util.Map.Entry<Set<String>, java.util.Map.Entry<Multiset<String>, Set<Long>>> e : growingAlliances
            .entrySet()) {
          Multiset<String> mergedItemset = e.getValue().getKey();
          Set<Long> unionDocId = e.getValue().getValue();
          Set<String> parentItemset = itemsetParentMap.get(e.getKey());
          double confidence = unionDocId.size() * 1.0 / fgIdsMap.get(parentItemset).size();
          if (confidence < HIGH_CONFIDENCE_THRESHOLD && !RESEARCH_MODE) {
            continue;
          } else if (confidence >= 1) {
            if (LOG.isTraceEnabled())
              LOG.trace(mergedItemset + " is stronger alliance ({}) than its head's ({}) parent: " +
                  parentItemset + "@" + fgIdsMap.get(parentItemset).size(),
                  unionDocId.size(), e.getKey());
          }
          // The parent will be present in the final output within this itemset, so even if it
          // were pending alliance to get printed it can be removed now
          unalliedItemsets.remove(parentItemset);

          double klDiver = Double.MIN_VALUE;
          Integer bgCount = bgCountMap.get(mergedItemset.elementSet());
          if (bgCount == null) {
            if (!fallBackToItemsKLD) {
              bgCount = 1;
            } else {
              klDiver = calcComponentsKLDiver(mergedItemset.elementSet(), unionDocId.size(),
                  bgCountMap, fgCountMap, bgFgLogP, kldCache);
            }
          }
          if (bgCount != null) {
            klDiver = unionDocId.size() * 1.0 * (Math.log(unionDocId.size() * 1.0 / bgCount) + bgFgLogP);
          }

// double klDiver = unionDocId.size();
// Integer bgCount = bgCountMap.get(mergedItemset.elementSet());
// if (bgCount == null) {
// bgCount = 1;
// } else {
// // LOG.trace("it matches background");
// }
// klDiver *= (Math.log(unionDocId.size() * 1.0 / bgCount) + bgFgLogP);

          selectionFormat.out().append(printMultiset(mergedItemset));
          selectionFormat.format(
              "\t%.15f\t%.15f\t%.15f\t%d\t%.15f\t%.15f\t",
              confidence,
              klDiver,
              calcNormalizedSumTfIdf(mergedItemset, idfFromBG ? bgCountMap : fgCountMap,
                  idfFromBG ? bgNumTweets : fgNumTweets, bgIDFMap),
              unionDocId.size(),
              calcEntropy(mergedItemset.elementSet(), entropyFromBg ? bgCountMap : fgCountMap,
                  entropyFromBg ? bgNumTweets : fgNumTweets),
              calcCrossEntropy(mergedItemset.elementSet(), bgCountMap, fgCountMap, bgNumTweets, fgNumTweets));

          Set<Long> headDocIds = Sets.newCopyOnWriteArraySet(fgIdsMap.get(e.getKey()));
          selectionFormat.out().append(headDocIds.toString().substring(1))
              .append(Sets.difference(unionDocId, headDocIds).toString().substring(1));

          selectionFormat.out().append("\n");
        }

        // Print the parents that were pending alliance with children to make sure they have conf
        // those ones didn't prove to have any confident children, but we have to give them a chance
        for (java.util.Map.Entry<Set<String>, Double> e : unalliedItemsets.entrySet()) {
          Set<String> itemset = e.getKey();
          Multiset<String> mergedItemset = HashMultiset.create(itemset);
          LinkedList<Long> docids = fgIdsMap.get(itemset);

          double confidence;
          double klDiver = e.getValue();
          int supp = docids.size();
          double entropy;
          if (confidentItemsets.containsKey(itemset)) {
            confidence = confidentItemsets.get(itemset);
          } else {
            confidence = -1;
          }

          selectionFormat.out().append(printMultiset(mergedItemset));
          selectionFormat.format("\t%.15f\t%.15f\t%.15f\t%d\t%.15f\t%.15f\t",
              confidence, // 2
              klDiver, // 3
              calcNormalizedSumTfIdf(mergedItemset, idfFromBG ? bgCountMap : fgCountMap,
                  idfFromBG ? bgNumTweets : fgNumTweets, bgIDFMap), // 4
              supp, // 5
              calcEntropy(itemset, entropyFromBg ? bgCountMap : fgCountMap,
                  entropyFromBg ? bgNumTweets : fgNumTweets), // 6
              calcCrossEntropy(mergedItemset.elementSet(), bgCountMap, fgCountMap, bgNumTweets, fgNumTweets)); // 7
          selectionFormat.out().append(docids.toString().substring(1));
        }

      } finally {
        novelClose.close();
      }
    }

  }

  private static double calcComponentsKLDiver(Set<String> itemset, double itemsetCnt,
      Map<Set<String>, Integer> bgCountMap,
      Map<Set<String>, Integer> fgCountMap, double bgFgLogP, Map<String, Double> kldCache) {
    double retVal = 0;
    for (String item : itemset) {
      Double itemKLD = kldCache.get(item);
      if (itemKLD == null) {
        Set<String> itemKey = Collections.singleton(item);
        Integer bgItemCnt = bgCountMap.get(itemKey);
        Integer fgItemCnt = fgCountMap.get(itemKey);
        if (bgItemCnt == null) {
          continue; // this is very important because we don't want wierd words to get high scores
        }
        if (fgItemCnt == null) {
          fgItemCnt = (int) itemsetCnt;
        }
        // Multiplying by many hight numbers makes this value absolutlely high: fgItemCnt.doubleValue() *
        itemKLD = (Math.log(fgItemCnt.doubleValue() / bgItemCnt.doubleValue()) + bgFgLogP);
        kldCache.put(item, itemKLD);
      }
      retVal += itemKLD;
    }

    return itemsetCnt * retVal;
  }

  private static double calcCrossEntropy(Set<String> itemset, Map<Set<String>, Integer> bgCountMap,
      Map<Set<String>, Integer> fgCountMap, double bgNumTweets, double fgNumTweets) {
    double e = 0;
    for (String item : itemset) {
      Set<String> itemKey = Collections.singleton(item);
      Integer bgItemCnt = bgCountMap.get(itemKey);
      Integer fgItemCnt = fgCountMap.get(itemKey);
      if (bgItemCnt == null || fgItemCnt == null) {
        continue;
      }
      double bgItemP = bgItemCnt * 1.0 / bgNumTweets;
      double fgItemP = fgItemCnt * 1.0 / fgNumTweets;

      e += fgItemP * DoubleMath.log2(bgItemP);
    }
    return (QUALITY_APPRECIATE_LARGE_ALLIANCES ? -e : -e / itemset.size());
  }

  private static double calcEntropy(Set<String> itemset, Map<Set<String>, Integer> countMap, double numTweets) {
    double e = 0;
    for (String item : itemset) {
      Integer itemCnt = countMap.get(Collections.singleton(item));
      if (itemCnt == null) {
        continue;
      }
      double itemP = itemCnt * 1.0 / numTweets;
      e += itemP * DoubleMath.log2(itemP);
    }
    return (QUALITY_APPRECIATE_LARGE_ALLIANCES ? -e : -e / itemset.size());
  }

  private static double calcNormalizedSumTfIdf(Multiset<String> mergedItemset, Map<Set<String>, Integer> countMap,
      double numTweets, Map<String, Double> cachedIDFMap) {
    double retVal = 0;
    int sumTf = 0;
    for (Entry<String> e : mergedItemset.entrySet()) {
      Double idf = cachedIDFMap.get(e.getElement());
      if (idf == null) {
        Integer itemCnt = countMap.get(Collections.singleton(e.getElement()));
        if (itemCnt == null) {
          itemCnt = 0;
        }
        idf = Math.log(numTweets * 1.0 / (itemCnt + 1));
      }
      int tf = (QUALITY_APPRECIATE_LARGE_ALLIANCES ? e.getCount() : 1);
      sumTf += tf;
      retVal += tf * idf;
    }
    return retVal / sumTf;
  }

  private static CharSequence printHashset(Set<String> itemset) {
    String[] elts = itemset.toArray(new String[itemset.size()]);
    StringBuilder retVal = new StringBuilder();
    Arrays.sort(elts);
    for (String e : elts) {
      retVal.append("," + e + "(1)");
    }
    return retVal.substring(1);
  }

  private static CharSequence printMultiset(Multiset<String> mset) {
    String[] elts = mset.elementSet().toArray(new String[mset.entrySet().size()]);
    StringBuilder retVal = new StringBuilder();
    Arrays.sort(elts);
    for (String e : elts) {
      retVal.append("," + e + "(" + mset.count(e) + ")");
    }
    return retVal.substring(1);
  }
}
