package mtg.logic;

import org.junit.Assert;
import org.junit.Test;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.net.URL;
import java.util.regex.Matcher;

public class DeckTemplateTest {
    private static final String DECK_FILENAME = "oopsTemplate.dec";
    private static final String DECKLIST_FILENAME = "oops.dec";

    @Test
    public void testToDeck() throws IOException {
        final URL url = DeckTemplateTest.class.getClassLoader().getResource(DECK_FILENAME);
        final DeckTemplate template = new DeckTemplate(url.getPath());
        Assert.assertEquals(43, template.getNumEntries());
        final Deck deck1 = template.toDeck(new int[]{4, 4, 4, 4, 4, 2, 2, 1, 2, 3, 0, 0, 0, 11});
        final String[] cardNames = {"Balustrade Spy", "Undercity Informer",
                "Narcomoeba", "Lotus Petal", "Dark Ritual", "Dread Return",
                "Thassa's Oracle", "Chrome Mox", "Elvish Spirit Guide",
                "Simian Spirit Guide", "Summoner's Pact",
                "Rite of Flame", "Pyretic Ritual", "Desperate Ritual", "Seething Song",
                "Cabal Therapy"
        };
        final Deck deck2 = new Deck(cardNames, new int[]{4, 4, 4, 4, 4, 2, 2, 1, 2, 3, 0, 4, 2, 4, 1, 1});
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

    @Test
    public void testToString() throws IOException {
        final URL templateUrl = DeckTemplateTest.class.getClassLoader().getResource(DECK_FILENAME);
        final DeckTemplate template = new DeckTemplate(templateUrl.getPath());
        final URL decklistUrl = DeckTemplateTest.class.getClassLoader().getResource(DECKLIST_FILENAME);
        final Deck deck = Deck.fromFile(decklistUrl.getPath());
        final String[] lines = template.toString(deck).split("\n");
        try (final BufferedReader reader = new BufferedReader(new FileReader(decklistUrl.getPath()))) {
            int i = 0;
            String line = reader.readLine();
            while (line != null && i < lines.length) {
                Assert.assertEquals(line.trim(), lines[i].trim());
                System.out.println(lines[i]);
                line = reader.readLine();
                i++;
            }
            // Tolerate a difference of one trailing blank line in either direction
            if (line != null) {
                Assert.assertTrue(reader.readLine().trim().isEmpty());
                Assert.assertNull(reader.readLine());
            }
            if (i < lines.length) {
                Assert.assertTrue(lines[i].trim().isEmpty());
                Assert.assertEquals(lines.length-1, i);
            }
        }
    }
}
