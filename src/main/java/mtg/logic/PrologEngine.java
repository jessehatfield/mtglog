package mtg.logic;

import ec.util.MersenneTwisterFast;
import org.jpl7.Atom;
import org.jpl7.Dict;
import org.jpl7.Query;
import org.jpl7.Term;
import org.jpl7.Variable;

import java.io.File;
import java.lang.Integer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.BiConsumer;

public class PrologEngine {
    private final File prologSrcDir;
    private final List<BiConsumer<String[], Results>> callbacks = new ArrayList<>();
    private PrologProblem problem;

    public PrologEngine(String srcPath) {
        this.prologSrcDir = new File(srcPath);
    }

    public void setProblem(final PrologProblem problem) {
        this.problem = problem;
        for (final String localName : problem.getSources()) {
            consultFile(localName);
        }
    }

    public void addCallback(final BiConsumer<String[], Results> callback) {
        callbacks.add(callback);
    }

    public void consultFile(String localName) {
        final String sourcePath = new File(prologSrcDir, localName).getAbsolutePath();
        Query consultQuery = new Query("consult", new Term[] { new Atom(sourcePath)});
        consultQuery.allSolutions();
        consultQuery.close();
    }

    /**
     * Test a specific hand, putting back cards as required.
     * @param objective The problem to test; sources should already be loaded
     * @param hand The cards in the hand to test
     * @param library The remainder of the library
     * @param sideboard The relevant cards in the sideboard
     * @param mulligans The number of cards to put back from the hand (i.e. mulligans so far)
     * @return A Results object representing the outputs of this trial
     */
    public Results testHand(final SingleObjectivePrologProblem objective, final String[] hand,
                            final String[] library, final String[] sideboard,
                            final int mulligans, final int powders) {
        final Map<Atom, Term> params = new HashMap<>();
        for (Map.Entry<String, Object> entry : objective.getParams().entrySet()) {
            final String key = entry.getKey();
            final Object val = entry.getValue();
            if (val instanceof Integer) {
                params.put(new Atom(key), new org.jpl7.Integer((Integer) val));
            } else if (val instanceof String) {
                params.put(new Atom(key), new Atom((String) val));
            } else {
                throw new IllegalArgumentException("Doesn't know how to convert parameter "
                        + key + ": " + val + " of type " + val.getClass() + " into Prolog term");
            }
        }
        final Variable outputs = new Variable("Outputs");
        Term[] queryTerms = new Term[] {
                Term.stringArrayToList(hand),
                Term.stringArrayToList(library),
                Term.stringArrayToList(sideboard),
                new org.jpl7.Integer(mulligans),
                new Dict(new Atom("params"), params),
                outputs};
        final long startTime = System.currentTimeMillis();
        final Query handQuery = new Query(objective.getPredicate(), queryTerms);
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
        long duration = System.currentTimeMillis() - startTime;
        return new Results(outputMap, duration, mulligans, powders);
    }

    /**
     * Check whether a specific hand and library permits using a Serum Powder,
     * if the objective provides a predicate for testing that, or just check
     * for the existence of a Powder otherwise.
     * @param objective The problem to test; sources should already be loaded
     * @param hand The cards in the hand to test
     * @param library The remainder of the library
     * @return True if this hand contains a Serum Powder and no reason not to use it
     */
    public boolean canSerumPowder(final SingleObjectivePrologProblem objective,
                                  final String[] hand,
                                  final String[] library) {
        boolean canPowder = containsCard(hand, "Serum Powder");
        if (canPowder) {
            final String predicate = objective.getSerumPowderPredicate();
            if (predicate != null) {
                Term[] queryTerms = new Term[] {
                        Term.stringArrayToList(hand),
                        Term.stringArrayToList(library)};
                final Query powderQuery = new Query(predicate, queryTerms);
                canPowder = powderQuery.hasSolution();
            }
        }
        return canPowder;
    }

    private boolean containsCard(final String[] zone, final String card) {
        for (final String member : zone) {
            if (card.equals(member)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Run a single random game/hand, including performing mulligans as
     * required/permitted by the problem definition
     * @param objective The problem to test; sources should already be loaded
     * @param deck The deck to experiment with
     * @param rng The random number generator to use for shuffling
     * @return A Results object representing the outputs of a single trial
     */
    public Results simulateGame(final SingleObjectivePrologProblem objective, final Deck deck,
                                final MersenneTwisterFast rng) {
        final int maxMulligans = objective.getMaxMulligans();
        final int handSize = objective.getHandSize();
        int mulligans = 0;
        int powders = 0;
        Results individualResult;
        String[] currentDeck = deck.getShuffled(rng);
        do {
            // draw a random hand
            Deck.shuffle(currentDeck, rng);
            String[] hand = Arrays.copyOfRange(currentDeck, 0, handSize);
            String[] library = Arrays.copyOfRange(currentDeck, handSize, currentDeck.length);
            individualResult = testHand(objective, hand, library, deck.getSideboard(), mulligans, powders);
            for (final BiConsumer<String[], Results> callback : callbacks) {
                callback.accept(hand, individualResult);
            }
            while (!individualResult.isSuccess(0) && canSerumPowder(objective, hand, library)) {
                powders++;
                currentDeck = library;
                Deck.shuffle(currentDeck, rng);
                hand = Arrays.copyOfRange(currentDeck, 0, handSize);
                library = Arrays.copyOfRange(currentDeck, handSize, currentDeck.length);
                individualResult = testHand(objective, hand, library, deck.getSideboard(), mulligans, powders);
                for (final BiConsumer<String[], Results> callback : callbacks) {
                    callback.accept(hand, individualResult);
                }
            }
            mulligans++;
        } while (!individualResult.isSuccess(0) && mulligans <= maxMulligans);
        return individualResult;
    }

    /**
     * Run a number of independent random games/hands with the same deck, by repeatedly shuffling,
     * drawing a hand, and passing it to the logic engine.
     * @param objective The problem to test; sources should already be loaded
     * @param deck The deck to experiment with
     * @param n The number of hands to sample and test
     * @param rng The random number generator to use for shuffling
     * @return A Results object aggregating all the outputs of all the trials
     */
    public Results simulateGames(final SingleObjectivePrologProblem objective, final Deck deck,
                                 int n, MersenneTwisterFast rng) {
        Results aggregatedResults = new Results();
        for (int i = 0; i < n; i++) {
            Results individualResult = simulateGame(objective, deck, rng);
            aggregatedResults.add(individualResult);
        }
        return aggregatedResults;
    }
}
