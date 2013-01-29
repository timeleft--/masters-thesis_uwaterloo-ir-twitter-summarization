package ca.uwaterloo.twitter;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import java.lang.reflect.InvocationTargetException;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.AbstractIterator;

import ca.uwaterloo.twitter.TokenIterator;
import ca.uwaterloo.twitter.TokenIterator.LatinTokenIterator;

public class TokenIteratorTest {

  protected Class<? extends AbstractIterator<String>> targetClazz;

  @Before
  public void setUp() {
    targetClazz = LatinTokenIterator.class;
  }

  @Test
  public void testBasic() throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance(
        "Basic Test");
    assertEquals("basic", target.next());
    assertEquals("test", target.next());
    assertFalse(target.hasNext());
  }

  @Test
  public void oneWordShort() throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance("OneWord");
    assertEquals("oneword", target.next());
    assertFalse(target.hasNext());
  }

  // @Test
  // public void testNoShort() {
  // TokenIterator target = new TokenIterator("no short");
  // assertEquals("short", target.next());
  // assertFalse(target.hasNext());
  // }

  @Test
  public void testApostropheMiddle() throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance("Apostrphe shouldn't be 'always delimiter' " +
            "like's ain'tt don't");
    assertEquals("apostrphe", target.next());
    assertEquals("shouldnt", target.next());
    assertEquals("be", target.next());
    assertEquals("always", target.next());
    assertEquals("delimiter", target.next());
    assertEquals("like", target.next());
    assertEquals("s", target.next());
    assertEquals("ain", target.next());
    assertEquals("tt", target.next());
    assertEquals("dont", target.next());
    assertFalse(target.hasNext());
  }

  @Test
  public void testApostropheExtremes() throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance("'quoted'''words'");
    assertEquals("quoted", target.next());
    assertEquals("words", target.next());
    assertFalse(target.hasNext());

    target = new TokenIterator("''''");
    assertFalse(target.hasNext());

    target = new TokenIterator("'t");
    assertEquals("t", target.next());
    assertFalse(target.hasNext());

    target = new TokenIterator("t'");
    assertEquals("t", target.next());
    assertFalse(target.hasNext());

    target = new TokenIterator("'t'");
    assertEquals("t", target.next());
    assertFalse(target.hasNext());
  }

  //FIXME: The UDF test fails here because I can't write it so that it descriminates between hashtags that should 
  // be returned with position tweetLen and the symbol # that should be returned in its position
  //@Test
  public void testSymbols() throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance("`~!1@#$%^&*()-_+={}|\\/?><'\":; you_rock");
    // 1 to insure the token doesn't start with @ or #
    // FIXME: # and @ should be treated as delimiters except in the begining
    assertEquals("1@#", target.next());
    // YA 20121120 Now we don't return tokens made of all symbols: assertEquals("_", target.next());
    assertEquals("you_rock", target.next());
    assertFalse(target.hasNext());
  }

  @Test
  public void testShortenning() throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance("coooooooooooooooooool");
    assertEquals("coool", target.next());
    assertFalse(target.hasNext());
  }

  @Test
  public void testMentions() throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance("@younos");
    assertEquals("@younos", target.next());
    // assertEquals("younos", target.next());
    assertFalse(target.hasNext());
  }

  @Test
  public void testHashtagsNorep() {
    TokenIterator target = new TokenIterator("#hashtag");
    target.setRepeatHashTag(false);
    assertEquals("#hashtag", target.next());
    assertFalse(target.hasNext());
  }

  @Test
  public void testHashtagsRepeat() {
    TokenIterator target = new TokenIterator("#hashtag");
    target.setRepeatHashTag(true);
    assertEquals("hashtag", target.next());
    assertEquals("#hashtag", target.next());
    assertFalse(target.hasNext());
  }

  @Test
  public void testHashtagsRepeatAtTheEnd() {
    TokenIterator target = new TokenIterator("#hashtag repeated");
    target.setRepeatHashTag(true);
    target.setRepeatedHashTagAtTheEnd(true);
    assertEquals("hashtag", target.next());
    assertEquals("repeated", target.next());
    assertEquals("#hashtag", target.next());
    assertFalse(target.hasNext());

    target = new TokenIterator("#hashtag repeated");
    target.setRepeatHashTag(true);
    target.setRepeatedHashTagAtTheEnd(false);
    assertEquals("hashtag", target.next());
    assertEquals("#hashtag", target.next());
    assertEquals("repeated", target.next());
    assertFalse(target.hasNext());

    target = new TokenIterator("#hashtag1 #hashtag2 repeated");
    target.setRepeatHashTag(true);
    target.setRepeatedHashTagAtTheEnd(true);
    assertEquals("hashtag1", target.next());
    assertEquals("hashtag2", target.next());
    assertEquals("repeated", target.next());
    assertEquals("#hashtag1", target.next());
    assertEquals("#hashtag2", target.next());
    assertFalse(target.hasNext());
  }

  @Test
  public void testPoundChar() {
    TokenIterator target = new TokenIterator("#");
    target.setRepeatHashTag(true);
    // YA 20121120 Now we don't return tokens made of all symbols: assertEquals("#", target.next());
    assertFalse(target.hasNext());

    target = new TokenIterator("##");
    target.setRepeatHashTag(true);
    // YA 20121120 Now we don't return tokens made of all symbols:assertEquals("#", target.next());
    // YA 20121120 Now we don't return tokens made of all symbols:assertEquals("##", target.next());
    assertFalse(target.hasNext());

    target = new TokenIterator("##");
    target.setRepeatHashTag(false);
    // YA 20121120 Now we don't return tokens made of all symbols:assertEquals("##", target.next());
    assertFalse(target.hasNext());
  }

  // @Test
  // public void testAsciiOnly(){
  // ASCIITokenIterator target = new ASCIITokenIterator("très جداً");
  // assertEquals("trs", target.next());
  // assertFalse(target.hasNext());
  // }

  @Test
  public void testLatinOnly() throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance("très جداً Özsu");
    assertEquals("très", target.next());
    assertEquals("Özsu".toLowerCase(), target.next());
    assertFalse(target.hasNext());
  }

  @Test
  public void testUrl() throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance(
        "http://youtube.com/dsdf33 OK www.wikipedia.com GOOD https://www.bank.com GOTO HTTP://WATCH.THIS www2012_conference");
    assertEquals("URL", target.next());
    assertEquals("ok", target.next());
    assertEquals("URL", target.next());
    assertEquals("good", target.next());
    assertEquals("URL", target.next());
    assertEquals("goto", target.next());
    assertEquals("URL", target.next());
    assertEquals("www2012_conference", target.next());
    assertFalse(target.hasNext());
  }

  @Test
  public void testNumbers() throws InstantiationException, IllegalAccessException,
      IllegalArgumentException, InvocationTargetException, SecurityException {
    // TokenIterator target = new TokenIterator(
    @SuppressWarnings("unchecked")
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance(
        "On 05-07/2012 28th birthday buy 3333. 22,for 12,234.99 each 14.");
    assertEquals("on", target.next());
    assertEquals("05", target.next());
    assertEquals("07", target.next());
    assertEquals("2012", target.next());
    assertEquals("28th", target.next());
    assertEquals("birthday", target.next());
    assertEquals("buy", target.next());
    assertEquals("3333", target.next());
    assertEquals("22", target.next());
    assertEquals("for", target.next());
    assertEquals("12234.99", target.next());
    assertEquals("each", target.next());
    assertEquals("14", target.next());
    assertFalse(target.hasNext());
  }

  @SuppressWarnings("unchecked")
  @Test
  public void testNonEnglish() throws IllegalArgumentException, SecurityException,
      InstantiationException, IllegalAccessException, InvocationTargetException {
    AbstractIterator<String> target = (AbstractIterator<String>) targetClazz.getConstructors()[0]
        .newInstance(
//            "Yungin RT @StaxxFifth: \ud83d\ude02\ud83d\ude02\ud83d\ude02\ud83d\ude02\ud83d\ude02\ud83d\ude02\ud83d\ude02\ud83d\ude02\ud83d\ude02 RT @BankRoll_Lo: Forbs #ThenAndNow Still Got Me Weak\ud83d\ude2d\ud83d\ude2d\ud83d\ude2d\ud83d\ude2d  http://t.co/vQLLxUw5");
     "\"@CWilson_06: \ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba\ud83d\udcba &lt;------- There you go Romney! Take one boo \ud83d\ude1d\" many seats");
    int i = 0;
    while (target.hasNext())
      System.out.println(++i + ": " + target.next());
    System.out.println(i);
  }
}
