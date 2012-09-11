package ca.uwaterloo.timeseries;

import java.awt.Color;
import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.nio.channels.Channels;
import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.apache.commons.math.stat.descriptive.SummaryStatistics;
import org.apache.lucene.analysis.WhitespaceAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.FieldSelector;
import org.apache.lucene.document.FieldSelectorResult;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.MultiReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.index.TermEnum;
import org.apache.lucene.index.TermFreqVector;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.queryParser.QueryParser.Operator;
import org.apache.lucene.search.Collector;
import org.apache.lucene.search.FilteredQuery;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.NumericRangeFilter;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.Scorer;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.NIOFSDirectory;
import org.apache.lucene.util.Version;
import org.apache.mahout.math.map.OpenObjectIntHashMap;
import org.rrd4j.ConsolFun;
import org.rrd4j.DsType;
import org.rrd4j.core.RrdDb;
import org.rrd4j.core.RrdDef;
import org.rrd4j.core.RrdSafeFileBackend;
import org.rrd4j.core.Sample;
import org.rrd4j.core.Util;
import org.rrd4j.graph.RrdGraph;
import org.rrd4j.graph.RrdGraphDef;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import com.google.common.hash.Hashing;

public class PlotTermFrequencyTimeSeries {
  
  private static Random rand = new Random(System.currentTimeMillis());
  
  public static enum RunMode {
    RRD4J, VERTICAL, DUMP1S, DUMPDELTAT
  };
  
  public static char DELIM = '\t';
  // TODO: command line
  public static RunMode runMode = RunMode.VERTICAL;
  public static boolean writeUnixTime = true;
  public static boolean fillZeros = true;
//  public static boolean rHeader = true;
  
  private static long windowLength = 3600000;
  private static long timeStep = 60000;
  
  private static String ixPath = "/u2/yaboulnaga/data/twitter-trec2011/indexes/twt_pos-stored_chunks/001_twt_pos-stored_1hr_chunks";
  private static String outParent = "/u2/yaboulnaga/data/twitter-trec2011/timeseries/";
  
  // Generated using:
  // cat 2011.topics.MB1-50.txt | grep title | tr ' ' '\n' | tr '[A-Z]' '[a-z]' | tr -dc
  // '[A-Za-z0-9\n]' | sed 's/.*/"&",/'
  private static Set<String> watchedTerms = Sets.newCopyOnWriteArraySet(Arrays.asList(
      "bbc",
      "world",
      "service",
      "staff",
      "cuts",
      
      "2022",
      "fifa",
      "soccer",
      
      "haiti",
      "aristide",
      "return",
      
      "mexico",
      "drug",
      "war",
      
      "nist",
      "computer",
      "security",
      
      "nsa",
      
      "pakistan",
      "diplomat",
      "arrest",
      "murder",
      
      "phone",
      "hacking",
      "british",
      "politicians",
      
      "toyota",
      "recall",
      
      "egyptian",
      "protesters",
      "attack",
      "museum",
      
      "kubica",
      "crash",
      
      "assange",
      "nobel",
      "peace",
      "nomination",
      
      "oprah",
      "winfrey",
      "halfsister",
      // I manually added this
      "half", "sister",
      
      "release",
      "of",
      "the",
      "rite",
      
      "thorpe",
      "return",
      "in",
      "2012",
      "olympics",
      
      "release",
      "of",
      "known",
      "and",
      "unknown",
      
      "white",
      "stripes",
      "breakup",
      
      "william",
      "and",
      "kate",
      "fax",
      "savethedate",
      
      "cuomo",
      "budget",
      "cuts",
      
      "taco",
      "bell",
      "filling",
      "lawsuit",
      
      "emanuel",
      "residency",
      "court",
      "rulings",
      
      "healthcare",
      "law",
      "unconstitutional",
      
      "amtrak",
      "train",
      "service",
      
      "super",
      "bowl",
      "seats",
      
      "tsa",
      "airport",
      "screening",
      
      "us",
      "unemployment",
      
      "reduce",
      "energy",
      "consumption",
      
      "detroit",
      "auto",
      "show",
      
      "global",
      "warming",
      "and",
      "weather",
      
      "keith",
      "olbermann",
      "new",
      "job",
      
      "special",
      "olympics",
      "athletes",
      
      "state",
      "of",
      "the",
      "union",
      
      "and",
      "jobs",
      
      "dog",
      "whisperer",
      "cesar",
      "millans",
      "techniques",
      
      "msnbc",
      "rachel",
      "maddow",
      
      "sargent",
      "shriver",
      "tributes",
      
      "moscow",
      "airport",
      "bombing",
      
      "giffords",
      "recovery",
      
      "protests",
      "in",
      "jordan",
      
      "egyptian",
      "curfew",
      
      "beck",
      "attacks",
      "piven",
      
      "obama",
      "birth",
      "certificate",
      
      "holland",
      "iran",
      "envoy",
      "recall",
      
      "kucinich",
      "olive",
      "pit",
      "lawsuit",
      
      "white",
      "house",
      "spokesman",
      "replaced",
      
      "political",
      "campaigns",
      "and",
      "social",
      "media",
      
      "bottega",
      "veneta",
      
      "organic",
      "farming",
      "requirements",
      
      "egyptian",
      "evacuation",
      
      "carbon",
      "monoxide",
      "law",
      
      "war",
      "prisoners",
      "hatch",
      "act"));
  
