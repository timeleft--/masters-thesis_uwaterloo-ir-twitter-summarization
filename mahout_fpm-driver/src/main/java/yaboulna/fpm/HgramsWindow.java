package yaboulna.fpm;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.charset.Charset;
import java.sql.SQLException;
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
import org.apache.mahout.math.map.OpenIntObjectHashMap;
import org.apache.mahout.math.map.OpenObjectIntHashMap;
import org.joda.time.DateMidnight;
import org.joda.time.DateTimeZone;
import org.joda.time.MutableDateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import yaboulna.fpm.postgresql.HgramTransactionIterator;

import com.google.common.collect.Lists;
import com.google.common.io.Closeables;

public class HgramsWindow {
  private static Logger LOG = LoggerFactory.getLogger(HgramsWindow.class);

  protected static final DateTimeFormatter dateFmt = DateTimeFormat.forPattern("yyMMdd");
  private static final boolean REMOVE_OUTPUT_AUTOMATICALLY = false;
  private static final int TOPIC_WORDS_PER_MINUTE = 100;
  private static final int FREQUENT_PATTERNS_PER_MINUTE = 1;

  private static boolean USE_RELIABLE_ALGO;

  /**
   * java -cp target/mahout_fpm-driver-0.0.1-SNAPSHOT.jar yaboulna.fpm.HgramsWindow 1352199600 1352286000 file:///home/yaboulna/fim_out/debug 3600/3600 all ../fp-zhu/fim_closed 2
   * @param args
   *          windowStartUx (1352260800 for wining hour 1352199600 for elections day)
   *          windowEndUx (1352264400 for end of winning hour 1352286000 for end of elections day)
   *          path of output
   *          epochStep for example 28800/3600 for an 8 hour window with 1 hour steps
   *          all/sel all is the only recognized word and otherwise only selected features
   *          algo mahout or path to the compiled executable of fp_zhu
   *          [hgramlen]
   *          [minSupp]
   *          [historyDays]
   * @throws IOException
   * @throws SQLException
   * @throws ClassNotFoundException
   */
  public static void main(String[] args) throws IOException, SQLException, ClassNotFoundException {

    long windowStartUx = Long.parseLong(args[0]);

    long windowEndUx = Long.parseLong(args[1]);

    Path outRoot = new Path(args[2]);
    Configuration conf = new Configuration();
    FileSystem fs = FileSystem.get(outRoot.toUri(), conf);

    LOG.info("outroot:" + outRoot.toUri());
    if (fs.exists(outRoot)) {
      if (REMOVE_OUTPUT_AUTOMATICALLY) {
        fs.delete(outRoot, true);
      } else {
        throw new IllegalArgumentException("Output path already exists.. remove it yourself: "
            + outRoot.toUri());
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

    boolean stdUnigrams = true;
    if (args[4].equals("all")) {
      LOG.info("Generatint the frequent patterns associated with all hgrams");
      stdUnigrams = false;
    } else {
// LOG.info("Using mahout implementation because it supports selection of head items");
    }

    String fpZhuExe = null;
    if (args[5].equals("mahout")) {
      LOG.info("Using mahout implementation");
      USE_RELIABLE_ALGO = false;
    } else {
      USE_RELIABLE_ALGO = true;
      fpZhuExe = args[5];// "fim_closed""fim_maximal";
    }

    int hgramLen = 3;
    if (args.length > 6) {
      hgramLen = Integer.parseInt(args[6]);
    }

    int minSupport = 5;
    if (args.length > 7) {
      minSupport = Integer.parseInt(args[7]);
    }

    int historyDaysCnt = 30;
    if (args.length > 8) {
      historyDaysCnt = Integer.parseInt(args[8]);
    }

    DateMidnight startDayOfTopicWords = new DateMidnight(0L);
    DateMidnight endDayOfTopicWords = new DateMidnight(0L);
    Set<String> topicWords = null;

    while (windowStartUx < windowEndUx) {
      LOG.info("Strting Mining period from: {} to {}", windowStartUx, windowStartUx + epochLen);

      DateMidnight startDay = new DateMidnight(windowStartUx * 1000, DateTimeZone.forID("HST"));
      DateMidnight endDay = new DateMidnight(windowEndUx * 1000, DateTimeZone.forID("HST"));

      List<String> days = Lists.newLinkedList();
      MutableDateTime currDay = new MutableDateTime(startDay);
      while (!currDay.isAfter(endDay)) {
        days.add(dateFmt.print(currDay));
        currDay.addDays(1);
      }

      LOG.info("Days: " + days);

      Path epochOut = new Path(outRoot, "fp_" + epochLen + "_" + windowStartUx);

      // TODO: 2 should be replaced by the maximum hgram length
      HgramTransactionIterator transIter = new HgramTransactionIterator(days, windowStartUx,
          windowStartUx + epochLen, hgramLen);
      HgramTransactionIterator transIter2 = new HgramTransactionIterator(days, windowStartUx,
          windowStartUx + epochLen, hgramLen);

      try {
        transIter.init();
        transIter2.init();

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
              windowEndUx, hgramLen);
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

          File epochCooccursLocal = new File(outRoot.toUri().toString().substring("file:".length()), "cooccurs_" + epochLen
              + "_" + windowStartUx);

          File tempDir = new File(outRoot.toUri().toString().substring("file:".length()),"tmp");
          tempDir.mkdirs();
          
          File tmpFile = File.createTempFile("fpzhu", "trans", tempDir);
          tmpFile.deleteOnExit();

          String cmd = fpZhuExe + " " + tmpFile.getAbsolutePath()
              + " "
              + minSupport + " "
              + epochOutLocal + " "
              + epochCooccursLocal;

          PrintStream feeder = new PrintStream(new FileOutputStream(tmpFile), true, "US-ASCII");

          OpenObjectIntHashMap<String> itemIds = new OpenObjectIntHashMap<String>();
          OpenIntObjectHashMap<String> decodeMap = new OpenIntObjectHashMap<String>();
          try {
            // TODO: Can we make use of the negative numbers to indicate (to ourselves) what heads are interesting
            int i = 1; // get() returns 0 for items that are not contained

            while (transIter.hasNext()) {
              Pair<List<String>, Long> trans = transIter.next();
              if (transIter.getRowsRead() % 10000 == 0) {
                LOG.info("Read {} into the temp file {}. Last trans: " + trans.toString(),
                    transIter.getRowsRead(), tmpFile.getAbsolutePath().toString());
              }
              for (String item : trans.getFirst()) {
                int id = itemIds.get(item);
                if (id == 0) {
                  id = i++; // TODO: use murmur chat and check for collisions, iff maintaining the same id across epochs

                  itemIds.put(item, id);
                  decodeMap.put(id, item);
                }
                feeder.print(id + " ");
              }
              feeder.print("\n");
            }
          } finally {
            feeder.flush();
            feeder.close();
          }
          LOG.info("Read {} into the temp file {} (now flushed).", transIter.getRowsRead(), tmpFile
              .getAbsolutePath().toString());

          Runtime rt = Runtime.getRuntime();

          LOG.info("Executing command: " + cmd);
          Process proc = rt.exec(cmd);

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

          File epochOutText = new File(epochOut.toUri().toString().substring("file:".length()));

          //TODO translate epochCooccursLocal as well
          LOG.info("Translating the output file {} into {}", epochOutLocal.getAbsolutePath(),
              epochOutText.getAbsolutePath());

          BufferedReader decodeReader = new BufferedReader(new FileReader(epochOutLocal));
          FileWriterWithEncoding decodeWriter = new FileWriterWithEncoding(epochOutText,
              Charset.forName("UTF-8"));
          try {
            int lnNum = 0;
            String ln;
            while ((ln = decodeReader.readLine()) != null) {
              ++lnNum;
              if (lnNum % 10000 == 0) {
                LOG.info("Translated {} frequent itemsets, but didn't flush yet", lnNum);
              }

              String[] codes = ln.split(" ");
              if (codes.length == 2) {
                // only the hgram and its frequency
                continue;
              }
              int c;
              for (c = 0; c < codes.length - 1; ++c) {
                decodeWriter.write(decodeMap.get(Integer.parseInt(codes[c])) + " ");
              }
              decodeWriter.write("\t" + codes[c].substring(0, codes[c].length() - 1).substring(1)
                  + "\n");

            }
          } finally {
            decodeReader.close();
            decodeWriter.flush();
            decodeWriter.close();
          }

          LOG.info("Translated the output file {} into {} and flushed, deleteing the original",
              epochOutLocal.getAbsolutePath(), epochOutText.getAbsolutePath());
          epochOutLocal.delete();

        } else { // if (!USE_RELIABLE_ALGO || stdUnigrams)

          SequenceFile.Writer writer = new SequenceFile.Writer(fs, conf, epochOut, Text.class,
              TopKStringPatterns.class);
          try {
            FPGrowth<String> fp = new FPGrowth<String>();

            fp.generateTopKFrequentPatterns(
                transIter,
                fp.generateFList(transIter2, minSupport),
                minSupport,
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
      windowStartUx += stepSec;
    }
  }
}
