/*
select ngramarr as compgram, sum(cnt) as sumcnt, min(cnt) as mincnt, max(cnt) as maxcnt,
      min(epochstartux) as firstepoch, (1352206800 - min(epochstartux))/3600 AS numepochs,
      sum(cnt)/((1352206800 - min(epochstartux))/3600) as avgcnt
from bak_compcnt_1hr4 
where date=121106 and epochstartux < 1352206800
group by ngramarr
*/
/* ,
      |/(( ( ( ( (1352206800 - min(epochstartux))/3600 ) - count(*) ) * 
               ( (sum(cnt)/((1352206800 - min(epochstartux))/3600))^2 ) )
              + sum( ( cnt - (sum(cnt)/((1352206800 - min(epochstartux))/3600)) )^2 ))
                 / ((1352206800 - min(epochstartux))/3600)) as stdevcnt

*/
/*
select aggr2.*, (aggr2.avgcnt + (2*aggr2.stdevcnt)) as threshold from
   (select aggr.*, 
      |/( ( (aggr.numepochs - count(*) over v) * ((0 - aggr.avgcnt)^2) + sum((aggr.cnt - aggr.avgcnt)^2) over v)  /  aggr.numepochs) as stdevcnt
   from (select ngramarr as compgram, cnt, min(epochstartux) over w as firstepoch,
	sum(cnt) over w as sumcnt, min(cnt) over w as mincnt, max(cnt) over w as maxcnt,
	 (1352206800 - min(epochstartux) over w )/3600 AS numepochs,
	sum(cnt) over w /((1352206800 - min(epochstartux) over w )/3600) as avgcnt
      from bak_compcnt_1hr4 
      where date=121106 and epochstartux < 1352206800
      window w AS (partition by ngramarr)) aggr
   window v AS (partition by compgram)) aggr2
 --where (aggr2.avgcnt + (2*aggr2.stdevcnt)) < aggr2.maxcnt
 */

 -- (select stddev_pop(totalcnt)/avg(totalcnt) as avgvol, stddev_pop(totalcnt) as stdevvol, stddev_pop(totalcnt)/avg(totalcnt) as deviation_proportion_vol from volume_1hr1 where epochstartmillis >= (1352120400 * 1000::INT8) and epochstartmillis < (1352206800 * 1000::INT8))
/*
This maintains all the values so that we can look at it.. watch out becaue I was changing some stuff so it might be wrong
 select *, (aggr2.stdevcnt/aggr2.avgcnt) as deviation_proprtion_cnt
  from (
   select aggr.*, 
      |/( ( (aggr.numepochs - count(*)) * ((0 - aggr.avgcnt)^2) + sum((aggr.cnt - aggr.avgcnt)^2) over v)  /  aggr.age) as stdevcnt
   from (select ngramarr as compgram, epochstartux, cnt, min(epochstartux) over w as firstepoch,
	sum(cnt) over w as sumcnt, min(cnt) over w as mincnt, max(cnt) over w as maxcnt,
	 (1352206800 - min(epochstartux) over w )/3600 AS age,
	sum(cnt) over w /((1352206800 - min(epochstartux) over w )/3600) as avgcnt
      from bak_compcnt_1hr4 
      where ngramlen = 4 and (date=121106 or date=121105)and epochstartux >= 1352120400 and epochstartux < 1352206800
      window w AS (partition by ngramarr)) aggr
   window v AS (partition by compgram)  --order by avgcnt desc
   ) aggr2
 where (aggr2.stdevcnt/aggr2.avgcnt) > (select stddev_pop(totalcnt)/avg(totalcnt) as deviation_proportion_vol from volume_1hr1 where epochstartmillis >= (1352120400 * 1000::INT8) and epochstartmillis < (1352206800 * 1000::INT8))
  or aggr2.age = 1
order by (aggr2.stdevcnt/aggr2.avgcnt) desc;
*/

select *, (aggr2.stdevcnt/aggr2.avgcnt) as deviation_proprtion_cnt
  from
   (select compgram, min(aggr.avgcnt) as avgcnt, min(aggr.age) as age, --min or max or whatever.. it will be repeated in every row anyway 
      |/( ( (min(aggr.age) - count(*)) * ((0 - min(aggr.avgcnt))^2) + sum((aggr.cnt - aggr.avgcnt)^2))  /  min(aggr.age)) as stdevcnt
   from (select ngramarr as compgram, cnt, min(epochstartux) over w as firstepoch,
	sum(cnt) over w as sumcnt, min(cnt) over w as mincnt, max(cnt) over w as maxcnt,
	 (1352206800 - min(epochstartux) over w )/3600 AS age,
	sum(cnt) over w /((1352206800 - min(epochstartux) over w )/3600) as avgcnt
      from bak_compcnt_1hr2 
      where ngramlen = 2 and (date=121106 or date=121105)and epochstartux >= 1352120400 and epochstartux < 1352206800
      window w AS (partition by ngramarr)) aggr
   group by compgram) aggr2
 where (aggr2.stdevcnt/aggr2.avgcnt) > (select stddev_pop(totalcnt)/avg(totalcnt) as deviation_proportion_vol from volume_1hr1 where epochstartmillis >= (1352120400 * 1000::INT8) and epochstartmillis < (1352206800 * 1000::INT8))
  or aggr2.age = 1
order by aggr2.avgcnt desc;


                 
