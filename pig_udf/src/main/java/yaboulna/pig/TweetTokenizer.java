/**
 * 
 */
package yaboulna.pig;

import java.io.IOException;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.pig.EvalFunc;
import org.apache.pig.backend.executionengine.ExecException;
import org.apache.pig.data.BagFactory;
import org.apache.pig.data.DataBag;
import org.apache.pig.data.DataType;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.apache.pig.impl.logicalLayer.schema.Schema;

import ca.uwaterloo.twitter.TokenIterator.LatinTokenIterator;

import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

/**
 * @author yaboulna
 * 
 */
public class TweetTokenizer extends EvalFunc<DataBag> {

  // After implementing this I figured that this is probably gonna bloat the  data,
  // so I left it for my FIM algorithm to decide what to cross.. what was I thinking?
  private boolean generateCrossOfHashtagsAndNGrams = false;
  /*
   * (non-Javadoc)
   * 
   * @see org.apache.pig.EvalFunc#exec(org.apache.pig.data.Tuple)
   */

  @Override
  public DataBag exec(Tuple input) throws IOException {
    if (input == null || input.isNull() || input.size() < 1 || input.isNull(0)) {
      return null;
    }
    try {
      String tweet = StringEscapeUtils.unescapeJava((String) input.get(0));

      LatinTokenIterator tokenIter = new LatinTokenIterator(tweet);
      tokenIter.setRepeatHashTag(true);
      tokenIter.setRepeatedHashTagAtTheEnd(true);

      // Change array of bytes into bag of ints
// // This will overflow for anything over 127, make sure to interpret it properly
// byte[] pos = new byte[] {0};
//
// LinkedHashMap<String, DataByteArray> resMap = Maps.newLinkedHashMap();
// while (tokenIter.hasNext()) {
// String token = tokenIter.next();
// DataByteArray tokenPosList = resMap.get(token);
// if (tokenPosList == null) {
// tokenPosList = new DataByteArray();
// resMap.put(token, tokenPosList);
// }
// tokenPosList.append(pos);
// ++pos[0];
// }
      String prevToken = null;

      LinkedHashSet<String> hashtags = Sets.newLinkedHashSet();
      // Stripped hashtags so that we don't correlate hashtag with them
      // YA 130117 Less objects, more efficien -- YA-LOME
      // Set<String> hashtagsStripped = Sets.newHashSet();

      int pos = 0;

// LinkedHashMap<Tuple, DataBag> resMap = Maps.newLinkedHashMap();
      List<Tuple> resList = Lists.newArrayListWithExpectedSize(28);

      while (tokenIter.hasNext()) {
        String token = tokenIter.next();

        if (token.charAt(0) == '#') {
          // combine hashtag with all other tokens.. later, when they are available,
          // so now just put it in a structure for later
          hashtags.add(token);

          // YA-LOME hashtagsStripped.add(token.substring(1));

          // since we will combine them with all ngrams there is no point of emmitting them
          // here, they will be emitted in all combinations later
          continue;
        }

// addTokenToResMap(TupleFactory.getInstance().newTuple(token), pos, resList);
        resList.add(pos, TupleFactory.getInstance().newTuple(token));

// if (prevToken != null) {
// Tuple bigram = TupleFactory.getInstance().newTuple(2);
// bigram.set(0, prevToken);
// bigram.set(1, token);
// // addTokenToResMap(bigram, pos - 1, resList); //resMap);
// resList.add(pos - 1, bigram);
// }
        ++pos;
// prevToken = token;
      }

      // These are the token that we will combine the hashtags with, take a snapshot now
// Tuple[] existingKeys = new Tuple[resMap.size()];
// resMap.keySet().toArray(existingKeys);
// List<Tuple> existingKeys = Lists.newArrayList(resList);

      Integer tweetLen = pos;

      // This doesn't work in the context of Pig where apparently the Guava version is 11.0.2 regardless of
      // the Guava I include with the project.. maybe I should also inclde some Mangos
// Set<Set<String>> hashtagsPowerSet = Sets.powerSet(Sets.newCopyOnWriteArraySet(hashtags));
      Set<Set<String>> hashtagsPowerSet;
      if (hashtags.size() < 5) {
        hashtagsPowerSet = Sets.powerSet(hashtags);
      } else {
        // tooo many combinations will result, and these are probably spam tags.. FIXME: HUERISTIC
        hashtagsPowerSet = Sets.newLinkedHashSetWithExpectedSize(hashtags.size() + 1);
        for (String htag : hashtags) {
          hashtagsPowerSet.add(ImmutableSet.of(htag));
        }
        hashtagsPowerSet.add(ImmutableSet.copyOf(hashtags));
      }

      // Add the hashtag (combination) itself
      for (Set<String> htagSet : hashtagsPowerSet) {
        if (htagSet.size() == 0) {
          continue; // phi
        }

        Tuple htagSetTuple = TupleFactory.getInstance().newTuple(htagSet.size());
        int s = 0;
        for (String htag : htagSet) {
          htagSetTuple.set(s++, htag);
        }

        addTupleToResultTuples(htagSetTuple, tweetLen, tweetLen, resList, true); // , resTuples);
      }

      // Merge the two loops into one
// for (Set<String> htagSet : hashtagsPowerSet) {
// if (htagSet.size() == 0) {
// continue; // phi
// }
//
// // Add the hashtag (combination) itself
// Tuple htagSetTuple = TupleFactory.getInstance().newTuple(htagSet.size());
// int s = 0;
// for (String htag : htagSet) {
// htagSetTuple.set(s++, htag);
// }
// addTokenToResMap(htagSetTuple, pos, resMap);
//
// // Add the combination with all of ngrams as well
// for (Tuple ngramTuple : existingKeys) {
// Tuple htagNgram = TupleFactory.getInstance().newTuple(ngramTuple.size() + htagSet.size());
// int i = 0;
// for (; i < ngramTuple.size(); ++i) {
// String token = (String) ngramTuple.get(i);
// // YA-LOME if (hashtagsStripped.contains(token)) {
// if (isStrippedHashtag(hashtags, token)) {
// // this is an ngram with our artificially created stripped hashtag
// // so the correlation between this hashtag and other words is arleady
// // accounted for, and we are about to get an artificial correlation
// break;
// }
// htagNgram.set(i, token);
//
// }
// if (i < ngramTuple.size()) {
// // break from prev loop
// continue;
// }
// for (String htag : htagSet) {
// htagNgram.set(i++, htag);
// }
// // add the tuple as if this ngram starts at the end of the Tweet, but without incrementing pos
// // so that all hashtag ngrams has pos == Tweet length, so we treat them specially
// // Iterator<Tuple> tokenPosIter = resMap.get(ngramTuple).iterator();
// // while(tokenPosIter.hasNext()){
// // Integer p = (Integer) tokenPosIter.next().get(0);
// // addTokenToResMap(htagNgram, p, resMap);
// // }
// addTokenToResMap(htagNgram, pos, resMap);
// }
// }
//
// // END change array to bag
// Tuple[] resArr = new Tuple[resMap.size()];
// int i = 0;
// for (Tuple ngramTuple : resMap.keySet()) {
// // DataByteArray tokenPosList = resMap.get(token);
// DataBag tokenPosList = resMap.get(ngramTuple);
// Tuple tokenTuple = TupleFactory.getInstance().newTuple(4);
// tokenTuple.set(0, ngramTuple);
// tokenTuple.set(1, ngramTuple.size());
// // Tweet length: works well with repeat hashtag at the end FIXME: I don't know what the pos will actually mean
// tokenTuple.set(2, pos);
// tokenTuple.set(3, (tokenPosList));
// resArr[i++] = tokenTuple;
// }
// DataBag result = BagFactory.getInstance().newDefaultBag(Arrays.asList(resArr));

// DataBag hashtagPosBag = BagFactory.getInstance().newDefaultBag();
// hashtagPosBag.add(TupleFactory.getInstance().newTuple(((Object) tweetLen)));

// List<Tuple> resTuples = Lists.newLinkedList();

      for (int t = 0; t < tweetLen; ++t) {
// for (Tuple ngramTuple : existingKeys) {
        Tuple tokenTuple = resList.remove(t);
        String token = (String) tokenTuple.get(0);
        // DataBag tokenPosBag = resMap.get(ngramTuple);
        // addTupleToResultTuples(ngramTuple, tweetLen, tokenPosBag, resTuples);
        addTupleToResultTuples(tokenTuple, tweetLen, t, resList, false); // resTuples);
        Tuple bigram = null;
        if (prevToken != null) {
          bigram = TupleFactory.getInstance().newTuple(2);
          bigram.set(0, prevToken);
          bigram.set(1, token);
// addTokenToResMap(bigram, pos - 1, resList); //resMap);
// resList.add(pos - 1, bigram);
          addTupleToResultTuples(bigram, tweetLen, t - 1, resList, true);
        }

        if (generateCrossOfHashtagsAndNGrams) {
          boolean tokenHashtag = isStrippedHashtag(hashtags, token);

          // combine with hashtag powerset
          if (!tokenHashtag) {
            boolean prevTokenHashtag = isStrippedHashtag(hashtags, prevToken);
            for (Set<String> htagSet : hashtagsPowerSet) {
              if (htagSet.size() == 0) {
                continue; // phi
              }

// int i = 0;
// for (; i < ngramTuple.size(); ++i) {
// String token = (String) ngramTuple.get(i);
// // YA-LOME if (hashtagsStripped.contains(token)) {
// if (isStrippedHashtag(hashtags, token)) {
// // this is an ngram with our artificially created stripped hashtag
// // so the correlation between this hashtag and other words is arleady
// // accounted for, and we are about to get an artificial correlation
// break;
// }
// }
// if (i == ngramTuple.size()) {
//
// // no break from prev loop, we can construct the object.. yeah looping twice to prevent GC limit exceeded
// Tuple htagNgram = TupleFactory.getInstance().newTuple(
// ngramTuple.size() + htagSet.size());

              Tuple htagTokenTuple = TupleFactory.getInstance().newTuple(1 +
                  htagSet.size());
              htagTokenTuple.set(0, token);

              int i = 1;
              for (String htag : htagSet) {
                htagTokenTuple.set(i++, htag);
              }
// addTupleToResultTuples(htagNgram, tweetLen, hashtagPosBag, resTuples);
              addTupleToResultTuples(htagTokenTuple, tweetLen, tweetLen, resList, true); // , resTuples);

              if (!prevTokenHashtag) {

                Tuple htagBigramTuple = TupleFactory.getInstance().newTuple(2 +
                    htagSet.size());
                htagBigramTuple.set(0, prevToken);
                htagBigramTuple.set(1, token);
                i = 2;
                for (String htag : htagSet) {
                  htagBigramTuple.set(i++, htag);
                }

                addTupleToResultTuples(htagBigramTuple, tweetLen, tweetLen, resList, true); // , resTuples);

              }
            }
          }
        }
        prevToken = token;
      }

      DataBag result = BagFactory.getInstance().newDefaultBag(resList); // resTuples);

      return result;

    } catch (Exception e) {
      throw new IOException("Caught exception processing input row "
          + input.toDelimitedString("\t"), e);
    }
  }
  private void addTupleToResultTuples(Tuple ngramTuple, Integer tweetLen, Integer pos,
      List<Tuple> resTupleList, boolean appendToEnd) throws ExecException {
    Tuple resultsTuple = TupleFactory.getInstance().newTuple(4);
    resultsTuple.set(0, ngramTuple);
    resultsTuple.set(1, ngramTuple.size());
    // Tweet length: works well with repeat hashtag at the end FIXME: I don't know what the pos will actually mean
    resultsTuple.set(2, tweetLen);

    resultsTuple.set(3, pos);
    if (!appendToEnd) {
      resTupleList.add(pos, resultsTuple);
    } else {
      resTupleList.add(resultsTuple);
    }
  }

