select * from 
(select  trim(leading '{' from trim(trailing '}' from CAST(ngramarr[1:2] AS VARCHAR)))  as ngram, avg(cnt) as avgcnt 
from cnt_1hr3 where cnt>5  and date<121105 group by ngramarr having '%obama%' like ANY (ngramarr)) as bg
join
assoc1hr3_121105 a on a."ngramAssoc.ngram" = bg.ngram
where a."ngramAssoc.yuleQ" > 0 
order by avgcnt desc;

-- a."ngramAssoc.a1b1"