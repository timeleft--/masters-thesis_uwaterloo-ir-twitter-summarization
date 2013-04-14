package yaboulna.fpm.fpzhu.closed;

import java.io.File;
import java.io.IOException;
import java.math.RoundingMode;
import java.util.AbstractMap;
import java.util.Arrays;
import java.util.Collections;
import java.util.Formatter;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.comparator.NameFileComparator;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Charsets;
import com.google.common.base.Joiner;
import com.google.common.base.Splitter;
import com.google.common.collect.HashMultiset;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Multiset;
import com.google.common.collect.Multiset.Entry;
import com.google.common.collect.Sets;
import com.google.common.collect.Sets.SetView;
import com.google.common.io.Closer;
import com.google.common.io.Files;
import com.google.common.io.LineProcessor;
import com.google.common.math.DoubleMath;

public class DivergeBGMap {
  private final static Logger LOG = LoggerFactory.getLogger(DivergeBGMap.class);

  private static final Splitter comaSplitter = Splitter.on(',');
  static class ItemsetTabCountProcessor implements LineProcessor<Map<String, Integer>> {

    private static final String NUM_TWEETS_STR = "NUMTWEETS";

    public static final CopyOnWriteArraySet<String> NUM_TWEETS_KEY = Sets.newCopyOnWriteArraySet(Arrays
        .asList(NUM_TWEETS_STR));

// Builder<String, Integer> mapBuilder = ImmutableMap.builder();
    final Map<Set<String>, Integer> fpCntMap;
    final LinkedHashMap<Set<String>, LinkedList<Long>> fpDocIdsMap;
// Avoid copying this from one frame to another = Maps.newHashMapWithExpectedSize(4444444);

    public ItemsetTabCountProcessor(Map<Set<String>, Integer> fgCountMap,
        LinkedHashMap<Set<String>, LinkedList<Long>> fgIdsMap) {
      this.fpCntMap = fgCountMap;
      this.fpDocIdsMap = fgIdsMap;
    }

