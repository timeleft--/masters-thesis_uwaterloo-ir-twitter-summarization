psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min (ngramLen int2, ngram text, date int4, epochStartMillis int8, cnt int4);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min2 (CHECK (ngramLen = 2)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min2 ALTER COLUMN ngramlen SET DEFAULT 2;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min2 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams2';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min2_date ON cnt_5min2(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min2_ngramLen ON cnt_5min2(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min3 (CHECK (ngramLen = 3)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min3 ALTER COLUMN ngramlen SET DEFAULT 3;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min3 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams3';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min3_date ON cnt_5min3(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min3_ngramLen ON cnt_5min3(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min4 (CHECK (ngramLen = 4)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min4 ALTER COLUMN ngramlen SET DEFAULT 4;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min4 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams4';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min4_date ON cnt_5min4(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min4_ngramLen ON cnt_5min4(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min5 (CHECK (ngramLen = 5)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min5 ALTER COLUMN ngramlen SET DEFAULT 5;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min5 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams5';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min5_date ON cnt_5min5(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min5_ngramLen ON cnt_5min5(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min6 (CHECK (ngramLen = 6)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min6 ALTER COLUMN ngramlen SET DEFAULT 6;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min6 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams6';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min6_date ON cnt_5min6(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min6_ngramLen ON cnt_5min6(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min7 (CHECK (ngramLen = 7)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min7 ALTER COLUMN ngramlen SET DEFAULT 7;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min7 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams7';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min7_date ON cnt_5min7(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min7_ngramLen ON cnt_5min7(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min8 (CHECK (ngramLen = 8)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min8 ALTER COLUMN ngramlen SET DEFAULT 8;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min8 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams8';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min8_date ON cnt_5min8(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min8_ngramLen ON cnt_5min8(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min9 (CHECK (ngramLen = 9)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min9 ALTER COLUMN ngramlen SET DEFAULT 9;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min9 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams9';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min9_date ON cnt_5min9(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min9_ngramLen ON cnt_5min9(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min10 (CHECK (ngramLen = 10)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min10 ALTER COLUMN ngramlen SET DEFAULT 10;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min10 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams10';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min10_date ON cnt_5min10(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min10_ngramLen ON cnt_5min10(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min11 (CHECK (ngramLen = 11)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min11 ALTER COLUMN ngramlen SET DEFAULT 11;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min11 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams11';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min11_date ON cnt_5min11(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min11_ngramLen ON cnt_5min11(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min12 (CHECK (ngramLen = 12)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min12 ALTER COLUMN ngramlen SET DEFAULT 12;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min12 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams12';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min12_date ON cnt_5min12(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min12_ngramLen ON cnt_5min12(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min13 (CHECK (ngramLen = 13)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min13 ALTER COLUMN ngramlen SET DEFAULT 13;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min13 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams13';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min13_date ON cnt_5min13(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min13_ngramLen ON cnt_5min13(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min14 (CHECK (ngramLen = 14)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min14 ALTER COLUMN ngramlen SET DEFAULT 14;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min14 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams14';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min14_date ON cnt_5min14(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min14_ngramLen ON cnt_5min14(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min15 (CHECK (ngramLen = 15)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min15 ALTER COLUMN ngramlen SET DEFAULT 15;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min15 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams15';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min15_date ON cnt_5min15(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min15_ngramLen ON cnt_5min15(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min16 (CHECK (ngramLen = 16)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min16 ALTER COLUMN ngramlen SET DEFAULT 16;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min16 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams16';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min16_date ON cnt_5min16(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min16_ngramLen ON cnt_5min16(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min17 (CHECK (ngramLen = 17)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min17 ALTER COLUMN ngramlen SET DEFAULT 17;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min17 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams17';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min17_date ON cnt_5min17(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min17_ngramLen ON cnt_5min17(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min18 (CHECK (ngramLen = 18)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min18 ALTER COLUMN ngramlen SET DEFAULT 18;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min18 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams18';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min18_date ON cnt_5min18(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min18_ngramLen ON cnt_5min18(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min19 (CHECK (ngramLen = 19)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min19 ALTER COLUMN ngramlen SET DEFAULT 19;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min19 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams19';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min19_date ON cnt_5min19(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min19_ngramLen ON cnt_5min19(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min20 (CHECK (ngramLen = 20)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min20 ALTER COLUMN ngramlen SET DEFAULT 20;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min20 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams20';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min20_date ON cnt_5min20(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min20_ngramLen ON cnt_5min20(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min21 (CHECK (ngramLen = 21)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min21 ALTER COLUMN ngramlen SET DEFAULT 21;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min21 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams21';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min21_date ON cnt_5min21(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min21_ngramLen ON cnt_5min21(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min22 (CHECK (ngramLen = 22)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min22 ALTER COLUMN ngramlen SET DEFAULT 22;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min22 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams22';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min22_date ON cnt_5min22(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min22_ngramLen ON cnt_5min22(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min23 (CHECK (ngramLen = 23)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min23 ALTER COLUMN ngramlen SET DEFAULT 23;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min23 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams23';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min23_date ON cnt_5min23(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min23_ngramLen ON cnt_5min23(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min24 (CHECK (ngramLen = 24)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min24 ALTER COLUMN ngramlen SET DEFAULT 24;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min24 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams24';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min24_date ON cnt_5min24(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min24_ngramLen ON cnt_5min24(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min25 (CHECK (ngramLen = 25)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min25 ALTER COLUMN ngramlen SET DEFAULT 25;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min25 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams25';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min25_date ON cnt_5min25(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min25_ngramLen ON cnt_5min25(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min26 (CHECK (ngramLen = 26)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min26 ALTER COLUMN ngramlen SET DEFAULT 26;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min26 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams26';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min26_date ON cnt_5min26(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min26_ngramLen ON cnt_5min26(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min27 (CHECK (ngramLen = 27)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min27 ALTER COLUMN ngramlen SET DEFAULT 27;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min27 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams27';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min27_date ON cnt_5min27(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min27_ngramLen ON cnt_5min27(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min28 (CHECK (ngramLen = 28)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min28 ALTER COLUMN ngramlen SET DEFAULT 28;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min28 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams28';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min28_date ON cnt_5min28(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min28_ngramLen ON cnt_5min28(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min29 (CHECK (ngramLen = 29)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min29 ALTER COLUMN ngramlen SET DEFAULT 29;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min29 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams29';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min29_date ON cnt_5min29(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min29_ngramLen ON cnt_5min29(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min30 (CHECK (ngramLen = 30)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min30 ALTER COLUMN ngramlen SET DEFAULT 30;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min30 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams30';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min30_date ON cnt_5min30(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min30_ngramLen ON cnt_5min30(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min31 (CHECK (ngramLen = 31)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min31 ALTER COLUMN ngramlen SET DEFAULT 31;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min31 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams31';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min31_date ON cnt_5min31(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min31_ngramLen ON cnt_5min31(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min32 (CHECK (ngramLen = 32)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min32 ALTER COLUMN ngramlen SET DEFAULT 32;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min32 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams32';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min32_date ON cnt_5min32(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min32_ngramLen ON cnt_5min32(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min33 (CHECK (ngramLen = 33)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min33 ALTER COLUMN ngramlen SET DEFAULT 33;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min33 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams33';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min33_date ON cnt_5min33(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min33_ngramLen ON cnt_5min33(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min34 (CHECK (ngramLen = 34)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min34 ALTER COLUMN ngramlen SET DEFAULT 34;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min34 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams34';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min34_date ON cnt_5min34(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min34_ngramLen ON cnt_5min34(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min35 (CHECK (ngramLen = 35)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min35 ALTER COLUMN ngramlen SET DEFAULT 35;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min35 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams35';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min35_date ON cnt_5min35(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min35_ngramLen ON cnt_5min35(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min36 (CHECK (ngramLen = 36)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min36 ALTER COLUMN ngramlen SET DEFAULT 36;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min36 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams36';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min36_date ON cnt_5min36(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min36_ngramLen ON cnt_5min36(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min37 (CHECK (ngramLen = 37)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min37 ALTER COLUMN ngramlen SET DEFAULT 37;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min37 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams37';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min37_date ON cnt_5min37(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min37_ngramLen ON cnt_5min37(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min38 (CHECK (ngramLen = 38)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min38 ALTER COLUMN ngramlen SET DEFAULT 38;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min38 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams38';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min38_date ON cnt_5min38(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min38_ngramLen ON cnt_5min38(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min39 (CHECK (ngramLen = 39)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min39 ALTER COLUMN ngramlen SET DEFAULT 39;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min39 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams39';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min39_date ON cnt_5min39(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min39_ngramLen ON cnt_5min39(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min40 (CHECK (ngramLen = 40)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min40 ALTER COLUMN ngramlen SET DEFAULT 40;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min40 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams40';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min40_date ON cnt_5min40(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min40_ngramLen ON cnt_5min40(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min41 (CHECK (ngramLen = 41)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min41 ALTER COLUMN ngramlen SET DEFAULT 41;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min41 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams41';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min41_date ON cnt_5min41(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min41_ngramLen ON cnt_5min41(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min42 (CHECK (ngramLen = 42)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min42 ALTER COLUMN ngramlen SET DEFAULT 42;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min42 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams42';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min42_date ON cnt_5min42(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min42_ngramLen ON cnt_5min42(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min43 (CHECK (ngramLen = 43)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min43 ALTER COLUMN ngramlen SET DEFAULT 43;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min43 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams43';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min43_date ON cnt_5min43(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min43_ngramLen ON cnt_5min43(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min44 (CHECK (ngramLen = 44)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min44 ALTER COLUMN ngramlen SET DEFAULT 44;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min44 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams44';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min44_date ON cnt_5min44(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min44_ngramLen ON cnt_5min44(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min45 (CHECK (ngramLen = 45)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min45 ALTER COLUMN ngramlen SET DEFAULT 45;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min45 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams45';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min45_date ON cnt_5min45(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min45_ngramLen ON cnt_5min45(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min46 (CHECK (ngramLen = 46)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min46 ALTER COLUMN ngramlen SET DEFAULT 46;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min46 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams46';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min46_date ON cnt_5min46(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min46_ngramLen ON cnt_5min46(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min47 (CHECK (ngramLen = 47)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min47 ALTER COLUMN ngramlen SET DEFAULT 47;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min47 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams47';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min47_date ON cnt_5min47(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min47_ngramLen ON cnt_5min47(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min48 (CHECK (ngramLen = 48)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min48 ALTER COLUMN ngramlen SET DEFAULT 48;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min48 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams48';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min48_date ON cnt_5min48(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min48_ngramLen ON cnt_5min48(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min49 (CHECK (ngramLen = 49)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min49 ALTER COLUMN ngramlen SET DEFAULT 49;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min49 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams49';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min49_date ON cnt_5min49(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min49_ngramLen ON cnt_5min49(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min50 (CHECK (ngramLen = 50)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min50 ALTER COLUMN ngramlen SET DEFAULT 50;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min50 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams50';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min50_date ON cnt_5min50(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min50_ngramLen ON cnt_5min50(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min51 (CHECK (ngramLen = 51)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min51 ALTER COLUMN ngramlen SET DEFAULT 51;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min51 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams51';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min51_date ON cnt_5min51(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min51_ngramLen ON cnt_5min51(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min52 (CHECK (ngramLen = 52)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min52 ALTER COLUMN ngramlen SET DEFAULT 52;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min52 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams52';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min52_date ON cnt_5min52(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min52_ngramLen ON cnt_5min52(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min53 (CHECK (ngramLen = 53)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min53 ALTER COLUMN ngramlen SET DEFAULT 53;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min53 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams53';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min53_date ON cnt_5min53(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min53_ngramLen ON cnt_5min53(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min54 (CHECK (ngramLen = 54)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min54 ALTER COLUMN ngramlen SET DEFAULT 54;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min54 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams54';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min54_date ON cnt_5min54(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min54_ngramLen ON cnt_5min54(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min55 (CHECK (ngramLen = 55)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min55 ALTER COLUMN ngramlen SET DEFAULT 55;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min55 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams55';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min55_date ON cnt_5min55(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min55_ngramLen ON cnt_5min55(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min56 (CHECK (ngramLen = 56)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min56 ALTER COLUMN ngramlen SET DEFAULT 56;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min56 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams56';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min56_date ON cnt_5min56(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min56_ngramLen ON cnt_5min56(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min57 (CHECK (ngramLen = 57)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min57 ALTER COLUMN ngramlen SET DEFAULT 57;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min57 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams57';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min57_date ON cnt_5min57(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min57_ngramLen ON cnt_5min57(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min58 (CHECK (ngramLen = 58)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min58 ALTER COLUMN ngramlen SET DEFAULT 58;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min58 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams58';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min58_date ON cnt_5min58(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min58_ngramLen ON cnt_5min58(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min59 (CHECK (ngramLen = 59)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min59 ALTER COLUMN ngramlen SET DEFAULT 59;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min59 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams59';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min59_date ON cnt_5min59(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min59_ngramLen ON cnt_5min59(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min60 (CHECK (ngramLen = 60)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min60 ALTER COLUMN ngramlen SET DEFAULT 60;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min60 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams60';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min60_date ON cnt_5min60(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min60_ngramLen ON cnt_5min60(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min61 (CHECK (ngramLen = 61)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min61 ALTER COLUMN ngramlen SET DEFAULT 61;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min61 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams61';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min61_date ON cnt_5min61(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min61_ngramLen ON cnt_5min61(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min62 (CHECK (ngramLen = 62)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min62 ALTER COLUMN ngramlen SET DEFAULT 62;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min62 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams62';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min62_date ON cnt_5min62(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min62_ngramLen ON cnt_5min62(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min63 (CHECK (ngramLen = 63)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min63 ALTER COLUMN ngramlen SET DEFAULT 63;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min63 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams63';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min63_date ON cnt_5min63(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min63_ngramLen ON cnt_5min63(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min64 (CHECK (ngramLen = 64)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min64 ALTER COLUMN ngramlen SET DEFAULT 64;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min64 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams64';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min64_date ON cnt_5min64(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min64_ngramLen ON cnt_5min64(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min65 (CHECK (ngramLen = 65)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min65 ALTER COLUMN ngramlen SET DEFAULT 65;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min65 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams65';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min65_date ON cnt_5min65(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min65_ngramLen ON cnt_5min65(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min66 (CHECK (ngramLen = 66)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min66 ALTER COLUMN ngramlen SET DEFAULT 66;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min66 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams66';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min66_date ON cnt_5min66(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min66_ngramLen ON cnt_5min66(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min67 (CHECK (ngramLen = 67)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min67 ALTER COLUMN ngramlen SET DEFAULT 67;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min67 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams67';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min67_date ON cnt_5min67(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min67_ngramLen ON cnt_5min67(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min68 (CHECK (ngramLen = 68)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min68 ALTER COLUMN ngramlen SET DEFAULT 68;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min68 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams68';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min68_date ON cnt_5min68(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min68_ngramLen ON cnt_5min68(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min69 (CHECK (ngramLen = 69)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min69 ALTER COLUMN ngramlen SET DEFAULT 69;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min69 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams69';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min69_date ON cnt_5min69(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min69_ngramLen ON cnt_5min69(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min70 (CHECK (ngramLen = 70)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min70 ALTER COLUMN ngramlen SET DEFAULT 70;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min70 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams70';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min70_date ON cnt_5min70(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min70_ngramLen ON cnt_5min70(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_5min71 (CHECK (ngramLen = 71)) INHERITS(cnt_5min);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_5min71 ALTER COLUMN ngramlen SET DEFAULT 71;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_5min71 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_5min_onefile/ngrams71';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min71_date ON cnt_5min71(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_5min71_ngramLen ON cnt_5min71(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr (ngramLen int2, ngram text, date int4, epochStartMillis int8, cnt int4);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr2 (CHECK (ngramLen = 2)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr2 ALTER COLUMN ngramlen SET DEFAULT 2;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr2 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams2';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr2_date ON cnt_1hr2(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr2_ngramLen ON cnt_1hr2(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr3 (CHECK (ngramLen = 3)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr3 ALTER COLUMN ngramlen SET DEFAULT 3;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr3 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams3';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr3_date ON cnt_1hr3(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr3_ngramLen ON cnt_1hr3(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr4 (CHECK (ngramLen = 4)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr4 ALTER COLUMN ngramlen SET DEFAULT 4;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr4 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams4';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr4_date ON cnt_1hr4(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr4_ngramLen ON cnt_1hr4(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr5 (CHECK (ngramLen = 5)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr5 ALTER COLUMN ngramlen SET DEFAULT 5;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr5 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams5';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr5_date ON cnt_1hr5(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr5_ngramLen ON cnt_1hr5(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr6 (CHECK (ngramLen = 6)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr6 ALTER COLUMN ngramlen SET DEFAULT 6;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr6 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams6';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr6_date ON cnt_1hr6(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr6_ngramLen ON cnt_1hr6(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr7 (CHECK (ngramLen = 7)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr7 ALTER COLUMN ngramlen SET DEFAULT 7;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr7 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams7';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr7_date ON cnt_1hr7(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr7_ngramLen ON cnt_1hr7(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr8 (CHECK (ngramLen = 8)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr8 ALTER COLUMN ngramlen SET DEFAULT 8;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr8 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams8';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr8_date ON cnt_1hr8(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr8_ngramLen ON cnt_1hr8(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr9 (CHECK (ngramLen = 9)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr9 ALTER COLUMN ngramlen SET DEFAULT 9;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr9 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams9';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr9_date ON cnt_1hr9(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr9_ngramLen ON cnt_1hr9(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr10 (CHECK (ngramLen = 10)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr10 ALTER COLUMN ngramlen SET DEFAULT 10;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr10 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams10';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr10_date ON cnt_1hr10(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr10_ngramLen ON cnt_1hr10(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr11 (CHECK (ngramLen = 11)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr11 ALTER COLUMN ngramlen SET DEFAULT 11;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr11 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams11';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr11_date ON cnt_1hr11(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr11_ngramLen ON cnt_1hr11(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr12 (CHECK (ngramLen = 12)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr12 ALTER COLUMN ngramlen SET DEFAULT 12;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr12 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams12';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr12_date ON cnt_1hr12(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr12_ngramLen ON cnt_1hr12(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr13 (CHECK (ngramLen = 13)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr13 ALTER COLUMN ngramlen SET DEFAULT 13;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr13 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams13';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr13_date ON cnt_1hr13(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr13_ngramLen ON cnt_1hr13(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr14 (CHECK (ngramLen = 14)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr14 ALTER COLUMN ngramlen SET DEFAULT 14;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr14 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams14';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr14_date ON cnt_1hr14(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr14_ngramLen ON cnt_1hr14(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr15 (CHECK (ngramLen = 15)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr15 ALTER COLUMN ngramlen SET DEFAULT 15;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr15 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams15';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr15_date ON cnt_1hr15(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr15_ngramLen ON cnt_1hr15(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr16 (CHECK (ngramLen = 16)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr16 ALTER COLUMN ngramlen SET DEFAULT 16;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr16 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams16';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr16_date ON cnt_1hr16(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr16_ngramLen ON cnt_1hr16(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr17 (CHECK (ngramLen = 17)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr17 ALTER COLUMN ngramlen SET DEFAULT 17;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr17 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams17';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr17_date ON cnt_1hr17(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr17_ngramLen ON cnt_1hr17(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr18 (CHECK (ngramLen = 18)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr18 ALTER COLUMN ngramlen SET DEFAULT 18;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr18 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams18';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr18_date ON cnt_1hr18(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr18_ngramLen ON cnt_1hr18(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr19 (CHECK (ngramLen = 19)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr19 ALTER COLUMN ngramlen SET DEFAULT 19;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr19 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams19';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr19_date ON cnt_1hr19(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr19_ngramLen ON cnt_1hr19(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr20 (CHECK (ngramLen = 20)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr20 ALTER COLUMN ngramlen SET DEFAULT 20;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr20 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams20';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr20_date ON cnt_1hr20(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr20_ngramLen ON cnt_1hr20(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr21 (CHECK (ngramLen = 21)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr21 ALTER COLUMN ngramlen SET DEFAULT 21;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr21 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams21';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr21_date ON cnt_1hr21(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr21_ngramLen ON cnt_1hr21(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr22 (CHECK (ngramLen = 22)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr22 ALTER COLUMN ngramlen SET DEFAULT 22;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr22 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams22';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr22_date ON cnt_1hr22(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr22_ngramLen ON cnt_1hr22(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr23 (CHECK (ngramLen = 23)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr23 ALTER COLUMN ngramlen SET DEFAULT 23;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr23 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams23';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr23_date ON cnt_1hr23(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr23_ngramLen ON cnt_1hr23(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr24 (CHECK (ngramLen = 24)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr24 ALTER COLUMN ngramlen SET DEFAULT 24;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr24 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams24';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr24_date ON cnt_1hr24(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr24_ngramLen ON cnt_1hr24(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr25 (CHECK (ngramLen = 25)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr25 ALTER COLUMN ngramlen SET DEFAULT 25;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr25 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams25';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr25_date ON cnt_1hr25(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr25_ngramLen ON cnt_1hr25(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr26 (CHECK (ngramLen = 26)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr26 ALTER COLUMN ngramlen SET DEFAULT 26;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr26 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams26';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr26_date ON cnt_1hr26(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr26_ngramLen ON cnt_1hr26(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr27 (CHECK (ngramLen = 27)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr27 ALTER COLUMN ngramlen SET DEFAULT 27;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr27 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams27';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr27_date ON cnt_1hr27(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr27_ngramLen ON cnt_1hr27(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr28 (CHECK (ngramLen = 28)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr28 ALTER COLUMN ngramlen SET DEFAULT 28;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr28 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams28';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr28_date ON cnt_1hr28(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr28_ngramLen ON cnt_1hr28(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr29 (CHECK (ngramLen = 29)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr29 ALTER COLUMN ngramlen SET DEFAULT 29;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr29 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams29';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr29_date ON cnt_1hr29(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr29_ngramLen ON cnt_1hr29(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr30 (CHECK (ngramLen = 30)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr30 ALTER COLUMN ngramlen SET DEFAULT 30;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr30 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams30';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr30_date ON cnt_1hr30(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr30_ngramLen ON cnt_1hr30(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr31 (CHECK (ngramLen = 31)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr31 ALTER COLUMN ngramlen SET DEFAULT 31;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr31 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams31';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr31_date ON cnt_1hr31(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr31_ngramLen ON cnt_1hr31(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr32 (CHECK (ngramLen = 32)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr32 ALTER COLUMN ngramlen SET DEFAULT 32;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr32 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams32';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr32_date ON cnt_1hr32(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr32_ngramLen ON cnt_1hr32(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr33 (CHECK (ngramLen = 33)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr33 ALTER COLUMN ngramlen SET DEFAULT 33;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr33 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams33';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr33_date ON cnt_1hr33(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr33_ngramLen ON cnt_1hr33(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr34 (CHECK (ngramLen = 34)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr34 ALTER COLUMN ngramlen SET DEFAULT 34;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr34 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams34';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr34_date ON cnt_1hr34(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr34_ngramLen ON cnt_1hr34(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr35 (CHECK (ngramLen = 35)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr35 ALTER COLUMN ngramlen SET DEFAULT 35;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr35 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams35';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr35_date ON cnt_1hr35(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr35_ngramLen ON cnt_1hr35(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr36 (CHECK (ngramLen = 36)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr36 ALTER COLUMN ngramlen SET DEFAULT 36;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr36 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams36';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr36_date ON cnt_1hr36(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr36_ngramLen ON cnt_1hr36(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr37 (CHECK (ngramLen = 37)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr37 ALTER COLUMN ngramlen SET DEFAULT 37;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr37 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams37';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr37_date ON cnt_1hr37(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr37_ngramLen ON cnt_1hr37(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr38 (CHECK (ngramLen = 38)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr38 ALTER COLUMN ngramlen SET DEFAULT 38;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr38 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams38';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr38_date ON cnt_1hr38(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr38_ngramLen ON cnt_1hr38(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr39 (CHECK (ngramLen = 39)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr39 ALTER COLUMN ngramlen SET DEFAULT 39;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr39 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams39';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr39_date ON cnt_1hr39(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr39_ngramLen ON cnt_1hr39(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr40 (CHECK (ngramLen = 40)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr40 ALTER COLUMN ngramlen SET DEFAULT 40;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr40 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams40';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr40_date ON cnt_1hr40(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr40_ngramLen ON cnt_1hr40(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr41 (CHECK (ngramLen = 41)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr41 ALTER COLUMN ngramlen SET DEFAULT 41;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr41 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams41';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr41_date ON cnt_1hr41(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr41_ngramLen ON cnt_1hr41(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr42 (CHECK (ngramLen = 42)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr42 ALTER COLUMN ngramlen SET DEFAULT 42;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr42 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams42';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr42_date ON cnt_1hr42(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr42_ngramLen ON cnt_1hr42(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr43 (CHECK (ngramLen = 43)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr43 ALTER COLUMN ngramlen SET DEFAULT 43;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr43 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams43';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr43_date ON cnt_1hr43(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr43_ngramLen ON cnt_1hr43(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr44 (CHECK (ngramLen = 44)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr44 ALTER COLUMN ngramlen SET DEFAULT 44;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr44 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams44';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr44_date ON cnt_1hr44(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr44_ngramLen ON cnt_1hr44(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr45 (CHECK (ngramLen = 45)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr45 ALTER COLUMN ngramlen SET DEFAULT 45;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr45 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams45';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr45_date ON cnt_1hr45(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr45_ngramLen ON cnt_1hr45(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr46 (CHECK (ngramLen = 46)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr46 ALTER COLUMN ngramlen SET DEFAULT 46;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr46 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams46';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr46_date ON cnt_1hr46(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr46_ngramLen ON cnt_1hr46(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr47 (CHECK (ngramLen = 47)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr47 ALTER COLUMN ngramlen SET DEFAULT 47;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr47 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams47';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr47_date ON cnt_1hr47(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr47_ngramLen ON cnt_1hr47(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr48 (CHECK (ngramLen = 48)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr48 ALTER COLUMN ngramlen SET DEFAULT 48;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr48 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams48';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr48_date ON cnt_1hr48(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr48_ngramLen ON cnt_1hr48(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr49 (CHECK (ngramLen = 49)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr49 ALTER COLUMN ngramlen SET DEFAULT 49;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr49 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams49';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr49_date ON cnt_1hr49(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr49_ngramLen ON cnt_1hr49(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr50 (CHECK (ngramLen = 50)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr50 ALTER COLUMN ngramlen SET DEFAULT 50;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr50 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams50';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr50_date ON cnt_1hr50(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr50_ngramLen ON cnt_1hr50(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr51 (CHECK (ngramLen = 51)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr51 ALTER COLUMN ngramlen SET DEFAULT 51;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr51 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams51';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr51_date ON cnt_1hr51(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr51_ngramLen ON cnt_1hr51(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr52 (CHECK (ngramLen = 52)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr52 ALTER COLUMN ngramlen SET DEFAULT 52;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr52 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams52';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr52_date ON cnt_1hr52(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr52_ngramLen ON cnt_1hr52(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr53 (CHECK (ngramLen = 53)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr53 ALTER COLUMN ngramlen SET DEFAULT 53;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr53 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams53';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr53_date ON cnt_1hr53(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr53_ngramLen ON cnt_1hr53(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr54 (CHECK (ngramLen = 54)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr54 ALTER COLUMN ngramlen SET DEFAULT 54;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr54 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams54';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr54_date ON cnt_1hr54(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr54_ngramLen ON cnt_1hr54(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr55 (CHECK (ngramLen = 55)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr55 ALTER COLUMN ngramlen SET DEFAULT 55;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr55 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams55';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr55_date ON cnt_1hr55(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr55_ngramLen ON cnt_1hr55(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr56 (CHECK (ngramLen = 56)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr56 ALTER COLUMN ngramlen SET DEFAULT 56;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr56 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams56';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr56_date ON cnt_1hr56(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr56_ngramLen ON cnt_1hr56(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr57 (CHECK (ngramLen = 57)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr57 ALTER COLUMN ngramlen SET DEFAULT 57;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr57 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams57';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr57_date ON cnt_1hr57(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr57_ngramLen ON cnt_1hr57(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr58 (CHECK (ngramLen = 58)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr58 ALTER COLUMN ngramlen SET DEFAULT 58;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr58 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams58';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr58_date ON cnt_1hr58(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr58_ngramLen ON cnt_1hr58(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr59 (CHECK (ngramLen = 59)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr59 ALTER COLUMN ngramlen SET DEFAULT 59;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr59 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams59';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr59_date ON cnt_1hr59(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr59_ngramLen ON cnt_1hr59(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr60 (CHECK (ngramLen = 60)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr60 ALTER COLUMN ngramlen SET DEFAULT 60;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr60 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams60';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr60_date ON cnt_1hr60(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr60_ngramLen ON cnt_1hr60(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr61 (CHECK (ngramLen = 61)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr61 ALTER COLUMN ngramlen SET DEFAULT 61;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr61 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams61';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr61_date ON cnt_1hr61(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr61_ngramLen ON cnt_1hr61(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr62 (CHECK (ngramLen = 62)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr62 ALTER COLUMN ngramlen SET DEFAULT 62;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr62 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams62';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr62_date ON cnt_1hr62(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr62_ngramLen ON cnt_1hr62(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr63 (CHECK (ngramLen = 63)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr63 ALTER COLUMN ngramlen SET DEFAULT 63;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr63 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams63';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr63_date ON cnt_1hr63(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr63_ngramLen ON cnt_1hr63(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr64 (CHECK (ngramLen = 64)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr64 ALTER COLUMN ngramlen SET DEFAULT 64;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr64 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams64';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr64_date ON cnt_1hr64(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr64_ngramLen ON cnt_1hr64(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr65 (CHECK (ngramLen = 65)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr65 ALTER COLUMN ngramlen SET DEFAULT 65;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr65 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams65';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr65_date ON cnt_1hr65(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr65_ngramLen ON cnt_1hr65(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr66 (CHECK (ngramLen = 66)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr66 ALTER COLUMN ngramlen SET DEFAULT 66;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr66 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams66';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr66_date ON cnt_1hr66(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr66_ngramLen ON cnt_1hr66(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr67 (CHECK (ngramLen = 67)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr67 ALTER COLUMN ngramlen SET DEFAULT 67;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr67 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams67';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr67_date ON cnt_1hr67(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr67_ngramLen ON cnt_1hr67(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr68 (CHECK (ngramLen = 68)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr68 ALTER COLUMN ngramlen SET DEFAULT 68;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr68 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams68';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr68_date ON cnt_1hr68(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr68_ngramLen ON cnt_1hr68(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr69 (CHECK (ngramLen = 69)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr69 ALTER COLUMN ngramlen SET DEFAULT 69;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr69 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams69';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr69_date ON cnt_1hr69(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr69_ngramLen ON cnt_1hr69(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr70 (CHECK (ngramLen = 70)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr70 ALTER COLUMN ngramlen SET DEFAULT 70;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr70 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams70';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr70_date ON cnt_1hr70(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr70_ngramLen ON cnt_1hr70(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1hr71 (CHECK (ngramLen = 71)) INHERITS(cnt_1hr);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1hr71 ALTER COLUMN ngramlen SET DEFAULT 71;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1hr71 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1hr_onefile/ngrams71';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr71_date ON cnt_1hr71(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1hr71_ngramLen ON cnt_1hr71(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day (ngramLen int2, ngram text, date int4, epochStartMillis int8, cnt int4);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day2 (CHECK (ngramLen = 2)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day2 ALTER COLUMN ngramlen SET DEFAULT 2;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day2 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams2';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day2_date ON cnt_1day2(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day2_ngramLen ON cnt_1day2(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day3 (CHECK (ngramLen = 3)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day3 ALTER COLUMN ngramlen SET DEFAULT 3;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day3 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams3';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day3_date ON cnt_1day3(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day3_ngramLen ON cnt_1day3(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day4 (CHECK (ngramLen = 4)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day4 ALTER COLUMN ngramlen SET DEFAULT 4;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day4 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams4';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day4_date ON cnt_1day4(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day4_ngramLen ON cnt_1day4(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day5 (CHECK (ngramLen = 5)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day5 ALTER COLUMN ngramlen SET DEFAULT 5;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day5 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams5';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day5_date ON cnt_1day5(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day5_ngramLen ON cnt_1day5(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day6 (CHECK (ngramLen = 6)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day6 ALTER COLUMN ngramlen SET DEFAULT 6;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day6 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams6';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day6_date ON cnt_1day6(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day6_ngramLen ON cnt_1day6(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day7 (CHECK (ngramLen = 7)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day7 ALTER COLUMN ngramlen SET DEFAULT 7;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day7 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams7';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day7_date ON cnt_1day7(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day7_ngramLen ON cnt_1day7(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day8 (CHECK (ngramLen = 8)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day8 ALTER COLUMN ngramlen SET DEFAULT 8;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day8 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams8';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day8_date ON cnt_1day8(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day8_ngramLen ON cnt_1day8(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day9 (CHECK (ngramLen = 9)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day9 ALTER COLUMN ngramlen SET DEFAULT 9;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day9 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams9';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day9_date ON cnt_1day9(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day9_ngramLen ON cnt_1day9(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day10 (CHECK (ngramLen = 10)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day10 ALTER COLUMN ngramlen SET DEFAULT 10;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day10 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams10';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day10_date ON cnt_1day10(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day10_ngramLen ON cnt_1day10(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day11 (CHECK (ngramLen = 11)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day11 ALTER COLUMN ngramlen SET DEFAULT 11;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day11 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams11';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day11_date ON cnt_1day11(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day11_ngramLen ON cnt_1day11(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day12 (CHECK (ngramLen = 12)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day12 ALTER COLUMN ngramlen SET DEFAULT 12;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day12 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams12';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day12_date ON cnt_1day12(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day12_ngramLen ON cnt_1day12(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day13 (CHECK (ngramLen = 13)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day13 ALTER COLUMN ngramlen SET DEFAULT 13;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day13 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams13';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day13_date ON cnt_1day13(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day13_ngramLen ON cnt_1day13(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day14 (CHECK (ngramLen = 14)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day14 ALTER COLUMN ngramlen SET DEFAULT 14;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day14 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams14';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day14_date ON cnt_1day14(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day14_ngramLen ON cnt_1day14(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day15 (CHECK (ngramLen = 15)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day15 ALTER COLUMN ngramlen SET DEFAULT 15;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day15 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams15';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day15_date ON cnt_1day15(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day15_ngramLen ON cnt_1day15(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day16 (CHECK (ngramLen = 16)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day16 ALTER COLUMN ngramlen SET DEFAULT 16;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day16 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams16';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day16_date ON cnt_1day16(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day16_ngramLen ON cnt_1day16(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day17 (CHECK (ngramLen = 17)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day17 ALTER COLUMN ngramlen SET DEFAULT 17;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day17 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams17';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day17_date ON cnt_1day17(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day17_ngramLen ON cnt_1day17(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day18 (CHECK (ngramLen = 18)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day18 ALTER COLUMN ngramlen SET DEFAULT 18;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day18 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams18';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day18_date ON cnt_1day18(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day18_ngramLen ON cnt_1day18(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day19 (CHECK (ngramLen = 19)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day19 ALTER COLUMN ngramlen SET DEFAULT 19;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day19 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams19';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day19_date ON cnt_1day19(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day19_ngramLen ON cnt_1day19(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day20 (CHECK (ngramLen = 20)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day20 ALTER COLUMN ngramlen SET DEFAULT 20;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day20 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams20';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day20_date ON cnt_1day20(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day20_ngramLen ON cnt_1day20(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day21 (CHECK (ngramLen = 21)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day21 ALTER COLUMN ngramlen SET DEFAULT 21;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day21 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams21';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day21_date ON cnt_1day21(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day21_ngramLen ON cnt_1day21(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day22 (CHECK (ngramLen = 22)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day22 ALTER COLUMN ngramlen SET DEFAULT 22;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day22 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams22';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day22_date ON cnt_1day22(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day22_ngramLen ON cnt_1day22(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day23 (CHECK (ngramLen = 23)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day23 ALTER COLUMN ngramlen SET DEFAULT 23;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day23 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams23';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day23_date ON cnt_1day23(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day23_ngramLen ON cnt_1day23(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day24 (CHECK (ngramLen = 24)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day24 ALTER COLUMN ngramlen SET DEFAULT 24;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day24 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams24';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day24_date ON cnt_1day24(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day24_ngramLen ON cnt_1day24(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day25 (CHECK (ngramLen = 25)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day25 ALTER COLUMN ngramlen SET DEFAULT 25;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day25 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams25';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day25_date ON cnt_1day25(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day25_ngramLen ON cnt_1day25(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day26 (CHECK (ngramLen = 26)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day26 ALTER COLUMN ngramlen SET DEFAULT 26;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day26 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams26';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day26_date ON cnt_1day26(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day26_ngramLen ON cnt_1day26(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day27 (CHECK (ngramLen = 27)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day27 ALTER COLUMN ngramlen SET DEFAULT 27;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day27 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams27';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day27_date ON cnt_1day27(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day27_ngramLen ON cnt_1day27(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day28 (CHECK (ngramLen = 28)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day28 ALTER COLUMN ngramlen SET DEFAULT 28;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day28 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams28';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day28_date ON cnt_1day28(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day28_ngramLen ON cnt_1day28(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day29 (CHECK (ngramLen = 29)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day29 ALTER COLUMN ngramlen SET DEFAULT 29;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day29 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams29';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day29_date ON cnt_1day29(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day29_ngramLen ON cnt_1day29(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day30 (CHECK (ngramLen = 30)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day30 ALTER COLUMN ngramlen SET DEFAULT 30;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day30 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams30';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day30_date ON cnt_1day30(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day30_ngramLen ON cnt_1day30(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day31 (CHECK (ngramLen = 31)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day31 ALTER COLUMN ngramlen SET DEFAULT 31;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day31 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams31';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day31_date ON cnt_1day31(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day31_ngramLen ON cnt_1day31(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day32 (CHECK (ngramLen = 32)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day32 ALTER COLUMN ngramlen SET DEFAULT 32;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day32 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams32';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day32_date ON cnt_1day32(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day32_ngramLen ON cnt_1day32(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day33 (CHECK (ngramLen = 33)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day33 ALTER COLUMN ngramlen SET DEFAULT 33;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day33 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams33';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day33_date ON cnt_1day33(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day33_ngramLen ON cnt_1day33(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day34 (CHECK (ngramLen = 34)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day34 ALTER COLUMN ngramlen SET DEFAULT 34;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day34 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams34';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day34_date ON cnt_1day34(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day34_ngramLen ON cnt_1day34(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day35 (CHECK (ngramLen = 35)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day35 ALTER COLUMN ngramlen SET DEFAULT 35;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day35 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams35';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day35_date ON cnt_1day35(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day35_ngramLen ON cnt_1day35(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day36 (CHECK (ngramLen = 36)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day36 ALTER COLUMN ngramlen SET DEFAULT 36;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day36 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams36';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day36_date ON cnt_1day36(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day36_ngramLen ON cnt_1day36(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day37 (CHECK (ngramLen = 37)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day37 ALTER COLUMN ngramlen SET DEFAULT 37;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day37 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams37';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day37_date ON cnt_1day37(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day37_ngramLen ON cnt_1day37(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day38 (CHECK (ngramLen = 38)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day38 ALTER COLUMN ngramlen SET DEFAULT 38;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day38 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams38';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day38_date ON cnt_1day38(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day38_ngramLen ON cnt_1day38(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day39 (CHECK (ngramLen = 39)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day39 ALTER COLUMN ngramlen SET DEFAULT 39;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day39 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams39';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day39_date ON cnt_1day39(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day39_ngramLen ON cnt_1day39(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day40 (CHECK (ngramLen = 40)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day40 ALTER COLUMN ngramlen SET DEFAULT 40;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day40 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams40';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day40_date ON cnt_1day40(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day40_ngramLen ON cnt_1day40(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day41 (CHECK (ngramLen = 41)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day41 ALTER COLUMN ngramlen SET DEFAULT 41;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day41 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams41';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day41_date ON cnt_1day41(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day41_ngramLen ON cnt_1day41(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day42 (CHECK (ngramLen = 42)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day42 ALTER COLUMN ngramlen SET DEFAULT 42;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day42 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams42';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day42_date ON cnt_1day42(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day42_ngramLen ON cnt_1day42(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day43 (CHECK (ngramLen = 43)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day43 ALTER COLUMN ngramlen SET DEFAULT 43;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day43 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams43';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day43_date ON cnt_1day43(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day43_ngramLen ON cnt_1day43(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day44 (CHECK (ngramLen = 44)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day44 ALTER COLUMN ngramlen SET DEFAULT 44;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day44 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams44';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day44_date ON cnt_1day44(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day44_ngramLen ON cnt_1day44(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day45 (CHECK (ngramLen = 45)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day45 ALTER COLUMN ngramlen SET DEFAULT 45;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day45 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams45';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day45_date ON cnt_1day45(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day45_ngramLen ON cnt_1day45(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day46 (CHECK (ngramLen = 46)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day46 ALTER COLUMN ngramlen SET DEFAULT 46;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day46 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams46';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day46_date ON cnt_1day46(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day46_ngramLen ON cnt_1day46(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day47 (CHECK (ngramLen = 47)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day47 ALTER COLUMN ngramlen SET DEFAULT 47;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day47 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams47';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day47_date ON cnt_1day47(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day47_ngramLen ON cnt_1day47(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day48 (CHECK (ngramLen = 48)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day48 ALTER COLUMN ngramlen SET DEFAULT 48;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day48 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams48';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day48_date ON cnt_1day48(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day48_ngramLen ON cnt_1day48(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day49 (CHECK (ngramLen = 49)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day49 ALTER COLUMN ngramlen SET DEFAULT 49;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day49 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams49';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day49_date ON cnt_1day49(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day49_ngramLen ON cnt_1day49(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day50 (CHECK (ngramLen = 50)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day50 ALTER COLUMN ngramlen SET DEFAULT 50;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day50 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams50';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day50_date ON cnt_1day50(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day50_ngramLen ON cnt_1day50(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day51 (CHECK (ngramLen = 51)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day51 ALTER COLUMN ngramlen SET DEFAULT 51;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day51 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams51';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day51_date ON cnt_1day51(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day51_ngramLen ON cnt_1day51(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day52 (CHECK (ngramLen = 52)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day52 ALTER COLUMN ngramlen SET DEFAULT 52;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day52 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams52';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day52_date ON cnt_1day52(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day52_ngramLen ON cnt_1day52(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day53 (CHECK (ngramLen = 53)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day53 ALTER COLUMN ngramlen SET DEFAULT 53;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day53 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams53';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day53_date ON cnt_1day53(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day53_ngramLen ON cnt_1day53(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day54 (CHECK (ngramLen = 54)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day54 ALTER COLUMN ngramlen SET DEFAULT 54;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day54 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams54';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day54_date ON cnt_1day54(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day54_ngramLen ON cnt_1day54(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day55 (CHECK (ngramLen = 55)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day55 ALTER COLUMN ngramlen SET DEFAULT 55;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day55 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams55';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day55_date ON cnt_1day55(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day55_ngramLen ON cnt_1day55(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day56 (CHECK (ngramLen = 56)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day56 ALTER COLUMN ngramlen SET DEFAULT 56;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day56 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams56';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day56_date ON cnt_1day56(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day56_ngramLen ON cnt_1day56(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day57 (CHECK (ngramLen = 57)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day57 ALTER COLUMN ngramlen SET DEFAULT 57;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day57 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams57';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day57_date ON cnt_1day57(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day57_ngramLen ON cnt_1day57(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day58 (CHECK (ngramLen = 58)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day58 ALTER COLUMN ngramlen SET DEFAULT 58;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day58 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams58';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day58_date ON cnt_1day58(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day58_ngramLen ON cnt_1day58(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day59 (CHECK (ngramLen = 59)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day59 ALTER COLUMN ngramlen SET DEFAULT 59;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day59 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams59';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day59_date ON cnt_1day59(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day59_ngramLen ON cnt_1day59(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day60 (CHECK (ngramLen = 60)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day60 ALTER COLUMN ngramlen SET DEFAULT 60;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day60 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams60';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day60_date ON cnt_1day60(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day60_ngramLen ON cnt_1day60(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day61 (CHECK (ngramLen = 61)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day61 ALTER COLUMN ngramlen SET DEFAULT 61;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day61 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams61';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day61_date ON cnt_1day61(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day61_ngramLen ON cnt_1day61(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day62 (CHECK (ngramLen = 62)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day62 ALTER COLUMN ngramlen SET DEFAULT 62;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day62 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams62';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day62_date ON cnt_1day62(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day62_ngramLen ON cnt_1day62(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day63 (CHECK (ngramLen = 63)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day63 ALTER COLUMN ngramlen SET DEFAULT 63;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day63 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams63';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day63_date ON cnt_1day63(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day63_ngramLen ON cnt_1day63(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day64 (CHECK (ngramLen = 64)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day64 ALTER COLUMN ngramlen SET DEFAULT 64;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day64 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams64';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day64_date ON cnt_1day64(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day64_ngramLen ON cnt_1day64(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day65 (CHECK (ngramLen = 65)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day65 ALTER COLUMN ngramlen SET DEFAULT 65;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day65 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams65';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day65_date ON cnt_1day65(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day65_ngramLen ON cnt_1day65(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day66 (CHECK (ngramLen = 66)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day66 ALTER COLUMN ngramlen SET DEFAULT 66;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day66 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams66';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day66_date ON cnt_1day66(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day66_ngramLen ON cnt_1day66(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day67 (CHECK (ngramLen = 67)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day67 ALTER COLUMN ngramlen SET DEFAULT 67;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day67 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams67';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day67_date ON cnt_1day67(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day67_ngramLen ON cnt_1day67(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day68 (CHECK (ngramLen = 68)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day68 ALTER COLUMN ngramlen SET DEFAULT 68;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day68 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams68';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day68_date ON cnt_1day68(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day68_ngramLen ON cnt_1day68(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day69 (CHECK (ngramLen = 69)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day69 ALTER COLUMN ngramlen SET DEFAULT 69;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day69 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams69';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day69_date ON cnt_1day69(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day69_ngramLen ON cnt_1day69(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day70 (CHECK (ngramLen = 70)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day70 ALTER COLUMN ngramlen SET DEFAULT 70;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day70 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams70';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day70_date ON cnt_1day70(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day70_ngramLen ON cnt_1day70(ngramLen);'
psql -p 5433 -d sample-0.01 -c  'CREATE UNLOGGED TABLE cnt_1day71 (CHECK (ngramLen = 71)) INHERITS(cnt_1day);'
psql -p 5433 -d sample-0.01 -c  'ALTER TABLE cnt_1day71 ALTER COLUMN ngramlen SET DEFAULT 71;'
psql -p 5433 -d sample-0.01 -c  "COPY cnt_1day71 (ngram, date, epochstartmillis, cnt) FROM '/home/yaboulna/vmshared/backup/cnt_1day_onefile/ngrams71';"
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day71_date ON cnt_1day71(date);'
psql -p 5433 -d sample-0.01 -c  'CREATE INDEX cnt_1day71_ngramLen ON cnt_1day71(ngramLen);'
