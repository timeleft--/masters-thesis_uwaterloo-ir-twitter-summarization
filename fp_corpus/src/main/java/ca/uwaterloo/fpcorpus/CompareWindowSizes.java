package ca.uwaterloo.fpcorpus;

import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.nio.channels.Channels;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.concurrent.CompletionService;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorCompletionService;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.mutable.MutableBoolean;
import org.apache.commons.lang.mutable.MutableFloat;
import org.apache.commons.lang.mutable.MutableLong;
import org.apache.commons.math.stat.descriptive.SummaryStatistics;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.PerFieldAnalyzerWrapper;
import org.apache.lucene.analysis.TwitterEnglishAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.MultiReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.index.TermFreqVector;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.queryParser.QueryParser.Operator;
import org.apache.lucene.search.Collector;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.Scorer;
import org.apache.lucene.store.MMapDirectory;
import org.apache.lucene.store.NIOFSDirectory;
import org.apache.lucene.util.Version;
import org.apache.mahout.common.Pair;
import org.apache.mahout.math.map.OpenIntFloatHashMap;
import org.apache.mahout.math.map.OpenIntObjectHashMap;
import org.apache.mahout.math.map.OpenObjectIntHashMap;
import org.apache.mahout.math.set.OpenIntHashSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import ca.uwaterloo.twitter.ItemSetIndexBuilder;
import ca.uwaterloo.twitter.ItemSetIndexBuilder.AssocField;
import ca.uwaterloo.twitter.TwitterAnalyzer;
import ca.uwaterloo.twitter.TwitterIndexBuilder.TweetField;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

public class CompareWindowSizes implements Callable<Pair<String, List<SummaryStatistics>>> {
  private static final Logger LOG = LoggerFactory
      .getLogger(CompareWindowSizes.class);
  
  private static final double LOG2 = Math.log(2);
  
  private static final long[] windowSizesArr = {
      300000, // 5min
      900000, // 15min
      1800000, // 30min
      3600000, // 1hr
      7200000, // 2hr
      14400000, // 4hr
      28800000, // 8hr
      // 57600000, // 16hr
      86400000 // 24hr
  };
  
  private static final Analyzer PLAIN_ANALYZER = new TwitterAnalyzer(); // Version.LUCENE_36);
  private static final Analyzer ENGLISH_ANALYZER = new TwitterEnglishAnalyzer();
  private static final Analyzer ANALYZER = new PerFieldAnalyzerWrapper(
      PLAIN_ANALYZER, ImmutableMap.<String, Analyzer> of(
          AssocField.STEMMED_EN.name, ENGLISH_ANALYZER));
  
  protected static IndexReader twtIxReader;
  protected static IndexSearcher twtIxSearcher;
  public static final String TWITTER_INDEX_ROOT =
       "/u2/yaboulnaga/datasets/twitter-trec2011/indexes/twt_stemmed-stored_8hr-increments/" +
       "1295740800000/1297209600000/index";
      // The parser used for this orig is not mine, so some issues arise because of # and _
//      "/u2/yaboulnaga/datasets/twitter-trec2011/indexes/twt_index_orig";
  
  private static final String COLLECTION_STRING_CLEANER = "[\\,\\[\\]]";
  
  private static final boolean DONOT_REPLACE = true;
  private static final boolean DUMP_INTERSECTION_DEFAULT = false;
  
  private final QueryParser fisQparser;
  protected final List<File> shortWindowIndexes;
  protected final File longWindowIndex;
  
  protected final SummaryStatistics diffSuppSUL = new SummaryStatistics();
  protected final SummaryStatistics extraItemsInLong = new SummaryStatistics();
  protected final SummaryStatistics extraItemsInShorts = new SummaryStatistics();
  protected final SummaryStatistics exactOverlap = new SummaryStatistics();
  protected final SummaryStatistics totalInShortUnion = new SummaryStatistics();
  protected final SummaryStatistics totalInLongWindow = new SummaryStatistics();
  protected final SummaryStatistics longerInShortUnion = new SummaryStatistics();
  protected final SummaryStatistics longerInLongWindow = new SummaryStatistics();
  
