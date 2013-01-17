/**
 * 
 */
package yaboulna.pig;

import java.io.IOException;
import java.util.Arrays;
import java.util.LinkedHashMap;
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

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

/**
 * @author yaboulna
 * 
 */
public class TweetTokenizer extends EvalFunc<DataBag> {

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
      
      List<String> hashtags = Lists.newLinkedList();
    //Stripped hashtags so that we don't correlate hashtag with them
      Set<String> hashtagsStripped = Sets.newHashSet();
      
      int pos = 0;
      int tweetLen = -1;
      
      LinkedHashMap<Tuple, DataBag> resMap = Maps.newLinkedHashMap();
      
      while (tokenIter.hasNext()) {
        String token = tokenIter.next();

        if (token.charAt(0) == '#') {
          // combine hashtag with all other tokens.. later, when they are available,
          // so now just put it in a structure for later
          hashtags.add(token);

          hashtagsStripped.add(token.substring(1));
          
          // As long as repeat hashtags is set tobe at the end, seeing a hashtag indicates that
          // we have reached the end of the tweet, and the length is the current pos
          if (tokenIter.getRepeatHashTag() && tokenIter.isRepeatedHashTagAtTheEnd()) {
            tweetLen = pos;
          }

          // since we will combine them with all ngrams there is no point of emmitting them
          // here, they will be emitted in all combinations later
          continue;
        }

        addTokenToResMap(TupleFactory.getInstance().newTuple(token), pos, resMap);
        if (prevToken != null) {
          Tuple bigram = TupleFactory.getInstance().newTuple(2);
          bigram.set(0, prevToken);
          bigram.set(1, token);
          addTokenToResMap(bigram, pos - 1, resMap);
        }
        ++pos;
        prevToken = token;
      }

      // These are the token that we will combine the hashtags with, take a snapshot now
      Tuple[] existingKeys = null;
      if(hashtags.size() > 0){
        existingKeys = resMap.keySet().toArray(new Tuple[0]);
      }
      
      Set<Set<String>> hashtagsPowerSet = Sets.powerSet(Sets.newCopyOnWriteArraySet(hashtags));
      
      for (Set<String> htagSet : hashtagsPowerSet) {
        if (htagSet.size() == 0) {
          continue; // phi
        }
        
        // Add the hashtag (combination) itself
        Tuple htagSetTuple = TupleFactory.getInstance().newTuple(htagSet.size());
        int s = 0;
        for(String htag: htagSet){
          htagSetTuple.set(s++, htag);
        }
        addTokenToResMap(htagSetTuple, pos, resMap);
        
        // Add the combination with all of ngrams as well
        for (Tuple ngramTuple : existingKeys) {
          Tuple htagNgram = TupleFactory.getInstance().newTuple(ngramTuple.size() + htagSet.size());
          int i = 0;
          for (; i < ngramTuple.size(); ++i) {
            String token = (String) ngramTuple.get(i);
            if (hashtagsStripped.contains(token)) {
              // this is an ngram with our artificially created stripped hashtag
              // so the correlation between this hashtag and other words is arleady
              // accounted for, and we are about to get an artificial correlation
              break;
            }
            htagNgram.set(i, token);

          }
          if (i < ngramTuple.size()) {
            // break from prev loop
            continue;
          }
          for (String htag : htagSet) {
            htagNgram.set(i++, htag);
          }
          // add the tuple as if this ngram starts at the end of the Tweet, but without incrementing pos
          // so that all hashtag ngrams has pos == Tweet length, so we treat them specially
// Iterator<Tuple> tokenPosIter = resMap.get(ngramTuple).iterator();
// while(tokenPosIter.hasNext()){
// Integer p = (Integer) tokenPosIter.next().get(0);
// addTokenToResMap(htagNgram, p, resMap);
// }
          addTokenToResMap(htagNgram, pos, resMap);
        }
      }

// END change array to bag
      Tuple[] resArr = new Tuple[resMap.size()];
      int i = 0;
      for (Tuple ngramTuple : resMap.keySet()) {
// DataByteArray tokenPosList = resMap.get(token);
        DataBag tokenPosList = resMap.get(ngramTuple);
        Tuple tokenTuple = TupleFactory.getInstance().newTuple(4);
        tokenTuple.set(0, ngramTuple);
        tokenTuple.set(1, ngramTuple.size());
        // Tweet length: works well with repeat hashtag at the end FIXME: I don't know what the pos will actually mean
        tokenTuple.set(2, ((tokenIter.getRepeatHashTag() && tokenIter.isRepeatedHashTagAtTheEnd())
            ? tweetLen
            : pos));
        tokenTuple.set(3, (tokenPosList));
        resArr[i++] = tokenTuple;
      }

      DataBag result = BagFactory.getInstance().newDefaultBag(Arrays.asList(resArr));

      return result;

    } catch (Exception e) {
      throw new IOException("Caught exception processing input row "
          + input.toDelimitedString("\t"), e);
    }
  }
  private void addTokenToResMap(Tuple ngram, int pos,
      LinkedHashMap<Tuple, DataBag> resMap) throws ExecException {
    DataBag tokenPosBag = resMap.get(ngram);
    if (tokenPosBag == null) {
      tokenPosBag = BagFactory.getInstance().newDefaultBag();
      resMap.put(ngram, tokenPosBag);
    }
    Tuple posTuple = TupleFactory.getInstance().newTuple(1);
    posTuple.set(0, pos);
    tokenPosBag.add(posTuple);

  }

  public Schema outputSchema(Schema input) {
    try {
      Schema.FieldSchema ngramFs = new Schema.FieldSchema("ngram", DataType.CHARARRAY);
      Schema.FieldSchema ngramLenFs = new Schema.FieldSchema("ngramLen", DataType.INTEGER);
      Schema.FieldSchema tweetLenFs = new Schema.FieldSchema("tweetLen", DataType.INTEGER);

// Schema.FieldSchema posFS = new Schema.FieldSchema("positions", DataType.BYTEARRAY);
// // cannot be handled by FOREACH DataType.BYTE);
//
// Schema tupleSchema = new Schema(Arrays.asList(tokenFs, posFS));

      Schema.FieldSchema posFS = new Schema.FieldSchema("posF", DataType.INTEGER);
      Schema posBag = new Schema(new Schema.FieldSchema("posT", new Schema(posFS), DataType.TUPLE));
      Schema.FieldSchema posBagFS = new Schema.FieldSchema("pos", posBag, DataType.BAG);

      Schema tupleSchema = new Schema(Arrays.asList(ngramFs, ngramLenFs, tweetLenFs, posBagFS));

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
