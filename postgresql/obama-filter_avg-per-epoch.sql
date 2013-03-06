select * from 
(select epochstartmillis/1000 as epochstartux, AVG(cnt) as obamacnt from cnt_1hr3_121105 where date=121105 group by epochstartmillis,ngramarr having 'obama' = ANY (ngramarr)) as obamaday 
join assoc1hr3_121105 a on  obamaday.epochstartux = a.epochstartux where a."ngramAssoc.a1b1" <= obamacnt and a."ngramAssoc.yuleQ" > 0 order by a."ngramAssoc.a1b1" desc;

