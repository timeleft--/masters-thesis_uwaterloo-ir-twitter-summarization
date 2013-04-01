package yaboulna.fpm;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.List;

import org.apache.commons.io.output.FileWriterWithEncoding;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;

public class HgramWindowTests {

  /**
   * @param args
   * @throws IOException
   */
  public static void main(String[] args) throws IOException {
    File epochOutLocal = new File(args[0]);
    File epochOutText = new File(args[0] + ".txt");
    BufferedReader decodeReader = new BufferedReader(new FileReader(epochOutLocal));
    FileWriterWithEncoding decodeWriter = new FileWriterWithEncoding(epochOutText,
        Charset.forName("UTF-8"));
    try {
      int lnNum = 0;
      String ln;

      List<String> distinctSortedTokens = Lists.newLinkedList();
      List<String> hashtags = Lists.newLinkedList();
      StringBuilder tokenBuilder = new StringBuilder();
      Joiner commaJoiner = Joiner.on(',');
      boolean pendingEndLn = false;
      while ((ln = decodeReader.readLine()) != null) {
        ++lnNum;
        distinctSortedTokens.clear();
        hashtags.clear();

        if (ln.charAt(0) == ' ') {
          if (lnNum == 1) {
            ln = ln.substring(1);
          } else {
            if (pendingEndLn) {
              // this is the transaction ids from lcm
              String[] ids = ln.substring(1).split(" ");
              if (ids.length <= 10) {
                decodeWriter.write("\t" + "tweet" + Integer.parseInt(ids[0]));
                for (int d = 1; d < ids.length; ++d) {
                  decodeWriter.write("," + "tweet" + Integer.parseInt(ids[d]));
                }
              }

              decodeWriter.write("\n");
              pendingEndLn = false;
            }
            // Not pending endln but still needs to be skipped, because prev line was len == 2
            continue;
          }
        } else if (pendingEndLn) {
          decodeWriter.write("\n");
          pendingEndLn = false;
        }

        String[] codes = ln.split(" ");
        if (codes.length == 2) {
          // only the ogram and its frequency
          continue;
        }
        int c;
        for (c = 0; c < codes.length - 1; ++c) {
          String item = "token" + Integer.parseInt(codes[c]);
          if (item.charAt(0) == '#') {
            hashtags.add(item);
            continue;
          }
          // there will be two brackets if the item is not a hashtag
          char[] itemChars = item.toCharArray();
          // the first char is always a bracket
          for (int x = 1; x < itemChars.length; ++x) {
            if (itemChars[x] == ','
                // the last char will be a bracket so we won't add it but will know that we have reached the end
                || x == itemChars.length - 1) {

              String token = tokenBuilder.toString();
              tokenBuilder.setLength(0);

              // Insertion sort of the itemset lexicographically
              int tokenIx = 0;
              for (String sortedToken : distinctSortedTokens) {
                int compRes = sortedToken.compareTo(token);
                if (compRes > 0) {
                  break;
                } else if (compRes == 0) {
                  tokenIx = -1;
                  break;
                }
                ++tokenIx;
              }
              if (tokenIx >= 0) {
                distinctSortedTokens.add(tokenIx, token);
              }

            } else {
              tokenBuilder.append(itemChars[x]);
            }

          }
        }
        for (String htag : hashtags) {
          int htagIx = distinctSortedTokens.indexOf(htag.substring(1));
          if (htagIx == -1) {
            distinctSortedTokens.add(htag);
          } else {
            // TODONE: else, should we replace the naked hashtag with the original one (think #obama obama :( )
            distinctSortedTokens.remove(htagIx);
            distinctSortedTokens.add(htagIx, htag);
          }

        }
        if (distinctSortedTokens.size() != 1) { // 0 is good, becuase it is the number of Tweets

          decodeWriter.write((distinctSortedTokens.size() == 0 ? "NUMTWEETS" :
              commaJoiner.join(distinctSortedTokens)) + "\t"
              + codes[c].substring(0, codes[c].length() - 1).substring(1));
          pendingEndLn = true;
// will be written only after making sure there aren't transaction ids for this itemset: + "\n");
        }
      }

    } finally {
      decodeReader.close();
      decodeWriter.flush();
      decodeWriter.close();
    }

  }

}
