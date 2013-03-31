package yaboulna.fpm.fpzhu.closed;

import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.Formatter;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.comparator.NameFileComparator;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Charsets;
import com.google.common.base.Splitter;
import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;
import com.google.common.io.Closer;
import com.google.common.io.Files;
import com.google.common.io.LineProcessor;
import com.google.common.primitives.Doubles;

public class DivergeBGMap {
  private final static Logger LOG = LoggerFactory.getLogger(DivergeBGMap.class);

  static class ItemsetTabCountProcessor implements LineProcessor<Map<String, Integer>> {

    public static final String NUM_TWEETS_KEY = "NUMTWEETS";

// Builder<String, Integer> mapBuilder = ImmutableMap.builder();
    final Map<String, Integer> fpCntMap;
// Avoid copying this from one frame to another = Maps.newHashMapWithExpectedSize(4444444);

    public ItemsetTabCountProcessor(Map<String, Integer> fpCntMap) {
      this.fpCntMap = fpCntMap;
    }

    @Override
    public boolean processLine(String line) throws IOException {
      int tabIx1 = 0;
      while (line.charAt(tabIx1) != '\t') {
        ++tabIx1;
      }
      String itemset = (tabIx1 > 0 ? line.substring(0, tabIx1) : NUM_TWEETS_KEY);

      int tabIx2 = tabIx1 + 1;
      while (line.charAt(tabIx2) != '\t') {
        if(tabIx2 == line.length()){ //not -1 because it is used in substring
          break;
        }
        ++tabIx2;
      }
      int count = Integer.parseInt(line.substring(tabIx1 + 1, tabIx2));

// mapBuilder.put(itemset, count);
      fpCntMap.put(itemset, count);

      return true;
    }

    @Override
    public Map<String, Integer> getResult() {
      return null; // fpCntMap avoid unneccesary copying.. am I thinking in C or R?? whatever!
    }
  }

  // max num of itemsets was 4434143 according to wc -l of the folder lcm_closed/4wk+1wk...1-abs672
  private static final int BG_MAX_NUM_ITEMSETS = 4444444;

  // max num of itemsets was 2688780 fp_3600_1352260800 in the folder lcm_closed/1hr+30min...1-abs5
  private static final int FG_MAX_NUM_ITEMSETS = 2700000;
  /**
   * @param args
   * @throws IOException
   */
  public static void main(String[] args) throws IOException {
    File bgDir = new File(args[0]);
    if (!bgDir.exists()) {
      throw new IllegalArgumentException("Path doesn't exist: " + bgDir.getAbsolutePath());
    }

    File fgDir = new File(args[1]);
    if (!fgDir.exists()) {
      throw new IllegalArgumentException("Path doesn't exist: " + fgDir.getAbsolutePath());
    }

    int histLenSecs = 4 * 7 * 24 * 3600; // TODO: Integer.parseInt(args[2]);

    List<File> fgFiles = (List<File>) FileUtils.listFiles(fgDir, FileFilterUtils.prefixFileFilter("fp_"),
        FileFilterUtils.trueFileFilter());
    Collections.sort(fgFiles, NameFileComparator.NAME_COMPARATOR);
    Map<String, Integer> fgMap = Maps.newHashMapWithExpectedSize(FG_MAX_NUM_ITEMSETS);

    List<File> bgFiles = (List<File>) FileUtils.listFiles(bgDir, FileFilterUtils.prefixFileFilter("fp_"),
        FileFilterUtils.trueFileFilter());
    Collections.sort(bgFiles, NameFileComparator.NAME_COMPARATOR);
    long loadedBgStartUx = -1;
    Map<String, Integer> bgMap = Maps.newHashMapWithExpectedSize(BG_MAX_NUM_ITEMSETS);;

    Splitter underscoreSplit = Splitter.on('_');

    for (File fgF : fgFiles) {
      long windowStartUx = Long.parseLong(Iterables.get(underscoreSplit.split(fgF.getName()), 2));
      long idealBgStartUx = windowStartUx - histLenSecs;

      // Load the appropriate background file
      for (int b = 0; b < bgFiles.size(); ++b) {
        long bgFileWinStart = Long.parseLong(Iterables.get(underscoreSplit.split(bgFiles.get(b).getName()), 2));
        long nextBgFileWinStart = Long.MAX_VALUE;
        if (b < bgFiles.size() - 1) {
          nextBgFileWinStart = Long.parseLong(Iterables.get(underscoreSplit.split(bgFiles.get(b + 1).getName()), 2));
        }
        if (b == bgFiles.size() - 1 || (idealBgStartUx >= bgFileWinStart && idealBgStartUx < nextBgFileWinStart)) {
          if (loadedBgStartUx != bgFileWinStart) {
            LOG.info("Loading background freqs from {}", bgFiles.get(b));
            loadedBgStartUx = bgFileWinStart;
            bgMap.clear();
            Files.readLines(bgFiles.get(b), Charsets.UTF_8, new ItemsetTabCountProcessor(bgMap));
            LOG.info("Loaded background freqs - num itemsets: {} ", bgMap.size());
          }
          break;
        }
      }

      fgMap.clear();
      LOG.info("Loading foreground freqs from {}", fgF);
      Files.readLines(fgF, Charsets.UTF_8, new ItemsetTabCountProcessor(fgMap));
      LOG.info("Loaded foreground freqs - num itemsets: {}", fgMap.size());

      final double bgNumTweets = bgMap.get(ItemsetTabCountProcessor.NUM_TWEETS_KEY);
      final double fgNumTweets = fgMap.get(ItemsetTabCountProcessor.NUM_TWEETS_KEY);
      final double bgFgLogP = Math.log((bgNumTweets + fgMap.size()) / (fgNumTweets + fgMap.size()));

      final File novelFile = new File(fgF.getParentFile(), fgF.getName().replaceFirst("fp_", "novel_"));
      if (novelFile.exists()) {
        // TODO: skip output that already exists
      }

      Closer novelClose = Closer.create();
      try {
        Formatter highPrecFormat = novelClose.register(new Formatter(novelFile, Charsets.UTF_8.name()));
// final Writer novelWr = novelClose.register(Channels.newWriter(FileUtils.openOutputStream(novelFile)
// .getChannel(), Charsets.UTF_8.name()));

        int counter = 0;
        for (String itemset : fgMap.keySet()) {
          double fgFreq = fgMap.get(itemset) + 1;
// double fgLogP = Math.log(fgFreq / fgNumTweets);

          Integer bgCount = bgMap.get(itemset);
          if (bgCount == null)
            bgCount = 1;
// bgLogP = 2 * fgLogP; // so that the final result will be the abs(fpLogP)
// } else {
// bgLogP = Math.log(bgCount / bgNumTweets);
// }

          double klDiver = fgFreq * (Math.log(fgFreq / bgCount) + bgFgLogP);
// novelWr.append(itemset).append('\t').append(Doubles. String.format(klDiver)).append('\n');
          highPrecFormat.format(itemset + "\t%.15f\n", klDiver);
          if (++counter % 10000 == 0) {
            LOG.info("Processed {} itemsets. Last one: {}", counter, itemset + "=" + klDiver);
          }
        }
      } finally {
        novelClose.close();
      }
    }

  }

}
