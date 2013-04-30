package yaboulna.fpm;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Collections;
import java.util.Formatter;
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
import com.google.common.collect.Multimap;
import com.google.common.collect.Multimaps;
import com.google.common.collect.Multiset;
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

    File diffDir = new File(dataDir, "diff");
    diffDir.mkdir();

    final Set<String> keywords = Sets.newHashSet(Arrays.copyOfRange(args, 3, args.length));

    List<File> selFiles = (List<File>) FileUtils.listFiles(dataDir,
        FileFilterUtils.and(new MyAffixFileFilter(selPfx, true), // FileFilterUtils.prefixFileFilter(selPfx),
            FileFilterUtils.notFileFilter(new MyAffixFileFilter("diff", false)), // FileFilterUtils.prefixFileFilter("diff")),
            FileFilterUtils.notFileFilter(new MyAffixFileFilter(".log", false))), // FileFilterUtils.suffixFileFilter("log"))),
        FileFilterUtils.trueFileFilter());
    Collections.sort(selFiles);

    final Set<Set<String>> selSet = Sets.newHashSetWithExpectedSize(10000);
    // Map = Maps.newHashMapWithExpectedSize(10000);
    double epochsWithOccs = 0;
    double epochsCountTot = 0;
    final Multimap<String, Long> leftOutItems = HashMultimap.create();
    for (File selF : selFiles) {
      
      final long epochstartux = 0l;//FIXME
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
        final Formatter diffFmt = diffClose.register(new Formatter(diffFile));

        int numCatchAllItemsets = Files.readLines(selF, Charsets.UTF_8, new AbstractLineProcessor() {

          void doSomethingUseful(Set<String> itemset) {
            if(itemset.size() > 15){
              ++retval;
              return;
            }
            if (keywords.isEmpty() || !Sets.intersection(keywords, itemset).isEmpty()) {
              selSet.add(itemset); // , null);
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

            for (Set<String> selected : selSet) {
              if (Sets.intersection(selected, itemset).equals(itemset)) {
                return;
              }
            }

            for(String leftOutItem: Sets.difference(itemset, keywords)){
              leftOutItems.put(leftOutItem, value);
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
    PerfMonKeyValueStore perfmonKV = new PerfMonKeyValueStore(Diff.class.getName(),
        Arrays.toString(args));
    try {
      perfmonKV.storeKeyValue("EpochsWithKW", epochsWithOccs);
      perfmonKV.storeKeyValue("EpochsCount", epochsCountTot);
    } finally {
      perfmonKV.close();
    }
  }

  private static String replaceFirst(String str, String replaced, String replacement) {
    int ix = str.indexOf(replaced);
    String retval = str.substring(0, ix);
    retval += replacement;
    retval += str.substring(ix + replaced.length());
    return retval;
  }
}