  // protected final SummaryStatistics MetricTotalInShortUnion = new SummaryStatistics();
  // protected final SummaryStatistics MetricTotalInLongWindow = new SummaryStatistics();
  // protected final SummaryStatistics MetricExactOverlap = new SummaryStatistics();
  // protected final SummaryStatistics MetricDiffLongerInShortUnion = new SummaryStatistics();
  // protected final SummaryStatistics MetricDiffLongerInLongWindow = new SummaryStatistics();
  
  protected final String id;
  protected boolean dumpIntersction = DUMP_INTERSECTION_DEFAULT;
  protected Writer dumpWr;
  protected final File outPath;
  
  public CompareWindowSizes(List<File> shortWindowIndexes, File longWindowIndex,
      String id, File outPath) throws CorruptIndexException, IOException {
    this.shortWindowIndexes = Lists.newArrayList(shortWindowIndexes);
    this.longWindowIndex = longWindowIndex;
    this.id = id;
    this.outPath = outPath;
    
    fisQparser = new QueryParser(Version.LUCENE_36,
        ItemSetIndexBuilder.AssocField.ITEMSET.name, ANALYZER);
    fisQparser.setDefaultOperator(Operator.AND);
  }
  
  public Pair<String, List<SummaryStatistics>> call() throws IOException, ParseException {
    
    final MultiReader shortWindowsUnion;
    final IndexReader longWindow;
    
    IndexReader[] shortWindowReaders = new IndexReader[shortWindowIndexes.size()];
    int i = 0;
    for (File shortWindowIx : shortWindowIndexes) {
      shortWindowReaders[i++] = IndexReader.open(NIOFSDirectory.open(shortWindowIx));
    }
    shortWindowsUnion = new MultiReader(shortWindowReaders);
    longWindow = IndexReader.open(NIOFSDirectory.open(longWindowIndex));
    
    OpenIntObjectHashMap<MutableLong> docIdInLongPatternInBoth = new OpenIntObjectHashMap<MutableLong>();
    IndexSearcher longWindowSearcher = new IndexSearcher(longWindow);
    
    if (dumpIntersction) {
      this.dumpWr = Channels.newWriter(FileUtils.openOutputStream(new File(outPath, id + ".csv"))
          .getChannel(), "UTF-8");
      
      this.dumpWr
          .append("shortsFIs\tshortsPMI\tshortsNMI\tshortsYule\tshortsGainRation\tshortsBeleheta\t"
              +
              "longFIs\tlongPMI\tlongNMI\tlongYule\tlongGainRation\tlongBeleheta\n");
    }
    
    for (int ds = 0; ds < shortWindowsUnion.maxDoc(); ++ds) {
      measureOverlap(shortWindowsUnion,
          ds,
          longWindow,
          longWindowSearcher,
          
          // itemsetInBoth,
          
          docIdInLongPatternInBoth,
          true,
          
          extraItemsInLong,
          true);
    }
    
    IndexSearcher shortWindowsUnionSearcher = new IndexSearcher(shortWindowsUnion);
    OpenIntHashSet docIdInShortPatternInBoth = new OpenIntHashSet();
    
    for (int dl = 0; dl < longWindow.maxDoc(); ++dl) {
      if (docIdInLongPatternInBoth.containsKey(dl)) {
        diffSuppSUL.addValue(docIdInLongPatternInBoth.get(dl).longValue()
            - Integer.parseInt(longWindow.document(dl).get(AssocField.SUPPORT.name)));
        continue;
      }
      
      OpenIntObjectHashMap<MutableLong> tempDocIdInShortPatternInBoth = new OpenIntObjectHashMap<MutableLong>();
      measureOverlap(longWindow,
          dl,
          shortWindowsUnion,
          shortWindowsUnionSearcher,
          
          // itemsetInBoth,
          tempDocIdInShortPatternInBoth,
          false,
          
          extraItemsInShorts,
          false);
      
      for (int docId : tempDocIdInShortPatternInBoth.keys().elements()) {
        
        docIdInShortPatternInBoth.add(docId);
        
        final Document docDlw = longWindow.document(dl);
        final Document docDsw = shortWindowsUnion.document(docId);
        diffSuppSUL.addValue(Integer.parseInt(docDsw.get(AssocField.SUPPORT.name))
            - Integer.parseInt(docDlw.get(AssocField.SUPPORT.name)));
      }
    }
    
    int exOl = docIdInLongPatternInBoth.size() + docIdInShortPatternInBoth.size();
    exactOverlap.addValue(exOl);
    // exlusiveInShortUnion.addValue(shortWindowsUnion.numDocs() - extraItemsInLong.getN()
    // - extraItemsInShorts.getN() - exOl);
    // exlusiveInLongWindow.addValue(longWindow.numDocs() - extraItemsInLong.getN()
    // - extraItemsInShorts.getN() - exOl);
    totalInLongWindow.addValue(longWindow.numDocs());
    totalInShortUnion.addValue(shortWindowsUnion.numDocs());
    longerInLongWindow.addValue(extraItemsInLong.getN());
    longerInShortUnion.addValue(extraItemsInShorts.getN());
    
    shortWindowsUnion.close();
    longWindow.close();
    if (this.dumpWr != null) {
      this.dumpWr.flush();
      this.dumpWr.close();
    }
    
    return new Pair<String, List<SummaryStatistics>>(id,
        Lists.newArrayList(
            totalInLongWindow,
            totalInShortUnion,
            exactOverlap,
            longerInLongWindow,
            longerInShortUnion,
            // exlusiveInLongWindow,
            // exlusiveInShortUnion,
            diffSuppSUL,
            extraItemsInLong,
            extraItemsInShorts
            // MetricTotalInLongWindow,
            // MetricTotalInShortUnion,
            // MetricExactOverlap,
            // MetricDiffLongerInLongWindow,
            // MetricDiffLongerInShortUnion
            ));
  }
  
