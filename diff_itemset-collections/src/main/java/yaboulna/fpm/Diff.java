package yaboulna.fpm;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Collections;
import java.util.Formatter;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.commons.lang.mutable.MutableInt;

import yaboulna.fpm.postgresql.PerfMonKeyValueStore;

import com.google.common.base.Charsets;
import com.google.common.base.Joiner;
import com.google.common.collect.HashMultimap;
import com.google.common.collect.Lists;
import com.google.common.collect.Multimap;
import com.google.common.collect.Sets;
import com.google.common.io.Closer;
import com.google.common.io.Files;
import com.google.common.io.LineProcessor;

public class Diff {
// private static final Logger LOG = org.slf4j.LoggerFactory.getLogger(Diff.class);

  static class MyAffixFileFilter implements IOFileFilter {

    final String afx;
    final boolean prefix;

    public MyAffixFileFilter(String afx, boolean isPrefix) {
      super();
      this.afx = afx;
      this.prefix = isPrefix;
    }

    public boolean accept(File file) {
      return accept(file.getParentFile(), file.getName());
    }

    public boolean accept(File dir, String name) {
      return (prefix ? name.startsWith(afx) : name.endsWith(afx));
    }

  }
  static abstract class AbstractLineProcessor implements LineProcessor<Integer> {

    Integer retval = 0;

    Pattern tabSplitPattern = Pattern.compile("\\t");

    Pattern commaSplitPattern = Pattern.compile("\\,");
    Pattern commaSpaceSplitPattern = Pattern.compile("\\, ");
    // TODO handle the ] character that splits documents common to all patterns in an alliance from those in some only

    public boolean processLine(String line) throws IOException {
      String[] fields = tabSplitPattern.split(line);
      Pattern[] splitPatterns = new Pattern[fields.length];
      for (int f = 0; f < 1; ++f) { // <fields.length
        if (fields[f].charAt(0) == '[') {
          fields[f] = fields[f].substring(0, fields[f].length() - 1).substring(1);
          splitPatterns[f] = commaSpaceSplitPattern;
        } else {
          splitPatterns[f] = commaSplitPattern;
        }
      }

      fields[0] = fields[0].replaceAll("\\([0-9]+\\)", "");

      Set<String> itemset = Sets.newHashSet(splitPatterns[0].split(fields[0]));

      doSomethingUseful(itemset);

      return true;
    }

    public Integer getResult() {
      return retval;
    }

    abstract void doSomethingUseful(Set<String> itemset);
  }

