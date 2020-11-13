package mtg.logic;

import ec.util.MersenneTwisterFast;
import org.jpl7.*;

import java.io.File;
import java.lang.Integer;
import java.util.*;

public class PrologEngine {
    private final File prologSrcDir;

    public PrologEngine(String srcPath) {
        this.prologSrcDir = new File(srcPath);
        System.out.println("Looking for prolog files in " + prologSrcDir + "...");
    }

    public void consultFile(String localName) {
        final String sourcePath = new File(prologSrcDir, localName).getAbsolutePath();
        System.out.println("Consulting " + sourcePath + "...");
        Query consultQuery = new Query("consult", new Term[] { new Atom(sourcePath)});
        consultQuery.allSolutions();
        consultQuery.close();
    }

    @Deprecated
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

    @Deprecated
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

    public Map<String, Term> simulateHand(final Deck deck, final int handSize, final int putBack,
                                          final Map<String, Integer> intParams, final boolean verbose,
                                          final MersenneTwisterFast rng) {
        final String[] shuffled = deck.getShuffled(rng);
        final String[] hand = Arrays.copyOfRange(shuffled, 0, handSize);
        final String[] library = Arrays.copyOfRange(shuffled, handSize, shuffled.length);
        final Map<Atom, Term> params = new HashMap<>();
        intParams.forEach((key, value) -> {
            params.put(new Atom(key), new org.jpl7.Integer(value));
        });
        final Variable outputs = new Variable("Outputs");
        Term[] queryTerms = new Term[] {
                Term.stringArrayToList(hand),
                Term.stringArrayToList(library),
                Term.stringArrayToList(deck.getSideboard()),
                new org.jpl7.Integer(putBack),
                new Dict(new Atom("params"), params),
                outputs};
        final Query handQuery = new Query("play_oops_hand", queryTerms);
        //handQuery.open();
        final Map<String, Term> bindings = handQuery.oneSolution();
        Map<String, Term> outputMap = null;
        if (bindings != null) {
            final Term outputTerm = bindings.get("Outputs");
            if (outputTerm instanceof Dict) {
                outputMap = new HashMap<>();
                for (Map.Entry<Atom, Term> entry : ((Dict) outputTerm).getMap().entrySet()) {
                    outputMap.put(entry.getKey().toString(), entry.getValue());
                }
            }
        }
        return outputMap;
    }

    private Results playHandAutomull(final Deck deck, final int handSize, final int maxMulligans,
                                 final Map<String, Integer> intParams, final boolean verbose,
                                 final MersenneTwisterFast rng) {
        Map<String, Term> bindings = null;
        int mulligans = 0;
        do {
            if (mulligans == intParams.getOrDefault("greedy", 0)) {
                intParams.put("protection", 0);
            }
            bindings = simulateHand(deck, handSize, mulligans, intParams, verbose, rng);
            mulligans++;
        } while (bindings == null && mulligans < maxMulligans);
        return new Results(bindings);
    }

    /**
     * Run a number of independent random games/hands with the same deck, by repeatedly shuffling,
     * drawing a hand, and passing it to the logic engine.
     * @param deck The deck to experiment with
     * @param n The number of hands to sample and test
     * @param handSize The number of cards to draw from the deck for each sample
     * @param verbose Whether to print debug information
     * @param mull Whether to mulligan hands that fail
     * @param minProtection TODO
     * @param greedyMullCount TODO
     * @param rng TODO
     * @return TODO
     */
    public Map<String, Integer> simulateGames(Deck deck, int n, int handSize,
                                              boolean verbose, boolean mull,
                                              int minProtection, int greedyMullCount,
                                              MersenneTwisterFast rng) {
        final Map<String, Integer> params = new HashMap<>();
        params.put("greedy", greedyMullCount);
        Results aggregatedResults = new Results();
        int protectedWins = 0;
        final Map<Integer, Integer> protCountDistribution = new LinkedHashMap<>();
        final int maxMull = mull ? handSize-1 : 0;
        for (int i = 0; i < n; i++) {
            params.put("protection", minProtection);
            Results individualResult = playHandAutomull(deck, handSize, maxMull, params, verbose, rng);
//                System.out.println("Sample hand: " + Arrays.deepToString(individualResult.listMetadata.get("hand")));
            aggregatedResults.add(individualResult);
            if (individualResult.nFailures > 0) {
                if (verbose || true) {
                    System.out.println("       loss.");
                }
            } else {
                final int protection = individualResult.intMetadata.get("protection").get(0);
                final int prevCount = protCountDistribution.getOrDefault(protection, 0);
                protCountDistribution.put(protection, prevCount + 1);
                if (individualResult.nSuccesses > 0 && protection >= minProtection) {
                    protectedWins++;
                }
                if (verbose || true) {
                    final List<String> sequence = individualResult.listMetadata.get("sequence").get(0);
                    System.out.println("        win: " + sequence + " (" + protection + "x protection)");
                }
            }
        }
        if (verbose) {
            System.out.println(protCountDistribution);
        }
        final Map<String, Integer> results = new LinkedHashMap<>();
        results.put("games", aggregatedResults.nTotal);
        results.put("wins", aggregatedResults.nSuccesses);
        results.put("protected", protectedWins);
        System.out.println(results);
        return results;
    }

    @Deprecated
    public int[] getResults(Deck deck, int n, int handSize, boolean verbose, MersenneTwisterFast rng) {
        return getResults(deck, n, handSize, verbose, false, true, false, rng);
    }

    @Deprecated
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
