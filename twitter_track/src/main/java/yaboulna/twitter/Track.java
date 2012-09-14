package yaboulna.twitter;

import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.nio.channels.Channels;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedList;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import twitter4j.FilterQuery;
import twitter4j.GeoLocation;
import twitter4j.ResponseList;
import twitter4j.StallWarning;
import twitter4j.Status;
import twitter4j.StatusDeletionNotice;
import twitter4j.StatusListener;
import twitter4j.StatusStream;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.TwitterStream;
import twitter4j.TwitterStreamFactory;
import twitter4j.User;

public class Track {
  private static final Logger LOG = LoggerFactory.getLogger(Track.class);
  
  static class QuotedStringBuilder { // extends StringBuilder {
    // Quoting string is the right thing to do for CSV, but will special handling in my other code
    // that deals with incorrect CSV I produced earlier.. so, I have this flag
    boolean correct = false;
    
    StringBuilder orig = new StringBuilder();
    
    public QuotedStringBuilder append(String str) {
      if (correct) {
        orig.append("\"" + str + "\"");
      } else {
        orig.append(str);
      }
      
      return this;
    }
    
    public QuotedStringBuilder append(double d) {
      orig.append(d);
      return this;
    }
    
    public QuotedStringBuilder append(long l) {
      orig.append(l);
      return this;
    }
    
    public QuotedStringBuilder append(char c) {
      orig.append(c);
      return this;
    }
    
    @Override
    public String toString() {
      // TODO Auto-generated method stub
      return orig.toString();
    }
  }
  
  // It will not be compatible with the code that already reads trec files
  // static SimpleDateFormat dateFmt = new SimpleDateFormat("yyyyMMddHHmmss");
  
  public static class DumpingListener implements StatusListener {
    final Writer statiWr;
    
    public DumpingListener(File tempFile) throws IOException {
      statiWr = Channels.newWriter(
          FileUtils.openOutputStream(
              tempFile).getChannel(), "UTF-8");
      // statiWr.append("TimeStamp" + "\t").append("TweetId" + "\t")
      // .append("Text" + "\t")
      // .append("UserId" + "\t")
      // .append("UserName" + "\t")
      // .append("GeoLocation.Latitude" + "\t")
      // .append("GeoLocation.Longitude" + "\t")
      // // .append("Place" + "\t")
      // .append("InReplyToStatusId" + "\t")
      // .append("InReplyToUserId" + "\t")
      // .append("RetweetCount" + "\t").append("Source" + "\n");
      statiWr.append("id\tscreenname\ttimestamp\ttweet\n");
    }
    
    public void onStatus(Status status) {
      String text = status.getText();
      if (text.startsWith("RT ")) {
        // skip retweets!
        return;
      }
      text = StringEscapeUtils.escapeJava(text);
      GeoLocation geoLoc = status.getGeoLocation();
      QuotedStringBuilder line = new QuotedStringBuilder();
      line.append(status.getId())
          .append('\t')
          .append(status.getUser().getScreenName())
          .append('\t')
          .append(status.getCreatedAt().getTime())
          .append('\t')
          .append(text)
//          .append('\t')
//          // line.append(status.getCreatedAt().getTime()) //(System.currentTimeMillis() /
//          // 1000))
//          // .append('\t')
//          // .append(status.getId())
//          // .append('\t')
//          // .append(text)
//          // .append('\t')
//          // .append(status.getUser().getId())
//          // .append('\t')
//          // .append(status.getUser().getName())
//          // .append('\t')
//          .append((geoLoc != null ? geoLoc.getLatitude() : -1))
//          .append('\t')
//          .append((geoLoc != null ? geoLoc.getLongitude()
//              : -1))
//          .append('\t')
//          // .append(status.getPlace()).append('\t')
//          .append(status.getInReplyToStatusId()).append('\t')
//          .append(status.getInReplyToUserId()).append('\t')
//          .append(status.getRetweetCount()).append('\t')
//          .append(status.getSource())
          .append('\n');
      try {
        synchronized (statiWr) {
          statiWr.append(line.toString());
        }
      } catch (IOException e) {
        LOG.error(e.getMessage(), e);
      }
      if (LOG.isTraceEnabled())
        LOG.trace(line.toString());
    }
    
    public void onDeletionNotice(
        StatusDeletionNotice statusDeletionNotice) {
      LOG.warn("Got a status deletion notice id: "
          + statusDeletionNotice.getStatusId());
    }
    
