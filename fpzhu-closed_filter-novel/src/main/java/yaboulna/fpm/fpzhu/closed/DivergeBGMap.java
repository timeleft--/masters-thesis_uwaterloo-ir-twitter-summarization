package yaboulna.fpm.fpzhu.closed;

import java.io.File;
import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.lang.management.ThreadMXBean;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.AbstractMap;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.Formatter;
import java.util.HashSet;
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
import org.apache.commons.lang.mutable.MutableInt;
import org.apache.commons.math.stat.descriptive.DescriptiveStatistics;
import org.apache.commons.math3.stat.descriptive.SummaryStatistics;
import org.apache.log4j.Appender;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Level;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import yaboulna.fpm.postgresql.PerfMonKeyValueStore;

import com.google.common.base.Charsets;
import com.google.common.base.Splitter;
import com.google.common.collect.HashMultimap;
import com.google.common.collect.HashMultiset;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Multimap;
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

  private static final Splitter comaSplitter = Splitter.on(',');
  static class ItemsetTabCountProcessor implements LineProcessor<int[]> {

    private static final String NUM_TWEETS_STR = "NUMTWEETS";

    public static final CopyOnWriteArraySet<String> NUM_TWEETS_KEY = Sets.newCopyOnWriteArraySet(Arrays
        .asList(NUM_TWEETS_STR));

// Builder<String, Integer> mapBuilder = ImmutableMap.builder();
    final Map<Set<String>, Integer> fpCntMap;
    final Map<Set<String>, LinkedList<Long>> fpDocIdsMap;
// Avoid copying this from one frame to another = Maps.newHashMapWithExpectedSize(4444444);
    boolean skipOneCharSets = true;
    int ignoredCount = 0;
    int repeatedItemsetsLessOrEqNewCnt = 0;
    int repeatedItemsetsMoreNewCnt = 0;
    int sumDifferenceInRepeatedCnt = 0;
    int maxDifferenceInRepeatedCnt = 0;

    private SummaryStatistics unigramCountStats;

    public ItemsetTabCountProcessor(Map<Set<String>, Integer> fgCountMap,
        Map<Set<String>, LinkedList<Long>> fgIdsMap) {
      this(fgCountMap, fgIdsMap, null);
    }

    public ItemsetTabCountProcessor(Map<Set<String>, Integer> bgCountMap) {
      this(bgCountMap, null);
    }

    public ItemsetTabCountProcessor(Map<Set<String>, Integer> fgCountMap,
        Map<Set<String>, LinkedList<Long>> fgIdsMap, SummaryStatistics unigramCountStats) {
      this.fpCntMap = fgCountMap;
      this.fpDocIdsMap = fgIdsMap;
      this.unigramCountStats = unigramCountStats;
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

      if (ENFORCE_HIGHER_SUPPORT && count < ENFORCED_SUPPORT) {
        return true;
      }

      String ids = (tabIx2 < line.length() ? line.substring(tabIx2 + 1) : "");

// mapBuilder.put(itemset, count);
      CopyOnWriteArraySet<String> itemset = Sets.newCopyOnWriteArraySet(comaSplitter.split(itemsetStr));

      if (skipOneCharSets && // itemset.size() > 1 &&
          ((itemsetStr.length() - (itemset.size() - 1)) * 1.0 / itemset.size()) < 2) {
// if (LOG.isTraceEnabled())
// LOG.trace("Filtering out itemset {} with average item length of {}, appearing in docs: "
// + ids.substring(0, Math.min(ids.length(), 189)), itemset, "[less than 2]");
        ++ignoredCount;
        return true;
      }
      Integer currCnt = fpCntMap.get(itemset);
      if (currCnt != null) {
        LOG.debug("Repeated itemset {} with existing cnt {} and new cnt " + count, itemset, currCnt);

        if (fpDocIdsMap != null && ids.length() > 0) {

          LinkedList<Long> newDocIds = Lists.newLinkedList();
          for (String docid : comaSplitter.split(ids)) {
            newDocIds.add(Long.valueOf(docid));
          }
          Iterator<Long> newDocIdsIter = newDocIds.iterator();
          Long newDocIdI = newDocIdsIter.next();

          LinkedList<Long> mergedIds = Lists.newLinkedList();
          for (Long existingDocId : fpDocIdsMap.get(itemset)) {
            while (newDocIdI < existingDocId) {

              mergedIds.add(newDocIdI);

              if (newDocIdsIter.hasNext()) {
                newDocIdI = newDocIdsIter.next();
              } else {
                newDocIdI = Long.MAX_VALUE;
              }
            }

            mergedIds.add(existingDocId);

            if (existingDocId.equals(newDocIdI)) {
              if (newDocIdsIter.hasNext()) {
                newDocIdI = newDocIdsIter.next();
              } else {
                newDocIdI = Long.MAX_VALUE;
              }
            }
          }

          while (newDocIdI < Long.MAX_VALUE) {

            mergedIds.add(newDocIdI);

            if (newDocIdsIter.hasNext()) {
              newDocIdI = newDocIdsIter.next();
            } else {
              newDocIdI = Long.MAX_VALUE;
            }
          }

          count = mergedIds.size();

          if (currCnt >= count) {
            ++repeatedItemsetsLessOrEqNewCnt;
            sumDifferenceInRepeatedCnt += currCnt - count;
            if (currCnt - count > maxDifferenceInRepeatedCnt) {
              maxDifferenceInRepeatedCnt = currCnt - count;
            }
            return true;
          } else {
            ++repeatedItemsetsMoreNewCnt;
            sumDifferenceInRepeatedCnt += count - currCnt;
            if (count - currCnt > maxDifferenceInRepeatedCnt) {
              maxDifferenceInRepeatedCnt = count - currCnt;
            }

            fpCntMap.put(itemset, count);
            fpDocIdsMap.put(itemset, mergedIds);
          }

        } else {

          if (currCnt >= count) {
            ++repeatedItemsetsLessOrEqNewCnt;
            sumDifferenceInRepeatedCnt += currCnt - count;
            if (currCnt - count > maxDifferenceInRepeatedCnt) {
              maxDifferenceInRepeatedCnt = currCnt - count;
            }
            return true;
          } else {
            ++repeatedItemsetsMoreNewCnt;
            sumDifferenceInRepeatedCnt += count - currCnt;
            if (count - currCnt > maxDifferenceInRepeatedCnt) {
              maxDifferenceInRepeatedCnt = count - currCnt;
            }
            fpCntMap.put(itemset, count);
          }
        }
      } else {
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
      }
      if (unigramCountStats != null && itemset.size() == 1) {
        unigramCountStats.addValue(count);
      }
      return true;
    }
    @Override
    public int[] getResult() {
      return new int[]{ignoredCount, repeatedItemsetsLessOrEqNewCnt, repeatedItemsetsMoreNewCnt,
          sumDifferenceInRepeatedCnt, maxDifferenceInRepeatedCnt};
    }
  }

  // max num of itemsets was 4434143 according to wc -l of the folder lcm_closed/4wk+1wk...1-abs672
  private static final int BG_MAX_NUM_ITEMSETS = 4444444;

  // max num of itemsets was 2688780 fp_3600_1352260800 in the folder lcm_closed/1hr+30min...1-abs5
  private static final int FG_MAX_NUM_ITEMSETS = 2700000;

// private static final double CONFIDENCE_LOW_THRESHOLD = 0.1; // upper bound to ???
  private static final double CONFIDENCE_DEFAULT_THRESHOLD = 0.1; // lower bound

  private static final double ITEMSET_SIMILARITY_JACCARD_GOOD_THRESHOLD = 0.8; // Jaccard similarity
// private static final double ITEMSET_SIMILARITY_COSINE_GOOD_THRESHOLD = 0.66; // Cosine similarity
  private static final double ITEMSET_SIMILARITY_PROMISING_THRESHOLD = 0;// 0.33; // Jaccard similarity
  private static final int ITEMSET_SIMILARITY_PPJOIN_MIN_LENGTH = 3;
  private static final double ITEMSET_SIMILARITY_BAD_THRESHOLD = 0.1; // Cosine or Jaccard similariy