    @Override
    public boolean processLine(String line) throws IOException {
      int tabIx1 = 0;
      while (line.charAt(tabIx1) != '\t') {
        ++tabIx1;
      }
      String itemsetStr = (tabIx1 > 0 ? line.substring(0, tabIx1) : NUM_TWEETS_STR);

      int tabIx2 = tabIx1 + 1;
      while (tabIx2 < line.length() && line.charAt(tabIx2) != '\t') {
        ++tabIx2;
      }
      int count = DoubleMath.roundToInt(Double.parseDouble(line.substring(tabIx1 + 1, tabIx2)), RoundingMode.UP);

// mapBuilder.put(itemset, count);
      CopyOnWriteArraySet<String> itemset = Sets.newCopyOnWriteArraySet(comaSplitter.split(itemsetStr));
      fpCntMap.put(itemset, count);

      if (fpDocIdsMap != null) {
        String ids = (tabIx2 < line.length() ? line.substring(tabIx2 + 1) : "");
        if (ids.length() > 0) {

          LinkedList<Long> docIds = Lists.newLinkedList();
          fpDocIdsMap.put(itemset, docIds);
          for (String docid : comaSplitter.split(ids)) {
            docIds.add(Long.valueOf(docid));
          }
        }
      }

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

  private static final double CLOSED_CONFIDENCE_THRESHOLD = 0.05; // upper bound
  private static final double HIGH_CONFIDENCE_THRESHOLD = 0.05; // lower bound

  private static final double ITEMSET_SIMILARITY_GOOD_THRESHOLD = 0.66; // Jaccard or Cosine similarity
  private static final double ITEMSET_SIMILARITY_PROMISING_THRESHOLD = 0.33; // Jaccard similarity
  private static final double ITEMSET_SIMILARITY_BAD_THRESHOLD = 0.1; // Cosine or Jaccard similariy

  private static final double DOCID_SIMILARITY_GOOD_THRESHOLD = 0.75; // Overlap similarity

  private static final double KLDIVERGENCE_MIN = 10; // this is multiplied by frequency not prob

  private static final int MAX_LOOKBACK_FOR_PARENT = 1000;

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

    boolean stopMatchingLimitedBufferSize = true;
    boolean stopMatchingParentFSimLow = true;
    boolean avoidFormingNewAllianceIfPossible = true;
    if (args.length > 2) {
      stopMatchingLimitedBufferSize = args[2].contains("Buff");
      stopMatchingParentFSimLow = args[2].contains("SimLow");
      avoidFormingNewAllianceIfPossible = args[2].contains("AvoidNew");
    }

    int histLenSecs = 4 * 7 * 24 * 3600;
    if (args.length > 3) {
      histLenSecs = Integer.parseInt(args[3]);
    }

    String novelPfx = "novel_";
// if (args.length > 3) {
// novelPfx = args[3];
// }

    String selectionPfx = "sel_";

    // FIXME: if there are any .out files, this will cause an error now... skip them
    List<File> fgFiles = (List<File>) FileUtils.listFiles(fgDir, FileFilterUtils.prefixFileFilter("fp_"),
        FileFilterUtils.trueFileFilter());
    Collections.sort(fgFiles, NameFileComparator.NAME_COMPARATOR);
    Map<Set<String>, Integer> fgCountMap = Maps.newHashMapWithExpectedSize(FG_MAX_NUM_ITEMSETS);
    LinkedHashMap<Set<String>, LinkedList<Long>> fgIdsMap = Maps.newLinkedHashMap();

    List<File> bgFiles = (List<File>) FileUtils.listFiles(bgDir, FileFilterUtils.prefixFileFilter("fp_"),
        FileFilterUtils.trueFileFilter());
    Collections.sort(bgFiles, NameFileComparator.NAME_COMPARATOR);
    long loadedBgStartUx = -1;
    Map<Set<String>, Integer> bgCountMap = Maps.newHashMapWithExpectedSize(BG_MAX_NUM_ITEMSETS);
    Map<String, Double> bgIDFMap = Maps.newHashMapWithExpectedSize(BG_MAX_NUM_ITEMSETS / 10);

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
            bgCountMap.clear();
            bgIDFMap.clear();
            Files.readLines(bgFiles.get(b), Charsets.UTF_8, new ItemsetTabCountProcessor(bgCountMap, null));
            LOG.info("Loaded background freqs - num itemsets: {} ", bgCountMap.size());
          }
          break;
        }
      }

      fgCountMap.clear();
      fgIdsMap.clear();
      LOG.info("Loading foreground freqs from {}", fgF);
      Files.readLines(fgF, Charsets.UTF_8, new ItemsetTabCountProcessor(fgCountMap, fgIdsMap));
      LOG.info("Loaded foreground freqs - num itemsets: {}", fgCountMap.size());

      final double bgNumTweets = bgCountMap.get(ItemsetTabCountProcessor.NUM_TWEETS_KEY);
      final double fgNumTweets = fgCountMap.get(ItemsetTabCountProcessor.NUM_TWEETS_KEY);
      final double bgFgLogP = Math.log((bgNumTweets + fgCountMap.size()) / (fgNumTweets + fgCountMap.size()));

      final File novelFile = new File(fgF.getParentFile(), fgF.getName().replaceFirst("fp_", novelPfx)); // "novel_"));
      if (novelFile.exists()) {
        // TODO: skip output that already exists
      }

      final File selFile = new File(fgF.getParentFile(), fgF.getName().replaceFirst("fp_", selectionPfx));

      LinkedList<Set<String>> mergeCandidates = Lists.newLinkedList();
