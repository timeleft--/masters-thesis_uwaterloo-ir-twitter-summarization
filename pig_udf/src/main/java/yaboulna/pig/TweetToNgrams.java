/**
 * 
 */
package yaboulna.pig;

import java.io.IOException;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.LinkedList;
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
public class TweetToNgrams extends EvalFunc<DataBag> {

  private boolean generateCrossOfHashtagsAndNGrams = false;
  /*
   * (non-Javadoc)
   * 
   * @see org.apache.pig.EvalFunc#exec(org.apache.pig.data.Tuple)
   */

  @Override
  public DataBag exec(Tuple input) throws IOException {
    if (input == null || input.isNull() || input.size() < 2 || input.isNull(0)) {
      return null;
    }
    try {
      String tweet = StringEscapeUtils.unescapeJava((String) input.get(0));
      int ngramMaxLength = (Integer)input.get(1);
      
      LatinTokenIterator tokenIter = new LatinTokenIterator(tweet);
      tokenIter.setRepeatHashTag(true);
      tokenIter.setRepeatedHashTagAtTheEnd(true);

      LinkedList<String> prevTokens = Lists.newLinkedList(); // String[ngramMaxLength-1];

      LinkedHashSet<String> hashtags = Sets.newLinkedHashSet();

      int pos = 0;

      List<Tuple> resList = Lists.newArrayListWithExpectedSize(28);

      while (tokenIter.hasNext()) {
        String token = tokenIter.next();

        if (token.charAt(0) == '#') {
          // combine hashtag with all other tokens.. later, when they are available,
          // so now just put it in a structure for later
          hashtags.add(token);

          // since we will combine them with all ngrams there is no point of emmitting them
          // here, they will be emitted in all combinations later
          continue;
        }

        resList.add(pos, TupleFactory.getInstance().newTuple(token));

        ++pos;
      }

      Integer tweetLen = pos;

      //TODO: create an object only if hashtags.size > 0.. this will require some null checking in loops
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

      for (int t = 0; t < tweetLen; ++t) {
        Tuple tokenTuple = resList.remove(t);
        String token = (String) tokenTuple.get(0);
        addTupleToResultTuples(tokenTuple, tweetLen, t, resList, false); // resTuples);
        Tuple ngram = null;
        
        Tuple smallerTuple = TupleFactory.getInstance().newTuple(token);
        // will not go inside for the first iteration (when t=0 and prevTokens is empty
        for(String pTok: prevTokens) { //int v=0; v<ngramMaxLength-1; ++v){
          
          ngram = TupleFactory.getInstance().newTuple(smallerTuple.size() + 1);
          ngram.set(0, pTok);
            
          for(int v=1;v<smallerTuple.size() + 1; ++v){
            ngram.set(v, smallerTuple.get(v-1));
          }
          addTupleToResultTuples(ngram, tweetLen, t - smallerTuple.size(), resList, true);
          smallerTuple = ngram;
        }

        if (generateCrossOfHashtagsAndNGrams) {
          boolean tokenHashtag = isStrippedHashtag(hashtags, token);

          // combine with hashtag powerset
          if (!tokenHashtag) {
            boolean prevTokenHashtag = isStrippedHashtag(hashtags, prevTokens.getFirst());
            for (Set<String> htagSet : hashtagsPowerSet) {
              if (htagSet.size() == 0) {
                continue; // phi
              }

              Tuple htagTokenTuple = TupleFactory.getInstance().newTuple(1 +
                  htagSet.size());
              htagTokenTuple.set(0, token);

              int i = 1;
              for (String htag : htagSet) {
                htagTokenTuple.set(i++, htag);
              }
              
              addTupleToResultTuples(htagTokenTuple, tweetLen, tweetLen, resList, true); // , resTuples);

              if (!prevTokenHashtag) {

                Tuple htagBigramTuple = TupleFactory.getInstance().newTuple(2 +
                    htagSet.size());
                htagBigramTuple.set(0, prevTokens.getFirst());
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
        prevTokens.addFirst(token);
        while(prevTokens.size() >= ngramMaxLength){
          prevTokens.removeLast();
        }
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

  public Schema outputSchema(Schema input) {
    try {
      Schema.FieldSchema ngramFs = new Schema.FieldSchema("ngram", DataType.CHARARRAY);
      Schema.FieldSchema ngramLenFs = new Schema.FieldSchema("ngramLen", DataType.INTEGER);
      Schema.FieldSchema tweetLenFs = new Schema.FieldSchema("tweetLen", DataType.INTEGER);


      Schema.FieldSchema posFS = new Schema.FieldSchema("pos", DataType.INTEGER);
      Schema tupleSchema = new Schema(Arrays.asList(ngramFs, ngramLenFs, tweetLenFs, posFS));

      Schema.FieldSchema tupleFs = new Schema.FieldSchema("ngram-ngramLen-tweetLen-pos_tuple",
          tupleSchema,
          DataType.TUPLE);

      Schema bagSchema = new Schema(tupleFs);
      Schema.FieldSchema bagFs = new Schema.FieldSchema(
          "ngram-ngramLen-tweetLen-pos", bagSchema, DataType.BAG);

      return new Schema(bagFs);
    } catch (Exception e) {
      return null;
    }
  }

}
