package mtg.logic;

import ec.util.MersenneTwisterFast;
import org.jpl7.Atom;
import org.jpl7.Compound;
import org.jpl7.Term;
import org.jpl7.Query;
import org.jpl7.Util;
import org.jpl7.Variable;

import java.io.File;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;

public class PrologEngine {
    private final File prologSrcDir;

    public PrologEngine(String srcPath) {
        this.prologSrcDir = new File(srcPath);
        System.out.println("Looking for prolog files in " + prologSrcDir + "...");
    }

    public void consultFile(String localName) {
        final String sourcePath = new File(prologSrcDir, localName).getAbsolutePath();
        System.out.println("Consulting " + sourcePath + "...");
        new Query("consult", new Term[] { new Atom(sourcePath)}).allSolutions();
    }

    public void setShowProgress(final int interval) {
        new Query("asserta", new Term[] {
            new Compound("showProgress", new Term[] { new org.jpl7.Integer(interval) })
        }).allSolutions();
    }

    public Query buildQuery(String predicate, String[] hand, String[] deck, String[] sideboard) {
        Term handTerm = Util.stringArrayToList(hand);
        Term deckTerm = Util.stringArrayToList(deck);
        Term sideTerm = Util.stringArrayToList(sideboard);
        Variable sequence = new Variable("Sequence");
        Query winQ = new Query(predicate, new Term[] { handTerm, deckTerm, sideTerm, sequence });
        return winQ;
    }

    public Query buildQuery(String predicate, String[] hand, String[] other) {
        Term handTerm = Util.stringArrayToList(hand);
        Term otherTerm = Util.stringArrayToList(other);
        Variable sequence = new Variable("Sequence");
        Query q = new Query(predicate, new Term[] { handTerm, otherTerm, sequence });
        return q;
    }

    public void sim(Deck d, int n, boolean autoMull, int minProtection, int greedyMullCount, MersenneTwisterFast rng) {
        if (autoMull) {
            int w = simulateGames(d, n, 7, true, minProtection, greedyMullCount, rng).get("wins");
            System.out.println("Won " + w + " out of " + n + " on the first turn.");
        }
        else {
            double cantwin = 1.0;
            for (int i = 7; i > 3; i--) {
                System.out.println();
                System.out.println(i + " cards, " + n + " samples:");
                int[] result = getResults(d, n, i, false, false, true, true, rng);
                double winp = 100.0 * result[0] / n;
                double millp = 100.0 * result[1] / n;
                double wcp = 100.0 * result[2] / n;
                System.out.println(winp + "% first-turn win");
                System.out.println(millp + "% can mill deck but not win");
                System.out.println(wcp + "% have win condition but can't mill/win");
                cantwin *= 1 - (winp / 100);
            }
            double winp_automull = 100.0 * (1 - cantwin);
            System.out.println("\n" + winp_automull
                    + "% first-turn win if we mull all non-winning hands");
        }
    }