  private void measureOverlap(IndexReader shortDocsReader, int ds,
      final IndexReader longDocsReader, IndexSearcher longDocsSearcher,
      
      final OpenIntObjectHashMap<MutableLong> docIdInLongPatternInBoth,
      final boolean sumSupport,
      
      // final OpenObjectIntHashMap<Set<String>> itemsetInBothUnionSupport,
      
      final SummaryStatistics extraItems, final boolean shortUnionIsShortDoc)
      throws IOException, ParseException {
    final TermFreqVector tvDs = shortDocsReader
        .getTermFreqVector(ds, AssocField.ITEMSET.name);
    if (tvDs == null) {
      LOG.warn("Null term vector for document {} out of {}", tvDs, shortDocsReader.maxDoc());
      return;
    }
    
    final Set<String> tSetDs = Sets.newCopyOnWriteArraySet(Arrays
        .asList(tvDs.getTerms()));
    final Document docDS = shortDocsReader.document(ds);
    
    // if(itemsetInBothUnionSupport.containsKey(tSetDs)){
    // itemsetInBothUnionSupport.put(tSetDs, itemsetInBothUnionSupport.get(tSetDs)
    // + Integer.parseInt(docDS.get(AssocField.SUPPORT.name)));
    // return;
    // }
    
    // final int dsSupp = Integer.parseInt(docDS.get(AssocField.SUPPORT.name));
    // final double dsMetric = patternMetric(tSetDs, dsSupp);
    // if (shortUnionIsShortDoc) {
    // MetricTotalInShortUnion.addValue(dsMetric);
    // } else {
    // MetricTotalInLongWindow.addValue(dsMetric);
    // }
    
    final StringBuffer dsMetricStrBuffer = new StringBuffer();
    final double[] dsMetrics = new double[5];
    
    // final MutableBoolean exclusive = new MutableBoolean(true);
    // long MetricExactOverlapBefore = MetricExactOverlap.getN();
    // long MetricDiffLongerInLongWindowBefore = MetricDiffLongerInLongWindow.getN();
    // long MetricDiffLongerInShortUnionBefore = MetricDiffLongerInShortUnion.getN();
    
    Query query = fisQparser.parse(tSetDs.toString().replaceAll(
        COLLECTION_STRING_CLEANER, ""));
    Collector longDocsCollector = new Collector() {
      // IndexReader reader;
      int docBase;
      
      @Override
      public void setScorer(Scorer scorer) throws IOException {
        
      }
      
      @Override
      public void collect(int dl) throws IOException {
        dl += docBase;
        // exclusive.setValue(false);
        TermFreqVector tvDl = longDocsReader.getTermFreqVector(
            dl, AssocField.ITEMSET.name);
        
        Document docDL = longDocsReader.document(dl);
        // int dlSupp = Integer.parseInt(docDL.get(AssocField.SUPPORT.name));
        
        Set<String> tSetDl = Sets.newCopyOnWriteArraySet(Arrays
            .asList(tvDl.getTerms()));
        if (tSetDs.equals(tSetDl)) {
          
          MutableLong supportSum = null;
          if (sumSupport) {
            if (docIdInLongPatternInBoth.containsKey(dl)) {
              supportSum = docIdInLongPatternInBoth.get(dl);
            } else {
              supportSum = new MutableLong(0);
            }
            supportSum.add(Integer.parseInt(docDS.get(AssocField.SUPPORT.name)));
          }
          
          docIdInLongPatternInBoth.put(dl, supportSum);
          // itemsetInBothUnionSupport.put(tSetDs, itemsetInBothUnionSupport.get(tSetDs)
          // + Integer.parseInt(docDS.get(AssocField.SUPPORT.name)));
          
          // MetricExactOverlap.addValue(dsMetric);
        } else {
          // else because dumping the exact overlap is not useful
          if (dumpIntersction) {
            if (dsMetricStrBuffer.length() == 0) {
              int m = 0;
              for (double metric : patternMetric(tSetDs)) {
                dsMetrics[m++] = metric;
              }
              dsMetricStrBuffer.append(metricToString(dsMetrics));
            }
            double[] dlMetricDiff = patternMetric(tSetDl);
            for (int m = 0; m < dlMetricDiff.length; ++m) {
              dlMetricDiff[m] -= dsMetrics[m];
            }
            String dlMetricStr = metricToString(dlMetricDiff);
            if (shortUnionIsShortDoc) {
              dumpWr.append(tSetDs + "\t" + dsMetricStrBuffer.toString() + "\t"
                  + Sets.difference(tSetDl, tSetDs) + "\t"
                  + dlMetricStr + "\n");
            } else {
              dumpWr.append(Sets.difference(tSetDl, tSetDs) + "\t" + dlMetricStr + "\t"
                  + tSetDs + "\t" + dsMetricStrBuffer.toString() + "\n");
            }
          }
        }
        
        int diffLen = tvDl.size() - tSetDs.size();
        extraItems.addValue(diffLen);
        
        // double dlMetric = patternMetric(tSetDl, dlSupp);
        // if (shortUnionIsShortDoc) {
        // MetricTotalInLongWindow.addValue(dlMetric);
        // MetricDiffLongerInLongWindow.addValue(dlMetric - dsMetric);
        // } else {
        // // already added from previous run: MetricTotalInShortUnion
        // MetricDiffLongerInShortUnion.addValue(dlMetric - dsMetric);
        // }
        //
        // if (dumpIntersction) {
        // if (shortUnionIsShortDoc) {
        // dumpWr.append(tSetDs + "\t" + dsSupp + "\t" + dsMetric + "\t"
        // + Sets.difference(tSetDl, tSetDs) + "\t"
        // + dlSupp + "\t" + dlMetric + "\n");
        // } else {
        // dumpWr.append(Sets.difference(tSetDl, tSetDs) + "\t" + dlSupp + "\t" + dlMetric + "\t"
        // + tSetDs + "\t"
        // + dsSupp + "\t" + dsMetric + "\n");
        // }
        // }
        
      }
      
      @Override
      public void setNextReader(IndexReader reader, int docBase)
          throws IOException {
        // this.reader = reader;
        this.docBase = docBase;
        // exclusive.setValue(false);
      }
      
      @Override
      public boolean acceptsDocsOutOfOrder() {
        return true;
      }
    };
    longDocsSearcher.search(query, longDocsCollector);
    
    // boolean exclusive =
    // (MetricExactOverlapBefore == MetricExactOverlap.getN()) &&
    // (MetricDiffLongerInLongWindowBefore == MetricDiffLongerInLongWindow.getN()) &&
    // (MetricDiffLongerInShortUnionBefore == MetricDiffLongerInShortUnion.getN());
    boolean exclusive = dsMetricStrBuffer.length() == 0;
    if (dumpIntersction && exclusive) {
      dsMetricStrBuffer.append(metricToString(patternMetric(tSetDs)));
//      String dlMetricsZeros = metricToString(new double[5]);
      String dlMetricsZeros ="\t\t\t\t";
      if (shortUnionIsShortDoc) {
        dumpWr.append(tSetDs + "\t" + dsMetricStrBuffer.toString() + "\tX\t"
            + dlMetricsZeros + "\n");
      } else {
        dumpWr.append("X\t" + dlMetricsZeros + "\t" + tSetDs + "\t"
            + dsMetricStrBuffer.toString() + "\n");
      }
    }
  }
  
