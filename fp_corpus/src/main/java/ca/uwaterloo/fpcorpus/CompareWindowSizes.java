package ca.uwaterloo.fpcorpus;

import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.nio.channels.Channels;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.concurrent.CompletionService;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorCompletionService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.apache.commons.io.FileUtils;
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
import org.apache.lucene.store.SimpleFSDirectory;
import org.apache.lucene.util.Version;
import org.apache.mahout.common.Pair;
import org.apache.mahout.math.map.OpenIntObjectHashMap;
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
      57600000, // 16hr
      115200000 // 24hr
  };
  
  private static final Analyzer PLAIN_ANALYZER = new TwitterAnalyzer(); // Version.LUCENE_36);
  private static final Analyzer ENGLISH_ANALYZER = new TwitterEnglishAnalyzer();
  private static final Analyzer ANALYZER = new PerFieldAnalyzerWrapper(
      PLAIN_ANALYZER, ImmutableMap.<String, Analyzer> of(
          AssocField.STEMMED_EN.name, ENGLISH_ANALYZER));
  
  protected static IndexReader twtIxReader;
  public static final String TWITTER_INDEX_PATH =
      "/u2/yaboulnaga/datasets/twitter-trec2011/indexes/stemmed-stored_8hr-increments/1295740800000/1297209600000";
  // "/u2/yaboulnaga/datasets/twitter-trec2011/indexes/index_orig";
  
  private static final String COLLECTION_STRING_CLEANER = "[\\,\\[\\]]";
  
  private static final boolean DONOT_REPLACE = false;
  private static final boolean DUMP_INTERSECTION_DEFAULT = true;
  
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
  
  protected final SummaryStatistics entropyTotalInShortUnion = new SummaryStatistics();
  protected final SummaryStatistics entropyTotalInLongWindow = new SummaryStatistics();
  protected final SummaryStatistics entropyExactOverlap = new SummaryStatistics();
  protected final SummaryStatistics entropyDiffLongerInShortUnion = new SummaryStatistics();
  protected final SummaryStatistics entropyDiffLongerInLongWindow = new SummaryStatistics();
  
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
      shortWindowReaders[i++] = IndexReader.open(SimpleFSDirectory.open(shortWindowIx));
    }
    shortWindowsUnion = new MultiReader(shortWindowReaders);
    longWindow = IndexReader.open(SimpleFSDirectory.open(longWindowIndex));
    
    OpenIntObjectHashMap<MutableLong> docIdInLongPatternInBoth = new OpenIntObjectHashMap<MutableLong>();
    IndexSearcher longWindowSearcher = new IndexSearcher(longWindow);
    
    this.dumpWr = Channels.newWriter(FileUtils.openOutputStream(new File(outPath, id + ".dump"))
        .getChannel(), "UTF-8");
    
    for (int ds = 0; ds < shortWindowsUnion.maxDoc(); ++ds) {
      measureOverlap(shortWindowsUnion,
          ds,
          longWindow,
          longWindowSearcher,
          docIdInLongPatternInBoth,
          true, extraItemsInLong, true);
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
          tempDocIdInShortPatternInBoth,
          false, extraItemsInShorts, false);
      
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
    this.dumpWr.flush();
    this.dumpWr.close();
    
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
            extraItemsInShorts,
            entropyTotalInLongWindow,
            entropyTotalInShortUnion,
            entropyExactOverlap,
            entropyDiffLongerInLongWindow,
            entropyDiffLongerInShortUnion
            ));
  }
  
  private double patternEntropy(Set<String> pattern) throws IOException {
    double result = 0;
    for (String item : pattern) {
      Term term = new Term(TweetField.TEXT.name, item);
      double pt = twtIxReader.docFreq(term);
      if (pt == 0) {
        continue;
      }
      pt /= twtIxReader.numDocs();
      result -= pt * Math.log(pt) / LOG2;
    }
    return result;
  }
  
  private void measureOverlap(IndexReader shortDocsReader, int ds,
      final IndexReader longDocsReader, IndexSearcher longDocsSearcher,
      final OpenIntObjectHashMap<MutableLong> docIdInLongPatternInBoth,
      final boolean sumSupport,
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
    
    final double dsEntropy = patternEntropy(tSetDs);
    if (shortUnionIsShortDoc) {
      entropyTotalInShortUnion.addValue(dsEntropy);
    } else {
      entropyTotalInLongWindow.addValue(dsEntropy);
    }
    
    final Document docDS = shortDocsReader.document(ds);
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
        
        TermFreqVector tvDl = longDocsReader.getTermFreqVector(
            dl, AssocField.ITEMSET.name);
        
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
          
          entropyExactOverlap.addValue(dsEntropy);
        }
        
        int diffLen = tvDl.size() - tSetDs.size();
        extraItems.addValue(diffLen);
        
        double dlEnt = patternEntropy(tSetDl);
        if (shortUnionIsShortDoc) {
          entropyTotalInLongWindow.addValue(dlEnt);
          entropyDiffLongerInLongWindow.addValue(dlEnt - dsEntropy);
        } else {
          // already added from previous run: entropyTotalInShortUnion
          entropyDiffLongerInShortUnion.addValue(dlEnt - dsEntropy);
        }
        
        if (dumpIntersction) {
          if (shortUnionIsShortDoc) {
            dumpWr.append(tSetDs + "\t" + tSetDl + "\n");
          } else {
            dumpWr.append(tSetDl + "\t" + tSetDs + "\n");
          }
        }
      }
      
      @Override
      public void setNextReader(IndexReader reader, int docBase)
          throws IOException {
        // this.reader = reader;
        this.docBase = docBase;
      }
      
      @Override
      public boolean acceptsDocsOutOfOrder() {
        return true;
      }
    };
    longDocsSearcher.search(query, longDocsCollector);
    
  }
  
  public static void main(String[] args) throws CorruptIndexException, IOException,
      InterruptedException, ExecutionException {
    File inDir = new File(args[0]);
    File outPath = new File(args[1]);
    int dayStart = Integer.parseInt(args[2]);
    int dayEnd = Integer.parseInt(args[3]);
    CompletionService<Pair<String, List<SummaryStatistics>>> completion = new ExecutorCompletionService<Pair<String, List<SummaryStatistics>>>(
        Executors.newFixedThreadPool(Integer.parseInt(args[4])));
    int numJobs = 0;
    
    if (DONOT_REPLACE && outPath.exists()) {
      throw new IllegalArgumentException("Output file already exists: " + outPath);
    }
    
    twtIxReader = IndexReader.open(MMapDirectory.open(new File(TWITTER_INDEX_PATH)));
    
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
        "entTotLongWinMean\t" +
        "entTotLongWinVar\t" +
        "entTotLongWinN\t" +
        "entTotShortUnionMean\t" +
        "entTotShortUnionVar\t" +
        "entTotShortUnionN\t" +
        "entExactOverlapMean\t" +
        "entExactOverlapVar\t" +
        "entExactOverlapN\t" +
        "entDiffLongerInLongMean\t" +
        "entDiffLongerInLongVar\t" +
        "entDiffLongerInLongN\t" +
        "entDiffLongerInShortMean\t" +
        "entDiffLongerInShortVar\t" +
        "entDiffLongerInShortN\t" +
        "\n");
    
    for (int d = dayStart; d <= dayEnd; ++d) {
      File dayIn = new File(inDir, "d" + d);
      for (int ws = 0; ws < windowSizesArr.length - 1; ++ws) {
        for (int wl = ws + 1; wl < windowSizesArr.length; ++wl) {
          List<File> shortWindowReaders = Lists.newLinkedList();
          File longWindowPending = null;
          File[] startAscending = dayIn.listFiles();
          Arrays.sort(startAscending);
          for (File startDir : startAscending) {
            File[] endDescending = startDir.listFiles();
            Arrays.sort(endDescending);
            for (int e = endDescending.length - 1; e >= 0; --e) {
              File endDir = endDescending[e];
              long windowSize = Long.parseLong(endDir.getName())
                  - Long.parseLong(startDir.getName());
              if (windowSize == windowSizesArr[ws]) {
                shortWindowReaders.add(new File(endDir, "index"));
              } else if (windowSize == windowSizesArr[wl]) {
                if (longWindowPending != null) {
                  CompareWindowSizes compareCall = new CompareWindowSizes(shortWindowReaders,
                      new File(endDir, "index"),
                      d + "_" + startDir.getName() + "_" + // endDir.getName() + "_" +
                          windowSizesArr[ws] + "_" + windowSizesArr[wl], outPath);
                  
                  compareCall.dumpIntersction = (d == 1);
                  
                  completion.submit(compareCall);
                  ++numJobs;
                  shortWindowReaders.clear();
                } else {
                  if (shortWindowReaders.size() >= windowSizesArr[wl] / windowSizesArr[ws]) {
                    throw new AssertionError("The short union is becoming too powerful!!");
                  }
                }
                longWindowPending = endDir;
              }
            }
          }
        }
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
          
          + stats.get(8).getMean() + "\t" + // entTotLongWinMean
          +stats.get(8).getVariance() + "\t" + // "entTotLongWinVar
          +stats.get(8).getN() + "\t" + // "entTotLongWinN
          
          +stats.get(9).getMean() + "\t" + // "entTotShortUnionMean
          +stats.get(9).getVariance() + "\t" + // "entTotShortUnionVar
          +stats.get(9).getN() + "\t" + // "entTotShortUnionN
          
          +stats.get(10).getMean() + "\t" + // "entExactOverlapMean
          +stats.get(10).getVariance() + "\t" + // "entExactOverlapVar
          +stats.get(10).getN() + "\t" + // "entExactOverlapN
          
          +stats.get(11).getMean() + "\t" + // "entDiffLongerInLongMean
          +stats.get(11).getVariance() + "\t" + // entDiffLongerInLongVar
          +stats.get(11).getN() + "\t" + // entDiffLongerInLongN
          
          +stats.get(12).getMean() + "\t" + // entDiffLongerInShortMean
          +stats.get(12).getVariance() + "\t" + // entDiffLongerInShortVar
          +stats.get(12).getN() + "\t" + // entDiffLongerInShortN
          "\n");
      
      wr.flush();
    }
    
    wr.flush();
    wr.close();
  }
}
