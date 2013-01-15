SPLIT unigram INTO 
  pos0 IF pos==0,
  pos1 IF pos==1,
  pos2 IF pos==2,
  pos3 IF pos==3,
  pos4 IF pos==4,
  pos5 IF pos==5,
  pos6 IF pos==6,
  pos7 IF pos==7,
  pos8 IF pos==8,
  pos9 IF pos==9,
  pos10 IF pos==10,
  pos11 IF pos==11,
  pos12 IF pos==12,
  pos13 IF pos==13,
  pos14 IF pos==14,
  pos15 IF pos==15,
  pos16 IF pos==16,
  pos17 IF pos==17,
  pos18 IF pos==18,
  pos19 IF pos==19,
  pos20 IF pos==20,
  pos21 IF pos==21,
  pos22 IF pos==22,
  pos23 IF pos==23,
  pos24 IF pos==24,
  pos25 IF pos==25,
  pos26 IF pos==26,
  pos27 IF pos==27,
  pos28 IF pos==28,
  pos29 IF pos==29,
  pos30 IF pos==30,
  pos31 IF pos==31,
  pos32 IF pos==32,
  pos33 IF pos==33,
  pos34 IF pos==34,
  pos35 IF pos==35,
  pos36 IF pos==36,
  pos37 IF pos==37,
  pos38 IF pos==38,
  pos39 IF pos==39,
  pos40 IF pos==40,
  pos41 IF pos==41,
  pos42 IF pos==42,
  pos43 IF pos==43,
  pos44 IF pos==44,
  pos45 IF pos==45,
  pos46 IF pos==46,
  pos47 IF pos==47,
  pos48 IF pos==48,
  pos49 IF pos==49,
  pos50 IF pos==50,
  pos51 IF pos==51,
  pos52 IF pos==52,
  pos53 IF pos==53,
  pos54 IF pos==54,
  pos55 IF pos==55,
  pos56 IF pos==56,
  pos57 IF pos==57,
  pos58 IF pos==58,
  pos59 IF pos==59,
  pos60 IF pos==60,
  pos61 IF pos==61,
  pos62 IF pos==62,
  pos63 IF pos==63,
  pos64 IF pos==64,
  pos65 IF pos==65,
  pos66 IF pos==66,
  pos67 IF pos==67,
  pos68 IF pos==68,
  pos69 IF pos==69,
