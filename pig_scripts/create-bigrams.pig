SPLIT unigrams INTO 
  unigramsP0 IF pos==0,
  unigramsP1 IF pos==1,
  unigramsP2 IF pos==2,
  unigramsP3 IF pos==3,
  unigramsP4 IF pos==4,
  unigramsP5 IF pos==5,
  unigramsP6 IF pos==6,
  unigramsP7 IF pos==7,
  unigramsP8 IF pos==8,
  unigramsP9 IF pos==9,
  unigramsP10 IF pos==10,
  unigramsP11 IF pos==11,
  unigramsP12 IF pos==12,
  unigramsP13 IF pos==13,
  unigramsP14 IF pos==14,
  unigramsP15 IF pos==15,
  unigramsP16 IF pos==16,
  unigramsP17 IF pos==17,
  unigramsP18 IF pos==18,
  unigramsP19 IF pos==19,
  unigramsP20 IF pos==20,
  unigramsP21 IF pos==21,
  unigramsP22 IF pos==22,
  unigramsP23 IF pos==23,
  unigramsP24 IF pos==24,
  unigramsP25 IF pos==25,
  unigramsP26 IF pos==26,
  unigramsP27 IF pos==27,
  unigramsP28 IF pos==28,
  unigramsP29 IF pos==29,
  unigramsP30 IF pos==30,
  unigramsP31 IF pos==31,
  unigramsP32 IF pos==32,
  unigramsP33 IF pos==33,
  unigramsP34 IF pos==34,
  unigramsP35 IF pos==35,
  unigramsP36 IF pos==36,
  unigramsP37 IF pos==37,
  unigramsP38 IF pos==38,
  unigramsP39 IF pos==39,
  unigramsP40 IF pos==40,
  unigramsP41 IF pos==41,
  unigramsP42 IF pos==42,
  unigramsP43 IF pos==43,
  unigramsP44 IF pos==44,
  unigramsP45 IF pos==45,
  unigramsP46 IF pos==46,
  unigramsP47 IF pos==47,
  unigramsP48 IF pos==48,
  unigramsP49 IF pos==49,
  unigramsP50 IF pos==50,
  unigramsP51 IF pos==51,
  unigramsP52 IF pos==52,
  unigramsP53 IF pos==53,
  unigramsP54 IF pos==54,
  unigramsP55 IF pos==55,
  unigramsP56 IF pos==56,
  unigramsP57 IF pos==57,
  unigramsP58 IF pos==58,
  unigramsP59 IF pos==59,
  unigramsP60 IF pos==60,
  unigramsP61 IF pos==61,
  unigramsP62 IF pos==62,
  unigramsP63 IF pos==63,
  unigramsP64 IF pos==64,
  unigramsP65 IF pos==65,
  unigramsP66 IF pos==66,
  unigramsP67 IF pos==67,
  unigramsP68 IF pos==68,
  unigramsP69 IF pos==69;
