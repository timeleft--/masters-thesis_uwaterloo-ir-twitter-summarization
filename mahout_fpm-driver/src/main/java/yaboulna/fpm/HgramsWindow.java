package yaboulna.fpm;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Set;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.Text;
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

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import com.google.common.io.Closeables;

public class HgramsWindow {
  private static Logger LOG =  LoggerFactory.getLogger(HgramsWindow.class);

  protected static final DateTimeFormatter dateFmt = DateTimeFormat.forPattern("yyMMdd");
  private static final boolean REMOVE_OUTPUT_AUTOMATICALLY = false;
  private static final int TOPIC_WORDS_PER_MINUTE = 100;
  private static final int FREQUENT_PATTERNS_PER_MINUTE = 1;

  /**
   * 
   * @param args windowStartUx (1352260800 for wining hour 1352199600 for elections day)
   *              windowEndUx (1352264400 for end of winning hour 1352286000 for end of elections day)
   *              path of output
   *              epochName
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

    if (fs.exists(outRoot)) {
      if (REMOVE_OUTPUT_AUTOMATICALLY) {
        fs.delete(outRoot, true);
      } else {
        throw new IllegalArgumentException("Output path already exists.. remove it yourself: "
            + outRoot.toUri());
      }
    }

    int epochLen = 3600;
    
    if (args[3].equals("1day")) {
      epochLen = 3600 * 24;
    } else if (args[3].equals("1hr")) {
      epochLen = 3600;
    } else if (args[3].equals("5min")) {
      epochLen = 300;
      LOG.info("I am always using the counts and history from 1hr tables, so " +
      		" the counts of the whole hour will used if the window starts at a fraction of an hour");
    }
    
    boolean stdUnigrams = true;
    if(args[4].equals("all")){
      LOG.info("Generatint the frequent patterns associated with all hgrams");
      stdUnigrams =false;
    }
    
    int minSupport = 5;
    if (args.length > 5) {
      minSupport = Integer.parseInt(args[5]);
    }
    
    int historyDaysCnt = 7;
    if(args.length > 6){
      historyDaysCnt = Integer.parseInt(args[6]);
    }

    while (windowStartUx < windowEndUx) {
      LOG.info("Strting Mining period from: {} to {}", windowStartUx ,windowStartUx + epochLen);
      
      DateMidnight startDay = new DateMidnight(windowStartUx*1000, DateTimeZone.forID("HST"));
      DateMidnight endDay = new DateMidnight(windowEndUx * 1000, DateTimeZone.forID("HST"));
      
      List<String> days = Lists.newLinkedList();
      MutableDateTime currDay = new MutableDateTime(startDay);
      while (!currDay.isAfter(endDay)) {
        days.add(dateFmt.print(currDay));
        currDay.addDays(1);
      }
      
      LOG.info("Days: "+ days);
      
      SequenceFile.Writer writer = new SequenceFile.Writer(fs, conf, new Path(outRoot,"fp_"+epochLen+"_"+windowStartUx), Text.class,
          TopKStringPatterns.class);

      // TODO: 2 should be replaced by the maximum hgram length
      HgramTransactionIterator transIter = new HgramTransactionIterator(days, windowStartUx,
          windowStartUx + epochLen, 2);
      HgramTransactionIterator transIter2 = new HgramTransactionIterator(days, windowStartUx,
          windowStartUx + epochLen, 2);

      try {
        transIter.init();
        transIter2.init();

        Set<String> features = Sets.newHashSet();
        if(stdUnigrams){
          
          MutableDateTime histDay1 = new MutableDateTime(startDay);

          histDay1.addDays(-historyDaysCnt);

          features = transIter.getTopicWords(TOPIC_WORDS_PER_MINUTE * (epochLen / 60),dateFmt.print(histDay1));
        }
        
        FPGrowth<String> fp = new FPGrowth<String>();

        fp.generateTopKFrequentPatterns(
            transIter,
            fp.generateFList(transIter2, minSupport),
            minSupport,
            FREQUENT_PATTERNS_PER_MINUTE * (epochLen / 60), 
            features,
            new StringOutputConverter(new SequenceFileOutputCollector<Text, TopKStringPatterns>(
                writer)),
            new ContextStatusUpdater(null));

      } finally {
        Closeables.closeQuietly(writer);
        transIter.uninit();
        transIter2.uninit();
      }
      LOG.info("Done Mining period from: {} to {}", windowStartUx ,windowStartUx + epochLen);
      windowStartUx += epochLen;
    }
  }
}