  private static int MIN_SUPPORT = 3; // this is relative to the multireader,
  // not the window (if it reads more)
  private static int SAMPLE_ONE_TERM_EVERY = 64;
  private static int IMG_WIDTH = (int) windowLength / 1000;
  private static int IMG_HEIGHT = (int) (IMG_WIDTH * (4.0 / 9.0));
  
  public static void main(String[] args) throws IOException, ParseException {
    // Configuration conf = new Configuration();
    // List<Pair<Long, Path>> inPathList =
    // HourMinutesPathHierarchy.getInputPaths(1295740800000L, 300000L, new
    // Path("/Users/yia/Dropbox/tweets_csv_17hr"));
    // CSVTweetRecordReader csvReader = new CSVTweetRecordReader();
    // csvReader.initialize(new CombineFileSplit(inPathList.toArray(new
    // Path[0]), new Long[]{-1L}), conf);
    
    File indexParent = new File(ixPath);
    List<IndexReader> ixReadersList = Lists.newLinkedList();
    File[] startArr = indexParent.listFiles();
    Arrays.sort(startArr);
    
    long startTime = -1;
    
    for (File startDir : startArr) {
      if (ixReadersList.isEmpty()) {
        startTime = Long.parseLong(startDir.getName());
      }
      File[] endArr = startDir.listFiles();
      Arrays.sort(endArr);
      for (File endDir : endArr) {
        long endTime = Long.parseLong(endDir.getName());
        
        Directory dir = NIOFSDirectory.open(endDir);
        ixReadersList.add(IndexReader.open(dir));
        if (endTime - startTime >= windowLength) {
          final MultiReader ixReader = new MultiReader(
              ixReadersList.toArray(new IndexReader[0]));
          ixReadersList.clear();
          
          IndexSearcher ixSearcher = new IndexSearcher(ixReader);
          // Analyzer tweetNonStemmingAnalyzer = new
          // TwitterAnalyzer();;
          QueryParser twtQparser = new QueryParser(Version.LUCENE_36,
              "text", new WhitespaceAnalyzer(Version.LUCENE_36));
          twtQparser.setDefaultOperator(Operator.OR);
          
          while (startTime < endTime) {
            long winEnd = startTime + windowLength;
            
            Writer wr = null;
            RrdDb rrdb = null;
            RrdDef rrdDef = null;
            
            String outPath = outParent + startTime + "-" + winEnd
                + "_" + runMode.toString();
            switch (runMode) {
            case DUMP1S:
            case DUMPDELTAT:
            case VERTICAL:
              wr = Channels.newWriter(
                  FileUtils.openOutputStream(
                      new File(outPath + ".csv"))
                      .getChannel(), "UTF-8");
              break;
            case RRD4J:
              outPath += ".rrd";
              rrdDef = new RrdDef(outPath,
                  (startTime / 1000) - 1, 1);
              break;
            }
            
            // This reads the field as text.. stupid lucene messes
            // up
            // its
            // index cache when optimizing
            // Sort timeSort = new Sort(new SortField("timestamp",
            // SortField.LONG));
            
            List<String> tList = null;
            if (watchedTerms == null) {
              tList = Lists.newLinkedList();
              TermEnum tEnum = ixReader.terms();
              // .newArrayListWithCapacity((int)
              // ixReader.getUniqueTermCount());
              while (tEnum.next()) {
                Term t = tEnum.term();
                if ("text".equals(t.field())) {
                  String txt = t.text();
                  int hash = Hashing
                      .murmur3_32()
                      .hashString(txt,
                          Charset.forName("UTF-8"))
                      .asInt();
                  // txt.hashCode()
                  if (hash % SAMPLE_ONE_TERM_EVERY == 0
                      && ixReader.docFreq(t) >= MIN_SUPPORT) {
                    tList.add(txt);
                  }
                }
              }
              Collections.sort(tList);
            } else {
              tList = Lists.newCopyOnWriteArrayList(watchedTerms);
            }
            
            switch (runMode) {
            case RRD4J:
            case VERTICAL: {
              Sample rrSample = null;
              if (runMode.equals(RunMode.VERTICAL)) {// && !rHeader) {
                wr.append("\"TIMESTAMP\"");
              }
              
              OpenObjectIntHashMap<String> tIxMap = new OpenObjectIntHashMap<String>();
              
              int ix = 0;
              for (String t : tList) {
                
                tIxMap.put(t, ++ix);
                
                switch (runMode) {
                case VERTICAL: {
                  //This causes the error that there are less columns thancolumn names
//                  if(!rHeader || ix>1){
//                    wr.append(DELIM);
//                  }
//                  wr.append("\"" + t + "\"");
                  //This causes shifting the readings of each column to the previous one
                  wr.append(DELIM+"\"" + t + "\"");
                  // This is the less of evils, as it causes an extra column with all NAs
//                  wr.append((!rHeader?DELIM:"") + "\"" + t + "\"" + (rHeader?DELIM:""));
                  
                  break;
                }
                case RRD4J: {
                  rrdDef.addDatasource(dsNameFromTerm(t),
                      DsType.ABSOLUTE, 300, // unknown if
                      // no
                      // occurrence
                      // in
                      // 5 mins
                      // (endtime - startTime)
                      // / (1000 * MIN_SUPPORT),
                      0, Double.NaN);
                  break;
                }
                }
                
              }
              switch (runMode) {
              case VERTICAL: {
                wr.append("\n");
                
                break;
              }
              case RRD4J: {
                // 0.5 seems to be a magic number.. I'd say 0.99
                // :$
                rrdDef.addArchive(ConsolFun.AVERAGE, 0.5, 1,
                    (int) ((winEnd - startTime) / (1000)));
                // , 60,(int)((winEnd - startTime) / 60000));
                
                rrdb = new RrdDb(rrdDef);
                System.out.println("== RRD file created.");
                if (rrdb.getRrdDef().equals(rrdDef)) {
                  System.out
                      .println("Checking RRD file structure... OK");
                } else {
                  System.out
                      .println("Invalid RRD file created. This is a serious bug, bailing out");
                  return;
                }
                rrdb.close();
                rrdb = new RrdDb(outPath);
                
                System.out
                    .println("== RRD file closed then reponed (God knows why!)");
                rrSample = rrdb.createSample();
                
                break;
              }
              }
              
              // tList.clear();
              // tList = null;
              // List<String> tIxKeys = Lists.newArrayListWithCapacity(tIxMap.size());
              // tIxMap.keysSortedByValue(tIxKeys);
              
              // This messes up the sorting.. has to use a sort with it, and sort doesn't work
              // Query allTweets = twtQparser.parse(tList.toString().replaceAll("[\\,\\[\\]]", ""));
              Query allTweets = twtQparser.parse("*:*");
              
              // Time filter
              NumericRangeFilter<Long> timeFilter = NumericRangeFilter
                  .newLongRange("timestamp", Long.MIN_VALUE,
                      winEnd, true, false);
              TopDocs rs = ixSearcher.search(new FilteredQuery(
                  allTweets, timeFilter), ixReader.numDocs());
              // luckily they come sorted, coz this doesn't work:
              // timeSort);
              
              long epochStart = startTime;
              long epochEnd = epochStart + timeStep;
              
              // No need to keep order since we will pass along the key list
              // Map<String, Integer> counts = Maps.newTreeMap();
              // This causes an endless loop after the first call to clear.. TODO bug report
              // OpenObjectIntHashMap<String> counts = new OpenObjectIntHashMap<String>();
              Map<String, Integer> counts = Maps.newHashMap();
              int misordered = 0;
              SummaryStatistics misorderLag = new SummaryStatistics();
              for (int h = 0; h < rs.totalHits; ++h) {
                long timestamp = Long.parseLong(ixReader
                    .document(rs.scoreDocs[h].doc).get(
                        "timestamp"));
                if (timestamp < epochStart) {
                  System.err
                      .println("Out of order document - epochStart: "
                          + epochStart
                          + " timestamp: "
                          + timestamp);
                  misorderLag.addValue(epochStart - timestamp);
                  ++misordered;
                  if (misordered % 10 == 0) {
                    System.out.println("Misorder lag: " + misorderLag.toString());
                  }
                } else if (timestamp >= epochEnd) {
                  while (timestamp >= epochEnd) {
                    printPendingCounts(counts, wr, epochEnd,
                        rrSample, 
//                        tIxMap, 
                        tList);
                    // lasttime = timestamp;
                    epochStart = epochEnd;
                    epochEnd += timeStep;
                  }
                }
                
                TermFreqVector tfv = ixReader
                    .getTermFreqVector(rs.scoreDocs[h].doc,
                        "text");
                if (tfv == null) {
                  System.err
                      .println("Null Term Frequencies Vector for document"
                          + rs.scoreDocs[h].doc);
                  continue;
                }
                
                String[] docTerms = tfv.getTerms();
                for (String docT : docTerms) {
                  
                  if (!tIxMap.containsKey(docT)) {
                    continue;
                  }
                  if (!counts.containsKey(docT)) {
                    counts.put(docT, 0);
                  }
                  counts.put(docT, counts.get(docT) + 1);
                }
                
                if (wr != null && (h + 1) % 100 == 0) {
                  System.out.println("Flushing 100 docs");
                  wr.flush();
                }
              }
              
              printPendingCounts(counts, wr, epochEnd, rrSample,
//                  tIxMap, 
                  tList);
              System.out.println("Misorder lag: " + misorderLag.toString());
              
              if (runMode.equals(RunMode.RRD4J)) {
                rrdb.close();
                rrdb = new RrdDb(outPath, true);
                System.out
                    .println("File reopen in read-only mode");
                System.out.println("== Last update time was: "
                    + rrdb.getLastUpdateTime());
                System.out.println("== Last info was: "
                    + rrdb.getInfo());
                
                RrdGraphDef gDef = new RrdGraphDef();
                gDef.setWidth(IMG_WIDTH);
                gDef.setHeight(IMG_HEIGHT);
                gDef.setFilename(outPath + ".png");
                gDef.setStartTime(startTime / 1000);
                gDef.setEndTime(winEnd / 1000);
                gDef.setTitle("Frequencies of terms");
                gDef.setVerticalLabel("Frequency");
                
//                List<String> termsSorted = Lists
//                    .newArrayListWithCapacity(tIxMap.size());
//                tIxMap.keysSortedByValue(termsSorted);
                for (String t : tList) {
                  String dsname = dsNameFromTerm(t);
                  gDef.datasource(t, outPath, dsname,
                      ConsolFun.AVERAGE);
                  int red = tIxMap.get(t) % 256;
                  int green = t.hashCode() % 256;
                  int blue = rand.nextInt(256);
                  int color = blue + (green << 8)
                      + (red << 16);
                  gDef.line(t, Color.decode("" + color));
                }
                
                // gDef.gprint("sun", ConsolFun.AVERAGE,
                // "avgSun = %.3f%S\\c");
                
                gDef.setImageInfo("<img src='%s' width='%d' height = '%d'>");
                gDef.setPoolUsed(false);
                gDef.setImageFormat("png");
                System.out.println("Rendering graph "
                    + Util.getLapTime());
                // create graph finally
                RrdGraph graph = new RrdGraph(gDef);
                System.out.println(graph.getRrdGraphInfo()
                    .dump());
                System.out.println("== Graph created "
                    + Util.getLapTime());
                // locks info
                System.out.println("== Locks info ==");
                System.out.println(RrdSafeFileBackend
                    .getLockInfo());
                
              }
              
              break;
              
            }
            case DUMP1S:
            case DUMPDELTAT: {
              // final MutableLong lasttime = new MutableLong(
              // Long.valueOf(startDir.getName()));
              int count = 0;
              for (String t : tList) {
                final Term tTerm = new Term("text", t);
                
                String header = t + " ("
                    + ixReader.docFreq(tTerm) + ") ";
                wr.append(header);
                for (int s = header.length(); s < 30; ++s) {
                  wr.append(' ');
                }
                
                // I don't know what this actually gets me..
                // nonsense
                // TermDocs tDocs = ixReader.termDocs();
                // while(tDocs.next()){
                // int docId = tDocs.doc();
                // Document doc = ixReader.document(docId, new
                // FieldSelector() {
                //
                // @Override
                // public FieldSelectorResult accept(String
                // fieldName) {
                // if("timestamp".equals(fieldName)){
                // return FieldSelectorResult.LOAD;
                // } else {
                // return FieldSelectorResult.NO_LOAD;
                // }
                // }
                // });
                
                Query tQuery = new TermQuery(tTerm);
                NumericRangeFilter<Long> timeFilter = NumericRangeFilter
                    .newLongRange("timestamp",
                        Long.MIN_VALUE, winEnd, true,
                        false);
                
                final Map<Long, Integer> termTimestamps = Maps
                    .newTreeMap();
                ixSearcher.search(new FilteredQuery(tQuery,
                    timeFilter), new Collector() {
                  
                  @Override
                  public void setScorer(Scorer scorer)
                      throws IOException {
                    
                  }
                  
                  int docBase;
                  
                  @Override
                  public void setNextReader(
                      IndexReader reader, int docBase)
                      throws IOException {
                    this.docBase = docBase;
                  }
                  
                  @Override
                  public boolean acceptsDocsOutOfOrder() {
                    return false;
                  }
                  
                  @Override
                  public void collect(int docId)
                      throws IOException {
                    
                    docId += docBase;
                    
                    Document doc = ixReader.document(docId,
                        new FieldSelector() {
                          
                          @Override
                          public FieldSelectorResult accept(
                              String fieldName) {
                            if ("timestamp"
                                .equals(fieldName)) {
                              return FieldSelectorResult.LOAD;
                            } else {
                              return FieldSelectorResult.NO_LOAD;
                            }
                          }
                        });
                    
                    Long timestampt = Long.valueOf(doc
                        .get("timestamp"));
                    if (!termTimestamps
                        .containsKey(timestampt)) {
                      termTimestamps.put(timestampt, 0);
                    }
                    termTimestamps
                        .put(timestampt, termTimestamps
                            .get(timestampt) + 1);
                  }
                });
                
                long lasttime = startTime;
                for (Long timestampt : termTimestamps.keySet()) {
                  if (lasttime > timestampt) {
                    System.err
                        .println("Wrong document order for term "
                            + tTerm.text()
                            + " lasttime: "
                            + lasttime
                            + " timestamp: "
                            + timestampt);
                    continue;
                  }
                  switch (runMode) {
                  case DUMP1S:
                    while (lasttime < timestampt) {
                      wr.append('.');
                      lasttime += 1000;
                    }
                    wr.append(""
                        + termTimestamps
                            .get(timestampt)); // / (writeUnixTime?1000:1));
                    break;
                  case DUMPDELTAT:
                    for (int c = 0; c < termTimestamps
                        .get(timestampt); ++c) {
                      wr.append(","
                          + (timestampt - lasttime)
                          / 1000);
                      lasttime = timestampt;
                    }
                    break;
                  
                  }
                }
                
                if (runMode.equals(RunMode.DUMPDELTAT)) {
                  // this last number is the length of time
                  // waited
                  // WITHOUT an occurrence at the end
                  wr.append("," + (winEnd - lasttime) / 1000);
                }
                
                if (wr != null) {
                  wr.append('\n');
                  
                  if (++count % 100 == 0) {
                    System.out
                        .println("Flushing a 100 terms");
                    wr.flush();
                  }
                }
              }
            }
            }
            if (wr != null) {
              wr.flush();
              wr.close();
            }
            if (runMode.equals(RunMode.RRD4J)) {
              FileUtils.deleteQuietly(new File(outPath));
            }
            startTime += windowLength;
          }
          ixReader.close();
        }
      }
    }
    
  }
  
