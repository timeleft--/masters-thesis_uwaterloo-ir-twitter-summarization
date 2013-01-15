package yaboulna.pig;

import java.io.ByteArrayOutputStream;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.DataOutputStream;
import java.io.IOException;
import java.lang.reflect.Method;
import java.lang.reflect.UndeclaredThrowableException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.NavigableMap;
import java.util.Properties;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.filter.BinaryComparator;
import org.apache.hadoop.hbase.filter.ColumnPrefixFilter;
import org.apache.hadoop.hbase.filter.CompareFilter.CompareOp;
import org.apache.hadoop.hbase.filter.FamilyFilter;
import org.apache.hadoop.hbase.filter.Filter;
import org.apache.hadoop.hbase.filter.FilterList;
import org.apache.hadoop.hbase.filter.QualifierFilter;
import org.apache.hadoop.hbase.filter.RowFilter;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableInputFormat;
import org.apache.hadoop.hbase.mapreduce.TableMapReduceUtil;
import org.apache.hadoop.hbase.mapreduce.TableOutputFormat;
import org.apache.hadoop.hbase.mapreduce.TableSplit;
import org.apache.hadoop.hbase.util.Base64;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapreduce.InputFormat;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.OutputFormat;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.RecordWriter;
import org.apache.hadoop.security.UserGroupInformation;
import org.apache.pig.LoadCaster;
import org.apache.pig.LoadFunc;
import org.apache.pig.LoadPushDown;
import org.apache.pig.LoadStoreCaster;
import org.apache.pig.OrderedLoadFunc;
import org.apache.pig.ResourceSchema;
import org.apache.pig.StoreFuncInterface;
import org.apache.pig.backend.executionengine.ExecException;
import org.apache.pig.backend.hadoop.executionengine.mapReduceLayer.PigSplit;
import org.apache.pig.backend.hadoop.hbase.HBaseBinaryConverter;
import org.apache.pig.backend.hadoop.hbase.HBaseTableInputFormat.HBaseTableIFBuilder;
import org.apache.pig.builtin.Utf8StorageConverter;
import org.apache.pig.data.BagFactory;
import org.apache.pig.data.DataBag;
import org.apache.pig.data.DataByteArray;
import org.apache.pig.data.DataType;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.apache.pig.impl.PigContext;
import org.apache.pig.impl.logicalLayer.FrontendException;
import org.apache.pig.impl.util.ObjectSerializer;
import org.apache.pig.impl.util.UDFContext;
import org.apache.pig.impl.util.Utils;

import com.google.common.collect.Lists;

/**
 * Copied from {@link org.apache.pig.backend.hadoop.hbase.HBaseStorage} to
 * change {@link org.apache.pig.backend.hadoop.hbase.HBaseStorage#putNext} to
 * support custom timestamp. It'd be very difficult to do it in a clean way
 * since there was no provisioning to pass the timestamp and thus any change
 * will violate backward compatibility (important to the community).
 * 
 * @author yaboulna
 * 
 */
