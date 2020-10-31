package mtg.logic;

import org.junit.Assert;
import org.junit.Test;

import java.io.IOException;
import java.net.URL;
import java.util.regex.Matcher;

public class DeckTemplateTest {
    private static final String DECK_FILENAME = "oopsTemplate.dec";

    @Test
    public void testToDeck() throws IOException {
        final URL url = DeckTemplateTest.class.getClassLoader().getResource(DECK_FILENAME);
        final DeckTemplate template = new DeckTemplate(url.getPath());
        Assert.assertEquals(49, template.getNumEntries());
        final Deck deck1 = template.toDeck(new int[]{4, 4, 4, 4, 4, 2, 2, 1, 2, 3, 0});
        final String[] cardNames = {"Balustrade Spy", "Undercity Informer",
                "Narcomoeba", "Lotus Petal", "Dark Ritual", "Dread Return",
                "Thassa's Oracle", "Chrome Mox", "Elvish Spirit Guide",
                "Simian Spirit Guide", "Summoner's Pact", "Cabal Therapy"};
        final Deck deck2 = new Deck(cardNames, new int[]{4, 4, 4, 4, 4, 2, 2, 1, 2, 3, 0, 1});
        Assert.assertEquals(deck1, deck2);
    }

    @Test
    public void testCommentPattern() throws IOException {
        final String emptyLine = "";
        final String whitespace = "  ";
        final String comment1 = "#baz";
        final String comment2 = "%bar";
        final String comment3 = "// foo";
        final String inlineComment = "4 Narcomoeba // can work as a 3-of but test that later; tests with 1-2 waste too much time";
        Assert.assertFalse(DeckTemplate.COMMENT_PATTERN.matcher(whitespace).matches());
        Assert.assertFalse(DeckTemplate.COMMENT_PATTERN.matcher(emptyLine).matches());
        Assert.assertTrue(DeckTemplate.COMMENT_PATTERN.matcher(comment1).matches());
        Assert.assertTrue(DeckTemplate.COMMENT_PATTERN.matcher(comment2).matches());
        Assert.assertTrue(DeckTemplate.COMMENT_PATTERN.matcher(comment3).matches());
        final Matcher matcher = DeckTemplate.COMMENT_PATTERN.matcher(inlineComment);
        Assert.assertTrue(matcher.matches());
        Assert.assertEquals("4 Narcomoeba ", matcher.group(1));
    }
}
