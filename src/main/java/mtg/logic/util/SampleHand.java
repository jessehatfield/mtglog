package mtg.logic.util;

import mtg.logic.Deck;

public class SampleHand {
    String[] hand;
    String[] library = null;
    String[] sideboard = null;
    int mulligans = 0;

    public String[] getHand() {
        return hand;
    }

    public void setHand(String[] hand) {
        this.hand = hand;
    }

    public String[] getLibrary() {
        return library;
    }

    public void setLibrary(String[] library) {
        this.library = library;
    }

    public String[] getSideboard() {
        return sideboard;
    }

    public void setSideboard(String[] sideboard) {
        this.sideboard = sideboard;
    }

    public int getMulligans() {
        return mulligans;
    }

    public void setMulligans(int mulligans) {
        this.mulligans = mulligans;
    }

    public String[] getLibrary(final Deck deck) {
        if (library == null) {
            return deck.getRemainder(getHand());
        } else {
            return getLibrary();
        }
    }

    public String[] getSideboard(final Deck deck) {
        if (sideboard == null) {
            return deck.getSideboard();
        } else {
            return getSideboard();
        }
    }
}
