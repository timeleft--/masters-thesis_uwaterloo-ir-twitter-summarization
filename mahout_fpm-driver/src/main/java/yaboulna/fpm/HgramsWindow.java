package yaboulna.fpm;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintStream;
import java.lang.management.ManagementFactory;
import java.lang.management.ThreadMXBean;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Formatter;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.apache.commons.io.output.FileWriterWithEncoding;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.Text;
import org.apache.mahout.common.Pair;
import org.apache.mahout.fpm.pfpgrowth.convertors.ContextStatusUpdater;
import org.apache.mahout.fpm.pfpgrowth.convertors.SequenceFileOutputCollector;
import org.apache.mahout.fpm.pfpgrowth.convertors.string.StringOutputConverter;
import org.apache.mahout.fpm.pfpgrowth.convertors.string.TopKStringPatterns;
import org.apache.mahout.fpm.pfpgrowth.fpgrowth.FPGrowth;
import org.joda.time.DateMidnight;
import org.joda.time.DateTimeZone;
import org.joda.time.MutableDateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import yaboulna.fpm.postgresql.HgramTransactionIterator;
import yaboulna.fpm.postgresql.PerfMonKeyValueStore;

import com.google.common.base.Charsets;
import com.google.common.base.Joiner;
import com.google.common.collect.BiMap;
import com.google.common.collect.HashBiMap;
import com.google.common.collect.Lists;
import com.google.common.io.Closeables;
import com.google.common.io.Closer;

public class HgramsWindow {
  private static Logger LOG = LoggerFactory.getLogger(HgramsWindow.class);

  protected static final DateTimeFormatter dateFmt = DateTimeFormat.forPattern("yyMMdd");
  private static final boolean HALT_IF_OUT_PATH_EXISTS = false;
  private static final boolean SKIP_EXISTING_OUTPUT = true;
  private static final int TOPIC_WORDS_PER_MINUTE = 100;
  private static final int FREQUENT_PATTERNS_PER_MINUTE = 1;

  private static boolean USE_RELIABLE_ALGO;

