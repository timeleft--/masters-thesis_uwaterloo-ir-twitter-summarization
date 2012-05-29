package yaboulna.twitter;

import java.io.IOException;
import java.io.Writer;
import java.nio.channels.Channels;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedList;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringEscapeUtils;

import twitter4j.FilterQuery;
import twitter4j.GeoLocation;
import twitter4j.ResponseList;
import twitter4j.Status;
import twitter4j.StatusDeletionNotice;
import twitter4j.StatusListener;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.TwitterStream;
import twitter4j.TwitterStreamFactory;
import twitter4j.User;

public class Track {
	static class QuotedStringBuilder { // extends StringBuilder {
		StringBuilder orig = new StringBuilder();

		public QuotedStringBuilder append(String str) {
			orig.append("\"" + str + "\"");
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

	static SimpleDateFormat dateFmt = new SimpleDateFormat("yyyyMMddHHmmss");

	/**
	 * @param args
	 * @throws IOException
	 */
	public static void main(String[] args) throws IOException {
		String fname = args[0];
		for (int i = 1; i < args.length; ++i) {
			fname += "-" + args[i];
		}
		final Writer statiWr = Channels.newWriter(
				FileUtils.openOutputStream(
						//"D:\\datasets\\twitter\\" +
						FileUtils.getFile(fname
								+ "_" + dateFmt.format(new Date()) + ".log")) // manifencours.log"))
						.getChannel(), "UTF-8");
		try {
			statiWr.append("TimeStamp" + "\t").append("TweetId" + "\t")
					.append("Text" + "\t")
					.append("UserId" + "\t")
					.append("UserName" + "\t")
					.append("GeoLocation.Latitude" + "\t")
					.append("GeoLocation.Longitude" + "\t")
					// .append("Place" + "\t")
					.append("InReplyToStatusId" + "\t")
					.append("InReplyToUserId" + "\t")
					.append("RetweetCount" + "\t").append("Source" + "\n");

			StatusListener listener = new StatusListener() {
				public void onStatus(Status status) {
					String text = status.getText();
					if (text.startsWith("RT ")) {
						// skip retweets!
						return;
					}
					text = StringEscapeUtils.escapeJava(text);
					GeoLocation geoLoc = status.getGeoLocation();
					QuotedStringBuilder line = new QuotedStringBuilder();
					line.append((System.currentTimeMillis() / 1000))
							.append('\t')
							.append(status.getId())
							.append('\t')
							.append(text)
							.append('\t')
							.append(status.getUser().getId())
							.append('\t')
							.append(status.getUser().getName())
							.append('\t')
							.append((geoLoc != null ? geoLoc.getLatitude() : -1))
							.append('\t')
							.append((geoLoc != null ? geoLoc.getLongitude()
									: -1))
							.append('\t')
							// .append(status.getPlace()).append('\t')
							.append(status.getInReplyToStatusId()).append('\t')
							.append(status.getInReplyToUserId()).append('\t')
							.append(status.getRetweetCount()).append('\t')
							.append(status.getSource()).append('\n');
					try {
						synchronized (statiWr) {
							statiWr.append(line.toString());
						}
					} catch (IOException e) {

						e.printStackTrace();
					}
					System.out.print(line);
				}

				public void onDeletionNotice(
						StatusDeletionNotice statusDeletionNotice) {
					System.err.println("Got a status deletion notice id:"
							+ statusDeletionNotice.getStatusId());
				}

				public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
					System.err.println("Got track limitation notice:"
							+ numberOfLimitedStatuses);
				}

				public void onScrubGeo(long userId, long upToStatusId) {
					System.err.println("Got scrub_geo event userId:" + userId
							+ " upToStatusId:" + upToStatusId);
				}

				public void onException(Exception ex) {
					ex.printStackTrace();
				}

			};

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
						System.out.println(users.toString());

						if (users.size() > 0
								&& users.get(0).getScreenName().equals(arg)) {
							follow.add(users.get(0).getId());
						}
					} catch (TwitterException te) {
						te.printStackTrace();
						System.out.println("Failed to lookup users: "
								+ te.getMessage());
					}
				}
				if (arg.contains("#")) {
					track.add(token);
				}
			}
			TwitterStream twitterStream = new TwitterStreamFactory()
					.getInstance();
			twitterStream.addListener(listener);

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
			fq.setIncludeEntities(false);
			twitterStream.filter(fq);

			while (true) {
				int chint = System.in.read();
				if ((char) chint == 'q') {

					twitterStream.shutdown();
					twitterStream.cleanUp();

					break;
				} else if ((char) chint == 'f') {
					synchronized (statiWr) {
						statiWr.flush();
					}
				}
			}
		} finally {
			synchronized (statiWr) {
				statiWr.flush();
				statiWr.close();
			}
		}

	}
}
