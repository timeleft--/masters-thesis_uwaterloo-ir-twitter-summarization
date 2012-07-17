package ca.uwaterloo.timeseries;

import java.io.IOException;
import java.util.List;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.PathFilter;

import com.google.common.collect.Lists;

public class IntervalDirsPathsHierarchy {
	public List<Path> getEarlierIntervals(long currTime, String timeRootStr,
			Configuration conf) throws IOException {
		final List<Path> result = Lists.newLinkedList();
		Path timeRoot = new Path(timeRootStr);
		if (conf == null) {
			conf = new Configuration();
		}
		FileSystem fs = FileSystem.get(conf);
		final long currStartTime = currTime;
		for (FileStatus earlierWindow : fs.listStatus(timeRoot,
				new PathFilter() {
					@Override
					public boolean accept(Path p) {
						// should have used end time, but it doesn't make a
						// difference,
						// AS LONG AS windows don't overlap
						return Long.parseLong(p.getName()) < currStartTime;
					}
				})) {
			result.add(fs.listStatus(earlierWindow.getPath())[0].getPath());
		}
		return result;
	}
}
