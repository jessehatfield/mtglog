package mtg.logic.ec;

import ec.EvolutionState;
import ec.Individual;
import ec.simple.SimpleFitness;
import ec.util.Log;
import ec.util.MersenneTwisterFast;
import ec.util.Parameter;
import ec.vector.IntegerVectorIndividual;
import mtg.logic.Deck;
import mtg.logic.PrologEngine;
import mtg.logic.PrologProblem;
import mtg.logic.Results;
import mtg.logic.ec.stochastic.StochasticProblem;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;

public class MtgProblem extends StochasticProblem {
    private static final long serialVersionUID = 1;

    private String prologSrcDir;
    private int trials;
    private transient PrologEngine prolog;
    private PrologProblem problem;
    private int handLogNum = -1;

    public static final String PROLOG_SRC_PROPERTY = "prolog.src.dir";

    public static final String P_PROBLEM_SPEC = "spec";
    public static final String P_PROLOG_DIR = "srcdir";
    public static final String P_N_GAMES = "games";
    public static final String P_HAND_LOG = "log-hands";

    @Override
    public Parameter defaultBase() {
        return new Parameter("mtg.problem");
    }

    public MtgProblem() {
        prologSrcDir = System.getProperty(PROLOG_SRC_PROPERTY, System.getProperty("user.dir"));
    }

    /**
     * Fitness function that combines overall success with additional boolean
     * results, with priority in the order that they're specified in the problem
     * definition, with overall success taking precedence. That is, when
     * comparing two results, each statistic is only used if all statistics
     * listed before as well as the overall success are tied.
     *
     * To achieve this, allocate a certain number of digits to each property,
     * and truncate each percentage to that number of digits. That number
     * must be chosen based on the number of trials n:
     *   k = max(3, ceil(log10(n))).
     *   (minimum of 3 so the first percentage can range 0-100)
     * Then each percentage is truncated to k digits and shifted k digits:
     *   q(property, i) = truncate(p(property), k) / 10^(k*i)
     * And the fitness combines them all:
     *   fitness = 100*p(success) + 100*q(property 1, 1) + ...
     *
     * Should be interpretable as chunks of k digits, where k=3 for n
     * between up to 100, k=4 for n between 100 and 999, etc.
     * For example: f=100.100099033001 with n=100 means 100% success, 100%
     * property 1, 99% property 2, 1/3 property 3, and 1% property 4.
     * The same percentages with n=1000 would yield f=100.01000099003330010,
     * which allocates an extra digit to each field to allow for distinguishing
     * differences of 1/1000 (0.1%).
     *
     * Only appropriate for selection methods that care only about order,
     * i.e. shouldn't be used for fitness proportionate selection.
     */
    private double fitness(final IntegerVectorIndividual ind, final Deck deck, final EvolutionState state, final int threadnum) {
        final Results results = evaluateDeck(deck, state.random[threadnum]);
        /*
        final int k = Math.max((int) Math.ceil(Math.log10(trials)), 3);
        final double shift = Math.pow(10, k);
        double f = ((int) (results.getPSuccess() * shift)) / shift;
        final List<String> vars = problem.getBooleanOutputs();
        for (int i = 0; i < vars.size(); i++) {
            final double p = results.getP(vars.get(i));
            double truncated = ((int) (p * shift)) / shift;
            final double q = truncated / Math.pow(shift, 1+i);
            f += q;
        }
        f *= 100.0;
        */
        final int nSuccesses = results.getNSuccesses();
        final double f = results.getPSuccess();
        return f;
    }

    @Override
    public void evaluate(final EvolutionState state, final Individual ind,
                         final int subpopulation, final int threadnum) {
        if (ind.evaluated) {
            return;
        }
        final IntegerVectorIndividual ind2 = (IntegerVectorIndividual) ind;
        final DecklistVectorSpecies species = (DecklistVectorSpecies) ind.species;
        final Deck deck = species.template.toDeck(ind2.genome);
//        state.output.println("Evaluating " + Arrays.toString(ind2.genome) + " (" + deck.getSize() + " cards)...",
//                Log.D_STDOUT);
        double f = fitness(ind2, deck, state, threadnum);
        if (deck.getSize() > deck.getMinSize()) { // this should never happen
            // but if it does, ensure it can't beat any valid individual's fitness
            f -= (trials + 1);
        }
        ((SimpleFitness)ind2.fitness).setFitness(state, f, false);
        ind2.evaluated = true;
    }