unigramX2S0 = JOIN pos0 BY id, pos0+1 BY id;
unigramC2S0 = FOREACH unigramX2S0 GENERATE CONCAT(CONCAT(pos0::token, 'C'), pos0+1::token) as token, pos0::day as day, pos0::id as id, pos0::pos as pos;
unigramX2S1 = JOIN pos1 BY id, pos1+1 BY id;
unigramC2S1 = FOREACH unigramX2S1 GENERATE CONCAT(CONCAT(pos1::token, 'C'), pos1+1::token) as token, pos1::day as day, pos1::id as id, pos1::pos as pos;
unigramX2S2 = JOIN pos2 BY id, pos2+1 BY id;
unigramC2S2 = FOREACH unigramX2S2 GENERATE CONCAT(CONCAT(pos2::token, 'C'), pos2+1::token) as token, pos2::day as day, pos2::id as id, pos2::pos as pos;
unigramX2S3 = JOIN pos3 BY id, pos3+1 BY id;
unigramC2S3 = FOREACH unigramX2S3 GENERATE CONCAT(CONCAT(pos3::token, 'C'), pos3+1::token) as token, pos3::day as day, pos3::id as id, pos3::pos as pos;
unigramX2S4 = JOIN pos4 BY id, pos4+1 BY id;
unigramC2S4 = FOREACH unigramX2S4 GENERATE CONCAT(CONCAT(pos4::token, 'C'), pos4+1::token) as token, pos4::day as day, pos4::id as id, pos4::pos as pos;
unigramX2S5 = JOIN pos5 BY id, pos5+1 BY id;
unigramC2S5 = FOREACH unigramX2S5 GENERATE CONCAT(CONCAT(pos5::token, 'C'), pos5+1::token) as token, pos5::day as day, pos5::id as id, pos5::pos as pos;
unigramX2S6 = JOIN pos6 BY id, pos6+1 BY id;
unigramC2S6 = FOREACH unigramX2S6 GENERATE CONCAT(CONCAT(pos6::token, 'C'), pos6+1::token) as token, pos6::day as day, pos6::id as id, pos6::pos as pos;
unigramX2S7 = JOIN pos7 BY id, pos7+1 BY id;
unigramC2S7 = FOREACH unigramX2S7 GENERATE CONCAT(CONCAT(pos7::token, 'C'), pos7+1::token) as token, pos7::day as day, pos7::id as id, pos7::pos as pos;
unigramX2S8 = JOIN pos8 BY id, pos8+1 BY id;
unigramC2S8 = FOREACH unigramX2S8 GENERATE CONCAT(CONCAT(pos8::token, 'C'), pos8+1::token) as token, pos8::day as day, pos8::id as id, pos8::pos as pos;
unigramX2S9 = JOIN pos9 BY id, pos9+1 BY id;
unigramC2S9 = FOREACH unigramX2S9 GENERATE CONCAT(CONCAT(pos9::token, 'C'), pos9+1::token) as token, pos9::day as day, pos9::id as id, pos9::pos as pos;
unigramX2S10 = JOIN pos10 BY id, pos10+1 BY id;
unigramC2S10 = FOREACH unigramX2S10 GENERATE CONCAT(CONCAT(pos10::token, 'C'), pos10+1::token) as token, pos10::day as day, pos10::id as id, pos10::pos as pos;
unigramX2S11 = JOIN pos11 BY id, pos11+1 BY id;
unigramC2S11 = FOREACH unigramX2S11 GENERATE CONCAT(CONCAT(pos11::token, 'C'), pos11+1::token) as token, pos11::day as day, pos11::id as id, pos11::pos as pos;
unigramX2S12 = JOIN pos12 BY id, pos12+1 BY id;
unigramC2S12 = FOREACH unigramX2S12 GENERATE CONCAT(CONCAT(pos12::token, 'C'), pos12+1::token) as token, pos12::day as day, pos12::id as id, pos12::pos as pos;
unigramX2S13 = JOIN pos13 BY id, pos13+1 BY id;
unigramC2S13 = FOREACH unigramX2S13 GENERATE CONCAT(CONCAT(pos13::token, 'C'), pos13+1::token) as token, pos13::day as day, pos13::id as id, pos13::pos as pos;
unigramX2S14 = JOIN pos14 BY id, pos14+1 BY id;
unigramC2S14 = FOREACH unigramX2S14 GENERATE CONCAT(CONCAT(pos14::token, 'C'), pos14+1::token) as token, pos14::day as day, pos14::id as id, pos14::pos as pos;
unigramX2S15 = JOIN pos15 BY id, pos15+1 BY id;
unigramC2S15 = FOREACH unigramX2S15 GENERATE CONCAT(CONCAT(pos15::token, 'C'), pos15+1::token) as token, pos15::day as day, pos15::id as id, pos15::pos as pos;
unigramX2S16 = JOIN pos16 BY id, pos16+1 BY id;
unigramC2S16 = FOREACH unigramX2S16 GENERATE CONCAT(CONCAT(pos16::token, 'C'), pos16+1::token) as token, pos16::day as day, pos16::id as id, pos16::pos as pos;
unigramX2S17 = JOIN pos17 BY id, pos17+1 BY id;
unigramC2S17 = FOREACH unigramX2S17 GENERATE CONCAT(CONCAT(pos17::token, 'C'), pos17+1::token) as token, pos17::day as day, pos17::id as id, pos17::pos as pos;
unigramX2S18 = JOIN pos18 BY id, pos18+1 BY id;
unigramC2S18 = FOREACH unigramX2S18 GENERATE CONCAT(CONCAT(pos18::token, 'C'), pos18+1::token) as token, pos18::day as day, pos18::id as id, pos18::pos as pos;
unigramX2S19 = JOIN pos19 BY id, pos19+1 BY id;
unigramC2S19 = FOREACH unigramX2S19 GENERATE CONCAT(CONCAT(pos19::token, 'C'), pos19+1::token) as token, pos19::day as day, pos19::id as id, pos19::pos as pos;
unigramX2S20 = JOIN pos20 BY id, pos20+1 BY id;
unigramC2S20 = FOREACH unigramX2S20 GENERATE CONCAT(CONCAT(pos20::token, 'C'), pos20+1::token) as token, pos20::day as day, pos20::id as id, pos20::pos as pos;
unigramX2S21 = JOIN pos21 BY id, pos21+1 BY id;
unigramC2S21 = FOREACH unigramX2S21 GENERATE CONCAT(CONCAT(pos21::token, 'C'), pos21+1::token) as token, pos21::day as day, pos21::id as id, pos21::pos as pos;
unigramX2S22 = JOIN pos22 BY id, pos22+1 BY id;
unigramC2S22 = FOREACH unigramX2S22 GENERATE CONCAT(CONCAT(pos22::token, 'C'), pos22+1::token) as token, pos22::day as day, pos22::id as id, pos22::pos as pos;
unigramX2S23 = JOIN pos23 BY id, pos23+1 BY id;
unigramC2S23 = FOREACH unigramX2S23 GENERATE CONCAT(CONCAT(pos23::token, 'C'), pos23+1::token) as token, pos23::day as day, pos23::id as id, pos23::pos as pos;
unigramX2S24 = JOIN pos24 BY id, pos24+1 BY id;
unigramC2S24 = FOREACH unigramX2S24 GENERATE CONCAT(CONCAT(pos24::token, 'C'), pos24+1::token) as token, pos24::day as day, pos24::id as id, pos24::pos as pos;
unigramX2S25 = JOIN pos25 BY id, pos25+1 BY id;
unigramC2S25 = FOREACH unigramX2S25 GENERATE CONCAT(CONCAT(pos25::token, 'C'), pos25+1::token) as token, pos25::day as day, pos25::id as id, pos25::pos as pos;
unigramX2S26 = JOIN pos26 BY id, pos26+1 BY id;
unigramC2S26 = FOREACH unigramX2S26 GENERATE CONCAT(CONCAT(pos26::token, 'C'), pos26+1::token) as token, pos26::day as day, pos26::id as id, pos26::pos as pos;
unigramX2S27 = JOIN pos27 BY id, pos27+1 BY id;
unigramC2S27 = FOREACH unigramX2S27 GENERATE CONCAT(CONCAT(pos27::token, 'C'), pos27+1::token) as token, pos27::day as day, pos27::id as id, pos27::pos as pos;
unigramX2S28 = JOIN pos28 BY id, pos28+1 BY id;
unigramC2S28 = FOREACH unigramX2S28 GENERATE CONCAT(CONCAT(pos28::token, 'C'), pos28+1::token) as token, pos28::day as day, pos28::id as id, pos28::pos as pos;
unigramX2S29 = JOIN pos29 BY id, pos29+1 BY id;
unigramC2S29 = FOREACH unigramX2S29 GENERATE CONCAT(CONCAT(pos29::token, 'C'), pos29+1::token) as token, pos29::day as day, pos29::id as id, pos29::pos as pos;
unigramX2S30 = JOIN pos30 BY id, pos30+1 BY id;
unigramC2S30 = FOREACH unigramX2S30 GENERATE CONCAT(CONCAT(pos30::token, 'C'), pos30+1::token) as token, pos30::day as day, pos30::id as id, pos30::pos as pos;
unigramX2S31 = JOIN pos31 BY id, pos31+1 BY id;
unigramC2S31 = FOREACH unigramX2S31 GENERATE CONCAT(CONCAT(pos31::token, 'C'), pos31+1::token) as token, pos31::day as day, pos31::id as id, pos31::pos as pos;
unigramX2S32 = JOIN pos32 BY id, pos32+1 BY id;
unigramC2S32 = FOREACH unigramX2S32 GENERATE CONCAT(CONCAT(pos32::token, 'C'), pos32+1::token) as token, pos32::day as day, pos32::id as id, pos32::pos as pos;
unigramX2S33 = JOIN pos33 BY id, pos33+1 BY id;
unigramC2S33 = FOREACH unigramX2S33 GENERATE CONCAT(CONCAT(pos33::token, 'C'), pos33+1::token) as token, pos33::day as day, pos33::id as id, pos33::pos as pos;
unigramX2S34 = JOIN pos34 BY id, pos34+1 BY id;
unigramC2S34 = FOREACH unigramX2S34 GENERATE CONCAT(CONCAT(pos34::token, 'C'), pos34+1::token) as token, pos34::day as day, pos34::id as id, pos34::pos as pos;
unigramX2S35 = JOIN pos35 BY id, pos35+1 BY id;
unigramC2S35 = FOREACH unigramX2S35 GENERATE CONCAT(CONCAT(pos35::token, 'C'), pos35+1::token) as token, pos35::day as day, pos35::id as id, pos35::pos as pos;
unigramX2S36 = JOIN pos36 BY id, pos36+1 BY id;
unigramC2S36 = FOREACH unigramX2S36 GENERATE CONCAT(CONCAT(pos36::token, 'C'), pos36+1::token) as token, pos36::day as day, pos36::id as id, pos36::pos as pos;
unigramX2S37 = JOIN pos37 BY id, pos37+1 BY id;
unigramC2S37 = FOREACH unigramX2S37 GENERATE CONCAT(CONCAT(pos37::token, 'C'), pos37+1::token) as token, pos37::day as day, pos37::id as id, pos37::pos as pos;
unigramX2S38 = JOIN pos38 BY id, pos38+1 BY id;
unigramC2S38 = FOREACH unigramX2S38 GENERATE CONCAT(CONCAT(pos38::token, 'C'), pos38+1::token) as token, pos38::day as day, pos38::id as id, pos38::pos as pos;
unigramX2S39 = JOIN pos39 BY id, pos39+1 BY id;
unigramC2S39 = FOREACH unigramX2S39 GENERATE CONCAT(CONCAT(pos39::token, 'C'), pos39+1::token) as token, pos39::day as day, pos39::id as id, pos39::pos as pos;
unigramX2S40 = JOIN pos40 BY id, pos40+1 BY id;
unigramC2S40 = FOREACH unigramX2S40 GENERATE CONCAT(CONCAT(pos40::token, 'C'), pos40+1::token) as token, pos40::day as day, pos40::id as id, pos40::pos as pos;
unigramX2S41 = JOIN pos41 BY id, pos41+1 BY id;
unigramC2S41 = FOREACH unigramX2S41 GENERATE CONCAT(CONCAT(pos41::token, 'C'), pos41+1::token) as token, pos41::day as day, pos41::id as id, pos41::pos as pos;
unigramX2S42 = JOIN pos42 BY id, pos42+1 BY id;
unigramC2S42 = FOREACH unigramX2S42 GENERATE CONCAT(CONCAT(pos42::token, 'C'), pos42+1::token) as token, pos42::day as day, pos42::id as id, pos42::pos as pos;
unigramX2S43 = JOIN pos43 BY id, pos43+1 BY id;
unigramC2S43 = FOREACH unigramX2S43 GENERATE CONCAT(CONCAT(pos43::token, 'C'), pos43+1::token) as token, pos43::day as day, pos43::id as id, pos43::pos as pos;
unigramX2S44 = JOIN pos44 BY id, pos44+1 BY id;
unigramC2S44 = FOREACH unigramX2S44 GENERATE CONCAT(CONCAT(pos44::token, 'C'), pos44+1::token) as token, pos44::day as day, pos44::id as id, pos44::pos as pos;
unigramX2S45 = JOIN pos45 BY id, pos45+1 BY id;
unigramC2S45 = FOREACH unigramX2S45 GENERATE CONCAT(CONCAT(pos45::token, 'C'), pos45+1::token) as token, pos45::day as day, pos45::id as id, pos45::pos as pos;
unigramX2S46 = JOIN pos46 BY id, pos46+1 BY id;
unigramC2S46 = FOREACH unigramX2S46 GENERATE CONCAT(CONCAT(pos46::token, 'C'), pos46+1::token) as token, pos46::day as day, pos46::id as id, pos46::pos as pos;
unigramX2S47 = JOIN pos47 BY id, pos47+1 BY id;
unigramC2S47 = FOREACH unigramX2S47 GENERATE CONCAT(CONCAT(pos47::token, 'C'), pos47+1::token) as token, pos47::day as day, pos47::id as id, pos47::pos as pos;
unigramX2S48 = JOIN pos48 BY id, pos48+1 BY id;
unigramC2S48 = FOREACH unigramX2S48 GENERATE CONCAT(CONCAT(pos48::token, 'C'), pos48+1::token) as token, pos48::day as day, pos48::id as id, pos48::pos as pos;
unigramX2S49 = JOIN pos49 BY id, pos49+1 BY id;
unigramC2S49 = FOREACH unigramX2S49 GENERATE CONCAT(CONCAT(pos49::token, 'C'), pos49+1::token) as token, pos49::day as day, pos49::id as id, pos49::pos as pos;
unigramX2S50 = JOIN pos50 BY id, pos50+1 BY id;
unigramC2S50 = FOREACH unigramX2S50 GENERATE CONCAT(CONCAT(pos50::token, 'C'), pos50+1::token) as token, pos50::day as day, pos50::id as id, pos50::pos as pos;
unigramX2S51 = JOIN pos51 BY id, pos51+1 BY id;
unigramC2S51 = FOREACH unigramX2S51 GENERATE CONCAT(CONCAT(pos51::token, 'C'), pos51+1::token) as token, pos51::day as day, pos51::id as id, pos51::pos as pos;
unigramX2S52 = JOIN pos52 BY id, pos52+1 BY id;
unigramC2S52 = FOREACH unigramX2S52 GENERATE CONCAT(CONCAT(pos52::token, 'C'), pos52+1::token) as token, pos52::day as day, pos52::id as id, pos52::pos as pos;
unigramX2S53 = JOIN pos53 BY id, pos53+1 BY id;
unigramC2S53 = FOREACH unigramX2S53 GENERATE CONCAT(CONCAT(pos53::token, 'C'), pos53+1::token) as token, pos53::day as day, pos53::id as id, pos53::pos as pos;
unigramX2S54 = JOIN pos54 BY id, pos54+1 BY id;
unigramC2S54 = FOREACH unigramX2S54 GENERATE CONCAT(CONCAT(pos54::token, 'C'), pos54+1::token) as token, pos54::day as day, pos54::id as id, pos54::pos as pos;
unigramX2S55 = JOIN pos55 BY id, pos55+1 BY id;
unigramC2S55 = FOREACH unigramX2S55 GENERATE CONCAT(CONCAT(pos55::token, 'C'), pos55+1::token) as token, pos55::day as day, pos55::id as id, pos55::pos as pos;
unigramX2S56 = JOIN pos56 BY id, pos56+1 BY id;
unigramC2S56 = FOREACH unigramX2S56 GENERATE CONCAT(CONCAT(pos56::token, 'C'), pos56+1::token) as token, pos56::day as day, pos56::id as id, pos56::pos as pos;
unigramX2S57 = JOIN pos57 BY id, pos57+1 BY id;
unigramC2S57 = FOREACH unigramX2S57 GENERATE CONCAT(CONCAT(pos57::token, 'C'), pos57+1::token) as token, pos57::day as day, pos57::id as id, pos57::pos as pos;
unigramX2S58 = JOIN pos58 BY id, pos58+1 BY id;
unigramC2S58 = FOREACH unigramX2S58 GENERATE CONCAT(CONCAT(pos58::token, 'C'), pos58+1::token) as token, pos58::day as day, pos58::id as id, pos58::pos as pos;
unigramX2S59 = JOIN pos59 BY id, pos59+1 BY id;
unigramC2S59 = FOREACH unigramX2S59 GENERATE CONCAT(CONCAT(pos59::token, 'C'), pos59+1::token) as token, pos59::day as day, pos59::id as id, pos59::pos as pos;
unigramX2S60 = JOIN pos60 BY id, pos60+1 BY id;
unigramC2S60 = FOREACH unigramX2S60 GENERATE CONCAT(CONCAT(pos60::token, 'C'), pos60+1::token) as token, pos60::day as day, pos60::id as id, pos60::pos as pos;
unigramX2S61 = JOIN pos61 BY id, pos61+1 BY id;
unigramC2S61 = FOREACH unigramX2S61 GENERATE CONCAT(CONCAT(pos61::token, 'C'), pos61+1::token) as token, pos61::day as day, pos61::id as id, pos61::pos as pos;
unigramX2S62 = JOIN pos62 BY id, pos62+1 BY id;
unigramC2S62 = FOREACH unigramX2S62 GENERATE CONCAT(CONCAT(pos62::token, 'C'), pos62+1::token) as token, pos62::day as day, pos62::id as id, pos62::pos as pos;
unigramX2S63 = JOIN pos63 BY id, pos63+1 BY id;
unigramC2S63 = FOREACH unigramX2S63 GENERATE CONCAT(CONCAT(pos63::token, 'C'), pos63+1::token) as token, pos63::day as day, pos63::id as id, pos63::pos as pos;
unigramX2S64 = JOIN pos64 BY id, pos64+1 BY id;
unigramC2S64 = FOREACH unigramX2S64 GENERATE CONCAT(CONCAT(pos64::token, 'C'), pos64+1::token) as token, pos64::day as day, pos64::id as id, pos64::pos as pos;
unigramX2S65 = JOIN pos65 BY id, pos65+1 BY id;
unigramC2S65 = FOREACH unigramX2S65 GENERATE CONCAT(CONCAT(pos65::token, 'C'), pos65+1::token) as token, pos65::day as day, pos65::id as id, pos65::pos as pos;
unigramX2S66 = JOIN pos66 BY id, pos66+1 BY id;
unigramC2S66 = FOREACH unigramX2S66 GENERATE CONCAT(CONCAT(pos66::token, 'C'), pos66+1::token) as token, pos66::day as day, pos66::id as id, pos66::pos as pos;
unigramX2S67 = JOIN pos67 BY id, pos67+1 BY id;
unigramC2S67 = FOREACH unigramX2S67 GENERATE CONCAT(CONCAT(pos67::token, 'C'), pos67+1::token) as token, pos67::day as day, pos67::id as id, pos67::pos as pos;
unigramX2S68 = JOIN pos68 BY id, pos68+1 BY id;
unigramC2S68 = FOREACH unigramX2S68 GENERATE CONCAT(CONCAT(pos68::token, 'C'), pos68+1::token) as token, pos68::day as day, pos68::id as id, pos68::pos as pos;
ngramC2 = UNION 
  unigramC2S0,
  unigramC2S1,
  unigramC2S2,
  unigramC2S3,
  unigramC2S4,
  unigramC2S5,
  unigramC2S6,
  unigramC2S7,
  unigramC2S8,
  unigramC2S9,
  unigramC2S10,
  unigramC2S11,
  unigramC2S12,
  unigramC2S13,
  unigramC2S14,
  unigramC2S15,
  unigramC2S16,
  unigramC2S17,
  unigramC2S18,
  unigramC2S19,
  unigramC2S20,
  unigramC2S21,
  unigramC2S22,
  unigramC2S23,
  unigramC2S24,
  unigramC2S25,
  unigramC2S26,
  unigramC2S27,
  unigramC2S28,
  unigramC2S29,
  unigramC2S30,
  unigramC2S31,
  unigramC2S32,
  unigramC2S33,
  unigramC2S34,
  unigramC2S35,
  unigramC2S36,
  unigramC2S37,
  unigramC2S38,
  unigramC2S39,
  unigramC2S40,
  unigramC2S41,
  unigramC2S42,
  unigramC2S43,
  unigramC2S44,
  unigramC2S45,
  unigramC2S46,
  unigramC2S47,
  unigramC2S48,
  unigramC2S49,
  unigramC2S50,
  unigramC2S51,
  unigramC2S52,
  unigramC2S53,
  unigramC2S54,
  unigramC2S55,
  unigramC2S56,
  unigramC2S57,
  unigramC2S58,
  unigramC2S59,
  unigramC2S60,
  unigramC2S61,
  unigramC2S62,
  unigramC2S63,
  unigramC2S64,
  unigramC2S65,
  unigramC2S66,
  unigramC2S67,
  unigramC2S68,
