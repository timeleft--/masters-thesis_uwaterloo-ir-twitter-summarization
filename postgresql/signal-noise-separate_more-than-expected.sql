-- This standardizes the counts using the stationary population mean and stdanrd deviation before calculating the moving average of standardized counts. This should remove the effect of changing volume
with stationary as (select epochstartmillis, avg(cnt) as popmean, stddev_pop(cnt) as popstdv from cnt_1hr1 where date = 121106 and cnt > 5 group by epochstartmillis) select ngramarr, avg((cnt - popmean)/popstdv) as avgstdcnt, stddev_pop((cnt - popmean)/popstdv) as dvstdcnt from stationary join cnt_1hr1 std on stationary.epochstartmillis = std.epochstartmillis where date = 121106 and cnt > 5 group by ngramarr order by avgstdcnt desc limit 10000;

-- To use the above to select ngrams whose current count is more than what's expected of them, we do:
with stationary as (select epochstartmillis, avg(cnt) as popmean, stddev_pop(cnt) as popstdv from cnt_1hr1 where date >= 121025 and date < 121106 group by epochstartmillis), moving as (select ngramarr, avg((cnt - popmean)/popstdv) as avgstdcnt, stddev_pop((cnt - popmean)/popstdv) as dvstdcnt from stationary join cnt_1hr1 moving on stationary.epochstartmillis = moving.epochstartmillis where date >= 121025 and date <121106 and cnt > 5 group by ngramarr) select *, (curr.cnt - popmean)/popstdv as currstcnt from cnt_1hr1 curr join moving on curr.ngramarr = moving.ngramarr join stationary on curr.epochstartmillis = stationary.epochstartmillis + (24*3600000) where date = 121106 and (curr.cnt - popmean)/popstdv > (avgstdcnt); -- + 

-- the concept of the hour of day
with hod as (select (epochstartmillis%(24*3600000))/3600000 as hod, avg(cnt) as mean, stddev_pop(cnt) as dv from cnt_1hr1 where date >= 121025 and date < 121106 and cnt > 5 group by (epochstartmillis%(24*3600000))/3600000), moving as (select ngramarr, avg((cnt - hod.mean)/hod.dv) as meanstdcnt, stddev_pop((cnt - hod.mean)/hod.dv) as dvstdcnt from hod join cnt_1hr1 moving on hod.hod = (moving.epochstartmillis%(24*3600000))/3600000 where date >= 121025 and date < 121106 and cnt > 5 group by ngramarr) select * from moving order by meanstdcnt desc limit 10000;

----------------------------------------------------------------------------------------------------
--------------------------------   WITHOUT ACCOUNT FOR MISSING DATA   ------------------------------
----------------------------------------------------------------------------------------------------

-- using the above to detect more than what's expected:
--- when sorting by ratstdcnt_mv_hod desc a lot of words about elections and states appear, but also "the" and "to"
--- wher sorting by  ratstdcnt_hod_mv desc a lot of words that seam to be interesting appear.. most importantly no "the" or "to" or any high freq word
with hod as (select (epochstartmillis%(24*3600000))/3600000 as hod, avg(cnt) as mean, stddev_pop(cnt) as dv from cnt_1hr1 
           where date >= 121025 and date < 121106 and cnt > 5 
           group by (epochstartmillis%(24*3600000))/3600000), 
     moving as (select ngramarr, avg((cnt - hod.mean)/hod.dv) as meanstdcnt, stddev_pop((cnt - hod.mean)/hod.dv) as dvstdcnt 
           from hod join cnt_1hr1 moving on hod.hod = (moving.epochstartmillis%(24*3600000))/3600000 
           where date >= 121025 and date < 121106 and cnt > 5 group by ngramarr) 
select hod.hod, curr.ngramarr, 
--hod.mean,hod.dv,meanstdcnt, dvstdcnt, 
case when dvstdcnt <> 0 then (curr.cnt - meanstdcnt) / @dvstdcnt else NULL end as currstdcnt_mv, 
case when hod.dv <> 0 then(curr.cnt - hod.mean) / (@hod.dv) else NULL end as currstdcnt_hod,  
case when dvstdcnt <> 0 and hod.dv <> 0 then (((curr.cnt - hod.mean)/hod.dv) - meanstdcnt) / (@dvstdcnt) else NULL end as ratstdcnt_hod_mv, 
case when dvstdcnt <> 0 and hod.dv <> 0 then (((curr.cnt - meanstdcnt)/dvstdcnt) - hod.mean) / (@hod.dv) else NULL end as ratstdcnt_mv_hod, rank() OVER w,'ratstdcnt_mv_hod'
--case when dvstdcnt <> 0 and hod.dv <> 0 then (((((curr.cnt - hod.mean)/hod.dv) - meanstdcnt) / (@dvstdcnt)) + ((((curr.cnt - meanstdcnt)/dvstdcnt) - hod.mean) / (@hod.dv))) else NULL end as ratstdcnt
--case when dvstdcnt <> 0 and hod.dv <> 0 then (((((curr.cnt - hod.mean)/hod.dv) - meanstdcnt) / (@dvstdcnt)) * ((((curr.cnt - meanstdcnt)/dvstdcnt) - hod.mean) / (@hod.dv))) else NULL end as ratstdcnt
--case when dvstdcnt <> 0 and hod.dv <> 0 then |/(((((curr.cnt - hod.mean)/hod.dv) - meanstdcnt) / (@dvstdcnt))^2 + ((((curr.cnt - meanstdcnt)/dvstdcnt) - hod.mean) / (@hod.dv))^2) else NULL end as ratstdcnt
from (hod join cnt_1hr1 curr on (curr.epochstartmillis%(24*3600000))/3600000 = hod.hod) 
          join moving on curr.ngramarr = moving.ngramarr  
where curr.date = 121106 and curr.cnt > 5 
WINDOW w AS (PARTITION BY hod.hod)
order by ratstdcnt_mv_hod desc limit 10000;

-- (((curr.cnt - hod.mean)/hod.dv) - meanstdcnt) - dvstdcnt as diffstdcnt,








----------------------------------------------------------------------------------------------------
-------------------------             NOW THE NOTION OF MISSING DATA ------------------------------
----------------------------------------------------------------------------------------------------
