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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.BiConsumer;
import java.util.stream.Collectors;

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

public class PrologEngine {
    private static final Logger log = LogManager.getLogger();

    private final File prologSrcDir;
    private final List<BiConsumer<String[], Results>> callbacks = new ArrayList<>();
    private PrologProblem problem;
    private List<ResultConsumer> resultConsumers = new ArrayList<>();

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

    public void addFinalCallback(final ResultConsumer consumer) {
        resultConsumers.add(consumer);
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
        log.trace("Attempting hand: " + handQuery);
        final Map<String, Term> bindings = handQuery.oneSolution();
        Map<String, Term> outputMap = null;
        long duration = System.currentTimeMillis() - startTime;
        if (bindings != null) {
            final Term outputTerm = bindings.get("Outputs");
            log.trace("Success: " + outputTerm + " [" + duration + " ms]");
            if (outputTerm instanceof Dict) {
                outputMap = new HashMap<>();
                for (Map.Entry<Atom, Term> entry : ((Dict) outputTerm).getMap().entrySet()) {
                    outputMap.put(entry.getKey().toString(), entry.getValue());
                }
            }
        } else {
            log.trace("Failure. [" + duration + " ms]");
        }
        return new Results(outputMap, duration, mulligans, powders);
    }

    /**
     * Check whether a specific hand and library permits using a Serum Powder,
     * if the objective provides a predicate for testing that, and if so
     * determine the set of cards to put on the bottom first, if there have
     * been mulligans already.
     * @param objective The problem to test; sources should already be loaded
     * @param hand The cards in the hand to test
     * @param library The remainder of the library
     * @param bottom The number of cards we need to put on the bottom if using Powder
     * @return null if this hand doesn't contain Serum Powder or can't use it;
     *         otherwise a list of cards in the hand to put on the bottom
     *         before using
     */
    public List<String> canSerumPowder(final SingleObjectivePrologProblem objective,
                                       final String[] hand,
                                       final String[] library,
                                       final int bottom) {
        boolean canPowder = containsCard(hand, "Serum Powder");
        if (canPowder) {
            final String predicate = objective.getSerumPowderPredicate();
            if (predicate != null) {
                final Variable bottomVar = new Variable("Bottom");
                Term[] queryTerms = new Term[] {
                        Term.stringArrayToList(hand),
                        Term.stringArrayToList(library),
                        new org.jpl7.Integer(bottom),
                        bottomVar};
                final Query powderQuery = new Query(predicate, queryTerms);
                final Map<String, Term> bindings = powderQuery.oneSolution();
                if (bindings == null) {
                    return null;
                }
                final Term bottomTerm = bindings.get("Bottom");
                if (bottomTerm.isList()) {
                    return Arrays.stream(bottomTerm.listToTermArray())
                            .map(Term::name)
                            .collect(Collectors.toList());
                }
            }
        }
        return null;
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
     * @return A ResultSequence object representing the outputs of a single trial
     */
    public ResultSequence simulateGame(final SingleObjectivePrologProblem objective, final Deck deck,
                                       final MersenneTwisterFast rng) {
        final int maxMulligans = objective.getMaxMulligans();
        final int handSize = objective.getHandSize();
        int mulligans = objective.getStartingMulligans();
        int powders = 0;
        Results individualResult;
        String[] currentDeck = deck.getShuffled(rng);
        ResultSequence.Builder resultBuilder = ResultSequence.builder();
        do {
            // draw a random full-sized hand
            Deck.shuffle(currentDeck, rng);
            String[] hand = Arrays.copyOfRange(currentDeck, 0, handSize);
            String[] library = Arrays.copyOfRange(currentDeck, handSize, currentDeck.length);
            individualResult = testHand(objective, hand, library, deck.getSideboard(), mulligans, powders);
            for (final BiConsumer<String[], Results> callback : callbacks) {
                callback.accept(hand, individualResult);
            }
            resultBuilder.test(hand, individualResult);
            while (!individualResult.isSuccess(0)) {
                final int nBottom = mulligans - (handSize - hand.length);
                List<String> bottom = canSerumPowder(objective, hand, library, nBottom);
                if (bottom == null) {
                    if (mulligans < maxMulligans) {
                        resultBuilder.mulligan();
                    }
                    break;
                }
                powders++;
                resultBuilder.powder();
                // Start with the remaining library as the new deck
                currentDeck = new String[library.length + nBottom];
                System.arraycopy(library, 0, currentDeck, 0, library.length);
                // remove Powder from hand and put <nBottom> cards on the bottom
                final List<String> remainingHand = new ArrayList<>(Arrays.asList(hand));
                final boolean powder = remainingHand.remove("Serum Powder");
                assert(powder);
                for (int i = 0; i < nBottom; i++) {
                    final String bottomCard = bottom.get(i);
                    final boolean removed = remainingHand.remove(bottomCard);
                    assert(removed);
                    currentDeck[library.length + i] = bottomCard;
                }
                // draw <handSize> - <mulligans> cards for the next hand
                Deck.shuffle(currentDeck, rng);
                hand = Arrays.copyOfRange(currentDeck, 0, handSize - mulligans);
                library = Arrays.copyOfRange(currentDeck, handSize - mulligans, currentDeck.length);
                individualResult = testHand(objective, hand, library, deck.getSideboard(), mulligans, powders);
                for (final BiConsumer<String[], Results> callback : callbacks) {
                    callback.accept(hand, individualResult);
                }
                resultBuilder.test(hand, individualResult);
            }
            mulligans++;
        } while (!individualResult.isSuccess(0) && mulligans <= maxMulligans);
        return resultBuilder.keepAndBuild();
    }

    /**
     * Run a number of independent random games/hands with the same deck, by repeatedly shuffling,
     * drawing a hand, and passing it to the logic engine.
     * @param objective The problem to test; sources should already be loaded
     * @param deck The deck to experiment with
     * @param n The number of hands to sample and test
     * @param rng The random number generator to use for shuffling
     * @param printInterval If positive, print success rate every k trials
     * @return A Results object aggregating all the outputs of all the trials
     */
    public Results simulateGames(final SingleObjectivePrologProblem objective, final Deck deck,
                                 final int n, final MersenneTwisterFast rng, final int printInterval) {
        Results aggregatedResults = new Results();
        for (int i = 0; i < n; i++) {
            ResultSequence testResult = simulateGame(objective, deck, rng);
            for (ResultConsumer consumer : resultConsumers) {
                consumer.consumeResult(objective, deck, testResult);
            }
            aggregatedResults.add(testResult.getFinalResult());
            if (printInterval > 0 && (i+1) < n && (i+1) % printInterval == 0) {
                System.err.println(aggregatedResults.getNSuccesses() + " / " + aggregatedResults.getNTotal() +  " successes...");
            }
        }
        System.err.println(aggregatedResults.getNSuccesses() + " / " + aggregatedResults.getNTotal()
                +  " total successes.");
        return aggregatedResults;
    }
}
