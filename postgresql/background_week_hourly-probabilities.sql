
select *, (aggr2.stdevcnt/aggr2.avgcnt) as deviation_proprtion_cnt
  from
   (select compgram, min(firstepoch) as firstepoch, min(sumcnt) as sumcnt, min(mincnt) as mincnt, min(maxcnt) as maxcnt, 
   min(aggr.avgcnt) as avgcnt, min(aggr.age) as age,  --min or max or whatever.. it will be repeated in every row anyway 
    count(*) as appearances,
      |/( ( (min(aggr.age) - count(*)) * ((0 - min(aggr.avgcnt))^2) + sum((aggr.cnt - aggr.avgcnt)^2))  /  min(aggr.age)) as stdevcnt
   from (select ngramarr as compgram, cnt, min(epochstartux) over w as firstepoch,
	sum(cnt) over w as sumcnt, min(cnt) over w as mincnt, max(cnt) over w as maxcnt,
	 (1352206800 - min(epochstartux) over w )/3600 AS age,
	sum(cnt) over w /((1352206800 - min(epochstartux) over w )/3600) as avgcnt
      from bak_compcnt_1hr4 
      where ngramlen <= 4 and (date>121100 or date<=121106) and epochstartux >= 1351764000 and epochstartux < 1352206800
      and ((CAST(epochstartux as int8) % (3600*24)) / 3600 =  (1352206800 % (3600*24)) / 3600 or (1352206800 - epochstartux) / 3600 < 4)
      window w AS (partition by ngramarr)) aggr
   group by compgram) aggr2
 --where (aggr2.stdevcnt/aggr2.avgcnt) > (select stddev_pop(totalcnt)/avg(totalcnt) as deviation_proportion_vol from volume_1hr1 where epochstartmillis >= (1352120400 * 1000::INT8) and epochstartmillis < (1352206800 * 1000::INT8))
 -- or aggr2.age = 1
order by aggr2.avgcnt desc;

 