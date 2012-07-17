package ca.uwaterloo.timeseries;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import com.google.common.collect.Lists;

public class IncrementalChuncksParallelHiers {
	public static List<File> getPathsBefore(File incrementalLoc,
			File[] chuncksLocs, long endTime) throws IOException {
		List<File> ixRds = Lists.newLinkedList();

		long incrEndTime = getPathsForTime(incrementalLoc, true, false,
				Long.MIN_VALUE, ixRds, endTime);
		Arrays.sort(chuncksLocs);
		if (chuncksLocs != null) {
			int i = 0;
			long prevChunkEndTime = incrEndTime;
			while (i < chuncksLocs.length - 1) {
				prevChunkEndTime = getPathsForTime(chuncksLocs[i++], false,
						false, prevChunkEndTime, ixRds, endTime);
			}
			getPathsForTime(chuncksLocs[i], false, true, prevChunkEndTime,
					ixRds, endTime);
		}
		return ixRds;
	}

	private static long getPathsForTime(File parent, boolean pIncremental,
			boolean exceedTime, long windowStart, List<File> filesOut,
			long endTime) throws IOException {
		assert !(pIncremental && exceedTime) : "Those are mutually exclusive modes";
		long result = -1;
		File[] startFolders = parent.listFiles();
		Arrays.sort(startFolders);
		int minIx = -1;
		int maxIx = -1;
		for (int i = 0; i < startFolders.length; ++i) {
			long folderStartTime = Long.parseLong(startFolders[i].getName());
			if (minIx == -1 && folderStartTime >= windowStart) {
				minIx = i;
			}
			if (folderStartTime < endTime) {
				maxIx = i;
			} else {
				break;
			}
		}
		// if (minIx == maxIx) {
		// startFolders = new File[] { startFolders[minIx] };
		// } else {
		// startFolders = Arrays.copyOfRange(startFolders, minIx, maxIx);
		// }
		if (minIx == -1) {
			// This chunk ended where it should have started
			return windowStart;
		}
		startFolders = Arrays.copyOfRange(startFolders, minIx, maxIx + 1);
		for (File startFolder : startFolders) {
			boolean lastOne = false;
			File incrementalFolder = null;
			File[] endFolderArr = startFolder.listFiles();
			Arrays.sort(endFolderArr);
			for (File endFolder : endFolderArr) {
				if (Long.parseLong(endFolder.getName()) > endTime) {
					if (pIncremental) {
						break;
					} else {
						if (exceedTime) {
							lastOne = true;
						} else {
							break;
						}
					}
				}
				if (pIncremental) {
					incrementalFolder = endFolder;
				} else {
					filesOut.add(endFolder);
					result = Long.parseLong(endFolder.getName());
				}
				if (lastOne) {
					assert !pIncremental;
					break;
				}
			}
			if (incrementalFolder != null) {
				assert pIncremental;
				assert startFolders.length == 1;
				filesOut.add(incrementalFolder);
				result = Long.parseLong(incrementalFolder.getName());
				break; // shouldn't be needed
			}
		}
		return result;
	}
}
