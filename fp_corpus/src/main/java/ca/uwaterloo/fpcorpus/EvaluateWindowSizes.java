package ca.uwaterloo.fpcorpus;

import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.nio.channels.Channels;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Set;
import java.util.TreeMap;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.mutable.MutableLong;
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
import org.apache.lucene.search.Query;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.NIOFSDirectory;
import org.apache.mahout.math.map.OpenObjectFloatHashMap;
import org.apache.mahout.math.map.OpenObjectIntHashMap;
import org.jdom2.JDOMException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import ca.uwaterloo.trecutil.QRelUtil;
import ca.uwaterloo.trecutil.TopicsUtils;
import ca.uwaterloo.twitter.ItemSetIndexBuilder.AssocField;
import ca.uwaterloo.twitter.TwitterAnalyzer;
import ca.uwaterloo.twitter.TwitterIndexBuilder.TweetField;
import ca.uwaterloo.twitter.queryexpand.FISQueryExpander;
import ca.uwaterloo.twitter.queryexpand.FISQueryExpander.FISCollector;
import ca.uwaterloo.twitter.queryexpand.FISQueryExpander.QueryParseMode;
import ca.uwaterloo.twitter.queryexpand.ScoreIxObj;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

public class EvaluateWindowSizes implements Callable<Void> {
  private static final Logger LOG = LoggerFactory
      .getLogger(EvaluateWindowSizes.class);
  
  private static final double LOG2 = Math.log(2);
  
  private static final long[] historyLengths = {
      900000, // 15min
      1800000, // 30min
      3600000, // 1hr
      7200000, // 2hr
      14400000, // 4hr
      28800000, // 8hr
      57600000, // 16hr
      86400000, // 24hr
      86400000 * 2, // 2days
      86400000 * 3, // 3days
      86400000 * 4, // 4days
      86400000 * 5, // 5days
      86400000 * 6, // 6days
      86400000 * 7 // 1 week
  };
  
  private static final long[] windowSizesArr = {
      300000, // 5min
      900000, // 15min
      1800000, // 30min
      3600000, // 1hr
      7200000, // 2hr
      14400000, // 4hr
      28800000, // 8hr
      57600000, // 16hr
      86400000, // 24hr
  };
  
  private static final Analyzer PLAIN_ANALYZER = new TwitterAnalyzer(); // Version.LUCENE_36);
  private static final Analyzer ENGLISH_ANALYZER = new TwitterEnglishAnalyzer();
  private static final Analyzer ANALYZER = new PerFieldAnalyzerWrapper(
      PLAIN_ANALYZER, ImmutableMap.<String, Analyzer> of(
          AssocField.STEMMED_EN.name, ENGLISH_ANALYZER));
  
  private static final String COLLECTION_STRING_CLEANER = "[\\,\\[\\]]";
  
  private static final boolean DONOT_REPLACE = false;
  
  private static final boolean SEARCH_NONSTEMMED = false;
  
  private static final int CALC_METRICS_FOR_N_IRRELEVANT_TWEETS = 30;
  
  protected final String queryStr;
  protected final String queryTimeFmted;
  protected final String qid;
  
  public EvaluateWindowSizes(String id, String queryTimeFmted,
      String queryStr) throws CorruptIndexException, IOException {
    
    this.qid = id;
    this.queryStr = queryStr;
    this.queryTimeFmted = queryTimeFmted;
    
  }
  
