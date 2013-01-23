REGISTER piggybank.jar;
REGISTER file://$jdbcjar;
ngramsTokenizer = LOAD 'ngrams/ngramTokenizer' USING PigStorage('\t') AS (id: long, timeMillis: long, date: int, ngram: chararray, ngramLen: int, tweetLen: int,  position: int);
SPLIT ngramsTokenizer INTO ngrams IF position < tweetLen, htags OTHERWISE;
STORE ngrams INTO 'dummy' USING org.apache.pig.piggybank.storage.DBStorage('org.postgresql.Driver', 'jdbc:postgresql://localhost:5433/spritzer', 'yaboulna', '$dbpassword', 'INSERT INTO ngrams VALUES(:1, :2, :3, :4, :5, :6, :7);', '1000');
STORE htag INTO 'dummy' USING org.apache.pig.piggybank.storage.DBStorage('org.postgresql.Driver', 'jdbc:postgresql://localhost:5433/spritzer', 'yaboulna', '$dbpassword', 'INSERT INTO htag VALUES(:1, :2, :3, :4, :5, :6, :7);', '1000');