  public static void main(String[] args) throws IOException, ClassNotFoundException, SQLException {

    File dataDir = new File(args[0]);
    String selPfx = args[1];
    String origPfx = args[2];

    final int maxLegitAllianceLength = 20;
    // The keywords man
// ((args.length > 3) ?
// Integer.parseInt(args[3])
// : 20);

    File diffDir = new File(dataDir, "diff" + "_" + origPfx + "-" + selPfx);
    diffDir.mkdir();

    final Set<String> keywords = Sets.newHashSet(Arrays.copyOfRange(args, 3, args.length));

    List<File> selFiles = (List<File>) FileUtils.listFiles(dataDir,
        FileFilterUtils.and(new MyAffixFileFilter(selPfx, true), // FileFilterUtils.prefixFileFilter(selPfx),
            FileFilterUtils.notFileFilter(new MyAffixFileFilter("diff", true)), // FileFilterUtils.prefixFileFilter("diff")),
            FileFilterUtils.notFileFilter(new MyAffixFileFilter(".log", false))), // FileFilterUtils.suffixFileFilter("log"))),
        FileFilterUtils.notFileFilter(new MyAffixFileFilter("diff", true)));
    Collections.sort(selFiles);

    final Set<Set<String>> selSet = Sets.newHashSetWithExpectedSize(10000);
    // Map = Maps.newHashMapWithExpectedSize(10000);
    double epochsWithOccs = 0;
    double epochsCountTot = 0;
    final Multimap<String, Long> leftOutItems = HashMultimap.create();
    final Multimap<String, Long> selectedItems = HashMultimap.create();
    for (File selF : selFiles) {
      String[] nameParts = selF.getName().split("\\_");
      long epochstartuxParsed;
      try {
        epochstartuxParsed = Long.parseLong(nameParts[nameParts.length - 2]);
      } catch (NumberFormatException e) {
        System.err.println("Number format excpetion while parsing epoch start: " + nameParts[nameParts.length - 2]
            + " from array " +
            Arrays.toString(nameParts) + " at index " + (nameParts.length - 2));
        epochstartuxParsed = -1;
        continue;
      }
      final long epochstartux = epochstartuxParsed;
      ++epochsCountTot;
      selSet.clear();

      File origFile = new File(selF.getParentFile(), replaceFirst(selF.getName(), selPfx, origPfx));
      if (!origFile.exists()) {
// LOG.debug("Orig file {} does not exist for selection file {}", origFile, selF);
        System.out.println("Orig file does not exist for selection file: " + selF);
        continue;
      }

      Closer diffClose = Closer.create();
      try {
        File diffFile = new File(diffDir, replaceFirst(selF.getName(), selPfx,
            "diff_" + Joiner.on("-").join((keywords.isEmpty() ? Arrays.asList("NO", "KEYWORDS") : keywords))
                + "_" + origPfx + "-" + selPfx));
// LOG.debug

        System.out.println(origFile + " - " + selF + " = " + diffFile);

        final PerfMonKeyValueStore perfmonKV = diffClose.register(new PerfMonKeyValueStore(Diff.class.getName(),
            diffFile.getAbsolutePath()));
        // perfmonKV.batchSizeToWrite = 7;// FIXME: whenever you add a new perf key (if more than 10 or will not close
// immediately
        final Formatter diffFmt = diffClose.register(new Formatter(diffFile));

        int numCatchAllItemsets = Files.readLines(selF, Charsets.UTF_8, new AbstractLineProcessor() {

          void doSomethingUseful(Set<String> itemset) {
            if (itemset.size() > maxLegitAllianceLength) {
              ++retval;
              return;
            }
            if (keywords.isEmpty() || !Sets.intersection(keywords, itemset).isEmpty()) {
              selSet.add(itemset); // , null);
              for (String item : itemset) {
                selectedItems.put(item, epochstartux);
              }
            }
          }

        });

        final MutableInt origOccsOfKeyWords = new MutableInt(0);
        double leftOutCount = Files.readLines(origFile, Charsets.UTF_8, new AbstractLineProcessor() {

          @Override
          void doSomethingUseful(Set<String> itemset) {
            if (!keywords.isEmpty() && Sets.intersection(keywords, itemset).isEmpty()) {
              return;
            }

            origOccsOfKeyWords.increment();

            Set<String> minDiff = itemset;
            for (Set<String> selected : selSet) {
              Set<String> diff = Sets.difference(itemset, selected);
// if (Sets.intersection(selected, itemset).equals(itemset)) {
              if (diff.size() == 0) {
                return;
              }
              if (diff.size() < minDiff.size()) {
                minDiff = diff;
              }
            }

            for (String leftOutItem : minDiff) {
              // Sets.difference(itemset, keywords)) {
              leftOutItems.put(leftOutItem, epochstartux);
            }
            ++retval;
            diffFmt.format("%s\n", itemset.toString());
// LOG.info("{}", itemset);
          }

        });

        if (origOccsOfKeyWords.doubleValue() > 0) {
          ++epochsWithOccs;
          File selKeywordsFile = new File(diffFile.getParentFile(), selF.getName() + "_"
              + Joiner.on("-").join((keywords.isEmpty() ? Arrays.asList("NO", "KEYWORDS") : keywords)));
          FileUtils.writeLines(selKeywordsFile, selSet);

          perfmonKV.storeKeyValue(selKeywordsFile.getAbsolutePath(), -1);
          perfmonKV.storeKeyValue("NumCatchAllItemsets", numCatchAllItemsets);
          perfmonKV.storeKeyValue("OrigOccsOfKWs", origOccsOfKeyWords.doubleValue());
          perfmonKV.storeKeyValue("LeftOutCount", leftOutCount);
          perfmonKV.storeKeyValue("NumSelItemsets", selSet.size());
          perfmonKV
              .storeKeyValue("LeftOutPct", leftOutCount == 0 ? 0 : leftOutCount / origOccsOfKeyWords.doubleValue());
          if (selSet.size() > 0) {
            perfmonKV.storeKeyValue("SelToOrigCompRatio", selSet.size()
                / (origOccsOfKeyWords.doubleValue() - leftOutCount));
          }
        }
      } finally {
        diffClose.close();
      }
    }
    Closer aggregateCloser = Closer.create();

    try {
      PerfMonKeyValueStore perfmonKV = aggregateCloser.register(new PerfMonKeyValueStore(Diff.class.getName(),
          Arrays.toString(args)));
      perfmonKV.storeKeyValue("EpochsWithKW", epochsWithOccs);
      perfmonKV.storeKeyValue("EpochsCount", epochsCountTot);

      for (String kw : keywords) {
        leftOutItems.removeAll(kw);
      }
//Always create a file      if (leftOutItems.size() > 0) {
        File compLeftoutItemsFile = new File(diffDir, "comp-leftout-items_" +
            Joiner.on("-").join((keywords.isEmpty() ? Arrays.asList("NO", "KEYWORDS") : keywords))
            + "_" + origPfx + "-" + selPfx);
        Formatter compLeftOutFmt = aggregateCloser.register(new Formatter(compLeftoutItemsFile));

        File leftoutItemsFile = new File(diffDir, "leftout-items_" +
            Joiner.on("-").join((keywords.isEmpty() ? Arrays.asList("NO", "KEYWORDS") : keywords))
            + "_" + origPfx + "-" + selPfx);
        Formatter leftOutFmt = aggregateCloser.register(new Formatter(leftoutItemsFile));
        int minedWithLag = 0;
        for (String leftOutItemKey : leftOutItems.keySet()) {
          Set<Long> leftOutEpochs = Sets.newCopyOnWriteArraySet(leftOutItems.get(leftOutItemKey));
          leftOutFmt.format("%s\t%d\t%s\n", leftOutItemKey, leftOutEpochs.size(), leftOutEpochs.toString());

          perfmonKV.storeKeyValue("LeftOut_" + leftOutItemKey, leftOutEpochs.size());
         
          List<Long> compLeftOutEpochs = Lists.newLinkedList();
          if (selectedItems.containsKey(leftOutItemKey)) {
            Iterator<Long> selIter = selectedItems.get(leftOutItemKey).iterator();
            Long selEpoch = selIter.next();
            for(Long loEpoch: leftOutEpochs){
              while(selEpoch < loEpoch){
                if(selIter.hasNext()){
                  selEpoch = selIter.next();
                } else {
                  selEpoch = Long.MAX_VALUE;
                }
              }
              
              if(selEpoch - loEpoch > 1800){
                compLeftOutEpochs.add(loEpoch);
              } else {
                perfmonKV.storeKeyValue("MinedWithLag_" + leftOutItemKey, selEpoch);
                ++minedWithLag;
              }
            }
//            Set<Long> selectedEpochs = Sets.newCopyOnWriteArraySet(selectedItems.get(leftOutItemKey));
//            compLeftOutEpochs = Sets.difference(leftOutEpochs, selectedEpochs);
          }
          if (compLeftOutEpochs != null && compLeftOutEpochs.size() > 0) {
            compLeftOutFmt.format("%s\t%d\t%s\n", leftOutItemKey, compLeftOutEpochs.size(),
                compLeftOutEpochs.toString());
            perfmonKV.storeKeyValue("CompLeftOut_" + leftOutItemKey, compLeftOutEpochs.size());
          } else {
            perfmonKV.storeKeyValue("AlwaysMinedWithLag_" + leftOutItemKey, -1);
          }
        }
        perfmonKV.storeKeyValue("MinedWithLagCount", minedWithLag);
//      }
    } finally {
      aggregateCloser.close();
    }
  }
  private static String replaceFirst(String str, String replaced, String replacement) {
    int ix = str.indexOf(replaced);
    String retval = str.substring(0, ix);
    retval += replacement;
    retval += str.substring(ix + replaced.length());
    return retval;
  }
// Nov  6th  
// (actually,here,how,i,is,right,this,week - \#3eekmybiodistrict3,bio - for,obama,vote) \\ (\#sophiachat,qual - extra,salary - @brittd1178,and,can,everybody,get,nigger,of,office,out,so,this,vote,we) \\ (here,how,i,is,right,this,week - @brittd1178,and,can,get,out,so,vote,we - @laliminati,olmak)
// (and,get,out,vote - @laliminati,lali - geordie,shore) \\ (0,1,de,jong - geordie,shore - if,obama,wins) \\ (de,gol,pepe - hala,madrid - geordie,shore) \\ (de,gol,pepe - geordie,shore - for,i,voted) \\ (for,i,voted - for,obama,vote - fuera,juego) \\ (and,basketball,love - for,i,voted - el,madrid,real) \\ (\#countkun,11,6 - for,i,voted - eu,te,vivo) \\ (\#geordieshore,@charlottegshore - @sophiaabrahao,URL,live,on - academy,tool) \\ (if,romney,wins - geordie,shore - if,obama,wins) \\ (geordie,shore - if,obama,wins - @noemiking20,club,my,spots) \\ (a,alguém,considera,de,idade,partir,que,velho,você - for,i,voted - if,obama,wins) \\ (virginia,west - election,is,the,this - food,stamps) \\ (a,alguém,considera,de,idade,partir,que,velho,você - election,is,this - virginia,west) \\ (food,stamps - a,alguém,considera,de,idade,partir,que,velho,você - linda,mcmahon,senate) \\ (\#stayinline,in,line - got,obama,this - a,alguém,considera,de,idade,partir,que,velho,você) \\ (got,obama,this - projected,winner - canada,move,moving,to) \\ (obama,to,win - election,the,watching - projected,winner) \\ (elizabeth,warren - popular,vote - 163,172) \\ (\#forward,\#obama2012 - election,is,this - is,my,president,still) \\ (\#forward,\#obama2012 - of,president,the - back,in,office) \\ (\#forward,\#obama2012 - colorado,in,legalized - black,go,never,once,you) \\ (colorado,in,legal - food,stamps - colorado,in,is,legal,weed) \\ (acceptance,speech,wrote - in,is,legal,weed - cnn,on) \\ (come,to,yet - est,mais - colorado,move,to) \\ (come,to,yet - behind,flag,hair,her,in,obama - flag,that,weave)
//Nov 9th
//& \#iwillneverunderstand,why -   hari,pahlawan,selamat -   @chrisripley77,available,club,my,spots \\\hline
//&   \#iwillneverunderstand,why -   hari,pahlawan -   ao,lado,sempre,seu \\\hline
//
//&   \#iwillneverunderstand,why -   brian,shaw -   breaking,brown,coach,head,mike \\\hline
//&   @boyquotations,do,everyone,follow,followers,gain,more,rt,s,want,who,you -   brian,shaw -   jackson,jerry,phil,sloan \\\hline
//&   @boyquotations,do,everyone,follow,followers,gain,more,rt,s,want,who,you -   ao,lado,sempre,seu -   brian,shaw \\\hline
//&   09,11 -   \#tvoh,babette -   \#tvoh,ivar \\\hline
//&   futuro,será -   acha,que,você -   cia,david,director,petraeus,resigns \\\hline
//&   \#emawinbieber,\#mtvema,URL,at,be,bieber,big,i,justin,pick,the,think,tweet,will,winner,your -   give,love,me -   \#tvoh,johannes \\\hline
//&   \#emawinkaty,\#mtvema,URL,at,be,big,i,katy,perry,pick,the,think,tweet,will,winner,your -   \#emawingaga,\#mtvema,at,big,pick,the,tweet,winner,your -   \#emawinbieber,\#mtvema,URL,at,be,bieber,big,i,justin,pick,the,think,tweet,will,winner,your \\\hline
//&   \#emawinbieber,\#mtvema,URL,at,be,bieber,big,i,justin,pick,the,think,tweet,will,winner,your -   \#atatürkenot,atam,atatürkenot -   qui,veut \\\hline
//&   brown,mike -   \#emawinbieber,\#mtvema,URL,at,be,bieber,big,i,justin,pick,the,think,tweet,will,winner,your -   qui,veut \\\hline
//&   brown,mike -   \#qvemf,lilou -   \#emawinbieber,\#mtvema,URL,at,be,bieber,big,i,justin,pick,the,think,tweet,will,winner,your \\\hline
//&   brown,mike -   bulan,lahir -   @venomextreme,venom \\\hline
//&   @boyquotations,do,everyone,follow,followers,gain,more,rt,s,want,who,you -   brown,mike -   \#emawinbieber,\#mtvema,be,big,the,tweet,will,winner,your \\\hline
//&   \#ullychat,qual -   \#ullychat,@ullylages,qual -   brown,mike \\\hline
//&   o,pensado,que,sobre,tem,ultimamente,você -   URL,business,i,online -   coffee,green \\\hline
//&   @boyquotations,do,everyone,follow,followers,gain,more,rt,s,want,who,you -   o,que,tem,você -   o,pensado,que,sobre,tem,ultimamente,você \\\hline
//&   \#iwillneverunderstand,why -   o,pensado,que,sobre,tem,ultimamente,você -   \#mtvema,URL,at,be,big,pick,the,tweet,will,winner,your \\\hline
//&   \#iwillneverunderstand,why -   o,pensado,que,sobre,tem,ultimamente,você -   o,pensado,que,tem,ultimamente,você \\\hline
//&   hari,pahlawan,selamat -   \#mtvema,URL,at,be,big,pick,the,tweet,will,winner,your -   \#mtvema,URL,at,be,big,the,tweet,will,winner \\\hline
//&   hari,pahlawan,selamat -   \#mtvema,URL,at,be,big,pick,the,tweet,will,winner,your -   \#iwillneverunderstand,why \\\hline
//&   hari,pahlawan,selamat -   \#iwillneverunderstand,why -   pick,your \\\hline
//&   hari,pahlawan,selamat -   and,broke,selena,up -   \#iwillneverunderstand,why \\\hline
//&   \#asdtanya,\#hmmomspik,@ahspeakdoang -   \#iwillneverunderstand,why -   hari,pahlawan,selamat \\\hline
//&   \#iwillneverunderstand,why -   brown,mike -   hari,pahlawan,selamat \\\hline
//&   10,nov -   brown,mike -   10,11,2012 \\\hline
//&   10,11,2012 -   \#iwillneverunderstand,why -   hari,pahlawan,selamat \\\hline
//&  anıyoruz,kemal,mustafa -   hari,pahlawan,selamat -   \#iwillneverunderstand,why \\\hline
//  
}
