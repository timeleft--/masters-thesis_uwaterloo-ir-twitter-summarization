package ca.uwaterloo.timeseries;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.GregorianCalendar;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.WeakHashMap;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.mahout.common.Pair;

import com.google.common.collect.Lists;

public class HourMinutesPathHierarchy {
	public static final long FILE_INTERVAL_MILLIS_DEFAULT = 5 * 60 * 1000;
	public static final long FOLDER_INTERVAL_MILLIS_DEFAULT = 60 * 60 * 1000;

	private static Map<String, List<Pair<Long, Path>>> chilrdenCache = Collections
			.synchronizedMap(new WeakHashMap<String, List<Pair<Long, Path>>>());

	public static long getHourTimestamp(Long timestamp) {
		GregorianCalendar calendar = new GregorianCalendar(
				TimeZone.getTimeZone("GMT"));
		calendar.setTimeInMillis(timestamp);
		calendar.set(Calendar.MINUTE, 0);
		calendar.set(Calendar.SECOND, 0);
		calendar.set(Calendar.MILLISECOND, 0);
		return calendar.getTimeInMillis();
	}

	public static Pair<Long, Path> pathForTime(Path hourFolder,
			long exactTime, FileSystem fs) throws IOException {
		Pair<Long, Path> result = null;
		for (Pair<Long, Path> timeFile : getChildrenTimeList(hourFolder, false,
				fs)) {
			if (timeFile.getFirst() > exactTime) {
				result = timeFile;
			} else {
				break;
			}
		}
		return result;
	}

	private static List<Pair<Long, Path>> getChildrenTimeList(Path parent,
			boolean ascendingOrDescending, FileSystem fs) throws IOException {
		int direction = ascendingOrDescending ? 1 : -1;
		List<Pair<Long, Path>> timeList;
		String cacheKey = parent.toString() + direction;
		if (chilrdenCache.containsKey(cacheKey)) {
			timeList = chilrdenCache.get(cacheKey);
		} else {
			List<Path> children = new LinkedList<Path>();
			for (FileStatus status : fs.listStatus(parent)) {
				if (!status.isDir()) {
					children.add(status.getPath());
				}
			}
			Collections.sort(children);
			// File[] children = FileUtils.listFiles(parent, null,
			// false).toArray(new File[0]); // fs.listStatus(parent);
			// TODO: provide OS indpendent comparator
			// Arrays.sort(children);
			int childrenlength = children.size();
			timeList = new ArrayList<Pair<Long, Path>>(childrenlength);

			int i = (ascendingOrDescending ? 0 : childrenlength - 1);
			while (i >= 0 && i < childrenlength) {
				// File child = children[i];
				Path child = children.get(i);
				long childTime = Long.parseLong(child.getName());
				timeList.add(new Pair<Long, Path>(childTime, child));
				i += direction;
			}
			chilrdenCache.put(cacheKey, timeList);
		}
		return timeList;
	}

	public static List<Pair<Long, Path>> getInputPaths(long startTime,
			long windowSize, Path parent) throws IOException {
		return getInputPaths(null, FILE_INTERVAL_MILLIS_DEFAULT, FOLDER_INTERVAL_MILLIS_DEFAULT, startTime,
				Long.MAX_VALUE, windowSize, parent);
	}

	public static List<Pair<Long, Path>> getInputPaths(Configuration conf,
			long fileIntervalMillis, long folderIntervalMillis, long startTime, long endTime,
			long windowSize, Path parent) throws IOException {
		List<Pair<Long, Path>> result = Lists.newLinkedList();
		if(endTime <= 0){
			endTime = Long.MAX_VALUE;
		}
		if (windowSize <= 0) {
			windowSize = endTime - startTime;
		}
		endTime = Math.min(endTime, startTime + windowSize - 1);

		if (conf == null) {
			conf = new Configuration();
		}
		FileSystem fs = FileSystem.get(parent.toUri(), conf);

		long rhs = endTime + fileIntervalMillis;
		while (startTime < endTime) {
			long hourstamp = getHourTimestamp(startTime);
			Pair<Long, Path> folder = new Pair<Long, Path>(hourstamp, new Path(
					parent, hourstamp + ""));
			assert (folder.getFirst() >= startTime && folder.getFirst() < endTime) : "Folder "
					+ folder.getSecond()
					+ " is not suitable for the interval "
					+ startTime + "-" + endTime;
			List<Pair<Long, Path>> children = getChildrenTimeList(
					folder.getSecond(), true, fs);
			int i = 0;
			while (i < children.size()) {
				Pair<Long, Path> child = children.get(i);
				if (child.getFirst() < rhs) {
					if (child.getFirst() > startTime) {
						result.add(child);
					}
				} else {
					break;
				}
				++i;
			}

			startTime += folderIntervalMillis;
		}
		return result;
	}
}
