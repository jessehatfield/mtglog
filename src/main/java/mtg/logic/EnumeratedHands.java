package mtg.logic;

import java.util.Arrays;
import java.util.Iterator;
import java.util.Map;

public class EnumeratedHands implements Iterator<Deck.PossibleHand> {

    final String[] cardNames;
    final int[] currentHand;
    final int[] currentLibrary;
    final Deck deck;
    final int[] indices;
    private long retrieved = 0L;
    boolean finished = false;

    public EnumeratedHands(final Deck deck, final int handSize) {
        this.deck = deck;
        final Map<String, Integer> counts = deck.getCounts();
        cardNames = counts.keySet().toArray(new String[]{});
        currentHand = new int[cardNames.length];
        currentLibrary = new int[cardNames.length];
        for (int i = 0; i < cardNames.length; i++) {
            currentLibrary[i] = counts.get(cardNames[i]);
        }
        indices = new int[handSize];
        for (int i = 0; i < handSize; i++) {
            indices[i] = 0;
        }
        currentHand[0] = handSize;
        currentLibrary[0] -= handSize;
        if (currentLibrary[0] < 0) {
            finished = advanceHand();
        }
    }

    @Override
    public boolean hasNext() {
        return !finished;
    }

    @Override
    public Deck.PossibleHand next() {
        final Deck.PossibleHand current = new Deck.PossibleHand(
                cardNames,
                Arrays.copyOf(currentHand, currentHand.length),
                Arrays.copyOf(currentLibrary, currentLibrary.length));
        finished = advanceHand();
        retrieved++;
        return current;
    }

    public long getNumRetrieved() {
        return retrieved;
    }

    private int advanceIndex(int k) {
        int depth = k;
        currentHand[indices[k]] -= 1;
        currentLibrary[indices[k]] += 1;
        indices[k] += 1;
        if (indices[k] >= currentLibrary.length && k > 0) {
            indices[k] = advanceIndex(k - 1);
        }
        if (indices[k] < currentLibrary.length) {
            currentHand[indices[k]] += 1;
            currentLibrary[indices[k]] -= 1;
        }
        return indices[k];
    }

    private boolean advanceHand() {
        boolean valid = false;
        boolean done = false;
        while (!done && !valid) {
            advanceIndex(indices.length - 1);
            valid = true;
            for (int k = 0; k < indices.length; k++) {
                if (indices[k] >= currentLibrary.length) {
                    done = true;
                    break;
                } else if (currentLibrary[indices[k]] < 0) {
                    valid = false;
                    break;
                }
            }
        }
        return done;
    }

    public static long numUniqueHands(final Deck deck, final int handSize) {
        final EnumeratedHands iter = new EnumeratedHands(deck, handSize);
        long n = 0L;
        while(iter.hasNext()) {
            iter.next();
            n++;
        }
        return n;
    }
}
