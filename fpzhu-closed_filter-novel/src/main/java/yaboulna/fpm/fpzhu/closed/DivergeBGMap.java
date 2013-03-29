package yaboulna.fpm.fpzhu.closed;

import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.nio.channels.Channels;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.comparator.NameFileComparator;
import org.apache.commons.io.filefilter.FileFilterUtils;

import com.google.common.base.Charsets;
import com.google.common.base.Splitter;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableMap.Builder;
import com.google.common.collect.Iterables;
import com.google.common.io.Closer;
import com.google.common.io.Files;
import com.google.common.io.LineProcessor;

public class DivergeBGMap {

  static class ItemsetTabCountProcessor implements LineProcessor<Map<String, Integer>> {

    public static final String NUM_TWEETS_KEY = "NUMTWEETS";
    Builder<String, Integer> mapBuilder = ImmutableMap.builder();

    @Override
    public boolean processLine(String line) throws IOException {
      int tabIx = line.length() - 1;
      while (line.charAt(tabIx) != '\t') {
        --tabIx;
      }
      int count = Integer.parseInt(line.substring(tabIx + 1));

      String itemset = (tabIx > 0 ? line.substring(0, tabIx) : NUM_TWEETS_KEY);

      mapBuilder.put(itemset, count);

      return true;
    }

    @Override
    public Map<String, Integer> getResult() {
      return mapBuilder.build();
    }
  }
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

    int histLenSecs = 4 * 7 * 24 * 3600;  // TODO: Integer.parseInt(args[2]);

    List<File> fgFiles = (List<File>) FileUtils.listFiles(fgDir, FileFilterUtils.prefixFileFilter("fp_"),
        FileFilterUtils.trueFileFilter());
    Collections.sort(fgFiles, NameFileComparator.NAME_COMPARATOR);

    List<File> bgFiles = (List<File>) FileUtils.listFiles(bgDir, FileFilterUtils.prefixFileFilter("fp_"),
        FileFilterUtils.trueFileFilter());
    Collections.sort(bgFiles, NameFileComparator.NAME_COMPARATOR);
    long loadedBgStartUx = -1;
    Map<String, Integer> bgMap = null;

    Splitter underscoreSplit = Splitter.on('_');

    for (File fgF : fgFiles) {
      long windowStartUx = Long.parseLong(Iterables.get(underscoreSplit.split(fgF.getName()), 2));
      long idealBgStartUx = windowStartUx - histLenSecs;

      // Load the appropriate background file
      for (int b = 0; b < bgFiles.size(); ++b) {
        long bgFileWinStart = Long.parseLong(Iterables.get(underscoreSplit.split(bgFiles.get(b).getName()), 2));
        long nextBgFileWinStart = Long.MAX_VALUE;
        if (b < bgFiles.size() - 1) {
          Long.parseLong(Iterables.get(underscoreSplit.split(bgFiles.get(b + 1).getName()), 2));
        }
        if (b == bgFiles.size() - 1 || (idealBgStartUx >= bgFileWinStart && idealBgStartUx < nextBgFileWinStart)) {
          if (loadedBgStartUx != bgFileWinStart) {

            bgMap = Files.readLines(bgFiles.get(b), Charsets.UTF_8, new ItemsetTabCountProcessor());
          }
          break;
        }
      }

      Map<String, Integer> fgMap = Files.readLines(fgF, Charsets.UTF_8, new ItemsetTabCountProcessor());

      final double bgNumTweets = bgMap.get(ItemsetTabCountProcessor.NUM_TWEETS_KEY);
      final double fgNumTweets = fgMap.get(ItemsetTabCountProcessor.NUM_TWEETS_KEY);

      final File novelFile = new File(fgF.getParentFile(), fgF.getName().replaceFirst("fp_", "novel_"));
      if (novelFile.exists()) {
        // TODO: skip output that already exists
      }

      Closer novelClose = Closer.create();
      try {
        final Writer novelWr = novelClose.register(Channels.newWriter(FileUtils.openOutputStream(novelFile)
            .getChannel(), Charsets.UTF_8.name()));

        for (String itemset : fgMap.keySet()) {
          double fgLogP = Math.log(fgMap.get(itemset) / fgNumTweets);

          double bgLogP;
          Integer bgCount = bgMap.get(itemset);
          if (bgCount == null) {
            bgLogP = 2 * fgLogP; // so that the final result will be the abs(fpLogP)
          } else {
            bgLogP = Math.log(bgCount / bgNumTweets);
          }

          double logOdds = fgLogP - bgLogP;
          novelWr.append(itemset).append("\t" + logOdds);
        }
      } finally {
        novelClose.close();
      }
    }

  }

}