    public int[] getResults(Deck deck, int n, int handSize, boolean verbose, boolean mull,
                            boolean describe, boolean full, MersenneTwisterFast rng) {
        int w = 0;
        int mill = 0;
        int wc = 0;
        Query winQ;
        Query millQ;
        Query winconditionQ;
        for (int i = 0; i < n; i++) {
            String[] shuffled = deck.getShuffled(rng);
            //draw hand
            String[] hand = Arrays.copyOf(shuffled, handSize);
            String[] library = Arrays.copyOfRange(shuffled, handSize, shuffled.length);
            String[] side = deck.getSideboard();
            //play
            if (full) {
                winQ = buildQuery("win", hand, library, side);
            }
            else {
                winQ = buildQuery("win_basic", hand, library, side);
            }
            try {
                if (winQ.hasSolution()) {
                    w++;
                    if (verbose) {
                        System.out.print("Win with ");
                        System.out.print(handSize);
                        System.out.println(" cards");
                    }
                } else if (describe) {
                    //Gather other statistics
                    millQ = buildQuery("mill", hand, library, side);
                    winconditionQ = buildQuery("win_condition", hand, side);

                    if (millQ.hasSolution()) {
                        mill++;
                        if (verbose) {
                            System.out.print("Mill deck, can't win (");
                            System.out.print(handSize);
                            System.out.println(" cards)");
                        }
                    }
                    else if (winconditionQ.hasSolution()) {
                        wc++;
                        if (verbose) {
                            winconditionQ.open();
                            String all = "";
                            Map<String, Term> bindings = winconditionQ.getSolution();
                            while (bindings != null) {
                                Term sTerm = (Term) bindings.get("Sequence");
                                all += " " + sTerm.toString();
                                bindings = winconditionQ.getSolution();
                            }
                            winQ.close();
                            System.out.print("Have [" + all + " ], can't win (");
                            System.out.print(handSize);
                            System.out.println(" cards)");
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                System.out.println(Util.stringArrayToList(hand));
                System.out.println(Util.stringArrayToList(library));
                System.out.println(Util.stringArrayToList(side));
            }
        }
        int[] result = {w, mill, wc};
        return result;
    }

    public Map<String, Integer> simulateGames(Deck deck, int n, int handSize, boolean verbose, boolean mull, int minProtection, int greedyMullCount, MersenneTwisterFast rng) {
        final Term deckTerm = Util.stringArrayToList(deck.list());
        final Term sbTerm = Util.stringArrayToList(deck.getSideboard());
        final Variable sequencesV = new Variable("Sequences");
        final Variable handsV = new Variable("Hands");
        final Variable protCountsV = new Variable("ProtectionCounts");
        final Variable winsV = new Variable("Wins");
        final Query experimentQuery = new Query("play_games", new Term[] {
                new org.jpl7.Integer(n),
                deckTerm,
                sbTerm,
                new org.jpl7.Integer(handSize),
                new org.jpl7.Integer(mull ? handSize : 0),
                new org.jpl7.Integer(mull ? minProtection : 0),
                new org.jpl7.Integer(mull ? (greedyMullCount >= 0 ? greedyMullCount : handSize) : 0),
                handsV,
                sequencesV,
                protCountsV,
                winsV});
        experimentQuery.open();
        final Map<String, Term> bindings = experimentQuery.getSolution();
        final int wins = bindings.get("Wins").intValue();
        final Term[] protectionTerms = bindings.get("ProtectionCounts").toTermArray();
        if (verbose) {
            final Term[] handTerms = bindings.get("Hands").toTermArray();
            final Term[] seqTerms = bindings.get("Sequences").toTermArray();
            for (int i = 0; i < handTerms.length; i++) {
                final Term[] steps = seqTerms[i].toTermArray();
                System.out.println("Sample hand: " + Arrays.deepToString(handTerms[i].toTermArray()));
                if (steps.length == 0) {
                    System.out.println("       loss.");
                } else if (steps[steps.length-1].name().equalsIgnoreCase("mulligan")) {
                    System.out.println("       loss: " + Arrays.deepToString(steps));
                } else {
                    final int protectionCount = protectionTerms[i].intValue();
                    System.out.println("        win: " + Arrays.deepToString(steps) + " (" + protectionCount + "x protection)");
                }
            }
        }
        int protectedWins = 0;
        final Map<Integer, Integer> protCountDistribution = new LinkedHashMap<>();
        for (int i = 0; i < protectionTerms.length; i++) {
            final int protectionCount = protectionTerms[i].intValue();
            final int prevCount = protCountDistribution.getOrDefault(protectionCount, 0);
            protCountDistribution.put(protectionCount, prevCount + 1);
            if (protectionCount > 0) {
                protectedWins++;
            }
        }
        experimentQuery.close();
        if (verbose) {
            System.out.println(protCountDistribution);
        }
        final Map<String, Integer> results = new LinkedHashMap<>();
        results.put("games", n);
        results.put("wins", wins);
        results.put("protected", protectedWins);
        return results;
    }

    /*
    public Map<String, Integer>  simulateGames(Deck deck, int n, int handSize, boolean verbose, boolean mull, int greedyMullCount, MersenneTwisterFast rng) {
        return getResults(deck, n, handSize, verbose, mull, false, false, greedyMullCount, rng)[0];
    }
    */

    public Map<String, Integer> simulateGames(Deck deck, int n, int handSize, boolean verbose, int minProtection, int greedyMullCount, MersenneTwisterFast rng) {
        return simulateGames(deck, n, handSize, verbose, true, minProtection, greedyMullCount, rng);
    }

    public int[] getResults(Deck deck, int n, int handSize, boolean verbose, MersenneTwisterFast rng) {
        return getResults(deck, n, handSize, verbose, false, true, false, rng);
    }

    public void testHand(String[] hand, String[] deck) {
        Term handTerm = Util.stringArrayToList(hand);
        Term deckTerm = Util.stringArrayToList(deck);
        Variable sequence = new Variable("Sequence");
        Query winQ = new Query("win", new Term[] { handTerm, deckTerm, sequence });
        winQ.open();
        Map<String, Term> bindings = winQ.getSolution();
        if (bindings == null) {
            System.out.println("fail.");
        }
        else {
            Term sTerm = (Term) bindings.get("Sequence");
            System.out.println(sTerm);
            winQ.close();
        }
    }
}