// private static final double DOCID_SIMILARITY_GOOD_THRESHOLD = 0.75; // Overlap similarity

  private static final double KLDIVERGENCE_MIN = 0; // this is multiplied by frequency not prob

  private static final int MAX_LOOKBACK_FOR_PARENT = 1000;

  private static final boolean RESEARCH_MODE = true;

  private static final boolean QUALITY_APPRECIATE_LARGE_ALLIANCES = false;
  private static final boolean ITEMSETS_SEIZE_TO_EXIST_AFTER_JOINING_ALLIANCE = false;
  private static final boolean ALLIANCE_PREFER_SHORTER_ITEMSETS = false;
  private static final boolean ALLIANCE_PREFER_LONGER_ITEMSETS = false;

  private static final boolean PERFORMANCE_CALC_MODE_LESS_LOGGING = true;

  private static final boolean ENFORCE_HIGHER_SUPPORT = false;
  private static final int ENFORCED_SUPPORT = 33;
  private static final int HISTORY_LEN_IN_SECS = 7 * 24 * 3600;

  static boolean unLimitedBufferSize = false;
  static boolean stopMatchingParentFSimLow = false;
  static boolean allowFormingMultipleAlliances = false;
  static boolean ppJoin = false;
  static boolean idfFromBG = false;
  static boolean entropyFromBg = false;
  static boolean growAlliancesAcrossEpochs = false;
  static boolean filterLowKLD = false;
  static boolean fallBackToItemsKLD = false;
  static boolean cntUnMaximal = true;
  static boolean honorTemporalSimilarity = false;
  static int temporalSimilarityThreshold = 60; // seconds
  static int absMaxDiff = 1000; // TODO arg
  static boolean trending = false;
  static boolean perfMon = true;
  static boolean TOTALLY_IGNORE_1ITEMSETS = false;
  static boolean IGNORE_1ITEMSETS_VERY_HIGH_CNT = false;
  static boolean allianceKLDPositiveOnly = false;
  static boolean maxDiffFromMinSupp = true;
  static boolean noCosineSimilarity = true;
  static boolean noJaccardSim = false;

  /**
   * @param args
   * @throws IOException
   * @throws SQLException
   * @throws ClassNotFoundException
   */
  public static void main(String[] args) throws IOException, ClassNotFoundException, SQLException {
    File bgDir = new File(args[0]);
    if (!bgDir.exists()) {
      throw new IllegalArgumentException("Path doesn't exist: " + bgDir.getAbsolutePath());
    }

    File fgDir = new File(args[1]);
    if (!fgDir.exists()) {
      throw new IllegalArgumentException("Path doesn't exist: " + fgDir.getAbsolutePath());
    }

    final double confThreshold;
    if (args.length > 2) {
      confThreshold = Double.parseDouble(args[2]);
    } else {
      confThreshold = CONFIDENCE_DEFAULT_THRESHOLD;
    }

    if (args.length > 3) {
      unLimitedBufferSize = args[3].contains("ULBuff");
      stopMatchingParentFSimLow = args[3].contains("SimLow");
      allowFormingMultipleAlliances = args[3].contains("MultiAlli");
      ppJoin = args[3].contains("Ppj");
      idfFromBG = args[3].contains("IdfBg");
      entropyFromBg = args[3].contains("EntBg");
      growAlliancesAcrossEpochs = args[3].contains("Grow");
      filterLowKLD = args[3].contains("KldPosOnly");
      fallBackToItemsKLD = args[3].contains("ITKld");
      cntUnMaximal = !args[3].contains("MaxOnly");
      honorTemporalSimilarity = args[3].contains("Temporal");
      trending = args[3].contains("Trending");
      perfMon = !args[3].contains("NoPerfMon");
      TOTALLY_IGNORE_1ITEMSETS = args[3].contains("Ignore1Tot");
      IGNORE_1ITEMSETS_VERY_HIGH_CNT = args[3].contains("Ignore1VHi");
      allianceKLDPositiveOnly = args[3].contains("KLDPosOnly");
      maxDiffFromMinSupp = !args[3].contains("MaxSupp");
      noCosineSimilarity = !args[3].contains("LowCos");
      noJaccardSim = args[3].contains("NoJaccard");
    }

    LOG.info("unLimitedBufferSize: " + unLimitedBufferSize);
    LOG.info("stopMatchingParentFSimLow: " + stopMatchingParentFSimLow);
    LOG.info("allowFormingMultipleAlliances: " + allowFormingMultipleAlliances);
    LOG.info("ppJoin: " + ppJoin);
    LOG.info("idfFromBG: " + idfFromBG);
    LOG.info("entropyFromBg: " + entropyFromBg);
    LOG.info("growAlliancesAcrossEpochs: " + growAlliancesAcrossEpochs);
    LOG.info("filterLowKLD: " + filterLowKLD);
    LOG.info("fallBackToItemsKLD: " + fallBackToItemsKLD);
    LOG.info("cntUnMaximal: " + cntUnMaximal);
    LOG.info("honorTemporalSimilarity: " + honorTemporalSimilarity);
    LOG.info("trending: " + trending);
    LOG.info("perfMon: " + perfMon);
    LOG.info("TOTALLY_IGNORE_1ITEMSETS: " + TOTALLY_IGNORE_1ITEMSETS);
    LOG.info("IGNORE_1ITEMSETS_VERY_HIGH_CNT: " + IGNORE_1ITEMSETS_VERY_HIGH_CNT);
    LOG.info("allianceKLDPositiveOnly: " + allianceKLDPositiveOnly);
    LOG.info("maxDiffFromMinSupp: " + maxDiffFromMinSupp);
    LOG.info("noCosineSimilarity: " + noCosineSimilarity);
    LOG.info("NoJaccard: " + noJaccardSim);

    String thresholds = "";
    thresholds += " ITEMSET_SIMILARITY_JACCARD_GOOD_THRESHOLD=" + ITEMSET_SIMILARITY_JACCARD_GOOD_THRESHOLD;
    thresholds += " ITEMSET_SIMILARITY_COSINE_GOOD_THRESHOLD=ITEMSET_SIMILARITY_BAD_THRESHOLD";// +
// ITEMSET_SIMILARITY_COSINE_GOOD_THRESHOLD;
    thresholds += " ITEMSET_SIMILARITY_PROMISING_THRESHOLD=" + ITEMSET_SIMILARITY_PROMISING_THRESHOLD;
    thresholds += " ITEMSET_SIMILARITY_PPJOIN_MIN_LENGTH=" + ITEMSET_SIMILARITY_PPJOIN_MIN_LENGTH;
    thresholds += " ITEMSET_SIMILARITY_BAD_THRESHOLD=" + ITEMSET_SIMILARITY_BAD_THRESHOLD;
// thresholds += " DOCID_SIMILARITY_GOOD_THRESHOLD="+DOCID_SIMILARITY_GOOD_THRESHOLD;
    thresholds += " CONFIDENCE_HIGH_THRESHOLD=" + confThreshold;

    LOG.info("Thresholds: " + thresholds);

    int bgLenSecs = 4 * 7 * 24 * 3600;
    if (args.length > 4) {
      bgLenSecs = Integer.parseInt(args[4]);
    }

// String novelPfx = "novel_";
// // if (args.length > 3) {
// // novelPfx = args[3];
// // }
//
// String selectionPfx = "sel_";

    String options;
    if (args.length > 3) {
      options = args[3];
    } else {
      options = "defaultOpts";
    }

    options += "_conf" + confThreshold;

    if (filterLowKLD) {
      options += "_KLD" + KLDIVERGENCE_MIN;
    }
    if (honorTemporalSimilarity) {
      options += "_Secs" + temporalSimilarityThreshold;
    }
    if (!unLimitedBufferSize) {
      options += "_Buff" + MAX_LOOKBACK_FOR_PARENT;
    }

    args = Arrays.copyOf(args, 4);

    args[2] = options;

    args[3] = thresholds;

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
    final List<File> fgFiles = (List<File>) FileUtils.listFiles(fgDir, fpNotOutFilter,
        FileFilterUtils.trueFileFilter());
    Collections.sort(fgFiles, NameFileComparator.NAME_COMPARATOR);
    final LinkedHashMap<Set<String>, Integer> fgCountMap = Maps.newLinkedHashMap();
    final SummaryStatistics unigramCountStats = new SummaryStatistics();
    final Map<Set<String>, LinkedList<Long>> fgIdsMap = Maps.newHashMapWithExpectedSize(FG_MAX_NUM_ITEMSETS);
    final Map<Set<String>, Double> positiveKLDivergence = Maps.newHashMapWithExpectedSize(FG_MAX_NUM_ITEMSETS);

    Map<Set<String>, SummaryStatistics> historyStats = null;
    Map<Set<String>, MutableInt> historyTtl = null;
    if (trending) {
      historyStats = Maps.newHashMapWithExpectedSize(FG_MAX_NUM_ITEMSETS);
      historyTtl = Maps.newHashMapWithExpectedSize(FG_MAX_NUM_ITEMSETS);
    }

    final List<File> bgFiles = (List<File>) FileUtils.listFiles(bgDir, fpNotOutFilter,
        FileFilterUtils.trueFileFilter());
    Collections.sort(bgFiles, NameFileComparator.NAME_COMPARATOR);
    long loadedBgStartUx = -1;
    final Map<Set<String>, Integer> bgCountMap = Maps.newHashMapWithExpectedSize(BG_MAX_NUM_ITEMSETS);
    final Map<String, Double> bgIDFMap = Maps.newHashMapWithExpectedSize(BG_MAX_NUM_ITEMSETS / 10);

    Splitter underscoreSplit = Splitter.on('_');

    final Map<Set<String>, java.util.Map.Entry<Multiset<String>, Set<Long>>> growingAlliances = Maps.newHashMap();
    final Map<Set<String>, DescriptiveStatistics> alliedKLD = Maps.newHashMap();
    final Map<Set<String>, Set<String>> itemsetParentMap = Maps.newHashMap();
    final Map<Set<String>, Set<Set<String>>> allianceTransitive = Maps.newHashMap();
    final Multimap<Set<String>, Set<String>> allianceTransitiveInverse = HashMultimap.create();
    final Map<Set<String>, Double> unalliedItemsets = Maps.newHashMap();
    final Map<Set<String>, Double> confidentItemsets = Maps.newHashMap();
    final Set<String> preAllocatedSet1 = Sets.newHashSet();
    final Set<String> preAllocatedSet2 = Sets.newHashSet();
    final Set<Set<String>> ancestorItemsets = Sets.newHashSet();
    final HashSet<Set<String>> mergeCandidates = Sets.newHashSet(); // Lists.newLinkedList();

    // Multiset<String> mergedItemset = HashMultiset.create();
    // Set<Long> grandUionDocId = Sets.newHashSet();
    // Set<Long> grandIntersDocId = Sets.newHashSet();
    // LinkedList<Long> unionDocId;
    // Set<Long> intersDocId;
    // unionDocId = Lists.newLinkedList();
    // intersDocId = Sets.newHashSet();

    final Map<Set<String>, Double> kldCache = Maps.newHashMapWithExpectedSize(BG_MAX_NUM_ITEMSETS);

    final LinkedList<Set<String>> prevItemsets = Lists.newLinkedList();

    Closer perfMonCloser = Closer.create();

    try {
      PerfMonKeyValueStore perfMonKV = perfMonCloser.register(new PerfMonKeyValueStore(DivergeBGMap.class.getName(),
          Arrays.toString(args)));
      perfMonKV.batchSizeToWrite = 19; // FIXME: whenever you add a new perf key
      for (File fgF : fgFiles) {
        final File novelFile = new File(fgF.getParentFile(), fgF.getName()
            .replaceFirst("fp_", "novel_" + options + "_"));
        if (novelFile.exists()) {
          // TODO: skip output that already exists
        }

        final File selFile = new File(fgF.getParentFile(), fgF.getName().replaceFirst("fp_", "sel_" + options + "_"));

        org.apache.log4j.Logger rootLogger = org.apache.log4j.Logger.getRootLogger();
        if (PERFORMANCE_CALC_MODE_LESS_LOGGING) {
          rootLogger.setLevel(Level.INFO);
        }
        @SuppressWarnings("unchecked")
        Enumeration<Appender> appenders = rootLogger.getAllAppenders();
        while (appenders.hasMoreElements()) {
          Appender fileAppender = (Appender) appenders.nextElement();
          if (fileAppender instanceof FileAppender) {
            ((FileAppender) fileAppender).setFile(selFile.getAbsolutePath() + "_"
                + logFileNameFmt.format(new Date()) + ".log");
            ((FileAppender) fileAppender).activateOptions();
          }
        }
        long windowStartUx = Long.parseLong(Iterables.get(underscoreSplit.split(fgF.getName()), 2));
        long idealBgStartUx = windowStartUx - bgLenSecs;

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
              Files.readLines(bgFiles.get(b), Charsets.UTF_8, new ItemsetTabCountProcessor(bgCountMap));
              LOG.info("Loaded background freqs - num itemsets: {} ", bgCountMap.size());
            }
            break;
          }
        }

        final double hrsPerEpoch = Long.parseLong(Iterables.get(underscoreSplit.split(fgF.getName()), 1)) / 3600.0;
        if (!growAlliancesAcrossEpochs) {
          growingAlliances.clear();
          alliedKLD.clear();
          allianceTransitive.clear();
          allianceTransitiveInverse.clear();
          itemsetParentMap.clear();
          fgCountMap.clear();
          unigramCountStats.clear();
          fgIdsMap.clear();
        }
        positiveKLDivergence.clear();
        unalliedItemsets.clear();
        confidentItemsets.clear();
        mergeCandidates.clear();
        prevItemsets.clear();
        kldCache.clear();
        if (!idfFromBG) {
          bgIDFMap.clear();
        }

        final long historyLenInEpochSteps = Math.round(HISTORY_LEN_IN_SECS / (hrsPerEpoch * 3600.0));

        LOG.info("Loading foreground freqs from {}", fgF);
        int[] fileReadingPerfMeasures = Files.readLines(fgF, Charsets.UTF_8,
            new ItemsetTabCountProcessor(fgCountMap, fgIdsMap,
                (TOTALLY_IGNORE_1ITEMSETS || !IGNORE_1ITEMSETS_VERY_HIGH_CNT ? null : unigramCountStats)));
        LOG.info("Loaded foreground freqs - num itemsets: {}", fgCountMap.size());

        if (fgCountMap.size() == 0) {
          continue;
        }

        final double stopWordsThreshold = (TOTALLY_IGNORE_1ITEMSETS || !IGNORE_1ITEMSETS_VERY_HIGH_CNT ?
            Double.MAX_VALUE :
            unigramCountStats.getMean() + 2 * unigramCountStats.getStandardDeviation()
            );
        final double bgNumTweets = bgCountMap.get(ItemsetTabCountProcessor.NUM_TWEETS_KEY);
        final double fgNumTweets = fgCountMap.get(ItemsetTabCountProcessor.NUM_TWEETS_KEY);
        final double bgFgLogP = Math.log((bgNumTweets + fgCountMap.size()) / (fgNumTweets + fgCountMap.size()));

        final MutableInt unMaximalIS = new MutableInt(0);

        class StronglyClosedItemsetsFilter implements Runnable {

          private static final boolean ALLIANCES_MERGE_WITH_HEAD = false;
          private static final boolean PARENT_RECIPROCAL_CONFIDENCE_AZINDEFENCE = false;
          private boolean done;
          private int numLen1Itemsets = 0;
          private int absMaxDiffEnforced = 0;

          public void run() {
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
              kldCache.put(itemset, klDiver);

              if (itemset.size() == 1) {
                ++numLen1Itemsets; // .increment();
                if (!TOTALLY_IGNORE_1ITEMSETS) {
                  if (!IGNORE_1ITEMSETS_VERY_HIGH_CNT || fgFreq < stopWordsThreshold) {
                    prevItemsets.addLast(itemset);
                  }
                }
                continue;
              }

              if (!filterLowKLD || klDiver > KLDIVERGENCE_MIN) {
                positiveKLDivergence.put(itemset, klDiver);

              }
              // ////////////////////////////////////////////

              if (++counter % 10000 == 0) {
                LOG.info("Processed {} itemsets. Last one: {}", counter, itemset + "=" + klDiver);
              }

              // ////////////////////////////////////////////

              if (!filterLowKLD || klDiver > KLDIVERGENCE_MIN) {
                LinkedList<Long> iDocIds = fgIdsMap.get(itemset);
                if (iDocIds == null || iDocIds.isEmpty()) {
                  LOG.warn("Using a foreground file with truncated docids. No docids for itemset: " + iDocIds);
                  prevItemsets.addLast(itemset);
                  continue;
                }

                if (LOG.isTraceEnabled())
                  LOG.trace(itemset.toString() + iDocIds.size() + " docids: " + iDocIds);

                Double itemsetNorm = null;
                mergeCandidates.clear();

                Set<String> parentItemset = null;
                ancestorItemsets.clear();
                Iterator<Set<String>> prevIter = prevItemsets.descendingIterator();
                double maxConfidence = -1.0; // if there is no parent, then this is the first from these items
                boolean allied = false;

                int lookBackRecords = 0;

                while (prevIter.hasNext()) { // there are more than one parent: && !foundParent
                  Set<String> pis = prevIter.next();

                  Set<String> interset;
                  Set<String> isPisUnion = null;

                  if (!ppJoin || pis.size() < ITEMSET_SIMILARITY_PPJOIN_MIN_LENGTH
                      || itemset.size() < ITEMSET_SIMILARITY_PPJOIN_MIN_LENGTH) {
                    interset = Sets.intersection(itemset, pis);
                    if (!noCosineSimilarity)
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
                    while (currDiff <= maxDiff) { // allDiffPfxLen <= maxAllDiffPfx
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

                      ancestorItemsets.add(pis);

                      if (parentItemset == null) {
                        parentItemset = pis;
                        // first parent to encounter will be have the lowest support, thus gives highest confidence
                        double pisFreq = fgCountMap.get(pis);
                        maxConfidence = fgCountMap.get(itemset) / pisFreq;
                        if (LOG.isTraceEnabled())
                          LOG.trace("{} found parent {}, with confidence: " + maxConfidence,
                              itemset.toString() + fgCountMap.get(itemset), pis.toString() + pisFreq);
                      } else {
                        if (LOG.isTraceEnabled())
                          LOG.trace("{} found another parent {}, with confidence: "
                              + fgCountMap.get(itemset).doubleValue()
                              / fgCountMap.get(pis).doubleValue(),
                              itemset.toString() + fgCountMap.get(itemset), pis.toString() + fgCountMap.get(pis));
                      }
                    } else {
                      if (LOG.isTraceEnabled())
                        LOG.trace("{} is NOT longer that its 'parent' {}, with confidence: "
                            + fgCountMap.get(itemset).doubleValue()
                            / fgCountMap.get(pis).doubleValue(),
                            itemset.toString() + fgCountMap.get(itemset),
                            pis.toString() + fgCountMap.get(pis));
                    }
// if (maxConfidence >= HIGH_CONFIDENCE_THRESHOLD) {
// // it will get printed without alliances.. oh, it doesn't need alliance
// allied = true;
// break;
// }
                  } else {

                    // Itemset similiarity starts by a lightweight Jaccard Similarity similiarity,
                    // then if it is promising then the cosine similarity is calculated with IDF weights

                    double isPisSim = interset.size() * 1.0;
                    if (!noCosineSimilarity)
                      isPisSim /= isPisUnion.size();
                    if (// noCosineSimilarity ||
                    noJaccardSim || isPisSim > 0) { // >= ITEMSET_SIMILARITY_PROMISING_THRESHOLD
                      String simMeasure;
                      if (!noCosineSimilarity && isPisSim < ITEMSET_SIMILARITY_JACCARD_GOOD_THRESHOLD) {
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
                      } else if (noJaccardSim) {
                        simMeasure = "None";
                      } else {
                        simMeasure = "Jaccard";
                      }
                      if ((noJaccardSim && noCosineSimilarity) || isPisSim > 0) { // = ITEMSET_SIMILARITY_BAD_THRESHOLD) {
// // ITEMSET_SIMILARITY_COSINE_GOOD_THRESHOLD)
                        mergeCandidates.add(pis);
                        if (!(noJaccardSim && noCosineSimilarity) && LOG.isTraceEnabled())
                          LOG.trace("{} " + simMeasure + " {} = " + isPisSim,
                              itemset.toString() + fgCountMap.get(itemset),
                              pis.toString() + fgCountMap.get(pis));
                      }
                    }

                    if ((stopMatchingParentFSimLow && parentItemset != null &&
                        isPisSim < ITEMSET_SIMILARITY_BAD_THRESHOLD)
                        || (!unLimitedBufferSize && ++lookBackRecords > MAX_LOOKBACK_FOR_PARENT)) {
                      // TODONE: could this also work without checking foundParent -> NO, very few alliances happen
                      // TODO: are we losing anything by breaking on the first bad similarity
// if (LOG.isTraceEnabled())
// LOG.trace("Decided there won't be any more candidates for itemset {} when we encountered {}.",
// itemset, pis);
                      break; // the cluster of itemsets from these items is consumed
                    }
                  }
                }

// // Add to previous for next iterations to access it, regardless if it will get merged or not.. it can
// prevItemsets.addLast(itemset);

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

                Set<String> theOnlyOneIllMerge = null;
                int theOnlyOnesDifference = Integer.MAX_VALUE;
                if (growAlliancesAcrossEpochs && allianceTransitive.containsKey(itemset)) {
                  mergeCandidates.addAll(allianceTransitive.get(itemset));
                }

                if (LOG.isTraceEnabled())
                  LOG.trace(itemset.toString() + iDocIds.size() + " merge candidates: " + mergeCandidates);

                int bestUnofficialCandidateDiff = Integer.MAX_VALUE;
                Set<String> bestUnofficialCandidate = null;
                for (Set<String> cand : mergeCandidates) {

                  LinkedList<Long> candDocIds = fgIdsMap.get(cand);
                  if (candDocIds == null || candDocIds.isEmpty()) {
                    LOG.warn("Using a file with truncated inverted indexes");
                    continue;
                  }

                  int differentDocs = Math.max(candDocIds.size(), iDocIds.size())
                      - Math.min(candDocIds.size(), iDocIds.size());

                  double maxDiffCnt =
                      ((ancestorItemsets.contains(cand)) ?
                          // the (true) parent will necessarily be present in all documents of itemset
// differentDocs = candDocIds.size() - iDocIds.size();
// Math.floor((itemset.size() == 2?confThreshold: (1 - confThreshold)) * candDocIds.size())
                          (!PARENT_RECIPROCAL_CONFIDENCE_AZINDEFENCE ? Math.floor((1 - confThreshold)
                              * candDocIds.size()) :
                              Math.floor((1 / confThreshold) * iDocIds.size()))
                          :

                          Math.min(absMaxDiff * hrsPerEpoch, // hard max number of diff tweets to allow a merger
                              Math.max(0.9, // so that maxDiffCnt of 0 enters the loop
                                  Math.floor((1 - confThreshold) * // DOCID_SIMILARITY_GOOD_THRESHOLD) *
                                      (maxDiffFromMinSupp ? Math.min(candDocIds.size(), iDocIds.size()) :
                                          Math.max(candDocIds.size(), iDocIds.size()))))));

                  if (maxDiffCnt == absMaxDiff * hrsPerEpoch) {
                    ++absMaxDiffEnforced;
                  }

                  if (!ancestorItemsets.contains(cand)) {
// // unionDocId.clear();
// // intersDocId.clear();

                    // Intersection and union calculation (depends on that docIds are sorted)
                    // TODONE: use a variation of this measure that calculates the time period covered by each itemset
                    // TODONE: overlap of intersection with the current itemset's docids

                    Iterator<Long> iDidIter = iDocIds.iterator();
                    Iterator<Long> candDidIter = candDocIds.iterator();
                    long iDid = iDidIter.next(), candDid = candDidIter.next();

                    SummaryStatistics waitSecsTillCooc = null;
                    if (honorTemporalSimilarity) {
                      waitSecsTillCooc = new SummaryStatistics();
                    }
                    long lastCooc = Math.max(iDid, candDid) >>> 22;
                    while ((candDid > 0 && iDid > 0) &&
                        ((honorTemporalSimilarity &&
                        (waitSecsTillCooc.getN() == 0 || waitSecsTillCooc.getMean() < temporalSimilarityThreshold))
                        || differentDocs <= maxDiffCnt)) {
                      if (iDid == candDid) {
// intersDocId.add(iDid);
// unionDocId.add(iDid);
                        if (honorTemporalSimilarity) {
                          waitSecsTillCooc.addValue(((iDid >>> 22) - lastCooc) / 1000);
                        }
                        if (iDidIter.hasNext()) {
                          iDid = iDidIter.next();
                        } else {
                          iDid = -1;
// break;
                        }
                        if (candDidIter.hasNext()) {
                          candDid = candDidIter.next();
                          if (honorTemporalSimilarity) {
                            // how long will it wait for me this time?
                            lastCooc = candDid >>> 22;
                          }
                        } else {
                          candDid = -1;
// break;
                        }

                      } else if (iDid < candDid) {
// unionDocId.add(iDid);
                        ++differentDocs;
                        if (iDidIter.hasNext()) {
                          iDid = iDidIter.next();
                        } else {
                          iDid = -1;
// break;
                        }
                      } else {
// unionDocId.add(candDid);
                        ++differentDocs;
                        if (candDidIter.hasNext()) {
                          candDid = candDidIter.next();
                        } else {
                          candDid = -1;
// break;
                        }
// if (honorTemporalSimilarity) {
// // Poor cand came but I didn't overlap.. how long will it wait for me?
// lastCooc = candDid >>> 22;
// }
                      }
                    }
                    if (honorTemporalSimilarity && (iDid > 0 || candDid > 0)) {
                      long minMaxIDid = Math.min(iDocIds.getLast(), candDocIds.getLast());
                      // Assume that I would have come the next second if there were more docs in both,
                      // or after the average wait time, whichever is longer
                      waitSecsTillCooc.addValue(Math.max(
                          (waitSecsTillCooc.getN() > 0 ? waitSecsTillCooc.getMean() : -1),
                          ((((minMaxIDid >>> 22)) - lastCooc) / 1000) + 1));

                    }
                    // Residsue already accounted for in the Max - Min equation
// while (iDid > 0 && differentDocs <= maxDiffCnt) {
// ++differentDocs;
// if (iDidIter.hasNext()) {
// iDid = iDidIter.next();
// } else {
// iDid = -1;
// break;
// }
// }
                    if (honorTemporalSimilarity && LOG.isTraceEnabled()) {
                      LOG.trace(itemset.toString() + iDocIds.size()
                          + " differs in at least {} docs from {} with seconds till coocurrence of: " +
                          waitSecsTillCooc.toString().replace('\n', '|'), differentDocs,
                          cand.toString() + candDocIds.size());
                      if (differentDocs <= maxDiffCnt) {
                        LOG.trace("Similar docids");
                      } else {
                        LOG.trace("Dissimilar docids");
                      }
                      if ((waitSecsTillCooc.getN() != 0 && waitSecsTillCooc.getMean() < temporalSimilarityThreshold)) {
                        LOG.trace("Similar in time");
                      } else {
                        LOG.trace("Dissimilar in time");
                        if (differentDocs <= maxDiffCnt) {
                          LOG.trace("Dissimilar in time but not in DocIds.. woaaahh!!");
                        }
                      }
                    }

                  }
// else if(itemset.size() == 2){ // ancestor of a size 2 itemset.. might be language construct
// // filter out language constructs.. or that is, keep only named entities by YuleQ
// double a1b1 = iDocIds.size();
// double a1b0 = 0; //should be 0 since b is parent itemset, but not smooth
// double a0b1 = differentDocs;
// double a0b0 = fgNumTweets - iDocIds.size() - candDocIds.size() + a1b1;
// // Will always be 1 stupid
// double yuleQ = (a1b1 * a0b0 - a1b0 * a0b1) / (a1b1 * a0b0 + a1b0 * a0b1);
//
//
// }

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
                    int currentBestDifference = differentDocs;

                    if (!ITEMSETS_SEIZE_TO_EXIST_AFTER_JOINING_ALLIANCE) {
                      Set<Set<String>> candidateTransHeads = allianceTransitive.get(cand);
                      // what did the candidate do wrong to ignore it if it doesn't have earlier allies?
// if(candidateTransHeads == null){
// candidateTransHeads = allianceTransitive.get(itemset);
// } else {
//
// }

                      if (candidateTransHeads != null) {
                        if (mergeCandidates.contains(candidateTransHeads)) {
                          if (!allowFormingMultipleAlliances) {
                            // pretend that you are a very bad candidate.. so that your head wins the alliance:
                            currentBestDifference = Integer.MAX_VALUE;
                          }
                        } else {

                          for (Set<String> exitingAllianceHead : candidateTransHeads) {

                            Collection<Long> existingDocIds = (ALLIANCES_MERGE_WITH_HEAD ? fgIdsMap
                                .get(exitingAllianceHead) :
                                growingAlliances.get(exitingAllianceHead).getValue());
                            if (LOG.isTraceEnabled())
                              LOG.trace(itemset.toString() + iDocIds.size()
                                  + " offered one more merge option {} through candidate {}",
                                  (ALLIANCES_MERGE_WITH_HEAD ? exitingAllianceHead.toString() :
                                      growingAlliances.get(exitingAllianceHead).getKey().toString())
                                      + existingDocIds.size(),
                                  cand + "diff" + differentDocs);

                            int existingHeadNonOverlap = Integer.MAX_VALUE;
                            int existingMaxDiffCnt = 0;
                            if (allowFormingMultipleAlliances) {
                              // This way the alliance will get the score of the current cand, should be better than score
// of its alliance head
                              Iterator<Long> iDidIter = iDocIds.iterator();

                              Iterator<Long> existingDidIter = existingDocIds.iterator();
                              long iDid = iDidIter.next(), existingDid = existingDidIter.next();

                              existingHeadNonOverlap = Math.max(existingDocIds.size(), iDocIds.size())
                                  - Math.min(existingDocIds.size(), iDocIds.size());
                              existingMaxDiffCnt = (int) Math.min(absMaxDiff * hrsPerEpoch, // hard max number of diff
// tweets
// to
// allow a merger
                                  Math.max(0.9, // so that maxDiffCnt of 0 enters the loop
                                      Math.floor((1 - confThreshold) * // DOCID_SIMILARITY_GOOD_THRESHOLD) *
                                          Math.max(existingDocIds.size(), iDocIds.size()))));
                              if (existingMaxDiffCnt == absMaxDiff * hrsPerEpoch) {
                                ++absMaxDiffEnforced;
                              }

                              while ((existingDid > 0 && iDid > 0)
                                  && (existingHeadNonOverlap <= existingMaxDiffCnt)) {
                                if (iDid == existingDid) {
                                  // intersDocId.add(iDid);
                                  // unionDocId.add(iDid);
                                  if (iDidIter.hasNext()) {
                                    iDid = iDidIter.next();
                                  } else {
                                    iDid = -1;
// break;
                                  }
                                  if (existingDidIter.hasNext()) {
                                    existingDid = existingDidIter.next();
                                  } else {
                                    existingDid = -1;
// break;
                                  }
                                } else if (iDid < existingDid) {
                                  // unionDocId.add(iDid);
                                  ++existingHeadNonOverlap;
                                  if (iDidIter.hasNext()) {
                                    iDid = iDidIter.next();
                                  } else {
                                    iDid = -1;
// break;
                                  }

                                } else {
                                  // unionDocId.add(candDid);
                                  ++existingHeadNonOverlap;
                                  if (existingDidIter.hasNext()) {
                                    existingDid = existingDidIter.next();
                                  } else {
                                    existingDid = -1;
// break;
                                  }
                                }
                              }

// while (iDid > 0 && existingHeadNonOverlap <= existingMaxDiffCnt) {
// ++existingHeadNonOverlap;
// if (iDidIter.hasNext()) {
// iDid = iDidIter.next();
// } else {
// iDid = -1;
// break;
// }
// }
                            } // else: no need to calculate, since we will be biased to the alliance anyway
                            // just as if the current candidate does not exist; it is only a proxy to find
                            if ((!allowFormingMultipleAlliances && bestAllianceHead == cand)
                                || (existingHeadNonOverlap <= existingMaxDiffCnt &&
                                ((ALLIANCE_PREFER_SHORTER_ITEMSETS &&
                                    (exitingAllianceHead.size() < bestAllianceHead.size()))
                                    || (ALLIANCE_PREFER_LONGER_ITEMSETS &&
                                    (exitingAllianceHead.size() > bestAllianceHead.size()))
                                    || existingHeadNonOverlap < currentBestDifference))) {
                              // or equals prefers existing allinaces to forming new ones

                              if (allowFormingMultipleAlliances) { // TODO: this needs tweaking if more than one
// existing
                                currentBestDifference = existingHeadNonOverlap;
                              } // else: keeping the difference of cand, which should be better, so that
                              // other candidates have harder time beating the existing alliance

                              bestAllianceHead = exitingAllianceHead;
                            }
                          }
                        }
                      }
                    }
                    if ((ALLIANCE_PREFER_SHORTER_ITEMSETS &&
                        (theOnlyOneIllMerge == null || bestAllianceHead.size() < theOnlyOneIllMerge.size()))
                        || (ALLIANCE_PREFER_LONGER_ITEMSETS &&
                        (theOnlyOneIllMerge == null || bestAllianceHead.size() > theOnlyOneIllMerge.size()))
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
                    LOG.trace(
                        itemset.toString()
                            + iDocIds.size()
                            + " had diff of {} documents with the only one to merge with {}, while the max is: "
                            +
                            ((ancestorItemsets.contains(theOnlyOneIllMerge)) ?
                                // the (true) parent will necessarily be present in all documents of itemset
                                // differentDocs = candDocIds.size() - iDocIds.size();
                                (!PARENT_RECIPROCAL_CONFIDENCE_AZINDEFENCE ? Math.floor((1 - confThreshold)
                                    * fgIdsMap.get(theOnlyOneIllMerge).size()) :
                                    Math.floor((1 / confThreshold) * iDocIds.size()))
                                :
                                Math.min(absMaxDiff * hrsPerEpoch, // hard max number of diff tweets to allow a merger
                                    Math.max(0.9, // so that maxDiffCnt of 0 enters the loop
                                        Math.floor((1 - confThreshold) * // DOCID_SIMILARITY_GOOD_THRESHOLD)
                                            Math.max(fgIdsMap.get(theOnlyOneIllMerge).size(), iDocIds.size()))))),
                        theOnlyOnesDifference,
                        theOnlyOneIllMerge.toString() + fgIdsMap.get(theOnlyOneIllMerge).size());
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
                          LOG.trace(itemset.toString() + iDocIds.size()
                              + " joining its only one {} in a continuing alliance: " + transHeads.toString()
                              + fgIdsMap.get(transHeads).size(),
                              theOnlyOneIllMerge.toString() + fgIdsMap.get(theOnlyOneIllMerge).size());
                      } else {
                        // the new alliance will be better.. clear the one from earlier
                        // TODO: do I need to handle the inverse in this case.. or does it not happen anymore?
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
                  allianceTransitiveInverse.put(theOnlyOneIllMerge, itemset);

                  java.util.Map.Entry<Multiset<String>, Set<Long>> alliedItemsets = growingAlliances
                      .get(theOnlyOneIllMerge);

                  if (alliedItemsets == null) {
                    // ////// Create a new alliance
                    LinkedList<Long> theOnlyOnesDocIds = fgIdsMap.get(theOnlyOneIllMerge);
                    alliedItemsets = new AbstractMap.SimpleEntry<Multiset<String>, Set<Long>>(
                        HashMultiset.create(theOnlyOneIllMerge), Sets.newHashSet(theOnlyOnesDocIds));
                    growingAlliances.put(theOnlyOneIllMerge, alliedItemsets);

                    DescriptiveStatistics kldStats = new DescriptiveStatistics();

                    if (allianceKLDPositiveOnly) {
                      if (positiveKLDivergence.containsKey(theOnlyOneIllMerge)) {
                        kldStats.addValue(positiveKLDivergence.get(theOnlyOneIllMerge));
                      }
                    } else {
                      kldStats.addValue(kldCache.get(theOnlyOneIllMerge));
                    }

                    alliedKLD.put(theOnlyOneIllMerge, kldStats);

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

                  if (allianceKLDPositiveOnly) {
                    if (positiveKLDivergence.containsKey(itemset)) {
                      alliedKLD.get(theOnlyOneIllMerge).addValue(positiveKLDivergence.get(itemset));
                    }
                  } else {
                    alliedKLD.get(theOnlyOneIllMerge).addValue(kldCache.get(itemset));
                  }

                  allied = true;
                } else if (!mergeCandidates.isEmpty()) {
                  if (LOG.isTraceEnabled())
                    LOG.trace(
                        itemset.toString()
                            + iDocIds.size()
                            + " no one to merge with, had {} different docs with its best candidate {} while max diff is: "
                            + ((ancestorItemsets.contains(bestUnofficialCandidate)) ?
                                // the (true) parent will necessarily be present in all documents of itemset
                                // differentDocs = candDocIds.size() - iDocIds.size();
                                (!PARENT_RECIPROCAL_CONFIDENCE_AZINDEFENCE ? Math.floor((1 - confThreshold)
                                    * fgIdsMap.get(bestUnofficialCandidate).size()) :
                                    Math.floor((1 / confThreshold) * iDocIds.size()))
                                :
                                Math.min(absMaxDiff * hrsPerEpoch, // hard max number of diff tweets to allow a merger
                                    Math.max(0.9, // so that maxDiffCnt of 0 enters the loop
                                        Math.floor((1 - confThreshold) * // DOCID_SIMILARITY_GOOD_THRESHOLD)
                                            Math.max(fgIdsMap.get(bestUnofficialCandidate).size(), iDocIds.size()))))),
                        bestUnofficialCandidateDiff,
                        bestUnofficialCandidate.toString() + fgIdsMap.get(bestUnofficialCandidate).size());
                }

// maxConfidence = grandUionDocId.size() * 1.0 / fgIdsMap.get(parentItemset).size();

                if (maxConfidence >= confThreshold) {
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

                  // TODONE: are you sure about that?
                  if (cntUnMaximal) {
                    // The parent will be present in the final output within this itemset, so even if it
                    // were pending alliance to get printed it can be removed now
// unalliedItemsets.remove(parentItemset);
                    for (Set<String> pis : ancestorItemsets) {
// unalliedItemsets.remove(HashMultiset.create(pis));
// if (unalliedItemsets.containsKey(pis)) {
// unMaximalIS.increment();
// }

                      Set<String> origParent = pis;
                      while (pis != null) {
                        // unalliedItemsets.remove(parentItemset);
                        if (unalliedItemsets.containsKey(pis)) {
                          unMaximalIS.increment();
                        }
                        Set<String> grandParentItemset = itemsetParentMap.get(pis);
                        if (grandParentItemset == pis) {
                          break;
                        } else {
                          pis = grandParentItemset;
                        }
                      }
                      pis = origParent;
                    }
                  }
                }

                if (!allied) {
                  unalliedItemsets.put(itemset, klDiver);
                }

                if (!ITEMSETS_SEIZE_TO_EXIST_AFTER_JOINING_ALLIANCE || !allied) {
                  prevItemsets.addLast(itemset);
                } else {
                  if (LOG.isTraceEnabled())
                    LOG.trace(itemset.toString() + iDocIds.size()
                        + " doesn't exist outside of its alliance with head " + allianceTransitive.get(itemset));
                }
              }
            }

            done = true;

            try {
              while (true)
                Thread.sleep(Long.MAX_VALUE); // never die
            } catch (InterruptedException e) {
              LOG.debug("Bye bye");
            }
          }
        }
        StronglyClosedItemsetsFilter stronglyClosedItemsetsFilter = new StronglyClosedItemsetsFilter();
        Thread stronglyClosedThread = new Thread(stronglyClosedItemsetsFilter);
        stronglyClosedThread.start();

        while (!stronglyClosedItemsetsFilter.done && stronglyClosedThread.isAlive()) {
          Thread.sleep(1000);
        }

        long filteringCPUTime = -1;
        if (stronglyClosedThread.isAlive()) {
          ThreadMXBean tmxb = ManagementFactory.getThreadMXBean();
          filteringCPUTime = tmxb.getThreadCpuTime(stronglyClosedThread.getId());
          LOG.info("Filtering took {} nanoseconds = {} seconds", filteringCPUTime, filteringCPUTime / 1e9);

          stronglyClosedThread.interrupt();
        } else {
          LOG.error("The thread for calculating CPU time died :(.");
        }

        int alliedLowConf = 0;
        int overConfident = 0;
        Closer novelClose = Closer.create();
        try {
          Formatter novelFormat = novelClose.register(new Formatter(novelFile, Charsets.UTF_8.name()));

          for (java.util.Map.Entry<Set<String>, Double> positiveKLDEntry : positiveKLDivergence.entrySet()) {
            Set<String> itemset = positiveKLDEntry.getKey();
            novelFormat.format(itemset + "\t%.15f\t%s\n", positiveKLDEntry.getValue(), // klDiver,
                (fgIdsMap.containsKey(itemset) ? fgIdsMap.get(itemset) : ""));
          }

          Formatter selectionFormat = novelClose.register(new Formatter(selFile, Charsets.UTF_8.name()));

          final File trendingFile = new File(fgF.getParentFile(), fgF.getName().replaceFirst("fp_",
              "trending_" + options + "_"));

          final File notTrendingFile = new File(fgF.getParentFile(), fgF.getName().replaceFirst("fp_",
              "notTrending_" + options + "_"));

          Formatter trendingFmt = null;

          Formatter notTrendingFmt = null;
          if (trending) {
            trendingFmt = novelClose.register(new Formatter(trendingFile, Charsets.UTF_8.name()));
            notTrendingFmt = novelClose.register(new Formatter(notTrendingFile, Charsets.UTF_8.name()));
          }

          for (java.util.Map.Entry<Set<String>, java.util.Map.Entry<Multiset<String>, Set<Long>>> e : growingAlliances
              .entrySet()) {
            Multiset<String> mergedItemset = e.getValue().getKey();
            Set<Long> unionDocId = e.getValue().getValue();

            if (trending) {

              SummaryStatistics hs = historyStats.get(mergedItemset.elementSet());
              double historyAvg2StdDev = 0;
              if (hs != null) {
                historyAvg2StdDev = hs.getMean() + 2 * hs.getStandardDeviation();
              } else {
                hs = new SummaryStatistics();
              }

              double fgProb = unionDocId.size() * 1.0 / fgNumTweets;
              if (fgProb > historyAvg2StdDev) {
                trendingFmt.format(printMultiset(mergedItemset) + "\t%.15f\t%.15f\n", fgProb, historyAvg2StdDev); // ,unionDocId);
              } else {
                notTrendingFmt.format(printMultiset(mergedItemset) + "\t%.15f\t%.15f\n", fgProb, historyAvg2StdDev); // unionDocId);
              }

              hs.addValue(fgProb);

              historyStats.put(mergedItemset.elementSet(), hs);
              // TODO adjust for half epoch steps
              historyTtl.put(mergedItemset.elementSet(), new MutableInt(historyLenInEpochSteps + 1));
            }

            Set<String> parentItemset = itemsetParentMap.get(e.getKey());
            double confidence = unionDocId.size() * 1.0 / fgIdsMap.get(parentItemset).size();
            if (confidence < confThreshold) {
              ++alliedLowConf;
              if (!RESEARCH_MODE) {
                continue;
              }
            } else {
              // The parent will be present in the final output within this itemset, so even if it
              // were pending alliance to get printed it can be removed now
              if (cntUnMaximal) {
                // The parent will be present in the final output within this itemset, so even if it
                // were pending alliance to get printed it can be removed now

                // TODO: should really remove all of parents, ideally:
// for (Set<String> pis : ancestorItemsets) {
// unalliedItemsets.remove(HashMultiset.create(pis));
// }
                // Since this is just to produce some number
                Set<String> origParent = parentItemset;
                while (parentItemset != null) {
// unalliedItemsets.remove(parentItemset);
                  if (unalliedItemsets.containsKey(parentItemset)) {
                    unMaximalIS.increment();
                  }
                  Set<String> grandParentItemset = itemsetParentMap.get(parentItemset);
                  if (grandParentItemset == parentItemset) {
                    break;
                  } else {
                    parentItemset = grandParentItemset;
                  }
                }
                parentItemset = origParent;
              }

              if (confidence > 1) {
                ++overConfident;
                if (LOG.isTraceEnabled())
                  LOG.trace(mergedItemset.toString() + unionDocId.size()
                      + " is stronger alliance ({}) than its head's ({}) parent: " +
                      parentItemset.toString() + fgIdsMap.get(parentItemset).size(),
                      e.getKey().toString() + fgIdsMap.get(e.getKey()).size());
              }
            }

            Collection<Set<String>> allianceMembers = allianceTransitiveInverse.get(e.getKey());
            double mutualInfo = 0;
            double freqSubset = fgIdsMap.get(e.getKey()).size();
            for (Set<String> member : allianceMembers) {
              double freqSuperset = fgIdsMap.get(member).size();
              double conditionalProb;

// if(confidentItemsets.containsKey(member)){
// conditionalProb = confidentItemsets.get(member);
// } else {
// LOG.info("An itemset is member in an alliance without being confident.. can this be?)
              conditionalProb = freqSuperset / freqSubset;

              mutualInfo += conditionalProb * DoubleMath.log2(conditionalProb / (freqSuperset / fgNumTweets));
            }
            mutualInfo *= freqSubset / fgNumTweets;

            DescriptiveStatistics kldStats = alliedKLD.get(e.getKey());

            double kldSubset = kldCache.get(e.getKey());
            double subsetSelfInfo = -Math.log(freqSubset / fgNumTweets);
            double subsetSelfInfo2 = subsetSelfInfo * subsetSelfInfo;
            double kldGain = 0; // kldSubset;
            double kldGain2 = 0; // kldSubset * kldSubset;
            for (double membKld : kldStats.getValues()) {
              kldGain += membKld - kldSubset;
              kldGain2 += Math.pow((membKld - kldSubset), 2);
            }

            double yMeasure = 0;
// kldStats.getSum() * kldStats.getN();
            double kldSum = kldStats.getSum();
            double logM = Math.log(kldStats.getN());
            for (double val : kldStats.getValues()) {
              yMeasure += kldSum - val + logM;
            }
            double yMeasureNoDiv = yMeasure;
            yMeasure /= kldStats.getN();
// double klDiver = Double.MIN_VALUE;
// Integer bgCount = bgCountMap.get(mergedItemset.elementSet());
// if (bgCount == null) {
// if (!fallBackToItemsKLD) {
// bgCount = 1;
// } else {
// klDiver = calcComponentsKLDiver(mergedItemset.elementSet(), unionDocId.size(),
// bgCountMap, fgCountMap, bgFgLogP, kldCache);
// }
// }
// if (bgCount != null) {
// klDiver = unionDocId.size() * 1.0 * (Math.log(unionDocId.size() * 1.0 / bgCount) + bgFgLogP);
//
// }
// // klDiver *= (Math.log(unionDocId.size() * 1.0 / bgCount) + bgFgLogP);

            selectionFormat.out().append(printMultiset(mergedItemset));
            selectionFormat
                .format(
                    "\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%.15f\t%d\t%.15f\t%.15f\t%d\t%.15f\t%.15f\t",

                    kldStats.getVariance(), // 2
                    (kldGain2 + subsetSelfInfo2) / allianceMembers.size(), // 3
                    (kldStats.getSum() - mutualInfo) / allianceMembers.size(), // 4
                    (kldGain2 + subsetSelfInfo) / allianceMembers.size(), // 5
                    kldGain2 / kldStats.getSumsq(), // 6
                    kldGain2 / allianceMembers.size(), // 7
                    mutualInfo, // 8

// mutualInfo/allianceMembers.size(), //11
// kldGain, //12
// kldGain / allianceMembers.size(), //13
// kldGain2, //14
// kldGain2 / allianceMembers.size(), //15

                    yMeasure, // 9
                    kldStats.getSum(), // 10
                    kldStats.getSumsq(), // 11
                    kldStats.getMean() + 1.96 * kldStats.getStandardDeviation() / kldStats.getN(),// 12
                    kldStats.getKurtosis(), // 13
                    kldStats.getSkewness(), // 14
                    kldStats.getMean(), // 15

                    kldStats.getMin(), // 16
                    kldStats.getPercentile(0.5), // 17
                    kldStats.getMax(), // 18
                    (int) kldStats.getN(), // 19

                    confidence, // 20
                    calcNormalizedSumTfIdf(mergedItemset, idfFromBG ? bgCountMap : fgCountMap,
                        idfFromBG ? bgNumTweets : fgNumTweets, bgIDFMap), // 21
                    unionDocId.size(), // 22
                    calcEntropy(mergedItemset.elementSet(), entropyFromBg ? bgCountMap : fgCountMap,
                        entropyFromBg ? bgNumTweets : fgNumTweets), // 23
                    calcCrossEntropy(mergedItemset.elementSet(), bgCountMap, fgCountMap, bgNumTweets, fgNumTweets)); // 24

            Set<Long> headDocIds = Sets.newCopyOnWriteArraySet(fgIdsMap.get(e.getKey()));
            selectionFormat.out().append(headDocIds.toString().substring(1))
                .append(Sets.difference(unionDocId, headDocIds).toString().substring(1));

            selectionFormat.out().append("\n");
          }

          if (trending) {
            List<Set<String>> toDie = Lists.newLinkedList();
            for (java.util.Map.Entry<Set<String>, MutableInt> e : historyTtl.entrySet()) {
              if (e.getValue().intValue() == 1) {
                toDie.add(e.getKey());
              } else {
                e.getValue().decrement();
              }
            }
            for (Set<String> d : toDie) {
              historyTtl.remove(d);
              historyStats.remove(d);
            }
          }

          final File hcFile = new File(fgF.getParentFile(), fgF.getName().replaceFirst("fp_",
              "highConf_" + options + "_"));

          Formatter hcFormat = novelClose.register(new Formatter(hcFile, Charsets.UTF_8.name()));

          for (java.util.Map.Entry<Set<String>, Double> hcEntry : confidentItemsets.entrySet()) {
            Set<String> itemset = hcEntry.getKey();
            Double conf = hcEntry.getValue();
            hcFormat.format(itemset + "\t%.15f\t%.15f\t%s\n", positiveKLDivergence.get(itemset), conf,
                (fgIdsMap.containsKey(itemset) ? fgIdsMap.get(itemset) : ""));
          }
          // // Print the parents that were pending alliance with children to make sure they have conf
// // those ones didn't prove to have any confident children, but we have to give them a chance
// for (java.util.Map.Entry<Set<String>, Double> e : unalliedItemsets.entrySet()) {
// Set<String> itemset = e.getKey();
// Multiset<String> mergedItemset = HashMultiset.create(itemset);
// LinkedList<Long> docids = fgIdsMap.get(itemset);
//
// double confidence;
// double klDiver = e.getValue();
// int supp = docids.size();
// double entropy;
// if (confidentItemsets.containsKey(itemset)) {
// confidence = confidentItemsets.get(itemset);
// } else {
// confidence = -1;
// }
//
// selectionFormat.out().append(printMultiset(mergedItemset));
// selectionFormat.format("\t%.15f\t%.15f\t%.15f\t%d\t%.15f\t%.15f\t",
// confidence, // 2
// klDiver, // 3
// calcNormalizedSumTfIdf(mergedItemset, idfFromBG ? bgCountMap : fgCountMap,
// idfFromBG ? bgNumTweets : fgNumTweets, bgIDFMap), // 4
// supp, // 5
// calcEntropy(itemset, entropyFromBg ? bgCountMap : fgCountMap,
// entropyFromBg ? bgNumTweets : fgNumTweets), // 6
// calcCrossEntropy(mergedItemset.elementSet(), bgCountMap, fgCountMap, bgNumTweets, fgNumTweets)); // 7
// selectionFormat.out().append(docids.toString().substring(1));
// selectionFormat.out().append("\n");
// }

        } finally {
          novelClose.close();
        }
        LOG.info("Net itemsets after subtracting ignored: {} out of {} itemsets from file: " + fgF.getName(),
            fgCountMap.size() - (stronglyClosedItemsetsFilter.numLen1Itemsets + fileReadingPerfMeasures[0]),
            fgCountMap.size());

        LOG.info("CPUMillisFilter: {}", filteringCPUTime / 1e6);
        LOG.info("TotalItemsets: {}", fgCountMap.size() + fileReadingPerfMeasures[0]);
        LOG.info("Avg-2CharsItemsets: {}", fileReadingPerfMeasures[0]);
        LOG.info("RepItemsetsLessOrEqNew: {}", fileReadingPerfMeasures[1]);
        LOG.info("RepItemsetsMoreNew: {}", fileReadingPerfMeasures[2]);
        LOG.info("AvgDiffInRepeatedCnt: {}", fileReadingPerfMeasures[3] * 1.0
            / (fileReadingPerfMeasures[1] + fileReadingPerfMeasures[2]));
        LOG.info("MaxDiffInRepeatedCnt: {}", fileReadingPerfMeasures[4]);
        LOG.info("EnoughCharsItemsets: {}", fgCountMap.size());
        LOG.info("Len1Itemsets: {}", stronglyClosedItemsetsFilter.numLen1Itemsets);
        LOG.info("Len2+Itemsets: {}", fgCountMap.size() - stronglyClosedItemsetsFilter.numLen1Itemsets);
        LOG.info("UnalliedIS: {}", unalliedItemsets.size());
        LOG.info("UnalliedUnMaximal: {}", unMaximalIS.intValue());
        LOG.info("AlliedLowConf: {}", alliedLowConf);
        LOG.info("OverConfident: {}", overConfident);
        LOG.info("absMaxDiffEnforced: {}", stronglyClosedItemsetsFilter.absMaxDiffEnforced);
        LOG.info("KLD+Itemsets: {}", positiveKLDivergence.size());
        LOG.info("HighConfidenceIS: {}", confidentItemsets.size());
        LOG.info("StrongClosedIS: {}", growingAlliances.keySet().size());

        if (perfMon) {
          perfMonKV.storeKeyValue("Timestamp", System.currentTimeMillis());
          perfMonKV.storeKeyValue("CPUMillisFilter", filteringCPUTime / 1e6);
          perfMonKV.storeKeyValue("TotalItemsets", fgCountMap.size() + fileReadingPerfMeasures[0]);
          perfMonKV.storeKeyValue("Avg-2CharsItemsets", fileReadingPerfMeasures[0]);
          perfMonKV.storeKeyValue("RepItemsetsLessOrEqNew", fileReadingPerfMeasures[1]);
          perfMonKV.storeKeyValue("RepItemsetsMoreNew", fileReadingPerfMeasures[2]);
          perfMonKV.storeKeyValue("AvgDiffInRepeatedCnt", fileReadingPerfMeasures[3] * 1.0
              / (fileReadingPerfMeasures[1] + fileReadingPerfMeasures[2]));
          perfMonKV.storeKeyValue("MaxDiffInRepeatedCnt", fileReadingPerfMeasures[4]);
          perfMonKV.storeKeyValue("EnoughCharsItemsets", fgCountMap.size());
          perfMonKV.storeKeyValue("Len1Itemsets", stronglyClosedItemsetsFilter.numLen1Itemsets);
          perfMonKV.storeKeyValue("Len2+Itemsets", fgCountMap.size() - stronglyClosedItemsetsFilter.numLen1Itemsets);
          perfMonKV.storeKeyValue("UnalliedIS", unalliedItemsets.size());
          perfMonKV.storeKeyValue("UnalliedUnMaximal", unMaximalIS.intValue());
          perfMonKV.storeKeyValue("AlliedLowConf", alliedLowConf);
          perfMonKV.storeKeyValue("OverConfident", overConfident);
          perfMonKV.storeKeyValue("absMaxDiffEnforced", stronglyClosedItemsetsFilter.absMaxDiffEnforced);
          perfMonKV.storeKeyValue("KLD+Itemsets", positiveKLDivergence.size());
          perfMonKV.storeKeyValue("HighConfidenceIS", confidentItemsets.size());
          perfMonKV.storeKeyValue("StrongClosedIS", growingAlliances.keySet().size());
        }
        positiveKLDivergence.clear();
        confidentItemsets.clear();
        System.gc();

        if (perfMon)
          perfMonKV.storeKeyValue("MemoryMBUsed", Runtime.getRuntime().totalMemory() / (1 << 20));

        LOG.info("MemoryMBUsed: {}", Runtime.getRuntime().totalMemory() / (1 << 20));

      }
    } catch (InterruptedException e) {
      // ok
    } finally {
      perfMonCloser.close();
    }
  }
  private static double calcComponentsKLDiver(Set<String> itemset, double itemsetCnt,
      Map<Set<String>, Integer> bgCountMap,
      Map<Set<String>, Integer> fgCountMap, double bgFgLogP, Map<Set<String>, Double> kldCache) {
    double retVal = 0;
    for (String item : itemset) {
      Set<String> itemAsSet = Collections.singleton(item);
      Double itemKLD = kldCache.get(itemAsSet);
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
        kldCache.put(itemAsSet, itemKLD);
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