  public Void call() throws IOException, ParseException, java.text.ParseException {
    
    FISQueryExpander fisQEx;
    fisQEx = new FISQueryExpander(twtIncIxLoc, twtChunkIxLocs, queryTimeFmted);
    
    // List<String> targetTweets = Lists.newLinkedList();
    // for (Entry<String, Float> e :
    // qrelUtil.qRel.get(""+Integer.parseInt(qid.substring(2))).entrySet()) {
    // if (e.getValue() <= 0) {
    // targetTweets.add(e.getKey());
    // }
    // }
    LinkedHashMap<String, Float> targetTweets = qrelUtil.qRel.get(""
        + Integer.parseInt(qid.substring(2)));
    
    for (int h = 0; h < historyLengths.length; ++h) {
      for (int ws = 0; ws < windowSizesArr.length; ++ws) {
        long historyStart = fisQEx.getQueryTime() - historyLengths[h];
        int numShortWins = (int) Math.ceil(historyLengths[h] / windowSizesArr[ws]);
        if (numShortWins == 0 || numShortWins > 24) {
          // 2 hours of 5 mninutes or 1 day of 24 hours is the maximum we will wait for..
          // multireader would get tooo slow if there are more windows
          continue;
        }
        List<IndexReader> shortWindowReaderList = Lists.newArrayListWithCapacity(numShortWins);
        for (int d = dayStart; d <= dayEnd && shortWindowReaderList.size() < numShortWins; ++d) {
          File dayIn = new File(fisChunksPath, "d" + d);
          
          File shortWinDir = new File(dayIn, "w" + windowSizesArr[ws]);
          File[] shortsAsc = shortWinDir.listFiles();
          Arrays.sort(shortsAsc);
          for (File shortFile : shortsAsc) {
            long startTime = Long.parseLong(shortFile.getName());
            File endFile = shortFile.listFiles()[0];
            long endTime = Long.parseLong(endFile.getName());
            if (endTime < historyStart) {
              continue;
            }
            if (endTime > fisQEx.getQueryTime()) {
              break;
            }
            
            shortWindowReaderList.add(IndexReader.open(NIOFSDirectory.open(new File(endFile,
                "index"))));
            if (shortWindowReaderList.size() == numShortWins) {
              break;
            }
          }
        }
        
        final MultiReader shortWindowsUnion = new MultiReader(
            shortWindowReaderList.toArray(new IndexReader[0]));
        fisQEx.setFisIxReader(shortWindowsUnion);
        
        // /////////////////////////////////
        
        Writer twtMetricsWr = Channels.newWriter(FileUtils.openOutputStream(new File(outPath,
            "twtMetrics_" + qid + "_"
                + historyLengths[h] + "_" + windowSizesArr[ws] + ".csv"))
            .getChannel(),
            "UTF-8");
        twtMetricsWr
            .append("tweet\t" +
                "relevance\t" +
                "length\t" +
                "perplexity\n");
        
        OpenObjectFloatHashMap<Set<String>> aggregateScore = new OpenObjectFloatHashMap<Set<String>>();
        OpenObjectFloatHashMap<Set<String>> aggregateSupp = new OpenObjectFloatHashMap<Set<String>>();
        OpenObjectIntHashMap<Set<String>> relevanceCount = new OpenObjectIntHashMap<Set<String>>();
        // OpenIntFloatHashMap aggregateScores = new OpenIntFloatHashMap();
        // OpenIntObjectHashMap<String[]> allItemsets = new OpenIntObjectHashMap<String[]>();
        int numIrrelevantSeen = 0;
        for (String tweetId : targetTweets.keySet()) {
          Float relevance = targetTweets.get(tweetId);
          if (relevance <= 0 && numIrrelevantSeen >= CALC_METRICS_FOR_N_IRRELEVANT_TWEETS) {
            continue;
          }
          try {
            TopDocs tweetTopDocs = fisQEx.getTwtSearcher().search(new TermQuery(new Term(
                TweetField.ID.name, tweetId)),
                10);
            if (tweetTopDocs.totalHits != 1) {
              LOG.warn("Found {} tweets with tweetId {}", tweetTopDocs.totalHits, tweetId);
              continue;
            }
            
            int docId = tweetTopDocs.scoreDocs[0].doc;
            Document tweetDoc = fisQEx.getTwtIxReader().document(docId);
            OpenObjectFloatHashMap<String> queryTermWeight;
            MutableLong qLen = new MutableLong();
            String tweetStr = tweetDoc.get(TweetField.TEXT.name);
            if (relevance <= 0 && tweetStr.charAt(0) == 'R' && tweetStr.charAt(1) == 'T'){
              // we are not interested in measuring ReTweets... thye are easy to filter out 
              continue;
            }
            if (SEARCH_NONSTEMMED) {
              queryTermWeight = fisQEx.queryTermFreq(tweetStr,
                  qLen,
                  PLAIN_ANALYZER,
                  AssocField.ITEMSET.name);
            } else {
              queryTermWeight = new OpenObjectFloatHashMap<String>();
              TermFreqVector tv = fisQEx.getTwtIxReader().getTermFreqVector(docId,
                  TweetField.STEMMED_EN.name);
              if (tv == null) {
                continue;
              }
              for (String term : tv.getTerms()) {
                queryTermWeight.put(term, 1);
                qLen.add(1);
              }
            }
            
            float perplexity = 0;
            for (String word : queryTermWeight.keys()) {
              Term term = new Term(SEARCH_NONSTEMMED ? TweetField.TEXT.name
                  : TweetField.STEMMED_EN.name, word);
              float pt = fisQEx.getTwtIxReader().docFreq(term) / TWITTER_CORPUS_LENGTH_IN_TERMS;
              if (pt == 0) {
                continue;
              }
              perplexity += Math.log(pt) / LOG2;
            }
            perplexity /= -qLen.floatValue();
            perplexity = (float) Math.pow(2, perplexity);
            
            twtMetricsWr.append(tweetStr + "\t")
                .append(relevance + "\t")
                .append(qLen.intValue() + "\t") // length
                .append(perplexity + "\t") // perplexity
                .append("\n");
            
            if (relevance <= 0) {
              ++numIrrelevantSeen;
              continue;
            }
            
            Query query = fisQEx.parseQueryIntoTerms(queryTermWeight,
                qLen.floatValue(),
                QueryParseMode.DISJUNCTIVE,
                false,
                (SEARCH_NONSTEMMED ? AssocField.ITEMSET.name : AssocField.STEMMED_EN.name),
                fisQEx.getFisIxReader());
            
            FISCollector bm25Coll = new FISCollector(fisQEx, queryStr, queryTermWeight,
                qLen.floatValue(),
                -1);
            fisQEx.getFisSearcher().search(query, bm25Coll);
            
            TreeMap<ScoreIxObj<Integer>, String[]> rs = bm25Coll.getResultSet();
            Set<Set<String>> seenForThisQuery = Sets.newHashSet();
            for (ScoreIxObj<Integer> key : rs.keySet()) {
              Set<String> itemset = Sets.newCopyOnWriteArraySet(Arrays.asList(rs.get(key)));
              if (!seenForThisQuery.contains(itemset)) {
                seenForThisQuery.add(itemset);
                aggregateScore.put(itemset, key.score);
                relevanceCount.put(itemset, relevanceCount.get(itemset) + 1);
              }
              float supp = Float.parseFloat(fisQEx.getFisIxReader().document(key.obj)
                  .get(AssocField.SUPPORT.name));
              aggregateSupp.put(itemset, aggregateSupp.get(itemset) + supp);
              // aggregateScores.put(key.obj, aggregateScores.get(key.obj) + key.score);
              // allItemsets.put(key.obj, rs.get(key));
            }
            
          } catch (Exception ignored) {
            LOG.error(ignored.getMessage(), ignored);
          }
        }
        
        twtMetricsWr.flush();
        twtMetricsWr.close();
        // //////////////////////////////////
        
        Writer fisMetricsWr = Channels.newWriter(FileUtils.openOutputStream(new File(outPath,
            "fisMetrics_" + qid + "_"
                + historyLengths[h] + "_" + windowSizesArr[ws] + ".csv"))
            .getChannel(),
            "UTF-8");
        fisMetricsWr
            .append("itemset\t" +
                "length\t" +
                "bm25Sum\t" +
                "support\t" +
                "rel-count\t" +
                // "lift\t" +
                "coherence\t" +
                "all_conf\t" +
                // "chi-sq\t" +
                // "mutual-inf\t" +
                // "dfidf\t" +
                "entropy\t" +
                "sum-term-inf\t" +
                "sum-idf\n");
        // IntArrayList scoreAsc = new IntArrayList(aggregateScores.size());
        // aggregateScores.keysSortedByValue(scoreAsc);
        List<Set<String>> scoreAsc = Lists.newArrayListWithCapacity(aggregateScore.size());
        aggregateScore.keysSortedByValue(scoreAsc);
        for (int d = scoreAsc.size() - 1; d >= 0; --d) {
          // int docId = scoreAsc.get(d);
          // String[] itemset = allItemsets.get(docId);
          Set<String> itemset = scoreAsc.get(d);
          
          // MutableFloat maxTermSupp = new MutableFloat();
          // MutableFloat universe = new MutableFloat();
          // float[][] jointProbs = estimatePairWiseJointProbs(itemset, fisQEx, maxTermSupp,
          // universe);
          
          float[] tweetSupp = new float[itemset.size()];
          // float[] fisSupp = new float[itemset.length];
          float maxTermSupp = Float.MIN_VALUE;
          float totalTermSupp = 0;
          // for (int i = 0; i < itemset.length; ++i) {
          // Term termi = new Term(fisQEx.paramBM25StemmedIDF ? TweetField.STEMMED_EN.name
          // : TweetField.TEXT.name, itemset[i]);
          int i = -1;
          for (String item : itemset) {
            ++i;
            Term termi = new Term(fisQEx.paramBM25StemmedIDF ? TweetField.STEMMED_EN.name
                : TweetField.TEXT.name, item);
            tweetSupp[i] = fisQEx.getTwtIxReader().docFreq(termi);
            totalTermSupp += tweetSupp[i];
            if (tweetSupp[i] > maxTermSupp) {
              maxTermSupp = tweetSupp[i];
            }
            
            // termi = new Term(fisQEx.paramBM25StemmedIDF ? AssocField.STEMMED_EN.name
            // : AssocField.ITEMSET.name, itemset[i]);
            // fisSupp[i] = fisQEx.getFisIxReader().docFreq(termi);
          }
          
          float supp = aggregateSupp.get(itemset);
          
          fisMetricsWr.append(itemset + "\t") // "itemset\t
              .append(itemset.size() + "\t") // length\t
              .append(aggregateScore.get(itemset) + "\t") // bm25Sum
              .append(supp + "\t") // support
              .append(relevanceCount.get(itemset) + "\t") //rel-count
              // .append(calcLift(itemset, jointProbs) + "\t") //lift
              .append(supp / totalTermSupp + "\t") // coherence
              .append(supp / maxTermSupp + "\t") // all_conf
              // .append(calcChiSquare(jointProbs, universe.floatValue()) +"\t"); //chi-sq
              // .append(caclMutualInfo(jointProbs) + "\t" );//mutual-inf
              // .append(calcDfIdf(tweetSupp, fisSupp, fisQEx) + "\t") // dfidf \
              .append(calcEntropy(tweetSupp) + "\t") // entropy
              .append(calcSumTermInf(tweetSupp) + "\t") // sum-term-inf
              .append(calcSumIdf(tweetSupp, fisQEx) + "\t") // sum-idf
              .append("\n");
        }
        fisMetricsWr.flush();
        fisMetricsWr.close();
      }
    }
    fisQEx.close();
    return null;
  }
  