  private String metricToString(double[] dsMetrics) throws IOException {
    String result = Arrays.toString(dsMetrics).replace(',', '\t').replaceAll(" ", "");
    return result.substring(1, result.length() - 1);
  }
  
  // private double patternMetric(Set<String> tSet, float support) throws IOException {
  // // float[] termSupp = new float[tSet.size()];
  // float maxTermSupp = Float.MIN_VALUE;
  // float totalTermSupp = 0;
  // // int i = -1;
  // for (String item : tSet) {
  // // ++i;
  // char ch0 = item.charAt(0);
  // if(ch0 == '@' || ch0 == '#'){
  // continue;
  // }
  // Term termi = new Term(TweetField.TEXT.name, item);
  // float termSupp = twtIxReader.docFreq(termi);
  // totalTermSupp += termSupp;
  // if (termSupp > maxTermSupp) {
  // maxTermSupp = termSupp;
  // }
  // }
  // return support / maxTermSupp; //totalTermSupp;
  // }
  private double[] patternMetric(Set<String> tSet) throws IOException {
    List<String> itemsetList = Lists.newLinkedList();
    for (String item : tSet) {
      char ch0 = item.charAt(0);
      if (ch0 == '@' || ch0 == '#') {
        continue;
      }
      itemsetList.add(item);
    }
    MutableFloat maxTermSupp = new MutableFloat();
    MutableFloat totalTermSupp = new MutableFloat();
    OpenIntFloatHashMap[] jointFreq = EvaluateWindowSizes
        .estimatePairWiseJointFreqsFromTwitter(itemsetList.toArray(new String[0]),
            twtIxReader, twtIxSearcher, TweetField.TEXT.name,
            maxTermSupp, totalTermSupp);
    
    double[] result = new double[5];
    
    float numDocs = twtIxReader.numDocs();
    
    result[0] = EvaluateWindowSizes.averagePmi(jointFreq, numDocs);
    result[1] = EvaluateWindowSizes.calcNMI(jointFreq, numDocs, totalTermSupp.floatValue());
    result[2] = EvaluateWindowSizes.avgPairYuleQ(jointFreq, numDocs);
    result[3] = EvaluateWindowSizes.avgPairGainRatio(jointFreq, numDocs);
    result[4] = EvaluateWindowSizes.avgBleheta(jointFreq, numDocs);
    
    return result;
  }
  