// Multiset<String> mergedItemset = HashMultiset.create();
// Set<Long> grandUionDocId = Sets.newHashSet();
// Set<Long> grandIntersDocId = Sets.newHashSet();
// LinkedList<Long> unionDocId;
// Set<Long> intersDocId;
// unionDocId = Lists.newLinkedList();
// intersDocId = Sets.newHashSet();

      Map<Set<String>, java.util.Map.Entry<Multiset<String>, Set<Long>>> growingAlliances = Maps.newHashMap();
      Map<Set<String>, Set<String>> parentOfAllianceHead = Maps.newHashMap();
      Map<Set<String>, Set<Set<String>>> allianceTransitive = Maps.newHashMap();
      Map<Set<String>, Double> unalliedItemsets = Maps.newHashMap();
      Map<Set<String>, Double> confidentItemsets = Maps.newHashMap();

      LinkedList<Set<String>> prevItemsets = Lists.newLinkedList();

      Closer novelClose = Closer.create();
      try {
        Formatter highPrecFormat = novelClose.register(new Formatter(novelFile, Charsets.UTF_8.name()));
// final Writer novelWr = novelClose.register(Channels.newWriter(FileUtils.openOutputStream(novelFile)
// .getChannel(), Charsets.UTF_8.name()));

        Formatter selectionFormat = novelClose.register(new Formatter(selFile, Charsets.UTF_8.name()));

        int counter = 0;
        for (Set<String> itemset : fgCountMap.keySet()) {

          double fgFreq = fgCountMap.get(itemset) + 1.0;
// double fgLogP = Math.log(fgFreq / fgNumTweets);

          Integer bgCount = bgCountMap.get(itemset);
          if (bgCount == null)
            bgCount = 1;
// bgLogP = 2 * fgLogP; // so that the final result will be the abs(fpLogP)
// } else {
// bgLogP = Math.log(bgCount / bgNumTweets);
// }

          double klDiver = fgFreq * (Math.log(fgFreq / bgCount) + bgFgLogP);
// novelWr.append(itemset).append('\t').append(Doubles. String.format(klDiver)).append('\n');
          highPrecFormat.format(itemset + "\t%.15f\t%s\n", klDiver,
              (fgIdsMap.containsKey(itemset) ? fgIdsMap.get(itemset) : ""));

          // ////////////////////////////////////////////

          if (++counter % 10000 == 0) {
            LOG.info("Processed {} itemsets. Last one: {}", counter, itemset + "=" + klDiver);
          }

          // ////////////////////////////////////////////

          if (itemset.size() == 1) {
            prevItemsets.addLast(itemset);
          } else if (klDiver > KLDIVERGENCE_MIN) {
            LinkedList<Long> iDocIds = fgIdsMap.get(itemset);
            if (iDocIds == null || iDocIds.isEmpty()) {
              prevItemsets.addLast(itemset);
              continue;
            }

            Double itemsetNorm = null;
            mergeCandidates.clear();

            Set<String> parentItemset = null;
            Iterator<Set<String>> prevIter = prevItemsets.descendingIterator();
            double maxConfidence = -1.0; // if there is no parent, then this is the first from these items
            boolean allied = false;

            int lookBackRecords = 0;

            while (prevIter.hasNext()) { // there are more than one parent: && !foundParent
              Set<String> pis = prevIter.next();

              SetView<String> interset = Sets.intersection(pis, itemset);
              if (pis.size() == interset.size()) { // TODO: can the parent (shorter) come after?
                // one of the parent itemset (in the closed patterns lattice)

                mergeCandidates.add(pis);
                if (parentItemset == null) {
                  // first parent to encounter will be have the lowest support, thus gives highest confidence
                  double pisFreq = fgCountMap.get(pis);
                  maxConfidence = fgCountMap.get(itemset) / pisFreq;
                }
                parentItemset = pis;
// if (maxConfidence >= HIGH_CONFIDENCE_THRESHOLD) {
// // it will get printed without alliances.. oh, it doesn't need alliance
// allied = true;
// break;
// }
              } else {
                // TODO: prefix filter ppjoin; using an adaptation to get maxAllDiffPos
                // Itemset similiarity starts by a lightweight Jaccard Similarity similiarity,
                // then if it is promising then the cosine similarity is calculated with IDF weights
                SetView<String> isPisUnion = Sets.union(pis, itemset);
                double isPisSim = interset.size() * 1.0 / isPisUnion.size();
                if (isPisSim >= ITEMSET_SIMILARITY_PROMISING_THRESHOLD) {
                  double pisNorm = 0;
                  double itemsetNormTemp = 0;
                  if (isPisSim < ITEMSET_SIMILARITY_GOOD_THRESHOLD) {
                    // calculate the cosine similarity only if the jaccard similarity isn't enough
                    isPisSim = 0;
                    for (String interItem : isPisUnion) {
                      // IDF weights
                      Double idf = bgIDFMap.get(interItem);
                      if (idf == null) {
                        Integer bgCnt = bgCountMap.get(Sets.newCopyOnWriteArraySet(Arrays.asList(interItem)));
                        if (bgCnt == null) {
                          bgCnt = 0;
                        }
                        idf = Math.log(bgNumTweets / (1.0 + bgCnt));
                        idf *= idf;
                        bgIDFMap.put(interItem, idf);
                      }

                      if (interset.contains(interItem)) {
                        isPisSim += idf; // * idf;
                        pisNorm += idf; // * idf;
                        if (itemsetNorm == null) {
                          itemsetNormTemp += idf; // * idf;
                        }
                      } else if (pis.contains(interItem)) {
                        pisNorm += idf; // * idf;
                      } else if (itemsetNorm == null && itemset.contains(interItem)) {
                        itemsetNormTemp += idf; // * idf;
                      }

                    }
                    if (itemsetNorm == null) {
                      itemsetNorm = Math.sqrt(itemsetNormTemp);
                    }
                    isPisSim /= Math.sqrt(pisNorm) * itemsetNorm;
                  }
                  if (isPisSim >= ITEMSET_SIMILARITY_GOOD_THRESHOLD) {
                    mergeCandidates.add(pis);
                  }
                }

                if ((stopMatchingParentFSimLow && parentItemset != null &&
                    isPisSim < ITEMSET_SIMILARITY_BAD_THRESHOLD)
                    || (stopMatchingLimitedBufferSize && ++lookBackRecords > MAX_LOOKBACK_FOR_PARENT)) {
                  // TODONE: could this also work without checking foundParent -> NO, very few alliances happen
                  // TODO: are we losing anything by breaking on the first bad similarity
// if (LOG.isTraceEnabled())
// LOG.trace("Decided there won't be any more candidates for itemset {} when we encountered {}.",
// itemset, pis);
                  break; // the cluster of itemsets from these items is consumed
                }
              }
            }

            // Add to previous for next iterations to access it, regardless if it will get merged or not.. it can
            prevItemsets.add(itemset);

// mergedItemset.clear();

// grandUionDocId.clear();
// grandIntersDocId.clear();

            if (parentItemset == null) {
              unalliedItemsets.put(itemset, klDiver);
              continue;
            } else { // if (maxConfidence < CLOSED_CONFIDENCE_THRESHOLD) {

              double maxDiffCnt = Math.max(0.9, // so that maxDiffCnt of 0 enters the loop
                  Math.floor((1 - DOCID_SIMILARITY_GOOD_THRESHOLD) * iDocIds.size()));

              for (Set<String> cand : mergeCandidates) {
                LinkedList<Long> candDocIds = fgIdsMap.get(cand);
                int differentDocs = 0;
                if (parentItemset == cand) {
                  // the (true) parent will necessarily be present in all documents of itemset
                  differentDocs = candDocIds.size() - iDocIds.size();
                } else {
// unionDocId.clear();
// intersDocId.clear();

                  if (candDocIds == null || candDocIds.isEmpty()) {
                    LOG.warn("Using a file with truncated inverted indexes");
                    continue;
                  }

                  // Intersection and union calculation (depends on that docIds are sorted)
                  // TODO: use a variation of this measure that calculates the time period covered by each itemset
                  // TODONE: overlap of intersection with the current itemset's docids

                  Iterator<Long> iDidIter = iDocIds.iterator();
                  Iterator<Long> candDidIter = candDocIds.iterator();
                  long iDid = iDidIter.next(), candDid = candDidIter.next();
                  while (differentDocs <= maxDiffCnt && iDidIter.hasNext() && candDidIter.hasNext()) {
                    if (iDid == candDid) {
// intersDocId.add(iDid);
// unionDocId.add(iDid);
                      iDid = iDidIter.next();
                      candDid = candDidIter.next();
                    } else if (iDid < candDid) {
// unionDocId.add(iDid);
                      iDid = iDidIter.next();
                      ++differentDocs;
                    } else {
// unionDocId.add(candDid);
                      candDid = candDidIter.next();
                    }
                  }
                }
// Iterator<Long> remainingIter;
// if (iDidIter.hasNext()) {
// remainingIter = iDidIter;
// } else {
// remainingIter = candDidIter;
// }
// while (remainingIter.hasNext()) {
// unionDocId.add(remainingIter.next());
// }
// }
// // Similarity checking: jaccard similarity
// double docIdSim = intersDocId.size() * 1.0 / iDocIds.size(); //unionDocId.size();
// if (docIdSim >= DOCID_SIMILARITY_GOOD_THRESHOLD) {
//
// mergedItemset.addAll(Sets.union(itemset, cand));
//
// // add the union and intersection to grand ones
// grandUionDocId.addAll(unionDocId);
// grandIntersDocId = Sets.intersection(grandIntersDocId, intersDocId);
//
// }
                // If similar enough, attach to the merge candidate and put both in pending queue
                if (differentDocs <= maxDiffCnt) {
                  // Try and join and existing alliance
                  Set<String> bestAllianceHead = cand;

                  Set<Set<String>> existingAllainceHeads = allianceTransitive.get(cand);
                  // what did the candidate do wrong to ignore it if it doesn't have earlier allies?
// if(existingAllainceHeads == null){
// existingAllainceHeads = allianceTransitive.get(itemset);
// } else {
//
// }
                  if (existingAllainceHeads != null) {
                    int currentBestDifference = differentDocs;
                    for (Set<String> exitingAllianceHead : existingAllainceHeads) {
                      int existingHeadNonOverlap = 0;
                      Iterator<Long> iDidIter = iDocIds.iterator();
                      Iterator<Long> existingDidIter = fgIdsMap.get(exitingAllianceHead).iterator();
                      long iDid = iDidIter.next(), existingDid = existingDidIter.next();
                      while (existingHeadNonOverlap <= maxDiffCnt && iDidIter.hasNext() && existingDidIter.hasNext()) {
                        if (iDid == existingDid) {
                          // intersDocId.add(iDid);
                          // unionDocId.add(iDid);
                          iDid = iDidIter.next();
                          existingDid = existingDidIter.next();
                        } else if (iDid < existingDid) {
                          // unionDocId.add(iDid);
                          iDid = iDidIter.next();
                          ++existingHeadNonOverlap;
                        } else {
                          // unionDocId.add(candDid);
                          existingDid = existingDidIter.next();
                        }
                      }

                      if ((avoidFormingNewAllianceIfPossible && existingHeadNonOverlap <= maxDiffCnt)
                          || (!avoidFormingNewAllianceIfPossible && existingHeadNonOverlap <= currentBestDifference)) {
                        // <= prefers existing allinaces to forming new ones

                        currentBestDifference = existingHeadNonOverlap;
                        bestAllianceHead = exitingAllianceHead;

                        if (avoidFormingNewAllianceIfPossible) {
                          // not choosing the best possible, and hopefully there will be only one
                          // TODO: any problem with that?
//                          if (existingAllainceHeads.size() > 1) {
//                            LOG.trace(
//                                "There should be only one possible alliance head... or so I think. Itemset {}, candidate {}, alliance heads: "
//                                    + existingAllainceHeads, itemset, cand);
//                          }
                          break;
                        }
                      }
                    }
                  }

                  // /////////// Store that you joined this alliance
                  existingAllainceHeads = allianceTransitive.get(itemset);
                  if (existingAllainceHeads == null) {
                    existingAllainceHeads = Sets.newHashSet();
                    allianceTransitive.put(itemset, existingAllainceHeads);
                  }
                  if (existingAllainceHeads.contains(bestAllianceHead)) {
                    // // this itemset is already part of the alliance, in an earlier iteration
                    continue;
                  }
                  existingAllainceHeads.add(bestAllianceHead);

                  java.util.Map.Entry<Multiset<String>, Set<Long>> alliedItemsets = growingAlliances
                      .get(bestAllianceHead);

                  if (alliedItemsets == null) {
                    // ////// Create a new alliance
                    assert bestAllianceHead == cand : "Why aren't we joining the existing alliance?";
                    alliedItemsets = new AbstractMap.SimpleEntry<Multiset<String>, Set<Long>>(
                        HashMultiset.create(cand), Sets.newHashSet(candDocIds));
                    growingAlliances.put(cand, alliedItemsets);
                    if (cand.size() > parentItemset.size()
                        && candDocIds.size() < fgIdsMap.get(parentItemset).size()) {
                      parentOfAllianceHead.put(cand, parentItemset);
                    } else {
                      parentOfAllianceHead.put(cand, cand);
                    }

                    unalliedItemsets.remove(cand);
                  }
                  alliedItemsets.getKey().addAll(itemset);
                  alliedItemsets.getValue().addAll(iDocIds);

                  allied = true;
                }
              }
// maxConfidence = grandUionDocId.size() * 1.0 / fgIdsMap.get(parentItemset).size();
            }

            if (maxConfidence >= HIGH_CONFIDENCE_THRESHOLD) {
              confidentItemsets.put(itemset, maxConfidence);
// // write out the itemset (orig or merged) into selection file(s),
// // because it is high confidence either from the beginning or after merging
// // This is originally a high confidence itemset, we didnt increase conf yet: if (mergedItemset.isEmpty()) {
// Multiset<String> mergedItemset = HashMultiset.create(itemset); // mergedItemset.addAll(itemset);
// // } else {
// // klDiver = grandUionDocId.size();
// // bgCount = bgCountMap.get(mergedItemset.elementSet());
// // if (bgCount == null)
// // bgCount = 1;
// //
// // klDiver *= (Math.log(grandUionDocId.size() * 1.0 / bgCount) + bgFgLogP);
// //
// // // mergedItemset = Multisets.copyHighestCountFirst(mergedItemset);
// // }
// selectionFormat.out().append(printMultiset(mergedItemset));
// selectionFormat.format("\t%.15f\t%.15f\t%.15f\t%d\t%.15f\t",
// maxConfidence,
// klDiver,
// maxConfidence * klDiver,
// iDocIds.size(),
// maxConfidence * iDocIds.size());
// // if (grandUionDocId.isEmpty()) {
// selectionFormat.out().append(iDocIds.toString().substring(1));
// // } else {
// // selectionFormat.out().append(grandIntersDocId.toString().substring(1))
// // .append(Sets.difference(grandUionDocId, grandIntersDocId).toString().substring(1));
// // }
// selectionFormat.out().append("\n");

              // TODO: are you sure about that?
              // The parent will be present in the final output within this itemset, so even if it
              // were pending alliance to get printed it can be removed now
              unalliedItemsets.remove(parentItemset);
            }

            if (!allied) {
              unalliedItemsets.put(itemset, klDiver);
            }
          }
        }

        for (java.util.Map.Entry<Set<String>, java.util.Map.Entry<Multiset<String>, Set<Long>>> e : growingAlliances
            .entrySet()) {
          Set<Long> unionDocId = e.getValue().getValue();
          Set<String> parentItemset = parentOfAllianceHead.get(e.getKey());
          double confidence = unionDocId.size() * 1.0 / fgIdsMap.get(parentItemset).size();
          if (confidence < HIGH_CONFIDENCE_THRESHOLD) {
            continue;
          }
          // The parent will be present in the final output within this itemset, so even if it
          // were pending alliance to get printed it can be removed now
          unalliedItemsets.remove(parentItemset);
          Multiset<String> mergedItemset = e.getValue().getKey();
          double klDiver = unionDocId.size();
          Integer bgCount = bgCountMap.get(mergedItemset.elementSet());
          if (bgCount == null) {
            bgCount = 1;
          } else {
// LOG.trace("it matches background");
          }
          klDiver *= (Math.log(unionDocId.size() * 1.0 / bgCount) + bgFgLogP);

          selectionFormat.out().append(printMultiset(mergedItemset));
          selectionFormat.format("\t%.15f\t%.15f\t%.15f\t%d\t%.15f\t",
              confidence,
              klDiver,
              confidence * klDiver,
              unionDocId.size(),
              confidence * unionDocId.size());

          Set<Long> headDocIds = Sets.newCopyOnWriteArraySet(fgIdsMap.get(e.getKey()));
          selectionFormat.out().append(headDocIds.toString().substring(1))
              .append(Sets.difference(unionDocId, headDocIds).toString().substring(1));

          selectionFormat.out().append("\n");
        }
        growingAlliances.clear();

        // Print the parents that were pending alliance with children to make sure they have conf
        // those ones didn't prove to have any confident children, but we have to give them a chance
        for (java.util.Map.Entry<Set<String>, Double> e : unalliedItemsets.entrySet()) {
          Set<String> itemset = e.getKey();
          Multiset<String> mergedItemset = HashMultiset.create(itemset);
          LinkedList<Long> docids = fgIdsMap.get(itemset);

          double confidence;
          double klDiver = e.getValue();
          int supp = docids.size();
          double confKLD;
          double confSupp;
          if (confidentItemsets.containsKey(itemset)) {
            confidence = confidentItemsets.get(itemset);
            confKLD = confidence * klDiver;
            confSupp = confidence * supp;
          } else {
            confidence = -1;
            confKLD = -1;
            confSupp = -1;
          }

          selectionFormat.out().append(printMultiset(mergedItemset));
          selectionFormat.format("\t%.15f\t%.15f\t%.15f\t%d\t%.15f\t",
              confidence,
              klDiver,
              confKLD,
              supp,
              confSupp);
          selectionFormat.out().append(docids.toString().substring(1));
        }
        unalliedItemsets.clear();

      } finally {
        novelClose.close();
      }
    }

  }
  private static CharSequence printMultiset(Multiset<String> mset) {
    String[] ret = new String[mset.entrySet().size()];
    int i = 0;
    for (Entry<String> e : mset.entrySet()) {
      ret[i++] = e.getCount() + " " + e.getElement();
    }
    Arrays.sort(ret);
    return Joiner.on(",").join(ret);
  }
}
