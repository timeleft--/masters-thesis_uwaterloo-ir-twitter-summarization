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
import org.apache.commons.lang.mutable.MutableFloat;
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
import org.apache.lucene.search.BooleanClause.Occur;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.Collector;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.Scorer;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.search.TotalHitCountCollector;
import org.apache.lucene.store.NIOFSDirectory;
import org.apache.mahout.math.map.OpenIntFloatHashMap;
import org.apache.mahout.math.map.OpenObjectFloatHashMap;
import org.apache.mahout.math.map.OpenObjectIntHashMap;
import org.jdom2.JDOMException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import weka.core.ContingencyTables;
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
      // 57600000, // 16hr
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
      // 57600000, // 16hr
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
  
  private static final float AVG_TWEET_LENGTH = 9.6f;
  
  private static final boolean METRICS_FROM_TWITTER = true;
  private static final boolean METRICS_AVERAGED = true;
  
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
    
    // for (int h = 0; h < historyLengths.length; ++h) {
    // for (int ws = 0; ws < windowSizesArr.length; ++ws) {
    for (int h = historyLengths.length - 1; h >= 0; --h) {
      for (int ws = windowSizesArr.length - 1; ws >= 0; --ws) {
        long historyStart = fisQEx.getQueryTime() - historyLengths[h];
        int numShortWins = (int) Math.ceil(historyLengths[h] / windowSizesArr[ws]);
        if (numShortWins == 0 || numShortWins > 168) { // a week in hours
          // numShortWins > 24) {
          // // 2 hours of 5 mninutes or 1 day of 24 hours is the maximum we will wait for..
          // // multireader would get tooo slow if there are more windows
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
            if (relevance <= 0 && tweetStr.charAt(0) == 'R' && tweetStr.charAt(1) == 'T') {
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
              Term term = new Term(SEARCH_NONSTEMMED ? AssocField.ITEMSET.name
                  : AssocField.STEMMED_EN.name, word);
              // The best is to use sum of support / total support.. but duh!
              float pt = fisQEx.getFisIxReader().docFreq(term) * 1.0f
                  / fisQEx.getFisIxReader().numDocs();
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
                
                // "avg-cramerv\t" +
                "avg-yuleq\t" +
                // "avg-kruskal\t" +
                // "avg-fischerexact\t" +
                "avg-gainratio\t" +
                
                "avg-bleheta\t" +
                // "avg-berry\t" +
                
                "nmi\t" +
                "avg-pmi\t" +
                // "exp-pmi\t" +
                // "dfidf\t" +
                // "entropy\t" +
                // "avg-term-inf\t" +
                // "avg-idf\t" +
                "\n");
        // IntArrayList scoreAsc = new IntArrayList(aggregateScores.size());
        // aggregateScores.keysSortedByValue(scoreAsc);
        List<Set<String>> scoreAsc = Lists.newArrayListWithCapacity(aggregateScore.size());
        aggregateScore.keysSortedByValue(scoreAsc);
        for (int d = scoreAsc.size() - 1; d >= 0; --d) {
          // int docId = scoreAsc.get(d);
          // String[] itemset = allItemsets.get(docId);
          Set<String> itemset = scoreAsc.get(d);
          
          MutableFloat maxTermSupp = new MutableFloat();
          MutableFloat totalTermSupp = new MutableFloat();
          OpenIntFloatHashMap[] jointFreqs;
          List<String> itemsetList = Lists.newLinkedList();
          for (String item : itemset) {
            char ch0 = item.charAt(0);
            if (ch0 == '@' || ch0 == '#') {
              continue;
            }
            itemsetList.add(item);
          }
          if (METRICS_FROM_TWITTER) {
            jointFreqs = estimatePairWiseJointFreqsFromTwitter(itemsetList.toArray(new String[0]),
                fisQEx,
                fisQEx.paramBM25StemmedIDF ? TweetField.STEMMED_EN.name : TweetField.TEXT.name,
                maxTermSupp, totalTermSupp);
          } else {
            jointFreqs = estimatePairWiseJointFreqsFromFIS(itemsetList.toArray(new String[0]),
                fisQEx,
                fisQEx.paramBM25StemmedIDF ? AssocField.STEMMED_EN.name : AssocField.ITEMSET.name,
                maxTermSupp,
                totalTermSupp);
          }
          
          // float[] tweetSupp = new float[itemset.size()];
          // // float[] fisSupp = new float[itemset.length];
          // float maxTermSupp = Float.MIN_VALUE;
          // float totalTermSupp = 0;
          // // for (int i = 0; i < itemset.length; ++i) {
          // // Term termi = new Term(fisQEx.paramBM25StemmedIDF ? TweetField.STEMMED_EN.name
          // // : TweetField.TEXT.name, itemset[i]);
          // int i = -1;
          // for (String item : itemset) {
          // ++i;
          // Term termi = new Term(fisQEx.paramBM25StemmedIDF ? TweetField.STEMMED_EN.name
          // : TweetField.TEXT.name, item);
          // tweetSupp[i] = fisQEx.getTwtIxReader().docFreq(termi);
          // totalTermSupp += tweetSupp[i];
          // if (tweetSupp[i] > maxTermSupp) {
          // maxTermSupp = tweetSupp[i];
          // }
          //
          // // termi = new Term(fisQEx.paramBM25StemmedIDF ? AssocField.STEMMED_EN.name
          // // : AssocField.ITEMSET.name, itemset[i]);
          // // fisSupp[i] = fisQEx.getFisIxReader().docFreq(termi);
          // }
          
          float supp = aggregateSupp.get(itemset);
          float numDocs;
          if (METRICS_FROM_TWITTER) {
            numDocs = fisQEx.getTwtIxReader().numDocs();
          } else {
            // The number of FIS is irrelevant
            // The best would be the total support of all FIs, but that's a barra
            // so we can just use the same as above
            numDocs = fisQEx.getTwtIxReader().numDocs();
          }
          fisMetricsWr.append(itemset + "\t") // "itemset\t
              .append(itemset.size() + "\t") // length\t
              .append(aggregateScore.get(itemset) + "\t") // bm25Sum
              .append(supp + "\t") // support
              .append(relevanceCount.get(itemset) + "\t") // rel-count
              
              // .append(calcLift(itemset, jointFreqs) + "\t") //lift
              
              .append(supp / totalTermSupp.floatValue() + "\t") // coherence
              .append(supp / maxTermSupp.floatValue() + "\t") // all_conf
              
              // Contingency table
              // .append(avgPairCramerV(jointFreqs, numDocs) + "\t") // "avg-cramerv\t" +
              .append(avgPairYuleQ(jointFreqs, numDocs) + "\t") // "avg-yuleq\t" +
              // .append(avgPairKruskalTau(jointFreqs, numDocs) + "\t") // "avg-kruskal\t" +
              // .append(avgPairFischerExact(jointFreqs, numDocs) + "\t") // "avg-fischerexact\t" +
              .append(avgPairGainRatio(jointFreqs, numDocs) + "\t") // "avg-gainratio\t" +
              
              // Freom Pearce 2003 MWE evaluation
              .append(avgBleheta(jointFreqs, numDocs) + "\t") // bleheta and johnson
              // .append(avgBerry(jointFreqs, numDocs) + "\t") // berry 1973
              
              .append(calcNMI(jointFreqs, numDocs, totalTermSupp.floatValue()) + "\t") // normalized-mutual-inf
              .append(averagePmi(jointFreqs, numDocs) + "\t") // average-pairwise-mutual-inf
              // .append(expectedPmi(jointFreqs, numDocs, totalTermSupp.floatValue()) + "\t") //
              // expected-pairwise-mutual-inf
              // .append(calcDfIdf(tweetSupp, fisSupp, fisQEx) + "\t") // dfidf \
              // .append(calcEntropy(jointFreqs) + "\t") // entropy
              // .append(calcSumTermInf(jointFreqs) + "\t") // avg-term-inf
              // .append(calcSumIdf(jointFreqs, numDocs) + "\t") // avg-idf
              .append("\n");
        }
        fisMetricsWr.flush();
        fisMetricsWr.close();
      }
    }
    fisQEx.close();
    return null;
  }
  
  public static double avgBerry(OpenIntFloatHashMap[] jointFreqs, float numDocs) {
    if (jointFreqs.length == 1) {
      return 0;
    }
    double result = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      for (int j = i + 1; j < jointFreqs.length; ++j) {
        if (i == j) {
          continue;
        }
        // we'll leave the numbers cancel out
        // result += Math.abs(yuleQ(contingencyTable(i, j, jointFreqs, numDocs)));
        result += berry(i, j, jointFreqs, numDocs);
      }
    }
    if (METRICS_AVERAGED) {
      result = 2 * result / (jointFreqs.length * (jointFreqs.length - 1));
    }
    return result;
    
  }
  
  public static double berry(int i, int j, OpenIntFloatHashMap[] jointFreqs, float numDocs) {
    double p = jointFreqs[i].get(i) / (numDocs - jointFreqs[j].get(j));
    double fHat = p * jointFreqs[j].get(j) * AVG_TWEET_LENGTH;
    double result = (jointFreqs[i].get(j) - fHat) / Math.sqrt(fHat * (1 - p));
    return result;
  }
  
  public static double avgPairYuleQ(OpenIntFloatHashMap[] jointFreqs, float numDocs) {
    if (jointFreqs.length == 1) {
      return 0;
    }
    double result = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      for (int j = i + 1; j < jointFreqs.length; ++j) {
        if (i == j) {
          continue;
        }
        // we'll leave the numbers cancel out
        // result += Math.abs(yuleQ(contingencyTable(i, j, jointFreqs, numDocs)));
        result += yuleQ(contingencyTable(i, j, jointFreqs, numDocs));
      }
    }
    if (METRICS_AVERAGED) {
      result = 2 * result / (jointFreqs.length * (jointFreqs.length - 1));
    }
    return result;
    
  }
  
  /**
   * 
   * @param cont
   * @return +/-1 positive or negative perfect correlation, 0 no association
   */
  public static double yuleQ(double[][] cont) {
    double ad = cont[0][0] * cont[1][1];
    double bc = cont[0][1] * cont[1][0];
    return (ad - bc) / (ad + bc);
  }
  
  public static double avgPairCramerV(OpenIntFloatHashMap[] jointFreqs, float numDocs) {
    if (jointFreqs.length == 1) {
      return 0;
    }
    double result = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      for (int j = i + 1; j < jointFreqs.length; ++j) {
        if (i == j) {
          continue;
        }
        result += ContingencyTables.CramersV(contingencyTable(i, j, jointFreqs, numDocs));
        // ContingencyTables.chiSquared(contingencyTable(i, j, jointFreqs, numDocs), true);
      }
    }
    if (METRICS_AVERAGED) {
      result = 2 * result / (jointFreqs.length * (jointFreqs.length - 1));
    }
    return result;
    
  }
  
  public static double avgPairGainRatio(OpenIntFloatHashMap[] jointFreqs, float numDocs) {
    if (jointFreqs.length == 1) {
      return 0;
    }
    double result = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      for (int j = i + 1; j < jointFreqs.length; ++j) {
        if (i == j) {
          continue;
        }
        result += 2 / ContingencyTables.gainRatio(contingencyTable(i, j, jointFreqs, numDocs));
      }
    }
    // if(METRICS_AVERAGED){
    result = (jointFreqs.length * (jointFreqs.length - 1)) / result;
    // }
    return result;
    
  }
  
  public static double avgPairFischerExact(OpenIntFloatHashMap[] jointFreqs, float numDocs) {
    if (jointFreqs.length == 1) {
      return 0;
    }
    double result = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      for (int j = i + 1; j < jointFreqs.length; ++j) {
        if (i == j) {
          continue;
        }
        result += ContingencyTables.log2MultipleHypergeometric(contingencyTable(i,
            j,
            jointFreqs,
            numDocs));
      }
    }
    if (METRICS_AVERAGED) {
      result = 2 * result / (jointFreqs.length * (jointFreqs.length - 1));
    }
    return result;
    
  }
  
  public static double avgPairKruskalTau(OpenIntFloatHashMap[] jointFreqs, float numDocs) {
    if (jointFreqs.length == 1) {
      return 0;
    }
    double result = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      for (int j = i + 1; j < jointFreqs.length; ++j) {
        if (i == j) {
          continue;
        }
        result += 2 / ContingencyTables.tauVal(contingencyTable(i, j, jointFreqs, numDocs));
      }
    }
    // if(METRICS_AVERAGED){
    // result = 2 * result / (jointFreqs.length * (jointFreqs.length - 1));
    // }
    result = (jointFreqs.length * (jointFreqs.length - 1)) / result;
    return result;
    
  }
  
  public static double avgBleheta(OpenIntFloatHashMap[] jointFreqs, float numDocs) {
    if (jointFreqs.length == 1) {
      return 0;
    }
    double result = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      for (int j = i + 1; j < jointFreqs.length; ++j) {
        if (i == j) {
          continue;
        }
        result += 2 / bleheta(contingencyTable(i, j, jointFreqs, numDocs));
      }
    }
    // if(METRICS_AVERAGED){
    // result = 2 * result / (jointFreqs.length * (jointFreqs.length - 1));
    // }
    result = (jointFreqs.length * (jointFreqs.length - 1)) / result;
    return result;
    
  }
  
  public static double[][] contingencyTable(int i, int j, OpenIntFloatHashMap[] jointFreqs,
      float numDocs) {
    double[][] result = new double[2][2];
    result[0][0] = numDocs - (jointFreqs[i].get(i) + jointFreqs[j].get(j) - jointFreqs[i].get(j));
    result[0][1] = jointFreqs[j].get(j) - jointFreqs[i].get(j);
    result[1][0] = jointFreqs[i].get(i) - jointFreqs[i].get(j);
    result[1][1] = jointFreqs[i].get(j);
    return result;
  }
  
  public static double bleheta(double[][] cont) {
    double logOdds = (cont[0][0] * cont[1][1]) / (cont[0][1] * cont[1][0]);
    if (logOdds == 0 || Double.isInfinite(logOdds)) {
      return 0; // duh!
    }
    logOdds = Math.log(logOdds);
    
    double error = (1 / cont[0][0]) + (1 / cont[0][1]) + (1 / cont[1][0]) + (1 / cont[1][1]);
    if (Double.isNaN(error) || Double.isInfinite(error)) {
      return logOdds;
    }
    error = Math.sqrt(error);
    double result = logOdds - 3.29 * error;
    return result;
  }
  
  public static float calcSumIdf(OpenIntFloatHashMap[] jointFreqs, float numDocs) {
    float result = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      float ts = jointFreqs[i].get(i);
      if (ts == 0) {
        continue; // duh
      }
      result -= Math.log(ts / numDocs);
    }
    if (METRICS_AVERAGED) {
      result = result / jointFreqs.length;
    }
    return result;
    
  }
  
  public static float calcSumTermInf(OpenIntFloatHashMap[] jointFreqs) {
    float result = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      float ts = jointFreqs[i].get(i);
      if (ts == 0) {
        continue; // duh
      }
      result -= Math.log(ts / TWITTER_CORPUS_LENGTH_IN_TERMS) / LOG2;
    }
    if (METRICS_AVERAGED) {
      result = result / (jointFreqs.length);
    }
    return result;
    
  }
  
  public static float calcEntropy(OpenIntFloatHashMap[] jointFreqs) {
    float result = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      float pt = jointFreqs[i].get(i);
      
      if (pt == 0) {
        continue;
      }
      pt /= TWITTER_CORPUS_LENGTH_IN_TERMS;
      result -= pt * Math.log(pt) / LOG2;
    }
    if (METRICS_AVERAGED) {
      result = result / (jointFreqs.length);
    }
    return result;
    
  }
  
  // lift is a cascade measure, not really useful here when we want to measure the absolute quality
  // of itemsets. It could be used when searching for relevant ones for qEx for example
  // public static String calcLift(String[] itemset, float[][] jointFreqs) {
  //
  // return null;
  // }
  
  public static double pmi(int i, int j, OpenIntFloatHashMap[] jointFreqs, float numDocs) {
    // This metric becomes unstable when f(x,y) becomes less than 5 according to Pearce (2003)
    if (jointFreqs[j].get(j) < 6) {
      return 0;
    }
    // Multiplying by AVG_TWEET_LENGTH is my way of mimicing the window size of Church (1999)
    // And it is just equivalent to calculating the bigram probability not the doucment prob.
    float result = (jointFreqs[i].get(j) * numDocs) // * AVG_TWEET_LENGTH)
        / (jointFreqs[i].get(i) * jointFreqs[j].get(j));
    if (result == 0) {
      return 0; // duh;
    }
    return Math.log(result) / LOG2;
  }
  
  public static double expectedPmi(OpenIntFloatHashMap[] jointFreqs, float numDocs, float totalFreq) {
    if (jointFreqs.length == 1) {
      return 0;
    }
    double result = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      for (int j = i + 1; j < jointFreqs.length; ++j) {
        if (i == j) {
          continue;
        }
        result += (jointFreqs[i].get(j) / totalFreq)
            * pmi(i, j, jointFreqs, numDocs);
      }
    }
    return 2 * result;
  }
  
  public static double averagePmi(OpenIntFloatHashMap[] jointFreqs, float numDocs) {
    if (jointFreqs.length == 1) {
      return 0;
    }
    double result = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      for (int j = i + 1; j < jointFreqs.length; ++j) {
        if (i == j) {
          continue;
        }
        result += pmi(i, j, jointFreqs, numDocs);
      }
    }
    if (METRICS_AVERAGED) {
      result = 2 * result / (jointFreqs.length * (jointFreqs.length - 1));
    }
    return result;
  }
  
  public static double calcNMI(OpenIntFloatHashMap[] jointFreqs, float numDocs, float totalFreq) {
    if (jointFreqs.length == 1) {
      return 0;
    }
    double result = expectedPmi(jointFreqs, numDocs, totalFreq);
    
    double denim = 0;
    for (int i = 0; i < jointFreqs.length; ++i) {
      for (int j = i + 1; j < jointFreqs.length; ++j) {
        if (i == j) {
          continue;
        }
        double jp = (jointFreqs[i].get(j) / numDocs);
        if (jp == 0) {
          continue; // duh
        }
        denim -= jp * Math.log(jp) / LOG2;
      }
    }
    // result *=2;
    // denim *=2;
    result /= denim;
    return result;
  }
  
  /**
   * Estimating using the lucene inverted index is not possible.. cannot control the order of
   * reading
   * the posting list, and to cancel the collector I have to throw a runtime exception.. not good!
   * 
   * @param itemset
   * @param fisQEx
   * @param fieldName
   * @return
   * @throws IOException
   * @throws InterruptedException
   * @throws ExecutionException
   */
  public static OpenIntFloatHashMap[] estimatePairWiseJointFreqsFromTwitter(String[] itemset,
      FISQueryExpander fisQEx,
      String fieldName,
      MutableFloat maxTermSupp, MutableFloat totalTermSupp)
      throws IOException {
    return estimatePairWiseJointFreqsFromTwitter(itemset, fisQEx.getTwtIxReader(),
        fisQEx.getTwtSearcher(), fieldName, maxTermSupp, totalTermSupp);
  }
  
  public static OpenIntFloatHashMap[] estimatePairWiseJointFreqsFromTwitter(String[] itemset,
      IndexReader twtIxReader,
      IndexSearcher twtIxSearcher,
      String fieldName,
      MutableFloat maxTermSupp, MutableFloat totalTermSupp)
      throws IOException {
    // float[][] result = new float[itemset.length][itemset.length];
    OpenIntFloatHashMap[] result = new OpenIntFloatHashMap[itemset.length];
    totalTermSupp.setValue(0);
    maxTermSupp.setValue(Float.MIN_VALUE);
    for (int i = 0; i < itemset.length; ++i) {
      Term termi = new Term(fieldName, itemset[i]);
      result[i] = new OpenIntFloatHashMap();
      int termSupp = twtIxReader.docFreq(termi);
      result[i].put(i, termSupp);
      if (termSupp > maxTermSupp.floatValue()) {
        maxTermSupp.setValue(termSupp);
      }
      totalTermSupp.add(termSupp);
      TermQuery tqi = new TermQuery(termi);
      for (int j = i + 1; j < itemset.length; ++j) {
        Term termj = new Term(fieldName, itemset[j]);
        TermQuery tqj = new TermQuery(termj);
        BooleanQuery query = new BooleanQuery();
        query.add(tqi, Occur.MUST);
        query.add(tqj, Occur.MUST);
        TotalHitCountCollector counterCollector = new TotalHitCountCollector();
        twtIxSearcher.search(query, counterCollector);
        // result[i][j] = counterCollector.getTotalHits();
        // result[j][i] = result[i][j];
        result[i].put(j, counterCollector.getTotalHits());
      }
    }
    return result;
  }
  
  /**
   * Estimating using the lucene inverted index is not possible.. cannot control the order of
   * reading
   * the posting list, and to cancel the collector I have to throw a runtime exception.. not good!
   * 
   * @param itemset
   * @param fisQEx
   * @param fieldName
   * @return
   * @throws IOException
   * @throws InterruptedException
   * @throws ExecutionException
   */
  public static OpenIntFloatHashMap[] estimatePairWiseJointFreqsFromFIS(String[] itemset,
      final FISQueryExpander fisQEx,
      String fieldName,
      MutableFloat maxTermSupp, MutableFloat totalTermSupp)
      throws IOException {
    // float[][] result = new float[itemset.length][itemset.length];
    OpenIntFloatHashMap[] result = new OpenIntFloatHashMap[itemset.length];
    totalTermSupp.setValue(0);
    maxTermSupp.setValue(Float.MIN_VALUE);
    for (int i = 0; i < itemset.length; ++i) {
      Term termi = new Term(fieldName, itemset[i]);
      result[i] = new OpenIntFloatHashMap();
      TermQuery tqi = new TermQuery(termi);
      for (int j = i; j < itemset.length; ++j) {
        Term termj = new Term(fieldName, itemset[j]);
        TermQuery tqj = new TermQuery(termj);
        BooleanQuery query = new BooleanQuery();
        query.add(tqi, Occur.MUST);
        if (i != j) {
          query.add(tqj, Occur.MUST);
        }
        final MutableLong totalsupp = new MutableLong(0);
        
        fisQEx.getFisSearcher().search(query, new Collector() {
          
          @Override
          public void setScorer(Scorer scorer) throws IOException {
          }
          
          int docBase;
          
          @Override
          public void setNextReader(IndexReader reader, int docBase) throws IOException {
            this.docBase = docBase;
          }
          
          @Override
          public void collect(int docId) throws IOException {
            Document doc = fisQEx.getFisIxReader().document(docBase + docId);
            totalsupp.add(Long.parseLong(doc.get(AssocField.SUPPORT.name)));
          }
          
          @Override
          public boolean acceptsDocsOutOfOrder() {
            return false;
          }
        });
        
        result[i].put(j, totalsupp.floatValue());
        if (i == j) {
          if (totalsupp.floatValue() > maxTermSupp.floatValue()) {
            maxTermSupp.setValue(totalsupp);
          }
          totalTermSupp.add(totalsupp.floatValue());
        }
      }
    }
    return result;
  }
  
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