  private float calcSumIdf(float[] tweetSupp, FISQueryExpander fisQEx) {
    float numTweets = fisQEx.getTwtIxReader().numDocs();
    float result = 0;
    for (float ts : tweetSupp) {
      if (ts == 0) {
        continue; // duh
      }
      result -= Math.log(ts / numTweets);
    }
    return result;
  }
  
  private float calcSumTermInf(float[] termSupp) {
    float result = 0;
    for (float ts : termSupp) {
      if (ts == 0) {
        continue; // duh
      }
      result -= Math.log(ts / TWITTER_CORPUS_LENGTH_IN_TERMS) / LOG2;
    }
    return result / termSupp.length;
  }
  
  private float calcEntropy(float[] termSupp) {
    float result = 0;
    for (float pt : termSupp) {
      
      if (pt == 0) {
        continue;
      }
      pt /= TWITTER_CORPUS_LENGTH_IN_TERMS;
      result -= pt * Math.log(pt) / LOG2;
    }
    return result;
  }
  
  // lift is a cascade measure, not really useful here when we want to measure the absolute quality
  // of itemsets. It could be used when searching for relevant ones for qEx for example
  // private String calcLift(String[] itemset, float[][] jointProbs) {
  //
  // return null;
  // }
  
  // This needs counting the probabilities of a ^ !b .. lots of work!
  // private String calcChiSquare(float[][] jointProbs, float floatValue) {
  // return null;
  // }
  