  private static String dsNameFromTerm(String t) {
    String dsname = t;
    if (dsname.length() > 20) { // RrdPrimitive.STRING_LENGTH)
      dsname = dsname.substring(0, 20 - 1);
      dsname += ".";
    }
    return dsname;
  }
  
  private static void printPendingCounts(Map<String, Integer> counts,
      Writer wr, long time, Sample rrSample,
//      OpenObjectIntHashMap<String> tIxMap, 
      List<String> tIxKeys) throws IOException {
    switch (runMode) {
    case VERTICAL: {
      if (writeUnixTime) {
        time /= 1000;
      }
      wr.append(time + ""); // + DELIM);
      if (counts.isEmpty() && !fillZeros) {
        return;
      }
      for (String t : tIxKeys) {
        String cntStr;
        // int cnt = counts.get(t);
        
        // if (!fillZeros && cnt == 0) {
        // cntStr = "";
        // } else {
        // cntStr = cnt + "";
        // }
        if (counts.containsKey(t)) {
          cntStr = counts.get(t) + "";
        } else {
          if (fillZeros) {
            cntStr = "0";
          } else {
            cntStr = "";
          }
        }
        wr.append(DELIM +cntStr);
      }
      wr.append('\n');
      
      break;
    }
    case RRD4J: {
      if (counts.isEmpty()) {
        return;
      }
      rrSample.setTime(time / 1000);
      
      for (String t : tIxKeys) {
        rrSample.setValue(dsNameFromTerm(t), counts.get(t));
      }
      
      rrSample.update();
      break;
    }
    }
    counts.clear();
  }
}