  public static void main(String[] args) throws CorruptIndexException, IOException,
      InterruptedException, ExecutionException {
    File inDir = new File(args[0]);
    File outPath = new File(args[1]);
    int dayStart = Integer.parseInt(args[2]);
    int dayEnd = Integer.parseInt(args[3]);
    ExecutorService exec = Executors.newFixedThreadPool(Integer.parseInt(args[4]));
    CompletionService<Pair<String, List<SummaryStatistics>>> completion =
        new ExecutorCompletionService<Pair<String, List<SummaryStatistics>>>(exec);
    int numJobs = 0;
    
    if (DONOT_REPLACE && outPath.exists()) {
      throw new IllegalArgumentException("Output file already exists: " + outPath);
    }
    
    // TODO: should I use more timely indexes?????????? Up to the end time?? or between start and
    // end??
    File twtIxPath = new File(TWITTER_INDEX_ROOT);
    // TODO: handle the addition of stats
    twtIxReader = IndexReader.open(MMapDirectory.open(twtIxPath));
    twtIxSearcher = new IndexSearcher(twtIxReader);
    Writer wr = Channels.newWriter(FileUtils.openOutputStream(new File(outPath, "stats.csv"))
        .getChannel(), "UTF-8");
    
    wr.append("day\t" +
        "startTime\t" +
        "shortLengths\t" +
        "longLength\t" +
        "totalInLongWin\t" +
        "totalInShortUnion\t" +
        "exactOverlap\t" +
        "longerInLongWin\t" +
        "longerInShortUnion\t" +
        "exclusiveInLongWin\t" +
        "exlusiveInShortUnion\t" +
        "diffSuppSULMean\t" +
        "diffSuppSULVariance\t" +
        "diffSuppSULN\t" +
        "extraItemsInLongMean\t" +
        "extraItemsInLongVariance\t" +
        "extraItemsInLongN\t" +
        "extraItemsInShortMean\t" +
        "extraItemsInShortVariance\t" +
        "extraItemsInShortN\t" +
        // "entTotLongWinMean\t" +
        // "entTotLongWinVar\t" +
        // "entTotLongWinN\t" +
        // "entTotShortUnionMean\t" +
        // "entTotShortUnionVar\t" +
        // "entTotShortUnionN\t" +
        // "entExactOverlapMean\t" +
        // "entExactOverlapVar\t" +
        // "entExactOverlapN\t" +
        // "entDiffLongerInLongMean\t" +
        // "entDiffLongerInLongVar\t" +
        // "entDiffLongerInLongN\t" +
        // "entDiffLongerInShortMean\t" +
        // "entDiffLongerInShortVar\t" +
        // "entDiffLongerInShortN\t" +
        "\n");
    
    Random rand = new Random(System.currentTimeMillis());
    for (int d = dayStart; d <= dayEnd; ++d) {
      File dayIn = new File(inDir, "d" + d);
      
      for (int ws = 0; ws < windowSizesArr.length - 1; ++ws) {
        File shortWinDir = new File(dayIn, "w" + windowSizesArr[ws]);
        File[] shortsAsc = shortWinDir.listFiles();
        Arrays.sort(shortsAsc);
        
        for (int wl = ws + 1; wl < windowSizesArr.length; ++wl) {
          boolean dumped = false;
          File longWinDir = new File(dayIn, "w" + windowSizesArr[wl]);
          int numShortWins = (int) Math.ceil(windowSizesArr[wl] / windowSizesArr[ws]);
          if (numShortWins > 168) {
            // FIXME the case of 24 hours of 5 minutes has a glitch.. numshort windows is 288 but
            // there are only 287 files in day 12.. must be the interval that was skipped
            continue;
          }
          int numIntervals = shortsAsc.length / numShortWins; // floor
          for (File longWin : longWinDir.listFiles()) {
            
            longWin = longWin.listFiles()[0];
            
            // for (int i = 0; i < numIntervals; ++i) {
            int i = (numIntervals == 0 ? 0 : rand.nextInt(numIntervals));
            
            int startIx = i * numShortWins;
            int endIx = (i + 1) * numShortWins;
            String startTime = shortsAsc[startIx].getName();
            
            List<File> shortWindowReaderList = Lists.newArrayListWithCapacity(numShortWins);
            for (int j = startIx; j < endIx; ++j) {
              File f = shortsAsc[j].listFiles()[0];
              shortWindowReaderList.add(new File(f, "index"));
            }
            CompareWindowSizes compareCall = new CompareWindowSizes(shortWindowReaderList,
                new File(longWin, "index"),
                d + "_" + startTime + "_" + // endDir.getName() + "_" +
                    windowSizesArr[ws] + "_" + windowSizesArr[wl], outPath);
            
            if (true || !dumped && (rand.nextBoolean() || i == numIntervals - 1)) {
              dumped = true;
              compareCall.dumpIntersction = true;
            }
            completion.submit(compareCall);
            ++numJobs;
            
            // }
          }
        }
        // for (int wl = ws + 1; wl < windowSizesArr.length; ++wl) {
        // List<File> shortWindowReaders = Lists.newLinkedList();
        // File longWindowPending = null;
        // File[] startAscending = dayIn.listFiles();
        // Arrays.sort(startAscending);
        // for (File startDir : startAscending) {
        // File[] endDescending = startDir.listFiles();
        // Arrays.sort(endDescending);
        // for (int e = endDescending.length - 1; e >= 0; --e) {
        // File endDir = endDescending[e];
        // long windowSize = Long.parseLong(endDir.getName())
        // - Long.parseLong(startDir.getName());
        // if (windowSize == windowSizesArr[ws]) {
        // shortWindowReaders.add(new File(endDir, "index"));
        // } else if (windowSize == windowSizesArr[wl]) {
        // if (longWindowPending != null) {
        // CompareWindowSizes compareCall = new CompareWindowSizes(shortWindowReaders,
        // new File(endDir, "index"),
        // d + "_" + startDir.getName() + "_" + // endDir.getName() + "_" +
        // windowSizesArr[ws] + "_" + windowSizesArr[wl], outPath);
        //
        // compareCall.dumpIntersction = (counter++ % 7 == 0);
        //
        // completion.submit(compareCall);
        // ++numJobs;
        // shortWindowReaders.clear();
        // } else {
        // if (shortWindowReaders.size() >= windowSizesArr[wl] / windowSizesArr[ws]) {
        // throw new AssertionError("The short union is becoming too powerful!!");
        // }
        // }
        // longWindowPending = endDir;
        // }
        // }
        // }
        // }
      }
    }
    
    for (int j = 0; j < numJobs; ++j) {
      Future<Pair<String, List<SummaryStatistics>>> f = completion.take();
      Pair<String, List<SummaryStatistics>> comparison = f.get();
      
      String[] ids = comparison.getFirst().split("_");
      List<SummaryStatistics> stats = comparison.getSecond();
      
      long overlap = Math.round(stats.get(2).getSum()   // exactOverlap
          + stats.get(3).getSum()  // longerInLongWindow
          + stats.get(4).getSum()); // longerInShortUnion
      
      wr.append(ids[0] + "\t" // day
          + ids[1] + "\t" // startTime
          + ids[2] + "\t" // shortLengths
          + ids[3] + "\t" // longLength
          + stats.get(0).getSum() + "\t" // totalInLongWindow
          + stats.get(1).getSum() + "\t" // totalInShortUnion
          + stats.get(2).getSum() + "\t" // exactOverlap
          + stats.get(3).getSum() + "\t" // longerInLongWindow
          + stats.get(4).getSum() + "\t" // longerInShortUnion
          + (stats.get(0).getSum() - overlap) + "\t" // exlusiveInLongWindow
          + (stats.get(1).getSum() - overlap) + "\t" // exlusiveInShortUnion
          
          + stats.get(5).getMean() + "\t" // diffSuppSULMean
          + stats.get(5).getVariance() + "\t" // diffSuppSULVariance
          + stats.get(5).getN() + "\t" // diffSuppSULN
          
          + stats.get(6).getMean() + "\t" // extraItemsInLongMean
          + stats.get(6).getVariance() + "\t" // extraItemsInLongVariance
          + stats.get(6).getN() + "\t" // extraItemsIngLongN
          
          + stats.get(7).getMean() + "\t" // extraItemsInShortsMean
          + stats.get(7).getVariance() + "\t" // extraItemsInShortsVariance
          + stats.get(7).getN() + "\t" // extraItemsIngShortsN
          
          // + stats.get(8).getMean() + "\t" + // entTotLongWinMean
          // +stats.get(8).getVariance() + "\t" + // "entTotLongWinVar
          // +stats.get(8).getN() + "\t" + // "entTotLongWinN
          //
          // +stats.get(9).getMean() + "\t" + // "entTotShortUnionMean
          // +stats.get(9).getVariance() + "\t" + // "entTotShortUnionVar
          // +stats.get(9).getN() + "\t" + // "entTotShortUnionN
          //
          // +stats.get(10).getMean() + "\t" + // "entExactOverlapMean
          // +stats.get(10).getVariance() + "\t" + // "entExactOverlapVar
          // +stats.get(10).getN() + "\t" + // "entExactOverlapN
          //
          // +stats.get(11).getMean() + "\t" + // "entDiffLongerInLongMean
          // +stats.get(11).getVariance() + "\t" + // entDiffLongerInLongVar
          // +stats.get(11).getN() + "\t" + // entDiffLongerInLongN
          //
          // +stats.get(12).getMean() + "\t" + // entDiffLongerInShortMean
          // +stats.get(12).getVariance() + "\t" + // entDiffLongerInShortVar
          // +stats.get(12).getN() + "\t" + // entDiffLongerInShortN
          + "\n");
      
      wr.flush();
    }
    
    exec.shutdown();
    while (!exec.isTerminated()) {
      Thread.sleep(5000);
    }
    
    wr.flush();
    wr.close();
  }
}
