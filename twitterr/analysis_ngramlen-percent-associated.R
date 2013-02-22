# TODO: Add comment
# 
# Author: yia
###############################################################################


  
for(len in c(3:5))
# select count(*) from cnt_1hr3_121105 group by epochstartmillis;
perepoch_candidates_1hr3 <- c(333660,98667,414966,135644,344406,411697,336648,247954,381677,290328,415388,392663,426656,337329,127552,414377,173770,308111,214042,180472,257676,108230,416394,106705)
# select count(*) from compcnt_1hr3_121105 group by epochstartux;
perepoch_assoc_1hr3 <- c(34684, 33109, 19461, 37742, 24526, 27858, 31173, 36236, 30384, 20175, 37520, 33099, 32923, 38375, 37544, 16265, 35237, 38576, 24222, 33278, 16137, 17348, 37887, 15511)

perepoch_fracassoc_1hr3 <- perepoch_assoc_1hr3 /perepoch_candidates_1hr3

perepoch_candidates_1hr4 <- c(56676,44748,57566,48963,56013,55751,31341,63697,13465,9987,13526,16137,53124,59092,59805,10330,21106,17474,38260,23949,53644,26326,36273,52658)
perepoch_assoc_1hr4 <- c(38257,35574,20934,40831,25718,29225,32771,39214,33193,21196,40580,34981,34735,41287,40486,17378,38268,41290,26372,36161,17541,18337,40493,16507)
which(perepoch_assoc_1hr4 > perepoch_candidates_1hr4)

perepoch_fracassoc_1hr4 <- perepoch_assoc_1hr4 /perepoch_candidates_1hr4

perepoch_fracassoc_1hr4
  