  // Later later I will spend the time to calculate this, but now let's see the comine metrics
  // private String caclMutualInfo(float[][] jointProbs) {
  // return null;
  // }
  //
  // private float calcAllConf(float supp, float[][] jointProbs) {
  // float maxTermSupp = Float.MIN_VALUE;
  // for(int i=0; i< jointProbs.length; ++i){
  // if(jointProbs[i][i] > maxTermSupp){
  // maxTermSupp = jointProbs[i][i];
  // }
  // }
  // return supp / maxTermSupp;
  // }
  //
  // /**
  // * Also known as bond.. see comine
  // *
  // * @param itemset
  // * @param jointProbs
  // * @return
  // */
  // private float calcCoherence(float supp, float[][] jointProbs) {
  // float universe = 0;
  // for (int i = 0; i < jointProbs.length; ++i) {
  // universe += jointProbs[i][i];
  // }
  // return supp / universe;
  // }
  //
  // /**
  // * Estimating using the lucene inverted index is not possible.. cannot control the order of
  // * reading
  // * the posting list, and to cancel the collector I have to throw a runtime exception.. not good!
  // *
  // * @param itemset
  // * @param fisQEx
  // * @return
  // * @throws IOException
  // * @throws InterruptedException
  // * @throws ExecutionException
  // */
  // private float[][] estimatePairWiseJointProbs(String[] itemset, final FISQueryExpander fisQEx,
  // MutableFloat maxTermSupp, MutableFloat universe)
  // throws IOException {
  // float[][] result = new float[itemset.length][itemset.length];
  // universe.setValue(0);
  // maxTermSupp.setValue(Float.MIN_VALUE);
  // for (int i = 0; i < itemset.length; ++i) {
  // Term termi = new Term(fisQEx.paramBM25StemmedIDF ? AssocField.STEMMED_EN.name
  // : AssocField.ITEMSET.name, itemset[i]);
  //
  // result[i][i] = fisQEx.getTwtIxReader().docFreq(termi);
  // if(result[i][i] > maxTermSupp.floatValue()){
  // maxTermSupp.setValue(result[i][i]);
  // }
  // universe.add(result[i][i]);
  // TermQuery tqi = new TermQuery(termi);
  // for (int j = i + 1; j < itemset.length; ++j) {
  // Term termj = new Term(fisQEx.paramBM25StemmedIDF ? AssocField.STEMMED_EN.name
  // : AssocField.ITEMSET.name, itemset[j]);
  // TermQuery tqj = new TermQuery(termj);
  // BooleanQuery query = new BooleanQuery();
  // query.add(tqi, Occur.MUST);
  // query.add(tqj, Occur.MUST);
  // TotalHitCountCollector counterCollector = new TotalHitCountCollector();
  // fisQEx.getTwtSearcher().search(query, counterCollector);
  // result[i][j] = counterCollector.getTotalHits();
  // }
  // }
  // return result;
  // }
  