unigramsX2S0 = JOIN unigramsP0 BY id, unigramsP1 BY id;
unigramsC2S0 = FOREACH unigramsX2S0 GENERATE CONCAT(CONCAT(unigramsP0::token, 'C'), unigramsP1::token) as token, unigramsP0::day as day, unigramsP0::id as id, unigramsP0::pos as pos;
unigramsX2S1 = JOIN unigramsP1 BY id, unigramsP2 BY id;
unigramsC2S1 = FOREACH unigramsX2S1 GENERATE CONCAT(CONCAT(unigramsP1::token, 'C'), unigramsP2::token) as token, unigramsP1::day as day, unigramsP1::id as id, unigramsP1::pos as pos;
unigramsX2S2 = JOIN unigramsP2 BY id, unigramsP3 BY id;
unigramsC2S2 = FOREACH unigramsX2S2 GENERATE CONCAT(CONCAT(unigramsP2::token, 'C'), unigramsP3::token) as token, unigramsP2::day as day, unigramsP2::id as id, unigramsP2::pos as pos;
unigramsX2S3 = JOIN unigramsP3 BY id, unigramsP4 BY id;
unigramsC2S3 = FOREACH unigramsX2S3 GENERATE CONCAT(CONCAT(unigramsP3::token, 'C'), unigramsP4::token) as token, unigramsP3::day as day, unigramsP3::id as id, unigramsP3::pos as pos;
unigramsX2S4 = JOIN unigramsP4 BY id, unigramsP5 BY id;
unigramsC2S4 = FOREACH unigramsX2S4 GENERATE CONCAT(CONCAT(unigramsP4::token, 'C'), unigramsP5::token) as token, unigramsP4::day as day, unigramsP4::id as id, unigramsP4::pos as pos;
unigramsX2S5 = JOIN unigramsP5 BY id, unigramsP6 BY id;
unigramsC2S5 = FOREACH unigramsX2S5 GENERATE CONCAT(CONCAT(unigramsP5::token, 'C'), unigramsP6::token) as token, unigramsP5::day as day, unigramsP5::id as id, unigramsP5::pos as pos;
unigramsX2S6 = JOIN unigramsP6 BY id, unigramsP7 BY id;
unigramsC2S6 = FOREACH unigramsX2S6 GENERATE CONCAT(CONCAT(unigramsP6::token, 'C'), unigramsP7::token) as token, unigramsP6::day as day, unigramsP6::id as id, unigramsP6::pos as pos;
unigramsX2S7 = JOIN unigramsP7 BY id, unigramsP8 BY id;
unigramsC2S7 = FOREACH unigramsX2S7 GENERATE CONCAT(CONCAT(unigramsP7::token, 'C'), unigramsP8::token) as token, unigramsP7::day as day, unigramsP7::id as id, unigramsP7::pos as pos;
unigramsX2S8 = JOIN unigramsP8 BY id, unigramsP9 BY id;
unigramsC2S8 = FOREACH unigramsX2S8 GENERATE CONCAT(CONCAT(unigramsP8::token, 'C'), unigramsP9::token) as token, unigramsP8::day as day, unigramsP8::id as id, unigramsP8::pos as pos;
unigramsX2S9 = JOIN unigramsP9 BY id, unigramsP10 BY id;
unigramsC2S9 = FOREACH unigramsX2S9 GENERATE CONCAT(CONCAT(unigramsP9::token, 'C'), unigramsP10::token) as token, unigramsP9::day as day, unigramsP9::id as id, unigramsP9::pos as pos;
unigramsX2S10 = JOIN unigramsP10 BY id, unigramsP11 BY id;
unigramsC2S10 = FOREACH unigramsX2S10 GENERATE CONCAT(CONCAT(unigramsP10::token, 'C'), unigramsP11::token) as token, unigramsP10::day as day, unigramsP10::id as id, unigramsP10::pos as pos;
unigramsX2S11 = JOIN unigramsP11 BY id, unigramsP12 BY id;
unigramsC2S11 = FOREACH unigramsX2S11 GENERATE CONCAT(CONCAT(unigramsP11::token, 'C'), unigramsP12::token) as token, unigramsP11::day as day, unigramsP11::id as id, unigramsP11::pos as pos;
unigramsX2S12 = JOIN unigramsP12 BY id, unigramsP13 BY id;
unigramsC2S12 = FOREACH unigramsX2S12 GENERATE CONCAT(CONCAT(unigramsP12::token, 'C'), unigramsP13::token) as token, unigramsP12::day as day, unigramsP12::id as id, unigramsP12::pos as pos;
unigramsX2S13 = JOIN unigramsP13 BY id, unigramsP14 BY id;
unigramsC2S13 = FOREACH unigramsX2S13 GENERATE CONCAT(CONCAT(unigramsP13::token, 'C'), unigramsP14::token) as token, unigramsP13::day as day, unigramsP13::id as id, unigramsP13::pos as pos;
unigramsX2S14 = JOIN unigramsP14 BY id, unigramsP15 BY id;
unigramsC2S14 = FOREACH unigramsX2S14 GENERATE CONCAT(CONCAT(unigramsP14::token, 'C'), unigramsP15::token) as token, unigramsP14::day as day, unigramsP14::id as id, unigramsP14::pos as pos;
unigramsX2S15 = JOIN unigramsP15 BY id, unigramsP16 BY id;
unigramsC2S15 = FOREACH unigramsX2S15 GENERATE CONCAT(CONCAT(unigramsP15::token, 'C'), unigramsP16::token) as token, unigramsP15::day as day, unigramsP15::id as id, unigramsP15::pos as pos;
unigramsX2S16 = JOIN unigramsP16 BY id, unigramsP17 BY id;
unigramsC2S16 = FOREACH unigramsX2S16 GENERATE CONCAT(CONCAT(unigramsP16::token, 'C'), unigramsP17::token) as token, unigramsP16::day as day, unigramsP16::id as id, unigramsP16::pos as pos;
unigramsX2S17 = JOIN unigramsP17 BY id, unigramsP18 BY id;
unigramsC2S17 = FOREACH unigramsX2S17 GENERATE CONCAT(CONCAT(unigramsP17::token, 'C'), unigramsP18::token) as token, unigramsP17::day as day, unigramsP17::id as id, unigramsP17::pos as pos;
unigramsX2S18 = JOIN unigramsP18 BY id, unigramsP19 BY id;
unigramsC2S18 = FOREACH unigramsX2S18 GENERATE CONCAT(CONCAT(unigramsP18::token, 'C'), unigramsP19::token) as token, unigramsP18::day as day, unigramsP18::id as id, unigramsP18::pos as pos;
unigramsX2S19 = JOIN unigramsP19 BY id, unigramsP20 BY id;
unigramsC2S19 = FOREACH unigramsX2S19 GENERATE CONCAT(CONCAT(unigramsP19::token, 'C'), unigramsP20::token) as token, unigramsP19::day as day, unigramsP19::id as id, unigramsP19::pos as pos;
unigramsX2S20 = JOIN unigramsP20 BY id, unigramsP21 BY id;
unigramsC2S20 = FOREACH unigramsX2S20 GENERATE CONCAT(CONCAT(unigramsP20::token, 'C'), unigramsP21::token) as token, unigramsP20::day as day, unigramsP20::id as id, unigramsP20::pos as pos;
unigramsX2S21 = JOIN unigramsP21 BY id, unigramsP22 BY id;
unigramsC2S21 = FOREACH unigramsX2S21 GENERATE CONCAT(CONCAT(unigramsP21::token, 'C'), unigramsP22::token) as token, unigramsP21::day as day, unigramsP21::id as id, unigramsP21::pos as pos;
unigramsX2S22 = JOIN unigramsP22 BY id, unigramsP23 BY id;
unigramsC2S22 = FOREACH unigramsX2S22 GENERATE CONCAT(CONCAT(unigramsP22::token, 'C'), unigramsP23::token) as token, unigramsP22::day as day, unigramsP22::id as id, unigramsP22::pos as pos;
unigramsX2S23 = JOIN unigramsP23 BY id, unigramsP24 BY id;
unigramsC2S23 = FOREACH unigramsX2S23 GENERATE CONCAT(CONCAT(unigramsP23::token, 'C'), unigramsP24::token) as token, unigramsP23::day as day, unigramsP23::id as id, unigramsP23::pos as pos;
unigramsX2S24 = JOIN unigramsP24 BY id, unigramsP25 BY id;
unigramsC2S24 = FOREACH unigramsX2S24 GENERATE CONCAT(CONCAT(unigramsP24::token, 'C'), unigramsP25::token) as token, unigramsP24::day as day, unigramsP24::id as id, unigramsP24::pos as pos;
unigramsX2S25 = JOIN unigramsP25 BY id, unigramsP26 BY id;
unigramsC2S25 = FOREACH unigramsX2S25 GENERATE CONCAT(CONCAT(unigramsP25::token, 'C'), unigramsP26::token) as token, unigramsP25::day as day, unigramsP25::id as id, unigramsP25::pos as pos;
unigramsX2S26 = JOIN unigramsP26 BY id, unigramsP27 BY id;
unigramsC2S26 = FOREACH unigramsX2S26 GENERATE CONCAT(CONCAT(unigramsP26::token, 'C'), unigramsP27::token) as token, unigramsP26::day as day, unigramsP26::id as id, unigramsP26::pos as pos;
unigramsX2S27 = JOIN unigramsP27 BY id, unigramsP28 BY id;
unigramsC2S27 = FOREACH unigramsX2S27 GENERATE CONCAT(CONCAT(unigramsP27::token, 'C'), unigramsP28::token) as token, unigramsP27::day as day, unigramsP27::id as id, unigramsP27::pos as pos;
unigramsX2S28 = JOIN unigramsP28 BY id, unigramsP29 BY id;
unigramsC2S28 = FOREACH unigramsX2S28 GENERATE CONCAT(CONCAT(unigramsP28::token, 'C'), unigramsP29::token) as token, unigramsP28::day as day, unigramsP28::id as id, unigramsP28::pos as pos;
unigramsX2S29 = JOIN unigramsP29 BY id, unigramsP30 BY id;
unigramsC2S29 = FOREACH unigramsX2S29 GENERATE CONCAT(CONCAT(unigramsP29::token, 'C'), unigramsP30::token) as token, unigramsP29::day as day, unigramsP29::id as id, unigramsP29::pos as pos;
unigramsX2S30 = JOIN unigramsP30 BY id, unigramsP31 BY id;
unigramsC2S30 = FOREACH unigramsX2S30 GENERATE CONCAT(CONCAT(unigramsP30::token, 'C'), unigramsP31::token) as token, unigramsP30::day as day, unigramsP30::id as id, unigramsP30::pos as pos;
unigramsX2S31 = JOIN unigramsP31 BY id, unigramsP32 BY id;
unigramsC2S31 = FOREACH unigramsX2S31 GENERATE CONCAT(CONCAT(unigramsP31::token, 'C'), unigramsP32::token) as token, unigramsP31::day as day, unigramsP31::id as id, unigramsP31::pos as pos;
unigramsX2S32 = JOIN unigramsP32 BY id, unigramsP33 BY id;
unigramsC2S32 = FOREACH unigramsX2S32 GENERATE CONCAT(CONCAT(unigramsP32::token, 'C'), unigramsP33::token) as token, unigramsP32::day as day, unigramsP32::id as id, unigramsP32::pos as pos;
unigramsX2S33 = JOIN unigramsP33 BY id, unigramsP34 BY id;
unigramsC2S33 = FOREACH unigramsX2S33 GENERATE CONCAT(CONCAT(unigramsP33::token, 'C'), unigramsP34::token) as token, unigramsP33::day as day, unigramsP33::id as id, unigramsP33::pos as pos;
unigramsX2S34 = JOIN unigramsP34 BY id, unigramsP35 BY id;
unigramsC2S34 = FOREACH unigramsX2S34 GENERATE CONCAT(CONCAT(unigramsP34::token, 'C'), unigramsP35::token) as token, unigramsP34::day as day, unigramsP34::id as id, unigramsP34::pos as pos;
unigramsX2S35 = JOIN unigramsP35 BY id, unigramsP36 BY id;
unigramsC2S35 = FOREACH unigramsX2S35 GENERATE CONCAT(CONCAT(unigramsP35::token, 'C'), unigramsP36::token) as token, unigramsP35::day as day, unigramsP35::id as id, unigramsP35::pos as pos;
unigramsX2S36 = JOIN unigramsP36 BY id, unigramsP37 BY id;
unigramsC2S36 = FOREACH unigramsX2S36 GENERATE CONCAT(CONCAT(unigramsP36::token, 'C'), unigramsP37::token) as token, unigramsP36::day as day, unigramsP36::id as id, unigramsP36::pos as pos;
unigramsX2S37 = JOIN unigramsP37 BY id, unigramsP38 BY id;
unigramsC2S37 = FOREACH unigramsX2S37 GENERATE CONCAT(CONCAT(unigramsP37::token, 'C'), unigramsP38::token) as token, unigramsP37::day as day, unigramsP37::id as id, unigramsP37::pos as pos;
unigramsX2S38 = JOIN unigramsP38 BY id, unigramsP39 BY id;
unigramsC2S38 = FOREACH unigramsX2S38 GENERATE CONCAT(CONCAT(unigramsP38::token, 'C'), unigramsP39::token) as token, unigramsP38::day as day, unigramsP38::id as id, unigramsP38::pos as pos;
unigramsX2S39 = JOIN unigramsP39 BY id, unigramsP40 BY id;
unigramsC2S39 = FOREACH unigramsX2S39 GENERATE CONCAT(CONCAT(unigramsP39::token, 'C'), unigramsP40::token) as token, unigramsP39::day as day, unigramsP39::id as id, unigramsP39::pos as pos;
unigramsX2S40 = JOIN unigramsP40 BY id, unigramsP41 BY id;
unigramsC2S40 = FOREACH unigramsX2S40 GENERATE CONCAT(CONCAT(unigramsP40::token, 'C'), unigramsP41::token) as token, unigramsP40::day as day, unigramsP40::id as id, unigramsP40::pos as pos;
unigramsX2S41 = JOIN unigramsP41 BY id, unigramsP42 BY id;
unigramsC2S41 = FOREACH unigramsX2S41 GENERATE CONCAT(CONCAT(unigramsP41::token, 'C'), unigramsP42::token) as token, unigramsP41::day as day, unigramsP41::id as id, unigramsP41::pos as pos;
unigramsX2S42 = JOIN unigramsP42 BY id, unigramsP43 BY id;
unigramsC2S42 = FOREACH unigramsX2S42 GENERATE CONCAT(CONCAT(unigramsP42::token, 'C'), unigramsP43::token) as token, unigramsP42::day as day, unigramsP42::id as id, unigramsP42::pos as pos;
unigramsX2S43 = JOIN unigramsP43 BY id, unigramsP44 BY id;
unigramsC2S43 = FOREACH unigramsX2S43 GENERATE CONCAT(CONCAT(unigramsP43::token, 'C'), unigramsP44::token) as token, unigramsP43::day as day, unigramsP43::id as id, unigramsP43::pos as pos;
unigramsX2S44 = JOIN unigramsP44 BY id, unigramsP45 BY id;
unigramsC2S44 = FOREACH unigramsX2S44 GENERATE CONCAT(CONCAT(unigramsP44::token, 'C'), unigramsP45::token) as token, unigramsP44::day as day, unigramsP44::id as id, unigramsP44::pos as pos;
unigramsX2S45 = JOIN unigramsP45 BY id, unigramsP46 BY id;
unigramsC2S45 = FOREACH unigramsX2S45 GENERATE CONCAT(CONCAT(unigramsP45::token, 'C'), unigramsP46::token) as token, unigramsP45::day as day, unigramsP45::id as id, unigramsP45::pos as pos;
unigramsX2S46 = JOIN unigramsP46 BY id, unigramsP47 BY id;
unigramsC2S46 = FOREACH unigramsX2S46 GENERATE CONCAT(CONCAT(unigramsP46::token, 'C'), unigramsP47::token) as token, unigramsP46::day as day, unigramsP46::id as id, unigramsP46::pos as pos;
unigramsX2S47 = JOIN unigramsP47 BY id, unigramsP48 BY id;
unigramsC2S47 = FOREACH unigramsX2S47 GENERATE CONCAT(CONCAT(unigramsP47::token, 'C'), unigramsP48::token) as token, unigramsP47::day as day, unigramsP47::id as id, unigramsP47::pos as pos;
unigramsX2S48 = JOIN unigramsP48 BY id, unigramsP49 BY id;
unigramsC2S48 = FOREACH unigramsX2S48 GENERATE CONCAT(CONCAT(unigramsP48::token, 'C'), unigramsP49::token) as token, unigramsP48::day as day, unigramsP48::id as id, unigramsP48::pos as pos;
unigramsX2S49 = JOIN unigramsP49 BY id, unigramsP50 BY id;
unigramsC2S49 = FOREACH unigramsX2S49 GENERATE CONCAT(CONCAT(unigramsP49::token, 'C'), unigramsP50::token) as token, unigramsP49::day as day, unigramsP49::id as id, unigramsP49::pos as pos;
unigramsX2S50 = JOIN unigramsP50 BY id, unigramsP51 BY id;
unigramsC2S50 = FOREACH unigramsX2S50 GENERATE CONCAT(CONCAT(unigramsP50::token, 'C'), unigramsP51::token) as token, unigramsP50::day as day, unigramsP50::id as id, unigramsP50::pos as pos;
unigramsX2S51 = JOIN unigramsP51 BY id, unigramsP52 BY id;
unigramsC2S51 = FOREACH unigramsX2S51 GENERATE CONCAT(CONCAT(unigramsP51::token, 'C'), unigramsP52::token) as token, unigramsP51::day as day, unigramsP51::id as id, unigramsP51::pos as pos;
unigramsX2S52 = JOIN unigramsP52 BY id, unigramsP53 BY id;
unigramsC2S52 = FOREACH unigramsX2S52 GENERATE CONCAT(CONCAT(unigramsP52::token, 'C'), unigramsP53::token) as token, unigramsP52::day as day, unigramsP52::id as id, unigramsP52::pos as pos;
unigramsX2S53 = JOIN unigramsP53 BY id, unigramsP54 BY id;
unigramsC2S53 = FOREACH unigramsX2S53 GENERATE CONCAT(CONCAT(unigramsP53::token, 'C'), unigramsP54::token) as token, unigramsP53::day as day, unigramsP53::id as id, unigramsP53::pos as pos;
unigramsX2S54 = JOIN unigramsP54 BY id, unigramsP55 BY id;
unigramsC2S54 = FOREACH unigramsX2S54 GENERATE CONCAT(CONCAT(unigramsP54::token, 'C'), unigramsP55::token) as token, unigramsP54::day as day, unigramsP54::id as id, unigramsP54::pos as pos;
unigramsX2S55 = JOIN unigramsP55 BY id, unigramsP56 BY id;
unigramsC2S55 = FOREACH unigramsX2S55 GENERATE CONCAT(CONCAT(unigramsP55::token, 'C'), unigramsP56::token) as token, unigramsP55::day as day, unigramsP55::id as id, unigramsP55::pos as pos;
unigramsX2S56 = JOIN unigramsP56 BY id, unigramsP57 BY id;
unigramsC2S56 = FOREACH unigramsX2S56 GENERATE CONCAT(CONCAT(unigramsP56::token, 'C'), unigramsP57::token) as token, unigramsP56::day as day, unigramsP56::id as id, unigramsP56::pos as pos;
unigramsX2S57 = JOIN unigramsP57 BY id, unigramsP58 BY id;
unigramsC2S57 = FOREACH unigramsX2S57 GENERATE CONCAT(CONCAT(unigramsP57::token, 'C'), unigramsP58::token) as token, unigramsP57::day as day, unigramsP57::id as id, unigramsP57::pos as pos;
unigramsX2S58 = JOIN unigramsP58 BY id, unigramsP59 BY id;
unigramsC2S58 = FOREACH unigramsX2S58 GENERATE CONCAT(CONCAT(unigramsP58::token, 'C'), unigramsP59::token) as token, unigramsP58::day as day, unigramsP58::id as id, unigramsP58::pos as pos;
unigramsX2S59 = JOIN unigramsP59 BY id, unigramsP60 BY id;
unigramsC2S59 = FOREACH unigramsX2S59 GENERATE CONCAT(CONCAT(unigramsP59::token, 'C'), unigramsP60::token) as token, unigramsP59::day as day, unigramsP59::id as id, unigramsP59::pos as pos;
unigramsX2S60 = JOIN unigramsP60 BY id, unigramsP61 BY id;
unigramsC2S60 = FOREACH unigramsX2S60 GENERATE CONCAT(CONCAT(unigramsP60::token, 'C'), unigramsP61::token) as token, unigramsP60::day as day, unigramsP60::id as id, unigramsP60::pos as pos;
unigramsX2S61 = JOIN unigramsP61 BY id, unigramsP62 BY id;
unigramsC2S61 = FOREACH unigramsX2S61 GENERATE CONCAT(CONCAT(unigramsP61::token, 'C'), unigramsP62::token) as token, unigramsP61::day as day, unigramsP61::id as id, unigramsP61::pos as pos;
unigramsX2S62 = JOIN unigramsP62 BY id, unigramsP63 BY id;
unigramsC2S62 = FOREACH unigramsX2S62 GENERATE CONCAT(CONCAT(unigramsP62::token, 'C'), unigramsP63::token) as token, unigramsP62::day as day, unigramsP62::id as id, unigramsP62::pos as pos;
unigramsX2S63 = JOIN unigramsP63 BY id, unigramsP64 BY id;
unigramsC2S63 = FOREACH unigramsX2S63 GENERATE CONCAT(CONCAT(unigramsP63::token, 'C'), unigramsP64::token) as token, unigramsP63::day as day, unigramsP63::id as id, unigramsP63::pos as pos;
unigramsX2S64 = JOIN unigramsP64 BY id, unigramsP65 BY id;
unigramsC2S64 = FOREACH unigramsX2S64 GENERATE CONCAT(CONCAT(unigramsP64::token, 'C'), unigramsP65::token) as token, unigramsP64::day as day, unigramsP64::id as id, unigramsP64::pos as pos;
unigramsX2S65 = JOIN unigramsP65 BY id, unigramsP66 BY id;
unigramsC2S65 = FOREACH unigramsX2S65 GENERATE CONCAT(CONCAT(unigramsP65::token, 'C'), unigramsP66::token) as token, unigramsP65::day as day, unigramsP65::id as id, unigramsP65::pos as pos;
unigramsX2S66 = JOIN unigramsP66 BY id, unigramsP67 BY id;
unigramsC2S66 = FOREACH unigramsX2S66 GENERATE CONCAT(CONCAT(unigramsP66::token, 'C'), unigramsP67::token) as token, unigramsP66::day as day, unigramsP66::id as id, unigramsP66::pos as pos;
unigramsX2S67 = JOIN unigramsP67 BY id, unigramsP68 BY id;
unigramsC2S67 = FOREACH unigramsX2S67 GENERATE CONCAT(CONCAT(unigramsP67::token, 'C'), unigramsP68::token) as token, unigramsP67::day as day, unigramsP67::id as id, unigramsP67::pos as pos;
unigramsX2S68 = JOIN unigramsP68 BY id, unigramsP69 BY id;
unigramsC2S68 = FOREACH unigramsX2S68 GENERATE CONCAT(CONCAT(unigramsP68::token, 'C'), unigramsP69::token) as token, unigramsP68::day as day, unigramsP68::id as id, unigramsP68::pos as pos;
bigrams = UNION 
  unigramsC2S0,
  unigramsC2S1,
  unigramsC2S2,
  unigramsC2S3,
  unigramsC2S4,
  unigramsC2S5,
  unigramsC2S6,
  unigramsC2S7,
  unigramsC2S8,
  unigramsC2S9,
  unigramsC2S10,
  unigramsC2S11,
  unigramsC2S12,
  unigramsC2S13,
  unigramsC2S14,
  unigramsC2S15,
  unigramsC2S16,
  unigramsC2S17,
  unigramsC2S18,
  unigramsC2S19,
  unigramsC2S20,
  unigramsC2S21,
  unigramsC2S22,
  unigramsC2S23,
  unigramsC2S24,
  unigramsC2S25,
  unigramsC2S26,
  unigramsC2S27,
  unigramsC2S28,
  unigramsC2S29,
  unigramsC2S30,
  unigramsC2S31,
  unigramsC2S32,
  unigramsC2S33,
  unigramsC2S34,
  unigramsC2S35,
  unigramsC2S36,
  unigramsC2S37,
  unigramsC2S38,
  unigramsC2S39,
  unigramsC2S40,
  unigramsC2S41,
  unigramsC2S42,
  unigramsC2S43,
  unigramsC2S44,
  unigramsC2S45,
  unigramsC2S46,
  unigramsC2S47,
  unigramsC2S48,
  unigramsC2S49,
  unigramsC2S50,
  unigramsC2S51,
  unigramsC2S52,
  unigramsC2S53,
  unigramsC2S54,
  unigramsC2S55,
  unigramsC2S56,
  unigramsC2S57,
  unigramsC2S58,
  unigramsC2S59,
  unigramsC2S60,
  unigramsC2S61,
  unigramsC2S62,
  unigramsC2S63,
  unigramsC2S64,
  unigramsC2S65,
  unigramsC2S66,
  unigramsC2S67,
  unigramsC2S68;
