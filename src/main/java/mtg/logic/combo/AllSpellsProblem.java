package mtg.logic.combo;

import ec.util.MersenneTwisterFast;
import mtg.logic.Deck;
import mtg.logic.ec.MtgProblem;

import java.util.Map;

public class AllSpellsProblem extends MtgProblem {
    public AllSpellsProblem() {
        super();
        prolog.consultFile("mana.pl");
        prolog.consultFile("cards.pl");
        prolog.consultFile("oops.pl");
        prolog.consultFile("test.pl");
        System.out.println("Prolog files loaded.");
    }

    @Override
    protected Deck createDeck(int[] counts) {
        return new AllSpellsDeck(counts);
    }

    private int runSimulation(String decklistFile, int nGames, int handSize, int minProtection, int greedyMullCount) {
        MersenneTwisterFast rng = new MersenneTwisterFast();
        System.out.println("Loading decklist " + decklistFile + "...");
        Deck d = Deck.fromFile(AllSpellsDeck.cards, decklistFile);
//        printQueries(d, nGames, rng);
        boolean verbose = true;
        boolean automull = true;
        Map<String, Integer> results = prolog.simulateGames(d, nGames, handSize, verbose, automull, minProtection, greedyMullCount, rng);
        int nWins = results.get("wins");
        int nProtectedWins = results.get("protected");
        double p = ((double) nWins) / nGames;
        double stddev = Math.sqrt(nGames * p * (1-p));
        double pProtected = ((double) nProtectedWins) / nGames;
        double stddevProtected = Math.sqrt(nGames * pProtected * (1-pProtected));
        System.out.println(nWins + " wins (stddev=" + stddev + " ; p=" + p + ")");
        System.out.println(nProtectedWins + " protected wins (stddev=" + stddevProtected + " ; p=" + pProtected + ")");
//        prolog.sim(d, nGames, false, minProtection, int greedyMullCount, rng);
        return nWins;
    }

    public void printQueries(Deck d, int n, MersenneTwisterFast rng) {
        System.out.println("testHands(I) :-");
        System.out.println("    consult('cards.pl'),");
        System.out.println("    consult('mana.pl'),");
        System.out.println("    consult('belcher.pl'),");
        for (int i = 0; i < n; i++) {
            String[][] parts = d.drawHand(rng, 7);
            String[] hand = parts[0];
            String[] library = parts[1];
            String handList = "[ '" + escape(hand[0]) + "'";
            for (int j = 1; j < 7; j++) {
                handList += ", '" + escape(hand[j]) + "'";
            }
            handList += " ]";
            String deckList = "[ '" + escape(library[0]) + "'";
            for (int j = 1; j < library.length; j++) {
                deckList += ", '" + escape(library[j]) + "'";
            }
            deckList += " ]";
            System.out.println("    I is " + i + ", win_basic("
                    + handList + ", " + deckList + ", [], _);");
        }
        System.out.println("    I is -1, true.");
    }

    public void test() {
        String[] hand = {"Summoners Pact", "Summoners Pact", "Undercity Informer",
                "Simian Spirit Guide", "Simian Spirit Guide", "Summoners Pact"};
        String[] deck = {"Wild Cantor", "Elvish Spirit Guide", "Tinder Wall"};
        prolog.testHand(hand, deck);
    }

    public static String escape(String foo) {
        return foo.replace("'", "\\'");
    }

    public static void main(String[] args) {
        if (args.length >= 2) {
            AllSpellsProblem app = new AllSpellsProblem();
            app.prolog.setShowProgress(10);
            int minProtection = 0;
            int greedyMullCount = 7;
            int handSize = 7;
            if (args.length > 2) {
                minProtection = Integer.parseInt(args[2]);
            }
            if (args.length > 3) {
                greedyMullCount = Integer.parseInt(args[3]);
            }
            if (args.length > 4) {
                handSize = Integer.parseInt(args[4]);
            }
            app.runSimulation(args[0], Integer.parseInt(args[1]), handSize, minProtection, greedyMullCount);
        } else {
            System.out.println("Usage: AllSpellsProblem <decklist> <n games> [min protection to keep hand] [number of mulligans before giving up on protection goal] [hand size]");
        }
    }
}
