package mtg.logic;

import ec.util.MersenneTwisterFast;
import org.jpl7.Atom;
import org.jpl7.Dict;
import org.jpl7.Query;
import org.jpl7.Term;
import org.jpl7.Variable;

import java.io.File;
import java.lang.Integer;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Consumer;

public class PrologEngine {
    private final File prologSrcDir;
    private boolean verbose = false;
    private PrologProblem problem;
    private Consumer<String> logFunction = System.out::println;

    public PrologEngine(String srcPath) {
        this.prologSrcDir = new File(srcPath);
        log("Looking for prolog files in " + prologSrcDir + "...");
    }

    public void setProblem(final PrologProblem problem) {
        this.problem = problem;
        for (final String localName : problem.getSources()) {
            consultFile(localName);
        }
    }

    public void setLog(final Consumer<String> log) {
        this.logFunction = log;
    }

    private void log(final Object message) {
        logFunction.accept(message == null ? "null" : message.toString());
    }

    public void consultFile(String localName) {
        final String sourcePath = new File(prologSrcDir, localName).getAbsolutePath();
        log("Consulting " + sourcePath + "...");
        Query consultQuery = new Query("consult", new Term[] { new Atom(sourcePath)});
        consultQuery.allSolutions();
        consultQuery.close();
    }

    public void setVerbose(final boolean verbose) {
        this.verbose = verbose;
    }

    /**
     * Test a specific hand, putting back cards as required.
     * @param hand The cards in the hand to test
     * @param library The remainder of the library
     * @param sideboard The relevant cards in the sideboard
     * @param putBack The number of cards to put back from the hand (i.e. mulligans)
     * @return A Results object representing the outputs of this trial
     */
    public Results testHand(final String[] hand, final String[] library, final String[] sideboard, final int putBack) {
        final Map<Atom, Term> params = new HashMap<>();
        for (Map.Entry<String, Object> entry : problem.getParams().entrySet()) {
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
                new org.jpl7.Integer(putBack),
                new Dict(new Atom("params"), params),
                outputs};
        final long startTime = System.currentTimeMillis();
        final Query handQuery = new Query(problem.getPredicate(), queryTerms);
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
        return new Results(outputMap, duration);
    }

    /**
     * Run a single random game/hand, including performing mulligans as
     * required/permitted by the problem definition
     * @param deck The deck to experiment with
     * @param rng The random number generator to use for shuffling
     * @return A Results object representing the outputs of a single trial
     */
    public Results simulateGame(final Deck deck, final MersenneTwisterFast rng) {
        final int maxMulligans = problem.getMaxMulligans();
        int mulligans = 0;
        Results individualResult = null;
        do {
            if (verbose && individualResult != null) {
                log("        mulligan. [" + individualResult.getDuration(0) + "ms]");
            }
            // draw a random hand
            final int handSize = problem.getHandSize();
            final String[] shuffled = deck.getShuffled(rng);
            final String[] hand = Arrays.copyOfRange(shuffled, 0, handSize);
            final String[] library = Arrays.copyOfRange(shuffled, handSize, shuffled.length);
            if (verbose) {
                final String extra = mulligans > 0 ? " (must put back " + mulligans + ")" : "";
                log("Testing hand: " + Arrays.deepToString(hand) + extra);
            }
            individualResult = testHand(hand, library, deck.getSideboard(), mulligans);
            if (verbose) {
                if (individualResult.isSuccess(0)) {
                    log("        success: " + individualResult.getListMetadata(0)
                            + " ; " + individualResult.getIntMetadata(0)
                            + " ; " + individualResult.getStringMetadata(0)
                            + " [" + individualResult.getDuration(0) + " ms]");
                } else {
                    log("       failure. [" + individualResult.getDuration(0) + " ms]");
                }
            }
            mulligans++;
        } while (!individualResult.isSuccess(0) && mulligans < maxMulligans);
        return individualResult;
    }

    /**
     * Run a number of independent random games/hands with the same deck, by repeatedly shuffling,
     * drawing a hand, and passing it to the logic engine.
     * @param deck The deck to experiment with
     * @param n The number of hands to sample and test
     * @param rng The random number generator to use for shuffling
     * @return A Results object aggregating all the outputs of all the trials
     */
    public Results simulateGames(final Deck deck, int n, MersenneTwisterFast rng) {
        Results aggregatedResults = new Results();
        for (int i = 0; i < n; i++) {
            Results individualResult = simulateGame(deck, rng);
            aggregatedResults.add(individualResult);
        }
        if (verbose) {
            log(aggregatedResults);
        }
        return aggregatedResults;
    }
}