  private boolean isStrippedHashtag(LinkedHashSet<String> hashtags, String token) {
    if (token == null) {
      return true;
    }
    for (String tag : hashtags) {
      if (tag.length() != token.length() + 1) {
        continue;
      }
      int i = 0;
      for (; i < token.length(); ++i) {
        if (tag.charAt(i + 1) != token.charAt(i)) {
          break;
        }
      }
      if (i == tag.length() - 1) {
        return true;
      }
    }
    return false;
  }
// private void addTokenToResMap(Tuple ngram, int pos,
// List<Tuple> resList) throws ExecException {
// // DataBag tokenPosBag = resList.get(ngram);
// // if (tokenPosBag == null) {
// // tokenPosBag = BagFactory.getInstance().newDefaultBag();
// // resList.put(ngram, tokenPosBag);
// // }
// // Tuple posTuple = TupleFactory.getInstance().newTuple(1);
// // posTuple.set(0, pos);
// // tokenPosBag.add(posTuple);
// resList.add(pos, ngram);
// }

  public Schema outputSchema(Schema input) {
    try {
      Schema.FieldSchema ngramFs = new Schema.FieldSchema("ngram", DataType.CHARARRAY);
      Schema.FieldSchema ngramLenFs = new Schema.FieldSchema("ngramLen", DataType.INTEGER);
      Schema.FieldSchema tweetLenFs = new Schema.FieldSchema("tweetLen", DataType.INTEGER);

// Schema.FieldSchema posFS = new Schema.FieldSchema("positions", DataType.BYTEARRAY);
// // cannot be handled by FOREACH DataType.BYTE);
//
// Schema tupleSchema = new Schema(Arrays.asList(tokenFs, posFS));

// Schema.FieldSchema posFS = new Schema.FieldSchema("posF", DataType.INTEGER);
// Schema posBag = new Schema(new Schema.FieldSchema("posT", new Schema(posFS), DataType.TUPLE));
// Schema.FieldSchema posBagFS = new Schema.FieldSchema("pos", posBag, DataType.BAG);
// Schema tupleSchema = new Schema(Arrays.asList(ngramFs, ngramLenFs, tweetLenFs, posBagFS));

      Schema.FieldSchema posFS = new Schema.FieldSchema("pos", DataType.INTEGER);
      Schema tupleSchema = new Schema(Arrays.asList(ngramFs, ngramLenFs, tweetLenFs, posFS));

      Schema.FieldSchema tupleFs = new Schema.FieldSchema("ngram-ngramLen-tweetLen-pos_tuple",
          tupleSchema,
          DataType.TUPLE);

      Schema bagSchema = new Schema(tupleFs);
      // bagSchema.setTwoLevelAccessRequired(true);
      Schema.FieldSchema bagFs = new Schema.FieldSchema(
          "ngram-ngramLen-tweetLen-pos", bagSchema, DataType.BAG);

      return new Schema(bagFs);
    } catch (Exception e) {
      return null;
    }
  }

}