public class HBaseStorage extends LoadFunc implements StoreFuncInterface,
		LoadPushDown, OrderedLoadFunc {

	private static final Log LOG = LogFactory.getLog(HBaseStorage.class);

	private final static String STRING_CASTER = "UTF8StorageConverter";
	private final static String BYTE_CASTER = "HBaseBinaryConverter";
	private final static String CASTER_PROPERTY = "pig.hbase.caster";
	private final static String ASTERISK = "*";
	private final static String COLON = ":";
	private final static String HBASE_SECURITY_CONF_KEY = "hbase.security.authentication";
	private final static String HBASE_CONFIG_SET = "hbase.config.set";
	private final static String HBASE_TOKEN_SET = "hbase.token.set";
	// YA 2012-12-10 Pound means the tuple will contain the name of the column
	// before its value
	private final static String POUND = "#";
	private final static byte[] EMPTY_BYTE_ARRAY = new byte[0]; // Indicator
																// value.. TODO:
																// have an
																// explicit flag
	// YA 2012-12-10 END

	private List<ColumnInfo> columnInfo_ = Lists.newArrayList();
	private HTable m_table;

	// Use JobConf to store hbase delegation token
	private JobConf m_conf;
	@SuppressWarnings("rawtypes")
	private RecordReader reader;
	@SuppressWarnings("rawtypes")
	private RecordWriter writer;
	@SuppressWarnings("rawtypes")
	private TableOutputFormat outputFormat = null;
	private Scan scan;
	private String contextSignature = null;

	private final CommandLine configuredOptions_;
	private final static Options validOptions_ = new Options();
	private final static CommandLineParser parser_ = new GnuParser();

	private boolean loadRowKey_;
	private String delimiter_;
	private boolean ignoreWhitespace_;
	private final long limit_;
	private final int caching_;
	private final boolean noWAL_;

	protected transient byte[] gt_;
	protected transient byte[] gte_;
	protected transient byte[] lt_;
	protected transient byte[] lte_;

	private LoadCaster caster_;

	private ResourceSchema schema_;
	private RequiredFieldList requiredFieldList;

	private static void populateValidOptions() {
		validOptions_.addOption("loadKey", false, "Load Key");
		validOptions_.addOption("gt", true,
				"Records must be greater than this value "
						+ "(binary, double-slash-escaped)");
		validOptions_
				.addOption("lt", true,
						"Records must be less than this value (binary, double-slash-escaped)");
		validOptions_.addOption("gte", true,
				"Records must be greater than or equal to this value");
		validOptions_.addOption("lte", true,
				"Records must be less than or equal to this value");
		validOptions_.addOption("caching", true,
				"Number of rows scanners should cache");
		validOptions_.addOption("limit", true, "Per-region limit");
		validOptions_.addOption("delim", true, "Column delimiter");
		validOptions_.addOption("ignoreWhitespace", true,
				"Ignore spaces when parsing columns");
		validOptions_
				.addOption(
						"caster",
						true,
						"Caster to use for converting values. A class name, "
								+ "HBaseBinaryConverter, or Utf8StorageConverter. For storage, casters must implement LoadStoreCaster.");
		validOptions_
				.addOption(
						"noWAL",
						false,
						"Sets the write ahead to false for faster loading. To be used with extreme caution since this could result in data loss (see http://hbase.apache.org/book.html#perf.hbase.client.putwal).");
	}

	/**
	 * Constructor. Construct a HBase Table LoadFunc and StoreFunc to load or
	 * store the cells of the provided columns.
	 * 
	 * @param columnList
	 *            columnlist that is a presented string delimited by space
	 *            and/or commas. To retreive all columns in a column family
	 *            <code>Foo</code>, specify a column as either <code>Foo:</code>
	 *            or <code>Foo:*</code>. To fetch only columns in the CF that
	 *            start with <I>bar</I>, specify <code>Foo:bar*</code>. The
	 *            resulting tuple will always be the size of the number of
	 *            tokens in <code>columnList</code>. Items in the tuple will be
	 *            scalar values when a full column descriptor is specified, or a
	 *            map of column descriptors to values when a column family is
	 *            specified.
	 * 
	 * @throws ParseException
	 *             when unable to parse arguments
	 * @throws IOException
	 */
	public HBaseStorage(String columnList) throws ParseException, IOException {
		this(columnList, "");
	}

	/**
	 * Constructor. Construct a HBase Table LoadFunc and StoreFunc to load or
	 * store.
	 * 
	 * @param columnList
	 * @param optString
	 *            Loader options. Known options:
	 *            <ul>
	 *            <li>-loadKey=(true|false) Load the row key as the first column
	 *            <li>-gt=minKeyVal
	 *            <li>-lt=maxKeyVal
	 *            <li>-gte=minKeyVal
	 *            <li>-lte=maxKeyVal
	 *            <li>-limit=numRowsPerRegion max number of rows to retrieve per
	 *            region
	 *            <li>-delim=char delimiter to use when parsing column names
	 *            (default is space or comma)
	 *            <li>-ignoreWhitespace=(true|false) ignore spaces when parsing
	 *            column names (default true)
	 *            <li>-caching=numRows number of rows to cache (faster scans,
	 *            more memory).
	 *            <li>-noWAL=(true|false) Sets the write ahead to false for
	 *            faster loading. To be used with extreme caution, since this
	 *            could result in data loss (see
	 *            http://hbase.apache.org/book.html#perf.hbase.client.putwal).
	 *            </ul>
	 * @throws ParseException
	 * @throws IOException
	 */
	public HBaseStorage(String columnList, String optString)
			throws ParseException, IOException {
		populateValidOptions();
		String[] optsArr = optString.split(" ");
		try {
			configuredOptions_ = parser_.parse(validOptions_, optsArr);
		} catch (ParseException e) {
			HelpFormatter formatter = new HelpFormatter();
			formatter
					.printHelp(
							"[-loadKey] [-gt] [-gte] [-lt] [-lte] [-columnPrefix] [-caching] [-caster] [-noWAL] [-limit] [-delim] [-ignoreWhitespace]",
							validOptions_);
			throw e;
		}

		loadRowKey_ = true;
		if (configuredOptions_.hasOption("loadKey")) {
			String value = configuredOptions_.getOptionValue("loadKey");
			if (!"true".equalsIgnoreCase(value)) {
				loadRowKey_ = false;
			}
		}

		delimiter_ = ",";
		if (configuredOptions_.getOptionValue("delim") != null) {
			delimiter_ = configuredOptions_.getOptionValue("delim");
		}

		ignoreWhitespace_ = true;
		if (configuredOptions_.hasOption("ignoreWhitespace")) {
			String value = configuredOptions_
					.getOptionValue("ignoreWhitespace");
			if (!"true".equalsIgnoreCase(value)) {
				ignoreWhitespace_ = false;
			}
		}

		columnInfo_ = parseColumnList(columnList, delimiter_, ignoreWhitespace_);

		String defaultCaster = UDFContext.getUDFContext()
				.getClientSystemProps()
				.getProperty(CASTER_PROPERTY, STRING_CASTER);
		String casterOption = configuredOptions_.getOptionValue("caster",
				defaultCaster);
		if (STRING_CASTER.equalsIgnoreCase(casterOption)) {
			caster_ = new Utf8StorageConverter();
		} else if (BYTE_CASTER.equalsIgnoreCase(casterOption)) {
			caster_ = new HBaseBinaryConverter();
		} else {
			try {
				caster_ = (LoadCaster) PigContext
						.instantiateFuncFromSpec(casterOption);
			} catch (ClassCastException e) {
				LOG.error("Configured caster does not implement LoadCaster interface.");
				throw new IOException(e);
			} catch (RuntimeException e) {
				LOG.error("Configured caster class not found.", e);
				throw new IOException(e);
			}
		}
		LOG.debug("Using caster " + caster_.getClass());

		caching_ = Integer.valueOf(configuredOptions_.getOptionValue("caching",
				"100"));
		limit_ = Long.valueOf(configuredOptions_.getOptionValue("limit", "-1"));
		noWAL_ = configuredOptions_.hasOption("noWAL");
		initScan();
	}

	/**
	 * Returns UDFProperties based on <code>contextSignature</code>.
	 */
	private Properties getUDFProperties() {
		return UDFContext.getUDFContext().getUDFProperties(this.getClass(),
				new String[] { contextSignature });
	}

	/**
	 * @return <code> contextSignature + "_projectedFields" </code>
	 */
	private String projectedFieldsName() {
		return contextSignature + "_projectedFields";
	}

	/**
	 * 
	 * @param columnList
	 * @param delimiter
	 * @param ignoreWhitespace
	 * @return
	 */
	private List<ColumnInfo> parseColumnList(String columnList,
			String delimiter, boolean ignoreWhitespace) {
		List<ColumnInfo> columnInfo = new ArrayList<ColumnInfo>();

		// Default behavior is to allow combinations of spaces and delimiter
		// which defaults to a comma. Setting to not ignore whitespace will
		// include the whitespace in the columns names
		String[] colNames = columnList.split(delimiter);
		if (ignoreWhitespace) {
			List<String> columns = new ArrayList<String>();

			for (String colName : colNames) {
				String[] subColNames = colName.split(" ");

				for (String subColName : subColNames) {
					subColName = subColName.trim();
					if (subColName.length() > 0)
						columns.add(subColName);
				}
			}

			colNames = columns.toArray(new String[columns.size()]);
		}

		for (String colName : colNames) {
			// YA 20121210-03 Supporting passing a tuple of interleaved key and
			// values
			// columnInfo.add(new ColumnInfo(colName));
			columnInfo.addAll(ColumnInfo.factory(colName));
			// YA 20121210-03 END
		}

		return columnInfo;
	}

	private void initScan() {
		scan = new Scan();
		// YA 20121212 Always get all available versions
		scan.setMaxVersions();
		// Map-reduce jobs should not run with cacheBlocks
		scan.setCacheBlocks(false);

		// Set filters, if any.
		if (configuredOptions_.hasOption("gt")) {
			gt_ = Bytes.toBytesBinary(Utils.slashisize(configuredOptions_
					.getOptionValue("gt")));
			addRowFilter(CompareOp.GREATER, gt_);
		}
		if (configuredOptions_.hasOption("lt")) {
			lt_ = Bytes.toBytesBinary(Utils.slashisize(configuredOptions_
					.getOptionValue("lt")));
			addRowFilter(CompareOp.LESS, lt_);
		}
		if (configuredOptions_.hasOption("gte")) {
			gte_ = Bytes.toBytesBinary(Utils.slashisize(configuredOptions_
					.getOptionValue("gte")));
			addRowFilter(CompareOp.GREATER_OR_EQUAL, gte_);
		}
		if (configuredOptions_.hasOption("lte")) {
			lte_ = Bytes.toBytesBinary(Utils.slashisize(configuredOptions_
					.getOptionValue("lte")));
			addRowFilter(CompareOp.LESS_OR_EQUAL, lte_);
		}
		
		//YA 20130114 Adding support for "row equals something"
		if (configuredOptions_.hasOption("eq")) {
			// Not used elsewhere because the table output format doesn't support equals
			byte[] eq_ = Bytes.toBytesBinary(Utils.slashisize(configuredOptions_
					.getOptionValue("eq")));
			addRowFilter(CompareOp.EQUAL, eq_);
		}
		// END YA 201301014

		// apply any column filters
		FilterList allColumnFilters = null;
		for (ColumnInfo colInfo : columnInfo_) {
			// all column family filters roll up to one parent OR filter
			if (allColumnFilters == null) {
				allColumnFilters = new FilterList(
						FilterList.Operator.MUST_PASS_ONE);
			}

			// and each filter contains a column family filter
			FilterList thisColumnFilter = new FilterList(
					FilterList.Operator.MUST_PASS_ALL);
			thisColumnFilter.addFilter(new FamilyFilter(CompareOp.EQUAL,
					new BinaryComparator(colInfo.getColumnFamily())));

			if (colInfo.isColumnMap()) {

				if (LOG.isInfoEnabled()) {
					LOG.info("Adding family:prefix filters with values "
							+ Bytes.toString(colInfo.getColumnFamily()) + COLON
							+ Bytes.toString(colInfo.getColumnPrefix()));
				}

				// each column map filter consists of a FamilyFilter AND
				// optionally a PrefixFilter
				if (colInfo.getColumnPrefix() != null) {
					thisColumnFilter.addFilter(new ColumnPrefixFilter(colInfo
							.getColumnPrefix()));
				}
			} else if (colInfo.getColumnName() == EMPTY_BYTE_ARRAY) {
				// YA 20121210
				// No filtering necessary
				// YA 20121210 END
			} else {

				if (LOG.isInfoEnabled()) {
					LOG.info("Adding family:descriptor filters with values "
							+ Bytes.toString(colInfo.getColumnFamily()) + COLON
							+ Bytes.toString(colInfo.getColumnName()));
				}

				// each column value filter consists of a FamilyFilter AND
				// a QualifierFilter
				thisColumnFilter.addFilter(new QualifierFilter(CompareOp.EQUAL,
						new BinaryComparator(colInfo.getColumnName())));
			}

			allColumnFilters.addFilter(thisColumnFilter);
		}

		if (allColumnFilters != null) {
			addFilter(allColumnFilters);
		}
	}

	private void addRowFilter(CompareOp op, byte[] val) {
		if (LOG.isInfoEnabled()) {
			LOG.info("Adding filter " + op.toString() + " with value "
					+ Bytes.toStringBinary(val));
		}
		addFilter(new RowFilter(op, new BinaryComparator(val)));
	}

	private void addFilter(Filter filter) {
		FilterList scanFilter = (FilterList) scan.getFilter();
		if (scanFilter == null) {
			scanFilter = new FilterList(FilterList.Operator.MUST_PASS_ALL);
		}
		scanFilter.addFilter(filter);
		scan.setFilter(scanFilter);
	}

	/**
	 * Returns the ColumnInfo list for so external objects can inspect it. This
	 * is available for unit testing. Ideally, the unit tests and the main
	 * source would each mirror the same package structure and this method could
	 * be package private.
	 * 
	 * @return ColumnInfo
	 */
	public List<ColumnInfo> getColumnInfoList() {
		return columnInfo_;
	}

	/**
	 * YA 20121212 Return versions as a bag, in another bag with a tuple for
	 * each column qualifier. All of this is another tuple, optionally
	 * containing the row key. The schema is: (OptionalROWKey, {(COLQualifier,
	 * {(VERSION==SNOWFLAKE, {POS as int})})})
	 * 
	 */
	@Override
	public Tuple getNext() throws IOException {

		try {
			if (reader.nextKeyValue()) {
				ImmutableBytesWritable rowKey = (ImmutableBytesWritable) reader
						.getCurrentKey();
				Result result = (Result) reader.getCurrentValue();

				int tupleSize = columnInfo_.size();

				// use a map of families -> qualifiers with the most recent
				// version of the cell. Fetching multiple vesions could be a
				// useful feature.
				// YA 20121212 NavigableMap<byte[], NavigableMap<byte[],
				// byte[]>> resultsMap =
				// result.getNoVersionMap();
				NavigableMap<byte[], NavigableMap<byte[], NavigableMap<Long, byte[]>>> resultsMap = result
						.getMap();

				// YA 20121212
				Tuple container;
				int tupleOffset;
				if (loadRowKey_) {
					tupleSize = tupleSize + 1; // +1 for the ROW ID
					container = TupleFactory.getInstance().newTuple(tupleSize);
					container.set(0, new DataByteArray(rowKey.get()));
					tupleOffset = 1;
				} else {
					container = TupleFactory.getInstance().newTuple(tupleSize); // {(COL,
																				// BAG)}
																				// per
																				// column
					tupleOffset = 0;
				}
				// int startIndex = 0;
				// if (loadRowKey_) {
				// tuple.set(0, new DataByteArray(rowKey.get()));
				// startIndex++;
				// }
				// END YA 20121212

				for (int i = 0; i < columnInfo_.size(); ++i) {
					ColumnInfo columnInfo = columnInfo_.get(i);

					NavigableMap<byte[], NavigableMap<Long, byte[]>> cfResults = resultsMap
							.get(columnInfo.getColumnFamily());

					if (cfResults != null) {
						DataBag cfBag = BagFactory.getInstance()
								.newDefaultBag();
						container.set(tupleOffset + i, cfBag);
						if (columnInfo.isColumnMap()) {
							// It's a column family so we need to iterate and
							// set all
							// values found
							for (byte[] qualifier : cfResults.keySet()) {
								// We need to check against the prefix filter to
								// see if this value should be included. We
								// can't
								// just rely on the server-side filter, since a
								// user could specify multiple CF filters for
								// the
								// same CF.
								if (columnInfo.getColumnPrefix() == null
										|| columnInfo.hasPrefixMatch(qualifier)) {
									addQualifierVersions(qualifier, cfResults,
											cfBag);
								}
							}
						} else if (columnInfo.getColumnName() == EMPTY_BYTE_ARRAY) {
							// YA 20121210
							throw new IOException(
									"Cannot use pound while reading");
							// YA 20121210 END
						} else {
							// It's a column so set the value
							addQualifierVersions(columnInfo.getColumnName(),
									cfResults, cfBag);

						}
					} else {
						container.set(tupleOffset + i, Tuple.NULL);
					}
				}
				return container; // tuple;
			}
		} catch (InterruptedException e) {
			throw new IOException(e);
		}
		return null;
	}

	private void addQualifierVersions(byte[] qualifier,
			NavigableMap<byte[], NavigableMap<Long, byte[]>> cfResults,
			DataBag cfBag) throws ExecException {
		DataBag verBag = BagFactory.getInstance().newDefaultBag();

		Tuple qualifierVersTuple = TupleFactory.getInstance().newTuple(2);
		qualifierVersTuple.set(0, new DataByteArray(qualifier));
		qualifierVersTuple.set(1, verBag);

		cfBag.add(qualifierVersTuple);

		// byte[] cell = cfResults.get(quantifier);
		NavigableMap<Long, byte[]> versionMap = cfResults.get(qualifier);
		for (Long version : versionMap.keySet()) {
			byte[] cell = versionMap.get(version);

			// YA 20130114 Positions should be in a bag, interpretted as
			// integers
			// DataByteArray value =
			// cell == null ? new DataByteArray(new byte[] { Tuple.NULL }) : new
			// DataByteArray(cell);
			DataBag value = BagFactory.getInstance().newDefaultBag();

			if (cell == null) {
				Tuple nullTuple = TupleFactory.getInstance().newTuple(1);
				nullTuple.setNull(true);
				value.add(nullTuple);
			} else {
				for (byte pos : cell) {
					Tuple posTuple = TupleFactory.getInstance().newTuple(1);
					posTuple.set(0, (int) (0xff & pos));
					value.add(posTuple);
				}
			}
			// END exploding array into bag

			Tuple verValueTuple = TupleFactory.getInstance().newTuple(2);

			verValueTuple.set(0, version);
			verValueTuple.set(1, value);

			verBag.add(verValueTuple);
			if (LOG.isDebugEnabled()) {
				LOG.debug("Added qualifier version: ("
						+ Arrays.toString(qualifier) + ", " + version + ", "
						+ value);
			}
		}
	}

	@SuppressWarnings("rawtypes")
	@Override
	public InputFormat getInputFormat() {
		TableInputFormat inputFormat = new HBaseTableIFBuilder()
				.withLimit(limit_).withGt(gt_).withGte(gte_).withLt(lt_)
				.withLte(lte_).withConf(m_conf).build();
		return inputFormat;
	}

	@Override
	public void prepareToRead(
			@SuppressWarnings("rawtypes") RecordReader reader, PigSplit split) {
		this.reader = reader;
	}

	@Override
	public void setUDFContextSignature(String signature) {
		this.contextSignature = signature;
	}

	@Override
	public void setLocation(String location, Job job) throws IOException {
		Properties udfProps = getUDFProperties();
		job.getConfiguration().setBoolean("pig.noSplitCombination", true);

		initialiseHBaseClassLoaderResources(job);
		m_conf = initializeLocalJobConfig(job);
		String delegationTokenSet = udfProps.getProperty(HBASE_TOKEN_SET);
		if (delegationTokenSet == null) {
			addHBaseDelegationToken(m_conf, job);
			udfProps.setProperty(HBASE_TOKEN_SET, "true");
		}

		String tablename = location;
		if (location.startsWith("hbase://")) {
			tablename = location.substring(8);
		}

		// // Supporting partitions by days TODO(yaboulna): Pass the partition
		// postfix instead of time
		// int colonIx = tablename.indexOf(':');
		// if (colonIx != -1) {
		// long timestamp = Long.parseLong(tablename.substring(colonIx + 1));
		// // Interpreting the timestamp using the timezone GMT-10 so that day
		// boundaries
		// // fall at 3 and 5 AM in North America West and East coast
		// Calendar gregCal = new
		// GregorianCalendar(TimeZone.getTimeZone("GMT-10"));
		// gregCal.setTimeInMillis(timestamp);
		// tablename = tablename.substring(0, colonIx)
		// + "_" + gregCal.get(Calendar.YEAR)
		// + "-" + (gregCal.get(Calendar.MONTH) + 1) // +1 because Jan is 0..
		// duh!!
		// + "-" + gregCal.get(Calendar.DAY_OF_MONTH);
		// }

		if (m_table == null) {
			m_table = new HTable(m_conf, tablename);
		}
		m_table.setScannerCaching(caching_);
		m_conf.set(TableInputFormat.INPUT_TABLE, tablename);

		String projectedFields = udfProps.getProperty(projectedFieldsName());
		if (projectedFields != null) {
			// update columnInfo_
			pushProjection((RequiredFieldList) ObjectSerializer
					.deserialize(projectedFields));
		}

		for (ColumnInfo columnInfo : columnInfo_) {
			// do we have a column family, or a column?
			if (columnInfo.isColumnMap()
					|| columnInfo.getColumnName() == EMPTY_BYTE_ARRAY) {
				scan.addFamily(columnInfo.getColumnFamily());
			} else {
				scan.addColumn(columnInfo.getColumnFamily(),
						columnInfo.getColumnName());
			}

		}
		if (requiredFieldList != null) {
			Properties p = UDFContext.getUDFContext().getUDFProperties(
					this.getClass(), new String[] { contextSignature });
			p.setProperty(contextSignature + "_projectedFields",
					ObjectSerializer.serialize(requiredFieldList));
		}
		m_conf.set(TableInputFormat.SCAN, convertScanToString(scan));
	}

	private void initialiseHBaseClassLoaderResources(Job job)
			throws IOException {
		// Make sure the HBase, ZooKeeper, and Guava jars get shipped.
		TableMapReduceUtil.addDependencyJars(job.getConfiguration(),
				org.apache.hadoop.hbase.client.HTable.class,
				com.google.common.collect.Lists.class,
				org.apache.zookeeper.ZooKeeper.class);

	}

	private JobConf initializeLocalJobConfig(Job job) {
		Properties udfProps = getUDFProperties();
		Configuration jobConf = job.getConfiguration();
		JobConf localConf = new JobConf(jobConf);
		if (udfProps.containsKey(HBASE_CONFIG_SET)) {
			for (Entry<Object, Object> entry : udfProps.entrySet()) {
				localConf.set((String) entry.getKey(),
						(String) entry.getValue());
			}
		} else {
			Configuration hbaseConf = HBaseConfiguration.create();
			for (Entry<String, String> entry : hbaseConf) {
				// JobConf may have some conf overriding ones in hbase-site.xml
				// So only copy hbase config not in job config to UDFContext
				// Also avoids copying core-default.xml and core-site.xml
				// props in hbaseConf to UDFContext which would be redundant.
				if (jobConf.get(entry.getKey()) == null) {
					udfProps.setProperty(entry.getKey(), entry.getValue());
					localConf.set(entry.getKey(), entry.getValue());
				}
			}
			udfProps.setProperty(HBASE_CONFIG_SET, "true");
		}
		return localConf;
	}

	/**
	 * Get delegation token from hbase and add it to the Job
	 * 
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	private void addHBaseDelegationToken(Configuration hbaseConf, Job job) {

		if (!UDFContext.getUDFContext().isFrontend()) {
			return;
		}

		if ("kerberos".equalsIgnoreCase(hbaseConf.get(HBASE_SECURITY_CONF_KEY))) {
			try {
				// getCurrentUser method is not public in 0.20.2
				Method m1 = UserGroupInformation.class
						.getMethod("getCurrentUser");
				UserGroupInformation currentUser = (UserGroupInformation) m1
						.invoke(null, (Object[]) null);
				// Class and method are available only from 0.92 security
				// release
				Class tokenUtilClass = Class
						.forName("org.apache.hadoop.hbase.security.token.TokenUtil");
				Method m2 = tokenUtilClass.getMethod("obtainTokenForJob",
						new Class[] { Configuration.class,
								UserGroupInformation.class, Job.class });
				m2.invoke(null, new Object[] { hbaseConf, currentUser, job });
			} catch (ClassNotFoundException cnfe) {
				throw new RuntimeException("Failure loading TokenUtil class, "
						+ "is secure RPC available?", cnfe);
			} catch (RuntimeException re) {
				throw re;
			} catch (Exception e) {
				throw new UndeclaredThrowableException(e,
						"Unexpected error calling TokenUtil.obtainTokenForJob()");
			}
		}
	}

	@Override
	public String relativeToAbsolutePath(String location, Path curDir)
			throws IOException {
		return location;
	}

	private static String convertScanToString(Scan scan) {
		try {
			ByteArrayOutputStream out = new ByteArrayOutputStream();
			DataOutputStream dos = new DataOutputStream(out);
			scan.write(dos);
			return Base64.encodeBytes(out.toByteArray());
		} catch (IOException e) {
			LOG.error(e);
			return "";
		}

	}

	/**
	 * Set up the caster to use for reading values out of, and writing to,
	 * HBase.
	 */
	@Override
	public LoadCaster getLoadCaster() throws IOException {
		return caster_;
	}

	/*
	 * StoreFunc Methods
	 * 
	 * @see org.apache.pig.StoreFuncInterface#getOutputFormat()
	 */

	@SuppressWarnings("rawtypes")
	@Override
	public OutputFormat getOutputFormat() throws IOException {
		if (outputFormat == null) {
			if (m_conf == null) {
				throw new IllegalStateException(
						"setStoreLocation has not been called");
			} else {
				this.outputFormat = new TableOutputFormat();
				this.outputFormat.setConf(m_conf);
			}
		}
		return outputFormat;
	}

	@Override
	public void checkSchema(ResourceSchema s) throws IOException {
		if (!(caster_ instanceof LoadStoreCaster)) {
			LOG.error("Caster must implement LoadStoreCaster for writing to HBase.");
			throw new IOException("Bad Caster " + caster_.getClass());
		}
		schema_ = s;
		getUDFProperties().setProperty(contextSignature + "_schema",
				ObjectSerializer.serialize(schema_));
	}

	// Suppressing unchecked warnings for RecordWriter, which is not
	// parameterized by StoreFuncInterface
	@Override
	public void prepareToWrite(@SuppressWarnings("rawtypes") RecordWriter writer)
			throws IOException {
		this.writer = writer;
	}

	// Suppressing unchecked warnings for RecordWriter, which is not
	// parameterized by StoreFuncInterface
	@SuppressWarnings("unchecked")
	@Override
	public void putNext(Tuple timestampedT) throws IOException {
		if (timestampedT == null || timestampedT.isNull()
				|| timestampedT.isNull(0)) {
			LOG.info("putNext called with nothing to put");
			return;
		} else if (timestampedT.getType(0) != DataType.TUPLE) {
			LOG.error("This version of putNext takes the values to put as a tuple in index 0 of the tuple"
					+ " passed as an argument; e.g., putNext((values, to, put), optionalTimestamp)");
			return;
		}
		Tuple t = (Tuple) timestampedT.get(0);
		long ts = (timestampedT.size() < 2 || timestampedT.isNull(1) ? System
				.currentTimeMillis() : (Long) timestampedT.get(1));

		// YA 2012-12-10 For some reason the schema become all DataByteArray by
		// the time it is here
		// The schema below is the correct one but it is not a good one.. will
		// not use it at all
		// // The schema passed is that of the timestampedT and we'll be using
		// the first tuple of it
		// // ResourceFieldSchema[] fieldSchemas = (schema_ == null) ? null :
		// schema_.getFields();
		// ResourceFieldSchema[] fieldSchemas = (schema_ == null) ? null :
		// schema_.getFields()[0]
		// .getSchema().getFields();
		// // TODO I need to be able to print LOG messages.. why does this
		// Pig/Hadoop creature hate me?
		// if (LOG.isDebugEnabled()) {
		// LOG.warn("contextSignature == " + contextSignature);
		// LOG.warn("Schema == " + Arrays.toString(fieldSchemas));
		// }
		// byte type = (fieldSchemas == null) ? DataType.findType(t.get(0)) :
		// fieldSchemas[0].getType();

		try {
			if (LOG.isDebugEnabled()) {
				LOG.debug("putNext - key=" + t.get(0) + ", type="
						+ t.getType(0));
			}
			Put put = createPut(t.get(0), t.getType(0)); // type);

			if (LOG.isDebugEnabled()) {
				LOG.debug("putNext -- WAL disabled: " + noWAL_);
				for (ColumnInfo columnInfo : columnInfo_) {
					LOG.debug("putNext -- col: " + columnInfo);
				}
			}

			for (int i = 1; i < t.size(); ++i) {
				ColumnInfo columnInfo = columnInfo_.get(i - 1);
				if (LOG.isDebugEnabled()) {
					LOG.debug("putNext - tuple: " + i + ", value=" + t.get(i)
							+ ", cf:column=" + columnInfo);
				}

				if (columnInfo.isColumnMap()) {
					Map<String, Object> cfMap = (Map<String, Object>) t.get(i);
					for (String colName : cfMap.keySet()) {
						if (LOG.isDebugEnabled()) {
							LOG.debug("putNext - colName=" + colName
									+ ", class: " + colName.getClass());
						}
						// TODO deal with the fact that maps can have types now.
						// Currently we detect types at
						// runtime in the case of storing to a cf, which is
						// suboptimal.
						put.add(columnInfo.getColumnFamily(),
								Bytes.toBytes(colName.toString()),
								ts,
								objToBytes(cfMap.get(colName),
										DataType.findType(cfMap.get(colName))));
					}
				} else if (columnInfo.getColumnName() == EMPTY_BYTE_ARRAY) { // all
																				// are
																				// ==
																				// to
																				// the
																				// static
																				// array
					// YA 2012-12-10 using the next column info as the column
					// name if the name is an empty array
					// ColumnInfo columnInfoKey = columnInfo;

					columnInfo = null; // just as a guard
					byte[] keyBytes = objToBytes(t.get(i), t.getType(i));
					// (fieldSchemas == null) ? DataType.findType(t.get(i))
					// // Make sure to the key in schema so that the index
					// matches
					// : fieldSchemas[i].getType());
					++i;
					assert i <= columnInfo_.size() && i < t.size();

					ColumnInfo columnInfoVal = columnInfo_.get(i - 1);
					put.add(columnInfoVal.getColumnFamily(), keyBytes, ts,
							objToBytes(t.get(i), t.getType(i)));
					// (fieldSchemas == null) ? DataType.findType(t.get(i))
					// // Make sure to the key in schema so that the index
					// matches
					// : fieldSchemas[i].getType()));

					// YA 2012-12-10 END
				} else {
					put.add(columnInfo.getColumnFamily(),
							columnInfo.getColumnName(), ts,
							objToBytes(t.get(i), t.getType(i)));
					// (fieldSchemas == null) ?DataType.findType(t.get(i)) :
					// fieldSchemas[i].getType()));
				}
			}

			// try {
			writer.write(null, put);
			// } catch (InterruptedException e) {
			// throw new IOException(e);
			// }
		} catch (Exception e) {
			LOG.error("Exception while putting tuple: (" + t
					+ ") at timestamp: " + ts);
			LOG.error(e, e);
		}

	}

	/**
	 * Public method to initialize a Put. Used to allow assertions of how Puts
	 * are initialized by unit tests.
	 * 
	 * @param key
	 * @param type
	 * @return new put
	 * @throws IOException
	 */
	public Put createPut(Object key, byte type) throws IOException {
		Put put = new Put(objToBytes(key, type));

		if (noWAL_) {
			put.setWriteToWAL(false);
		}

		return put;
	}

	@SuppressWarnings("unchecked")
	private byte[] objToBytes(Object o, byte type) throws IOException {
		if (LOG.isDebugEnabled()) {
			LOG.debug("Casting " + o + " of class " + o.getClass() + " to "
					+ type + " using " + caster_);
		}
		LoadStoreCaster caster = (LoadStoreCaster) caster_;
		if (o == null)
			return null;
		switch (type) {
		case DataType.BYTEARRAY:
			return ((DataByteArray) o).get();
		case DataType.BAG:
			return caster.toBytes((DataBag) o);
		case DataType.CHARARRAY:
			return caster.toBytes((String) o);
		case DataType.DOUBLE:
			return caster.toBytes((Double) o);
		case DataType.FLOAT:
			return caster.toBytes((Float) o);
		case DataType.INTEGER:
			return caster.toBytes((Integer) o);
		case DataType.LONG:
			return caster.toBytes((Long) o);
		case DataType.BOOLEAN:
			return caster.toBytes((Boolean) o);

			// The type conversion here is unchecked.
			// Relying on DataType.findType to do the right thing.
		case DataType.MAP:
			return caster.toBytes((Map<String, Object>) o);

		case DataType.NULL:
			return null;
		case DataType.TUPLE:
			return caster.toBytes((Tuple) o);
		case DataType.ERROR:
			throw new IOException("Unable to determine type of " + o.getClass());
		default:
			throw new IOException("Unable to find a converter for tuple field "
					+ o);
		}
	}

	@Override
	public String relToAbsPathForStoreLocation(String location, Path curDir)
			throws IOException {
		return location;
	}

	@Override
	public void setStoreFuncUDFContextSignature(String signature) {
		this.contextSignature = signature;
	}

	@Override
	public void setStoreLocation(String location, Job job) throws IOException {
		if (location.startsWith("hbase://")) {
			job.getConfiguration().set(TableOutputFormat.OUTPUT_TABLE,
					location.substring(8));
		} else {
			job.getConfiguration()
					.set(TableOutputFormat.OUTPUT_TABLE, location);
		}

		String serializedSchema = getUDFProperties().getProperty(
				contextSignature + "_schema");
		if (serializedSchema != null) {
			schema_ = (ResourceSchema) ObjectSerializer
					.deserialize(serializedSchema);
		}

		initialiseHBaseClassLoaderResources(job);
		m_conf = initializeLocalJobConfig(job);
		// Not setting a udf property and getting the hbase delegation token
		// only once like in setLocation as setStoreLocation gets different Job
		// objects for each call and the last Job passed is the one that is
		// launched. So we end up getting multiple hbase delegation tokens.
		addHBaseDelegationToken(m_conf, job);
	}

	@Override
	public void cleanupOnFailure(String location, Job job) throws IOException {
	}

	/*
	 * LoadPushDown Methods.
	 */

	@Override
	public List<OperatorSet> getFeatures() {
		return Arrays.asList(LoadPushDown.OperatorSet.PROJECTION);
	}

	@Override
	public RequiredFieldResponse pushProjection(
			RequiredFieldList requiredFieldList) throws FrontendException {
		List<RequiredField> requiredFields = requiredFieldList.getFields();
		List<ColumnInfo> newColumns = Lists
				.newArrayListWithExpectedSize(requiredFields.size());

		if (this.requiredFieldList != null) {
			// in addition to PIG, this is also called by this.setLocation().
			LOG.debug("projection is already set. skipping.");
			return new RequiredFieldResponse(true);
		}

		/*
		 * How projection is handled : - pushProjection() is invoked by PIG on
		 * the front end - pushProjection here both stores serialized projection
		 * in the context and adjusts columnInfo_. - setLocation() is invoked on
		 * the backend and it reads the projection from context. setLocation
		 * invokes this method again so that columnInfo_ is adjected.
		 */

		// colOffset is the offset in our columnList that we need to apply to
		// indexes we get from
		// requiredFields
		// (row key is not a real column)
		int colOffset = loadRowKey_ ? 1 : 0;
		// projOffset is the offset to the requiredFieldList we need to apply
		// when figuring out which
		// columns to prune.
		// (if key is pruned, we should skip row key's element in this list when
		// trimming colList)
		int projOffset = colOffset;
		this.requiredFieldList = requiredFieldList;

		if (requiredFieldList != null
				&& requiredFields.size() > (columnInfo_.size() + colOffset)) {
			throw new FrontendException(
					"The list of columns to project from HBase is larger than HBaseStorage is configured to load.");
		}

		// remember the projection
		try {
			getUDFProperties().setProperty(projectedFieldsName(),
					ObjectSerializer.serialize(requiredFieldList));
		} catch (IOException e) {
			throw new FrontendException(e);
		}

		if (loadRowKey_
				&& (requiredFields.size() < 1 || requiredFields.get(0)
						.getIndex() != 0)) {
			loadRowKey_ = false;
			projOffset = 0;
		}

		for (int i = projOffset; i < requiredFields.size(); i++) {
			int fieldIndex = requiredFields.get(i).getIndex();
			newColumns.add(columnInfo_.get(fieldIndex - colOffset));
		}

		if (LOG.isDebugEnabled()) {
			LOG.debug("pushProjection After Projection: loadRowKey is "
					+ loadRowKey_);
			for (ColumnInfo colInfo : newColumns) {
				LOG.debug("pushProjection -- col: " + colInfo);
			}
		}
		columnInfo_ = newColumns;
		return new RequiredFieldResponse(true);
	}

	@Override
	public WritableComparable<InputSplit> getSplitComparable(InputSplit split)
			throws IOException {
		return new WritableComparable<InputSplit>() {
			TableSplit tsplit = new TableSplit();

			@Override
			public void readFields(DataInput in) throws IOException {
				tsplit.readFields(in);
			}

			@Override
			public void write(DataOutput out) throws IOException {
				tsplit.write(out);
			}

			@Override
			public int compareTo(InputSplit split) {
				return tsplit.compareTo((TableSplit) split);
			}
		};
	}

	/**
	 * Class to encapsulate logic around which column names were specified in
	 * each position of the column list. Users can specify columns names in one
	 * of 4 ways: 'Foo:', 'Foo:*', 'Foo:bar*' or 'Foo:bar'. The first 3 result
	 * in a Map being added to the tuple, while the last results in a scalar.
	 * The 3rd form results in a prefix-filtered Map.
	 */
	public static class ColumnInfo {

		final String originalColumnName; // always set
		final byte[] columnFamily; // always set
		final byte[] columnName; // set if it exists and doesn't contain '*'
		final byte[] columnPrefix; // set if contains a prefix followed by '*'

		// YA 20121210-03 Supporting passing a tuple of interleaved key and
		// values
		// public ColumnInfo(String colName) {
		// originalColumnName = colName;
		// String[] cfAndColumn = colName.split(COLON, 2);
		//
		// // CFs are byte[1] and columns are byte[2]
		// columnFamily = Bytes.toBytes(cfAndColumn[0]);
		// if (cfAndColumn.length > 1 &&
		// cfAndColumn[1].length() > 0 && !ASTERISK.equals(cfAndColumn[1])) {
		// if (cfAndColumn[1].endsWith(ASTERISK)) {
		// columnPrefix = Bytes.toBytes(cfAndColumn[1].substring(0,
		// cfAndColumn[1].length() - 1));
		// columnName = null;
		// }
		// else {
		// columnName = Bytes.toBytes(cfAndColumn[1]);
		// columnPrefix = null;
		// }
		// } else {
		// columnPrefix = null;
		// columnName = null;
		// }
		// }

		private ColumnInfo(String originalColumnName, String columnFamily,
				byte[] columnName, byte[] columnPrefix) {
			this.originalColumnName = originalColumnName;
			this.columnFamily = Bytes.toBytes(columnFamily);
			this.columnName = columnName;
			this.columnPrefix = columnPrefix;
		}

		public static Collection<? extends ColumnInfo> factory(String colName) {
			ColumnInfo res1 = null;
			ColumnInfo res2 = null;
			String[] cfAndColumn = colName.split(COLON, 2);

			// CFs are byte[1] and columns are byte[2]
			String colFam = cfAndColumn[0];
			if (cfAndColumn.length > 1 && cfAndColumn[1].length() > 0
					&& !ASTERISK.equals(cfAndColumn[1])
					&& !POUND.equals(cfAndColumn[1])) {
				if (cfAndColumn[1].endsWith(ASTERISK)) {
					res1 = new ColumnInfo(colName, colFam, null,
							Bytes.toBytes(cfAndColumn[1].substring(0,
									cfAndColumn[1].length() - 1)));

				} else {
					res1 = new ColumnInfo(colName, colFam,
							Bytes.toBytes(cfAndColumn[1]), null);

				}
			} else {
				if (ASTERISK.equals(cfAndColumn[1])) {
					res1 = new ColumnInfo(colName, colFam, null, null);

				} else if (POUND.equals(cfAndColumn[1])) {
					res1 = new ColumnInfo(colName, colFam, EMPTY_BYTE_ARRAY, // the
																				// value's
																				// name
																				// is
																				// still
																				// unknown
							null);
					res2 = new ColumnInfo(":#", colFam, EMPTY_BYTE_ARRAY, // this
																			// will
																			// be
																			// name
							null);
				}
			}
			if (res2 == null) {
				return Arrays.asList(res1);
			} else {
				// res2 first because it corresponds to the key which should
				// intuitively be passed first
				return Arrays.asList(res2, res1);
			}
		}

		// YA 20121210-03 END

		public byte[] getColumnFamily() {
			return columnFamily;
		}

		public byte[] getColumnName() {
			return columnName;
		}

		public byte[] getColumnPrefix() {
			return columnPrefix;
		}

		public boolean isColumnMap() {
			return columnName == null;
		}

		public boolean hasPrefixMatch(byte[] qualifier) {
			return Bytes.startsWith(qualifier, columnPrefix);
		}

		@Override
		public String toString() {
			return originalColumnName;
		}
	}
}
