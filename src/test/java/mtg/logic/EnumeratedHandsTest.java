package mtg.logic;

import org.junit.Assert;
import org.junit.Test;

import java.io.IOException;
import java.net.URL;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

public class EnumeratedHandsTest {
    static class DistinctHand {
        final long configurations;
        final String[] cards;
        DistinctHand(final long configurations, final String ...cards) {
            this.configurations = configurations;
            this.cards = Arrays.copyOf(cards, cards.length);
            Arrays.sort(this.cards);
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            DistinctHand that = (DistinctHand) o;
            return configurations == that.configurations &&
                    Arrays.equals(cards, that.cards);
        }

        @Override
        public int hashCode() {
            int result = Objects.hash(configurations);
            result = 31 * result + Arrays.hashCode(cards);
            return result;
        }

        @Override
        public String toString() {
            return "DistinctHand(cards=" + Arrays.toString(cards) + "; configurations=" + configurations + ")";
        }
    }

    @Test
    public void testEnumeration() {
        final String[] cards = new String[] {"fourofA", "singletonB", "fourofC", "singletonD"};
        final int[] counts = new int[] {4, 1, 4, 1};
        final Deck deck = new Deck(cards, counts);
        EnumeratedHands hands = new EnumeratedHands(deck, 3);
        int n = 0;
        int total = 0;
        long fiftyChooseThree = 50L * 49 * 48 / 6;
        Set<DistinctHand> expectedHands = new HashSet<>(Arrays.asList(
            // 3 copies of one card (must be A, C, or Unknown)
            new DistinctHand(4, "fourofA", "fourofA", "fourofA"),
            new DistinctHand(4, "fourofC", "fourofC", "fourofC"),
            new DistinctHand(fiftyChooseThree, "Unknown", "Unknown", "Unknown"),
            // 2 copies of one (must be A, C, or Unknown) + 1 copy of another
            new DistinctHand(300, "fourofA", "fourofA", "Unknown"),
            new DistinctHand(6, "fourofA", "fourofA", "singletonB"),
            new DistinctHand(24, "fourofA", "fourofA", "fourofC"),
            new DistinctHand(6, "fourofA", "fourofA", "singletonD"),
            new DistinctHand(300, "fourofC", "fourofC", "Unknown"),
            new DistinctHand(24, "fourofC", "fourofC", "fourofA"),
            new DistinctHand(6, "fourofC", "fourofC", "singletonB"),
            new DistinctHand(6, "fourofC", "fourofC", "singletonD"),
            new DistinctHand(25*49*4, "Unknown", "Unknown", "fourofA"),
            new DistinctHand(25*49, "Unknown", "Unknown", "singletonB"),
            new DistinctHand(25*49*4, "Unknown", "Unknown", "fourofC"),
            new DistinctHand(25*49, "Unknown", "Unknown", "singletonD"),
            // 3 unique cards
            new DistinctHand(16, "fourofA", "singletonB", "fourofC"),
            new DistinctHand(4, "fourofA", "singletonB", "singletonD"),
            new DistinctHand(16, "fourofA", "fourofC", "singletonD"),
            new DistinctHand(4, "singletonB", "fourofC", "singletonD"),
            new DistinctHand(200, "Unknown", "fourofA", "singletonB"),
            new DistinctHand(800, "Unknown", "fourofA", "fourofC"),
            new DistinctHand(200, "Unknown", "fourofA", "singletonD"),
            new DistinctHand(200, "Unknown", "singletonB", "fourofC"),
            new DistinctHand(50, "Unknown", "singletonB", "singletonD"),
            new DistinctHand(200, "Unknown", "fourofC", "singletonD")));
        Set<DistinctHand> computedHands = new HashSet<>();
        while (hands.hasNext()) {
            final Deck.PossibleHand hand = hands.next();
            computedHands.add(new DistinctHand(hand.combinations(), hand.getHand()));
            n++;
            total += hand.combinations();
        }
        Assert.assertEquals(n, 25);
        Assert.assertEquals(total, 60L * 59 * 58 / 6);
        final Set<DistinctHand> missingHands = new HashSet<>(expectedHands);
        missingHands.removeAll(computedHands);
        Assert.assertEquals("Expected but didn't compute: " + missingHands.toString(), 0, missingHands.size());
        final Set<DistinctHand> unexpectedHands = new HashSet<>(computedHands);
        unexpectedHands.removeAll(expectedHands);
        Assert.assertEquals("Computed unexpected hand(s): " + unexpectedHands.toString(), 0, unexpectedHands.size());
        Assert.assertEquals(expectedHands, computedHands);
    }

    @Test
    public void testDeckEnumeration() throws IOException {
        final URL deckURL = EnumeratedHandsTest.class.getClassLoader().getResource("stockOops.dec");
        final Deck deck = Deck.fromFile(deckURL.getPath());
        EnumeratedHands hands = new EnumeratedHands(deck, 7);
        int n = 0;
        int total = 0;
        while (hands.hasNext()) {
            final Deck.PossibleHand hand = hands.next();
            n++;
            total += hand.combinations();
        }
        System.out.println(n + " unique hands");
        System.out.println(total + " total hands");
        Assert.assertEquals(386206920L, total);
    }
}
