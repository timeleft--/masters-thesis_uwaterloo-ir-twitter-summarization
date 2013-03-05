package yaboulna.fpm;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashSet;
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

import yaboulna.fpm.postgresql.HgramTransactionIterator;

import com.google.common.collect.Lists;
import com.google.common.io.Closeables;

public class HgramsWindow {
 
  protected static final DateTimeFormatter dateFmt = DateTimeFormat.forPattern("yyMMdd");
  
  public static void main(String[] args) throws IOException, SQLException, ClassNotFoundException{
    
    long windowStartUx = Long.parseLong(args[0]);
    DateMidnight startDay = new DateMidnight(windowStartUx, DateTimeZone.forID("HST"));
    
    long windowEndUx = Long.parseLong(args[1]);
    DateMidnight endDay = new DateMidnight(windowEndUx, DateTimeZone.forID("HST"));
    
    List<String> days = Lists.newLinkedList();
    MutableDateTime currDay = new MutableDateTime(startDay);
    while(!currDay.isAfter(endDay)){
      days.add(dateFmt.print(currDay));
      currDay.addDays(1);
    }
    
    Path path = new Path(args[2]);
    Configuration conf = new Configuration();
    FileSystem fs = FileSystem.get(path.toUri(), conf);
    SequenceFile.Writer writer = new SequenceFile.Writer(fs, conf, path, Text.class, TopKStringPatterns.class);
    
    int minSupport = 5;
    if(args.length > 3){
      minSupport = Integer.parseInt(args[3]);
    }
        
    HgramTransactionIterator transIter = new HgramTransactionIterator(days, windowStartUx, windowEndUx, 2);
    HgramTransactionIterator transIter2 = new HgramTransactionIterator(days, windowStartUx, windowEndUx, 2);
    
    try{
    transIter.init();
    transIter2.init();
    
    FPGrowth<String> fp = new FPGrowth<String>();
    Set<String> features = new HashSet<String>();
    fp.generateTopKFrequentPatterns(
        transIter,
        fp.generateFList(transIter2, minSupport),
           minSupport,
           days.size() * 120, //5 per hour
           features,
           new StringOutputConverter(new SequenceFileOutputCollector<Text, TopKStringPatterns>(writer)),
           new ContextStatusUpdater(null));
    
    }finally{
      Closeables.closeQuietly(writer);
      transIter.uninit();
      transIter2.uninit();
    }
  }
   
}