    @Override
    public void setup(final EvolutionState state, final Parameter base) {
        final Parameter def = defaultBase();
        trials = state.parameters.getIntWithDefault(
                base.push(P_N_GAMES), def.push(P_N_GAMES), 1);
        final Parameter specA = base.push(P_PROBLEM_SPEC);
        final Parameter specB = def.push(P_PROBLEM_SPEC);
        try (final InputStream specInput = state.parameters.getResource(specA, specB)) {
            problem = PrologProblem.fromYaml(specInput);
        } catch (Exception e) {
            state.output.fatal("Failed to load problem specification file: "
                            + state.parameters.getString(specA, specB),
                    specA, specB);
        }
        prologSrcDir = state.parameters.getStringWithDefault(
                base.push(P_PROLOG_DIR), def.push(P_PROLOG_DIR), prologSrcDir);
        state.output.println("Initializing problem [" + problem.getName()
                + "], prolog src dir [ " + prologSrcDir
                + " ], trials [" + trials + "]...",
                Log.D_STDOUT);
        final File handLogFile = state.parameters.getFile(
                base.push(P_HAND_LOG), def.push(P_HAND_LOG));
        if (handLogFile == null) {
            state.output.warning("Not logging individual hands; provide filename to record and time them all",
                    base.push(P_HAND_LOG), def.push(P_HAND_LOG));
        } else {
            try {
                handLogNum = state.output.addLog(handLogFile, true);
                state.output.message("Logging all hands to  " + handLogFile.getAbsolutePath());
                state.output.println("duration (ms)\thand\twin\tmulligans", handLogNum);
            } catch (IOException e) {
                state.output.warning("Couldn't create/append to log file for recording hands",
                    base.push(P_HAND_LOG), def.push(P_HAND_LOG));
            }
        }
        initProlog(state);
    }

    private String getLogMessage(final String[] hand, final Results individualResult) {
        return individualResult.getDuration(0)
                + "\t" + Arrays.deepToString(hand)
                + "\t" + individualResult.isSuccess(0)
                + "\t" + individualResult.getMulliganCounts(0);
    }

    private void initProlog(final EvolutionState state) {
        prolog = new PrologEngine(prologSrcDir);
        prolog.setProblem(problem);
        if (state != null && handLogNum >= 0) {
            prolog.addCallback((h, r) -> state.output.println(getLogMessage(h, r), handLogNum));
        }
    }

    @Override
    public void reinitializeContacts(EvolutionState state) {
        initProlog(state);
    }

    private Results evaluateDeck(final Deck deck, final MersenneTwisterFast rng) {
        return prolog.simulateGames(deck, trials, rng);
    }

    private void printResults(final Results results) {
        System.out.println(results.getNSuccesses() + " wins (stddev="
                + results.getStdDevSuccesses() + " ; p="
                + results.getPSuccess() + ")");
        for (final String booleanVar : problem.getBooleanOutputs()) {
            System.out.println(results.getNWithProperty(booleanVar)
                    + " wins with property '" + booleanVar
                    + "' (stddev=" + results.getStdDev(booleanVar)
                    + " ; p=" + results.getP(booleanVar) + ")");
        }
    }

    @Override
    public void describe(final EvolutionState state,
                        final Individual ind,
                        final int subpopulation,
                        final int threadnum,
                        final int log) {
        for (int i = 0; i < state.population.subpops.length; i++) {
            for (int j = 0; j < state.population.subpops[i].individuals.length; j++) {
                final DecklistVectorIndividual decklistInd = (DecklistVectorIndividual)
                        state.population.subpops[i].individuals[j];
                state.output.println("\tindividual "
                        + decklistInd.genotypeToStringForHumans() + "; "
                        + decklistInd.fitness.fitnessToStringForHumans(), log);
            }
        }
    }

    public static void main(String[] args) throws IOException {
        if (args.length >= 3) {
            final MtgProblem app = new MtgProblem();
            app.problem = PrologProblem.fromYaml(args[0]);
            final String decklistFile = args[1];
            app.trials = Integer.parseInt(args[2]);
            app.initProlog(null);
            final Deck deck = Deck.fromFile(decklistFile);
            final MersenneTwisterFast rng = new MersenneTwisterFast();
            app.printResults(app.evaluateDeck(deck, rng));
        } else {
            System.out.println("Usage: MtgProblem <problem spec file> <decklist> <n games>");
        }
    }
}