    public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
      LOG.warn("Got track limitation notice: "
          + numberOfLimitedStatuses);
    }
    
    public void onScrubGeo(long userId, long upToStatusId) {
      LOG.warn("Got scrub_geo event userId: " + userId
          + " upToStatusId:" + upToStatusId);
    }
    
    public void onException(Exception ex) {
      LOG.error(ex.getMessage(), ex);
      try {
        synchronized (statiWr) {
          statiWr.flush();
        }
      } catch (IOException ignored) {
      }
    }
    
    @Override
    public void onStallWarning(StallWarning warning) {
      LOG.warn("Got a stall Warning: Put on your parachute! -> " + warning.toString());
    }
    
  }
  
  /**
   * @param args
   * @throws IOException
   * @throws TwitterException
   */
  public static void main(String[] args) {
    String dirname = args[0];
    for (int i = 1; i < args.length; ++i) {
      dirname += "-" + args[i];
    }
    File dir = FileUtils.getFile(dirname, System.currentTimeMillis() + ""); // dateFmt.format(new Date(
    while (true) {
      try {
        File tempFile = FileUtils.getFile(dir, "temp.csv");
        DumpingListener listener = new DumpingListener(tempFile);
        try {
          
          TwitterStream twitterStream = new TwitterStreamFactory()
              .getInstance();
          
          if (args.length > 1) {
            
            twitterStream.addListener(listener);
            
            LinkedList<Long> follow = new LinkedList<Long>();
            LinkedList<String> track = new LinkedList<String>();
            for (String arg : args) {
              String token = arg;
              while (token.startsWith("@") || token.startsWith("#")) {
                token = token.substring(1);
              }
              if (arg.contains("@")) {
                try {
                  Twitter twitter = new TwitterFactory().getInstance();
                  ResponseList<User> users = twitter
                      .lookupUsers(new String[] { token });
                  LOG.info(users.toString());
                  
                  if (users.size() > 0
                      && users.get(0).getScreenName().equals(arg)) {
                    follow.add(users.get(0).getId());
                  }
                } catch (TwitterException te) {
                  te.printStackTrace();
                  LOG.warn("Failed to lookup users: "
                      + te.getMessage());
                }
              }
              if (arg.contains("#")) {
                track.add(token);
              }
            }
            
            long[] followArr = null;
            if (follow.size() > 0) {
              followArr = new long[follow.size()];
              for (int i = 0; i < followArr.length; ++i) {
                followArr[i] = follow.get(i);
              }
            }
            
            String[] trackArr = null;
            if (track.size() > 0) {
              trackArr = new String[track.size()];
              for (int i = 0; i < trackArr.length; ++i) {
                trackArr[i] = "#" + track.get(i);
              }
            }
            
            FilterQuery fq = new FilterQuery(0/* 150000 */, followArr, trackArr);
            // fq.setIncludeEntities(false);
            twitterStream.filter(fq);
          } else {
            StatusStream sample = twitterStream.getSampleStream();
            while (true) {
              try {
                sample.next(listener);
              } catch (IllegalStateException e) {
                if (!"Stream already closed.".equals(e.getMessage())) {
                  LOG.error(e.getMessage(), e);
                }
                
                try {
                  sample.close();
                } catch (IOException ignored) {
                  // I hope the buffer will be closed somehow
                  LOG.trace(ignored.getMessage());
                }
                sample = null;
                throw e;
              }
            }
          }
          
          while (true) {
            int chint = System.in.read();
            if ((char) chint == 'q') {
              
              twitterStream.shutdown();
              twitterStream.cleanUp();
              
              throw new Exception("quit");
            } else if ((char) chint == 'f') {
              synchronized (listener.statiWr) {
                listener.statiWr.flush();
              }
            }
          }
        } finally {
          synchronized (listener.statiWr) {
            listener.statiWr.flush();
            listener.statiWr.close();
            FileUtils.moveFile(tempFile,
                FileUtils.getFile(tempFile.getParentFile(),
                    // dateFmt.format(new Date())));
                    System.currentTimeMillis() + "")); // ".csv"
          }
        }
        
      } catch (Exception ignored) {
        String msg = ignored.getMessage();
        // / this is really bad code.. sorry!
        if ("quit".equals(msg)) {
          break;
        }
        LOG.warn(msg, ignored);
      }
    }
  }
}