  // This will use an equal df for all terms, since out algo stores 50 top
  // thus to be meaningful the least that can be done is to sum the uspport values.. duh!
  // private float calcDfIdf(float[] tweetSupp, float[] fisSupp, FISQueryExpander fisQEx) {
  // float numTweets = fisQEx.getTwtIxReader().numDocs();
  // float numFIS = fisQEx.getFisIxReader().numDocs();
  // float result = 0;
  // for (int i = 0; i < tweetSupp.length; ++i) {
  // float global = tweetSupp[i] / numTweets;
  // if (global == 0) {
  // continue; // whateverrrrr
  // }
  // float local = fisSupp[i] / numFIS;
  // result -= local * Math.log(global) / LOG2;
  // }
  // return result;
  // }
  
  private static final float TWITTER_CORPUS_LENGTH_IN_TERMS = 100055949;
  
  static File fisChunksPath;
  static File outPath;
  static int dayStart;
  static int dayEnd;
  static QRelUtil qrelUtil;
  static File twtIncIxLoc;
  static File[] twtChunkIxLocs;
  
  public static void main(String[] args) throws CorruptIndexException, IOException,
      InterruptedException, ExecutionException, JDOMException {
    fisChunksPath = new File(args[0]);
    outPath = new File(args[1]);
    twtIncIxLoc = new File(args[2]);
    
    twtChunkIxLocs = new File(args[3]).listFiles();
    Arrays.sort(twtChunkIxLocs);
    
    dayStart = Integer.parseInt(args[4]);
    dayEnd = Integer.parseInt(args[5]);
    // TODO from args
    qrelUtil = new QRelUtil(new File(
        "/u2/yaboulnaga/datasets/twitter-trec2011/microblog11-qrels.txt"));
    TopicsUtils topicUtil = new TopicsUtils(
        "/u2/yaboulnaga/datasets/twitter-trec2011/2011.topics.MB1-50.xml",
        true);
    ExecutorService exec = Executors.newFixedThreadPool(Integer.parseInt(args[6]));
    int numJobs = 0;
    
    if (DONOT_REPLACE && outPath.exists()) {
      throw new IllegalArgumentException("Output file already exists: " + outPath);
    }
    
    Future<Void> lastFuture = null;
    for (int t = 0; t < topicUtil.topicIds.size(); ++t) {
      
      EvaluateWindowSizes compareCall = new EvaluateWindowSizes(topicUtil.topicIds.get(t),
          topicUtil.queryTimes.get(t), topicUtil.queries.get(t));
      
      lastFuture = exec.submit(compareCall);
      ++numJobs;
    }
    
    lastFuture.get();
    
    exec.shutdown();
    while (!exec.isTerminated()) {
      Thread.sleep(5000);
    }
    
  }
}
