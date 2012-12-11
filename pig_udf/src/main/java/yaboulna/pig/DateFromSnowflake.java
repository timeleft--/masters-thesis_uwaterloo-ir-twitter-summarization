package yaboulna.pig;

import java.io.IOException;
import java.util.Arrays;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.TimeZone;

import org.apache.pig.EvalFunc;
import org.apache.pig.data.DataType;
import org.apache.pig.data.Tuple;
import org.apache.pig.data.TupleFactory;
import org.apache.pig.impl.logicalLayer.schema.Schema;

public class DateFromSnowflake extends EvalFunc<Tuple> {
  
  @Override
  public Tuple exec(Tuple input) throws IOException {
    if (input == null || input.isNull() || input.size() < 1 || input.isNull(0)) {
      return null;
    }
    
    long sf = (Long) input.get(0);
    String tzName = "GMT-10";
    if (input.size() == 2 && !input.isNull(1)) {
      tzName = (String) input.get(1);
    }
    long timestamp = (sf >> 22) + ComposeSnowflake.TWEET_EPOCH_MAGIC_NUM;
    
    Tuple result = TupleFactory.getInstance().newTuple(2);
    result.set(0, timestamp);
    
    // Interpreting the timestamp using the timezone GMT-10 so that day boundaries
    // fall at 3 and 5 AM in North America West and East coast
    Calendar gregCal = new GregorianCalendar(TimeZone.getTimeZone(tzName));
    gregCal.setTimeInMillis(timestamp);
    result.set(1, ("" + gregCal.get(Calendar.YEAR)).substring(2)
        + toTwoCharStr(gregCal.get(Calendar.MONTH) + 1) // +1 because Jan is 0.. duh!!
        + toTwoCharStr(gregCal.get(Calendar.DAY_OF_MONTH)));
    
    return result;
  }
  
  public static String toTwoCharStr(int num) {
    String result = "" + num;
    if (result.length() == 1) {
      result = "0" + result;
    }
    return result;
  }
  
  @Override
  public Schema outputSchema(Schema input) {
    Schema.FieldSchema timeMillisFS = new Schema.FieldSchema("timeMillis", DataType.LONG);
    Schema.FieldSchema dateFS = new Schema.FieldSchema("date", DataType.CHARARRAY);
    Schema result = new Schema(Arrays.asList(timeMillisFS, dateFS));
    
    return result;
  }
  
}
