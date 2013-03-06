with hist as (select c.*, CAST(c.cnt as float8) /*/CAST(v.totalcnt as float8) */as prop 
	from cnt_1hr1 c join volume_1hr1 v on c.epochstartmillis = v.epochstartmillis 
	where date >= 121025 and date <= 121106),
    curr as (select c.*, v.totalcnt, CAST(c.cnt as float8)/*/CAST(v.totalcnt as float8) */ as prop 
	from cnt_1hr1 c join volume_1hr1 v on c.epochstartmillis = v.epochstartmillis 
	where date = 121106)
select curr.ngramarr, curr.epochstartmillis, avg(hist.prop) histmeanprop, stddev_pop(hist.prop) histdvprop, count(*) as appearances, 
case when stddev_pop(hist.prop) <> 0 then (min(curr.prop) - avg(hist.prop))/stddev_pop(hist.prop) else NULL end as stdprop
--, min(curr.prop) * min(curr.totalcnt) as cnt
from hist join curr on curr.ngramarr = hist.ngramarr 
group by curr.ngramarr, curr.epochstartmillis having count(*) > 3 order by stdprop desc limit 1000;