  /**
   * 
   * @param args
   *          windowStartUx (1352260800 for wining hour 1352199600 for elections day, 1349085600 for oct 1st 2012 5am)
   *          windowEndUx (1352264400 for end of winning hour 1352286000 for end of elections day, 1357038000 jan1,13)
   *          path of output
   *          epochStep for example 28800/3600 for an 8 hour window with 1 hour steps, 2419200/604800 4wk/1wk
   *          [cmd] absolute path to the command to use, or mahout to fall back to its unreliable slow implementation
   *          [minSupp/support] The minimum support, that is the absolute support desired at the trough of the day volume,
   *          has to be preceeded by a > for example, >5. An absolute support, for example 3360 will be used as is.
   *          [ogramlen] defaults to 5
   *          [weightTweetsByAge] if anything but false this will turn on the weighting of tweets (for use with lcm5)
   *          [all/sel] all (default) is the only recognized word and otherwise only selected features
   *          [historyDays] defaults to 30
   * @throws Exception 
   */
  public static void main(String[] args) throws Exception {

    long windowStartUx = Long.parseLong(args[0]);

    long windowEndUx = Long.parseLong(args[1]);

    Path outRoot = new Path(args[2]);
    Configuration conf = new Configuration();
    FileSystem fs = FileSystem.get(outRoot.toUri(), conf);

    LOG.info("outroot:" + outRoot.toUri());
    if (fs.exists(outRoot)) {
      if (HALT_IF_OUT_PATH_EXISTS) {
        throw new IllegalArgumentException("Output path already exists.. remove it yourself: "
            + outRoot.toUri());
      } else {
        if (!SKIP_EXISTING_OUTPUT) {
          fs.delete(outRoot, true);
        }
      }
    }

    String[] epochStep = args[3].split("/");
    int epochLen = Integer.parseInt(epochStep[0]);
    int stepSec = Integer.parseInt(epochStep[1]);

    if (epochLen < 3600) {
      LOG.info("I am always using the counts and history from 1hr tables, so " +
          " the counts of the whole hour will used if the window starts at a fraction of an hour");
    }

// int epochLen = 3600;
//
// if (args[3].equals("1day")) {
// epochLen = 3600 * 24;
// LOG.info("epoch: 1 day");
// } else if (args[3].equals("1hr")) {
// epochLen = 3600;
// LOG.info("epoch: 1hr");
// } else if (args[3].equals("5min")) {
// epochLen = 300;
// LOG.info("epoch: 5min");
// LOG.info("I am always using the counts and history from 1hr tables, so " +
// " the counts of the whole hour will used if the window starts at a fraction of an hour");
// }

    USE_RELIABLE_ALGO = true;
    String fimiExe;
    if (args.length > 4) {
      if (args[4].equals("mahout")) {
        LOG.info("Using mahout implementation");
        USE_RELIABLE_ALGO = false;
        fimiExe = null;
      } else {
        USE_RELIABLE_ALGO = true;
        fimiExe = args[4];
      }
    } else {
      fimiExe = "/home/yaboulna/fimi/fp-zhu/fim_closed";
    }

    int minSupp = 5;
    double suppPct = 0.0001; // when multiplied by the volume gives at least 5 (at the trough of the day)
    int support = -1;
    boolean relSupp = false;
    if (args.length > 5) {
      if (args[5].charAt(0) == '>') {
        minSupp = Integer.parseInt(args[5].substring(1));
        suppPct = minSupp * 0.0001 / 5;
        relSupp = true;
      } else {
        minSupp = -1;
        suppPct = -1;
        support = Integer.parseInt(args[5]);
      }
    }

    int ogramLen = 5;
    if (args.length > 6) {
      ogramLen = Integer.parseInt(args[6]);
    }

    boolean weightTweetsByAge = false;
    if (args.length > 7 && !args[7].equals("false")) {
      weightTweetsByAge = true;
    }

    boolean stdUnigrams = false;
    if (args.length > 8 && !args[8].equals("all")) {
      LOG.info("Generating the frequent patterns associated with all ograms");
      stdUnigrams = true;
    }

    int historyDaysCnt = 30;
    if (args.length > 9) {
      historyDaysCnt = Integer.parseInt(args[9]);
    }

    File tmpDir = new File("/home/yaboulna/tmp/");
    if (args.length > 10) {
      tmpDir = new File(args[10]);
    }

    DateMidnight startDayOfTopicWords = new DateMidnight(0L);
    DateMidnight endDayOfTopicWords = new DateMidnight(0L);
    Set<String> topicWords = null;

    for (; windowStartUx < windowEndUx; windowStartUx += stepSec) {
      LOG.info("Strting Mining period from: {} to {}", windowStartUx, windowStartUx + epochLen);
      Path epochOut = new Path(outRoot, "fp_" + epochLen + "_" + windowStartUx);
      if (fs.exists(epochOut)) {
        if (SKIP_EXISTING_OUTPUT) {
          LOG.info("Done mining period from: {} to {}.. output already exists", windowStartUx, windowStartUx + epochLen);
          continue;
        } else {
          LOG.error("Shouldn't be possible to be at this line of code: HALT and SKIP should work better togeher");
        }
      }

      DateMidnight startDay = new DateMidnight(windowStartUx * 1000, DateTimeZone.forID("HST"));
      // TODONE: Do we need the days to be all the days of the mined period, or just the sliding step. Do we cheat?
      // If we need to cheat, I will have to change this back:
// DateMidnight endDay = new DateMidnight(windowEndUx * 1000, DateTimeZone.forID("HST"));
      DateMidnight endDay = new DateMidnight((windowStartUx + epochLen) * 1000, DateTimeZone.forID("HST"));

      List<String> days = Lists.newLinkedList();
      MutableDateTime currDay = new MutableDateTime(startDay);
      while (!currDay.isAfter(endDay)) {
        days.add(dateFmt.print(currDay));
        currDay.addDays(1);
      }

      LOG.info("Days: " + days);

      HgramTransactionIterator transIter = new HgramTransactionIterator(days, windowStartUx,
          windowStartUx + epochLen, ogramLen);
      HgramTransactionIterator transIter2 = new HgramTransactionIterator(days, windowStartUx,
          windowStartUx + epochLen, ogramLen);

      try {
        transIter.init();
        transIter2.init();

        if (relSupp) {
          support = Math.max(3, transIter.getAbsSupport(suppPct));
        }
        int maxNumIdsToWriteOut = 200000 * support; // To avoid writing out ids for language itemsets FIXME: 2 is arbitrary
        LOG.info("Window support: {}", support);

        if (stdUnigrams
            // // TODO cache the "with hist table" and stop cheating (by looking in the future through using windowEndUx)
            && (startDayOfTopicWords.isAfter(startDay)
            || endDayOfTopicWords.isBefore(endDay))) {

          startDayOfTopicWords = startDay; // avoids recalculating the same
          endDayOfTopicWords = endDay;

          MutableDateTime histDay1 = new MutableDateTime(startDay);

          histDay1.addDays(-historyDaysCnt);

// topicWords = transIter.getTopicWords(TOPIC_WORDS_PER_MINUTE * (epochLen / 60),
// dateFmt.print(histDay1));
          HgramTransactionIterator transIter3 = new HgramTransactionIterator(days, windowStartUx,
              // TO cheat or not to cheat, that is no question
              windowStartUx + epochLen, ogramLen);
// windowEndUx, ogramLen);
          try {
            transIter3.init();
            topicWords = transIter3.getTopicWords(
                (int) (TOPIC_WORDS_PER_MINUTE * ((windowEndUx - windowStartUx) / 60)),
                dateFmt.print(histDay1));
          } finally {
            transIter3.uninit();
          }

        }

        if (USE_RELIABLE_ALGO) {

          if (stdUnigrams) {
            transIter.setTopicUnigrams(topicWords);
          }

          File epochOutLocal = new File(epochOut.toUri().toString().substring("file:".length())
              + ".out");
          epochOutLocal.getParentFile().mkdirs();

          File tmpFile = File.createTempFile("fimi", "transactions", tmpDir);
          tmpFile.deleteOnExit();

          ArrayList<Long> tweetIds = Lists.newArrayListWithExpectedSize(100000 * (epochLen / 3600));
// int tweetIdIx = 0;

          PrintStream feeder = new PrintStream(new FileOutputStream(tmpFile), true, "US-ASCII");

          BiMap<String, Integer> tokenIdMapping = HashBiMap.create();
          try {
            // TODONE: Can we make use of the negative numbers to indicate (to ourselves) what heads are interesting
            // NO, because the the names are used as array indexes, e.g: order[Trans->t[j]
            int i = 1; // We used OpenIntHashMap whose get() returns 0 for items that are not contained
            while (transIter.hasNext()) {
              Pair<List<String>, Long> trans = transIter.next();
              if (transIter.getRowsRead() % (100000.0 * epochLen / 3600.0) == 0) {
                LOG.info("Read {} into the temp file {}. Last trans: " + trans.toString(),
                    transIter.getRowsRead(), tmpFile.getAbsolutePath().toString());
              }
              for (String item : trans.getFirst()) {
                Integer id = tokenIdMapping.get(item);
                if (id == null) {
                  id = i++; // TODO: use murmur chat and check for collisions, iff maintaining the same id across epochs

                  tokenIdMapping.put(item, id);
                }
                feeder.print(id + " ");
              }
              feeder.print("\n");
              tweetIds.add(trans.getSecond()); // tweetIdIx++,
            }
          } finally {
            feeder.flush();
            feeder.close();
          }
          LOG.info("Read {} into the temp file {} (now flushed).", transIter.getRowsRead(), tmpFile
              .getAbsolutePath().toString());

          String cmd = fimiExe;
          if (weightTweetsByAge) {
            File weightsFile = File.createTempFile("fimiLcm", "tweetWeights", tmpDir);
            weightsFile.deleteOnExit();
            Closer weightClose = Closer.create();
            try {
              Formatter weightFormat = weightClose.register(new Formatter(weightsFile, Charsets.UTF_8.name()));
              long[] weightDecreaseMarkers = {3600 * 8, // this will get a weight of 0.8, and lower -0.2
                  3600 * 25, // 24 for a day and 1 hour that would be the same hour as now so we bias towards it
                  3600 * 24 * 8, // a week and 1 day that we also leave at higher weight since it is like today
                  3600 * 24 * 28 // 4 weeks.. anything more that this is very very old.. we will give it a weigh 0.2
              };

              int m = 0;
              double currWeight = 1.0;
              while (true) {
                if (epochLen <= weightDecreaseMarkers[m]
                    || m == weightDecreaseMarkers.length - 1) {
                  break;
                }

                currWeight -= 1.0 / (weightDecreaseMarkers.length + 1);
                ++m;
              }

              long nexMarkerId = snowFlakeAtUxtime(windowStartUx + epochLen - weightDecreaseMarkers[m--]);
              for (long tweetId : tweetIds) {
                if (currWeight < 1 && tweetId >= nexMarkerId) {
                  nexMarkerId = snowFlakeAtUxtime(windowStartUx + epochLen - weightDecreaseMarkers[m--]);
                  currWeight += 1.0 / (weightDecreaseMarkers.length + 1);
                }
                weightFormat.format("%.1f\n", currWeight);
              }
            } finally {
              weightClose.close();
            }
            cmd += " -w " + weightsFile.getAbsolutePath();
          }

          cmd += " " + tmpFile.getAbsolutePath()
              + " " + support + " " + epochOutLocal;

          final String finalCmd = cmd;

          LOG.info("Executing command: " + cmd);

          class CmdRunnable implements Runnable {
            Process proc;
            Exception error = null;
            @Override
            public void run() {
              Runtime rt = Runtime.getRuntime();
              try {
                proc = rt.exec(finalCmd);
              } catch (IOException e) {
                error = e;
              }
            }
          };
          CmdRunnable cmdRunnable = new CmdRunnable();
          Thread cmdThread = new Thread(cmdRunnable);
          cmdThread.start();

          Process proc = cmdRunnable.proc;
          while(proc == null){
            Thread.sleep(1000);
            proc = cmdRunnable.proc;
          }
          if(cmdRunnable.error != null){
            throw cmdRunnable.error;
          }

          LOG.info("Piping to output and error from the command to stdout and stderr");
          ExecutorService executor = Executors.newFixedThreadPool(2);

          HgramTransactionIterator.StreamPipe outPipe = new HgramTransactionIterator.StreamPipe(
              proc.getInputStream(),
              System.out);
          Future<Void> outFut = executor.submit(outPipe);

          HgramTransactionIterator.StreamPipe errPipe = new HgramTransactionIterator.StreamPipe(
              proc.getErrorStream(),
              System.err);
          Future<Void> errFut = executor.submit(errPipe);

          try {
            errFut.get();
            outFut.get();
          } catch (InterruptedException e) {
            e.printStackTrace();
          } catch (ExecutionException e) {
            e.printStackTrace();
          }

          executor.shutdown();

          File epochOutText = new File(epochOut.toUri().toString().substring("file:".length()) + "_supp" + support);

          if (!epochOutLocal.exists()) {
            LOG.info("The output file {} doesn't exist. Done mining epoch with no result.",
                epochOutLocal.getAbsolutePath());
            continue;
          }

          LOG.info("Translating the output file {} into {}", epochOutLocal.getAbsolutePath(),
              epochOutText.getAbsolutePath());

          BufferedReader decodeReader = new BufferedReader(new FileReader(epochOutLocal));
          FileWriterWithEncoding decodeWriter = new FileWriterWithEncoding(epochOutText,
              Charset.forName("UTF-8"));
          try {
            int lnNum = 0;
            String ln;
            BiMap<Integer, String> decodeMap = tokenIdMapping.inverse();
            List<String> distinctSortedTokens = Lists.newLinkedList();
            List<String> hashtags = Lists.newLinkedList();
            StringBuilder tokenBuilder = new StringBuilder();
            Joiner commaJoiner = Joiner.on(',');
            boolean pendingEndLn = false;
            while ((ln = decodeReader.readLine()) != null && !ln.isEmpty()) {
              ++lnNum;
              distinctSortedTokens.clear();
              hashtags.clear();
              if (lnNum % 10000 == 0) {
                LOG.info("Translated {} frequent itemsets, but didn't flush yet", lnNum);
              }

              if (ln.charAt(0) == ' ') {
                if (lnNum == 1) {
                  ln = ln.substring(1);
                } else {
                  if (pendingEndLn) {
                    // this is the transaction ids from lcm
                    String[] ids = ln.substring(1).split(" ");
                    if (ids.length <= maxNumIdsToWriteOut) {
                      decodeWriter.write("\t" + tweetIds.get(Integer.parseInt(ids[0])));
                      for (int d = 1; d < ids.length; ++d) {
                        decodeWriter.write("," + tweetIds.get(Integer.parseInt(ids[d])));
                      }
                    }

                    decodeWriter.write("\n");
                    pendingEndLn = false;
                  }
                  // Not pending endln but still needs to be skipped, because prev line was len == 2
                  continue;
                }
              } else if (pendingEndLn) {
                decodeWriter.write("\n");
                pendingEndLn = false;
              }

              String[] codes = ln.split(" ");
// if (codes.length == 2) {
// // only the ogram and its frequency
// continue;
// }
              int c;
              for (c = 0; c < codes.length - 1; ++c) {
                String item = decodeMap.get(Integer.parseInt(codes[c]));
                if (item.charAt(0) == '#') {
                  hashtags.add(item);
                  continue;
                }
                // there will be two brackets if the item is not a hashtag
                char[] itemChars = item.toCharArray();
                // the first char is always a bracket
                for (int x = 1; x < itemChars.length; ++x) {
                  if (itemChars[x] == ','
                      // the last char will be a bracket so we won't add it but will know that we have reached the end
                      || x == itemChars.length - 1) {

                    String token = tokenBuilder.toString();
                    tokenBuilder.setLength(0);

                    // Insertion sort of the itemset lexicographically
                    int tokenIx = 0;
                    for (String sortedToken : distinctSortedTokens) {
                      int compRes = sortedToken.compareTo(token);
                      if (compRes > 0) {
                        break;
                      } else if (compRes == 0) {
                        tokenIx = -1;
                        break;
                      }
                      ++tokenIx;
                    }
                    if (tokenIx >= 0) {
                      distinctSortedTokens.add(tokenIx, token);
                    }

                  } else {
                    tokenBuilder.append(itemChars[x]);
                  }

                }
              }
              for (String htag : hashtags) {
                int htagIx = distinctSortedTokens.indexOf(htag.substring(1));
                if (htagIx == -1) {
                  distinctSortedTokens.add(htag);
                } else {
                  // TODONE: else, should we replace the naked hashtag with the original one (think #obama obama :( )
                  distinctSortedTokens.remove(htagIx);
                  distinctSortedTokens.add(htagIx, htag);
                }

              }
// if (distinctSortedTokens.size() != 1) { // 0 is good, becuase it is the number of Tweets

              decodeWriter.write((distinctSortedTokens.size() == 0 ? "NUMTWEETS" :
                  commaJoiner.join(distinctSortedTokens)) + "\t"
                  + codes[c].substring(0, codes[c].length() - 1).substring(1));

              pendingEndLn = true; // distinctSortedTokens.size() != 1;
// will be written only after making sure there aren't transaction ids for this itemset: + "\n");

            }

          } finally {
            decodeReader.close();
            decodeWriter.flush();
            decodeWriter.close();
          }

          LOG.info("Translated the output file {} into {} and flushed, deleteing the original",
              epochOutLocal.getAbsolutePath(), epochOutText.getAbsolutePath());
          epochOutLocal.delete();

          long cmdCPUTime = -1;
          if (cmdRunnable.error == null) {
            ThreadMXBean tmxb = ManagementFactory.getThreadMXBean();
            cmdCPUTime = tmxb.getThreadCpuTime(cmdThread.getId());
            LOG.info("The cmd " + finalCmd + " executed in {} nanosecs = {}", cmdCPUTime, cmdCPUTime / 1e9);
          } else {
            LOG.error("Error while executing cmd: " + cmdRunnable.error);
          }

          Closer closer = Closer.create();
          try {
            PerfMonKeyValueStore perfMonKV = closer.register(new PerfMonKeyValueStore(HgramsWindow.class.getName(),
                Arrays.toString(args)));
            perfMonKV.storeKeyValue("TweetsVolume", transIter.getRowsRead());
            perfMonKV.storeKeyValue("TweetsSkipped", transIter.getRowsSkipped());
            perfMonKV.storeKeyValue("TweetsNet", (transIter.getRowsRead() - transIter.getRowsSkipped()));
            perfMonKV.storeKeyValue("DistinctTerms", tokenIdMapping.size());
            perfMonKV.storeKeyValue("CPUNanosMining", cmdCPUTime);
// perfMonKV.storeKeyValue("CPUSecsMining", "" + (cmdCPUTime / 1e9));
          } finally {
            closer.close();
          }

// File perfFile = new File(HgramsWindow.class.getName() + "_" + Joiner.on("_").join(args) + ".perf");
// Files
// .append(HgramsWindow.class.getName() + "=\"" + Arrays.toString(args) + "\"", perfFile, Charsets.US_ASCII);
// Files.append("RowsRead=" + transIter.getRowsRead(), perfFile, Charsets.US_ASCII);
// Files.append("RowsSkipped=" + transIter.getRowsSkipped(), perfFile, Charsets.US_ASCII);
// Files
// .append("RowsNet=" + (transIter.getRowsRead() - transIter.getRowsSkipped()), perfFile, Charsets.US_ASCII);
// Files.append("CPUNanosMining=" + cmdCPUTime, perfFile, Charsets.US_ASCII);
// Files.append("CPUSecsMining=" + (cmdCPUTime / 1e9), perfFile, Charsets.US_ASCII);

        } else { // if (!USE_RELIABLE_ALGO || stdUnigrams)

          SequenceFile.Writer writer = new SequenceFile.Writer(fs, conf, epochOut, Text.class,
              TopKStringPatterns.class);
          try {
            FPGrowth<String> fp = new FPGrowth<String>();

            fp.generateTopKFrequentPatterns(
                transIter,
                fp.generateFList(transIter2, support),
                support,
                FREQUENT_PATTERNS_PER_MINUTE * (epochLen / 60),
                topicWords,
                new StringOutputConverter(
                    new SequenceFileOutputCollector<Text, TopKStringPatterns>(
                        writer)),
                new ContextStatusUpdater(null));

          } finally {
            Closeables.closeQuietly(writer);
          }

        }

      } finally {

        transIter.uninit();
        transIter2.uninit();
      }
      LOG.info("Done Mining period from: {} to {}", windowStartUx, windowStartUx + epochLen);
// windowStartUx += stepSec;
    }
  }
  private static long snowFlakeAtUxtime(long uxTime) {
    long msecs = 0;
    return (((uxTime * 1000L + msecs) - 1288834974657L) << 22); // TWEET_EPOCH_MAGIC_NUM
  }
}
