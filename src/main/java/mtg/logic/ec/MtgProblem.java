package mtg.logic.ec;

import ec.EvolutionState;
import ec.Individual;
import ec.multiobjective.MultiObjectiveFitness;
import ec.simple.SimpleFitness;
import ec.util.Log;
import ec.util.MersenneTwisterFast;
import ec.util.Parameter;
import ec.vector.IntegerVectorIndividual;
import mtg.logic.Deck;
import mtg.logic.MongoResultStore;
import mtg.logic.MultiObjectivePrologProblem;
import mtg.logic.PrologEngine;
import mtg.logic.PrologProblem;
import mtg.logic.ResultStore;
import mtg.logic.SecondaryObjective;
import mtg.logic.SingleObjectivePrologProblem;
import mtg.logic.Results;
import mtg.logic.ec.stochastic.AdaptiveTrialsFitness;
import mtg.logic.ec.stochastic.BinomialNSGA2Fitness;
import mtg.logic.ec.stochastic.StochasticProblem;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class MtgProblem extends StochasticProblem {
    private static final long serialVersionUID = 1;

    private String prologSrcDir;
    private int baseTrials;
    private transient PrologEngine prolog;
    private PrologProblem problem;
    private int handLogNum = -1;
    private String adaptive;

    public static final String PROLOG_SRC_PROPERTY = "prolog.src.dir";

    public static final String P_PROBLEM_SPEC = "spec";
    public static final String P_PROLOG_DIR = "srcdir";
    public static final String P_N_GAMES = "games";
    public static final String P_HAND_LOG = "log-hands";
    public static final String P_ADAPT = "adapt-sampling";

    public static final String ADAPTIVE_CATCHUP = "catchup";
    public static final String ADAPTIVE_GENERATION_SQRT = "sqrt-gen";

    @Override
    public Parameter defaultBase() {
        return new Parameter("mtg.problem");
    }

    public MtgProblem() {
        prologSrcDir = System.getProperty(PROLOG_SRC_PROPERTY, System.getProperty("user.dir"));
    }

    private int trialsGen(final EvolutionState state) {
        if (ADAPTIVE_GENERATION_SQRT.equals(adaptive)) {
            double multiplier = Math.sqrt(state.generation + 1);
            return (int) Math.ceil(baseTrials * multiplier);
        } else {
            return baseTrials;
        }
    }

    int trialsInd(final int newTrials, final int padTrials, final Individual ind) {
        int gap = padTrials;
        if (ind.fitness instanceof BinomialNSGA2Fitness) {
            gap -= ((BinomialNSGA2Fitness) ind.fitness).getNSamples();
            gap = Math.max(gap, 0);
        }
        return gap + newTrials;
    }

    /**
     * Single-objective fitness function that gets the success rate of the first (or only) objective
     * defined in the problem specification.
     */
    private double fitness(final IntegerVectorIndividual ind, final Deck deck,
                           final int expectedMinTrials, final int newTrials,
                           final EvolutionState state, final int threadnum) {
        final SingleObjectivePrologProblem singleObjective = problem.getObjectives().get(0);
        final int trials = trialsInd(newTrials, expectedMinTrials, ind);
        final Results results = evaluateDeck(singleObjective, deck, trials, state.random[threadnum]);
        final double f;
        if (singleObjective.getFilter() == null) {
            f = results.getPSuccess();
        } else {
            f = results.getP(singleObjective.getFilter());
        }
        return f;
    }

    /**
     * Multi-objective fitness function that gets the success rates of all objectives defined in the
     * problem specification, in order.
     */
    private double[] objectives(final IntegerVectorIndividual ind, final Deck deck,
                           final int expectedMinTrials, final int newTrials,
                           final EvolutionState state, final int threadnum) {
        final List<SingleObjectivePrologProblem> objectives = problem.getObjectives();
        final List<SecondaryObjective> secondaryObjectives = new ArrayList<>();
        if (problem instanceof MultiObjectivePrologProblem) {
            secondaryObjectives.addAll(((MultiObjectivePrologProblem) problem).getSecondaryObjectives());
        }
        final double[] results = new double[objectives.size() + secondaryObjectives.size()];
        int i = 0;
        final Map<String, Results> resultsMap = new HashMap<>();
        final int trials = trialsInd(newTrials, expectedMinTrials, ind);
        for (final SingleObjectivePrologProblem objective : objectives) {
            final Results objectiveResults = evaluateDeck(objective, deck, trials, state.random[threadnum]);
            if (objective.getFilter() == null) {
                results[i] = objectiveResults.getPSuccess();
            } else {
                results[i] = objectiveResults.getP(objective.getFilter());
            }
            resultsMap.put(objective.getName(), objectiveResults);
            i++;
        }
        for (final SecondaryObjective secondaryObjective : secondaryObjectives) {
            final Results mainResults = resultsMap.get(secondaryObjective.getObjective());
            results[i] = mainResults.getP(secondaryObjective.getFilter());
            i++;
        }
        return results;
    }

    @Override
    public void evaluate(final EvolutionState state, final Individual ind,
                         final int subpopulation, final int threadnum) {
        if (ind.evaluated) {
            return;
        }
        final IntegerVectorIndividual vectorInd = (IntegerVectorIndividual) ind;
        final DecklistVectorSpecies species = (DecklistVectorSpecies) ind.species;
        final Deck deck = species.template.toDeck(vectorInd.genome);
        int padTrials = ADAPTIVE_CATCHUP.equals(adaptive) ? maxTrials : 0;
        int newTrials = trialsGen(state);
        if (vectorInd.fitness instanceof AdaptiveTrialsFitness) {
            ((AdaptiveTrialsFitness) vectorInd.fitness).setNTrials(newTrials);
        }
        if (vectorInd.fitness instanceof MultiObjectiveFitness) {
            final double[] o = objectives(vectorInd, deck, padTrials, newTrials, state, threadnum);
            ((MultiObjectiveFitness)vectorInd.fitness).setObjectives(state, o);
        } else {
            final double f = fitness(vectorInd, deck, padTrials, newTrials, state, threadnum);
            ((SimpleFitness)vectorInd.fitness).setFitness(state, f, false);
        }
        vectorInd.evaluated = true;
    }

    @Override
    public void setup(final EvolutionState state, final Parameter base) {
        final Parameter def = defaultBase();
        baseTrials = state.parameters.getIntWithDefault(
                base.push(P_N_GAMES), def.push(P_N_GAMES), 1);
        adaptive = state.parameters.getString(
                base.push(P_ADAPT), def.push(P_ADAPT));
        if ((adaptive != null)
                && !adaptive.equals(ADAPTIVE_CATCHUP)
                && !adaptive.equals(ADAPTIVE_GENERATION_SQRT)) {
            state.output.fatal("Doesn't understand adaptive sample size type",
                            base.push(P_ADAPT), def.push(P_ADAPT));
        }
        final Parameter specA = base.push(P_PROBLEM_SPEC);
        final Parameter specB = def.push(P_PROBLEM_SPEC);
        try {
            problem = PrologProblem.fromYaml(() -> state.parameters.getResource(specA, specB));
        } catch (Exception e) {
            state.output.fatal("Failed to load problem specification file: "
                    + state.parameters.getString(specA, specB),
                    specA, specB);
        }
        prologSrcDir = state.parameters.getStringWithDefault(
                base.push(P_PROLOG_DIR), def.push(P_PROLOG_DIR), prologSrcDir);
        state.output.println("Initializing problem [" + problem.getName()
                + "], prolog src dir [ " + prologSrcDir
                + " ], trials [" + baseTrials + "]...",
                Log.D_STDOUT);
        final List<String> objectiveNames = problem.getObjectives().stream()
                .map(SingleObjectivePrologProblem::getName).collect(Collectors.toList());
        state.output.println(objectiveNames.size() + " problem objective(s): "
                + objectiveNames, Log.D_STDOUT);
        if (objectiveNames.size() > 1) {
            state.output.println("If using single-objective fitness function, "
                    + "first objective '" + objectiveNames.get(0) + "' will "
                    + "take precedence; if using multi-objective, will try to "
                    +  "use all.",
                    Log.D_STDOUT);
        }
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

    private Results evaluateDeck(final SingleObjectivePrologProblem objective,
                                 final Deck deck,
                                 final int n,
                                 final MersenneTwisterFast rng) {
        int interval = n < 20 ? 0 : n / 20;
        return prolog.simulateGames(objective, deck, n, rng, interval);
    }

    private void printResults(final SingleObjectivePrologProblem objective,
                              final Results results) {
        if (objective.getFilter() != null) {
            final String prop = objective.getFilter();
            System.out.println("    " + results.getNWithProperty(prop) + " successes (stddev="
                    + results.getStdDev(prop) + " ; p="
                    + results.getP(prop) + ")");
        }
        System.out.println("    " + results.getNSuccesses() + " wins (stddev="
                + results.getStdDevSuccesses() + " ; p="
                + results.getPSuccess() + ")");
        for (final String booleanVar : objective.getBooleanOutputs()) {
            System.out.println("    " + results.getNWithProperty(booleanVar)
                    + " wins with property '" + booleanVar
                    + "' (stddev=" + results.getStdDev(booleanVar)
                    + " ; p=" + results.getP(booleanVar) + ")");
        }
        for (final String categoricalVar : objective.getCategoricalOutputs()) {
            final Map<String, Integer> distribution = results.getValueDistribution(categoricalVar);
            for (final Map.Entry<String, Integer> entry : distribution.entrySet()) {
                System.out.println("    " + entry.getValue()
                        + " wins with " + categoricalVar
                        + " == " + entry.getKey());
            }
        }
        final int nMull = results.getNWithProperty("mulligan");
        final double avgMulls = results.getPropertySum("nMulligans") / ((double) nMull);
        System.out.println("    " + nMull
                + " wins with at least one mulligan (stddev="
                + results.getStdDev("mulligan")
                + " ; p=" + results.getP("mulligan")
                + "), avg # in those games: " + avgMulls + ")");
        final int nPowder = results.getNWithProperty("powder");
        if (nPowder > 0) {
            final double avgPowders = results.getPropertySum("nPowders") / ((double) nPowder);
            System.out.println("    " + nPowder
                    + " wins with at least one Serum Powder (stddev="
                    + results.getStdDev("powder")
                    + " ; p=" + results.getP("powder")
                    + "), avg # in those games: " + avgPowders + ")");
        }
    }

    private void printResults(final SecondaryObjective secondaryObjective,
                              final Results mainResults) {
        final String prop = secondaryObjective.getFilter();
        if (secondaryObjective.getFilter() != null) {
            System.out.println("    " + mainResults.getNWithProperty(prop) + " successes (stddev="
                    + mainResults.getStdDev(prop) + " ; p="
                    + mainResults.getP(prop) + ")");
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
                        + decklistInd.fitness.fitnessToStringForHumans().replaceAll("\n", "\n\t\t"),
                        log);
            }
        }
    }

    public static void main(String[] args) throws IOException {
        if (args.length >= 3) {
            final MtgProblem app = new MtgProblem();
            app.problem = PrologProblem.fromYaml(args[0]);
            final String decklistFile = args[1];
            app.baseTrials = Integer.parseInt(args[2]);
            app.initProlog(null);
            ResultStore store = null;
            if (args.length >= 5) {
                store = new MongoResultStore(args[3], args[4]);
                store.setCacheSize(100);
                app.prolog.addFinalCallback(store);
            }
            final Deck deck = Deck.fromFile(decklistFile);
            final MersenneTwisterFast rng = new MersenneTwisterFast();
            final Map<String, Results> resultsMap = new HashMap<>();
            for (final SingleObjectivePrologProblem objective : app.problem.getObjectives()) {
                System.out.println("Objective: " + objective.getName());
                final Results objectiveResults = app.evaluateDeck(objective, deck, app.baseTrials, rng);
                app.printResults(objective, objectiveResults);
                resultsMap.put(objective.getName(), objectiveResults);
                if (store != null) {
                    store.flushResults();
                }
            }
            if (store != null) {
                store.close();
            }
            if (app.problem instanceof MultiObjectivePrologProblem) {
                for (final SecondaryObjective secondaryObjective :
                        ((MultiObjectivePrologProblem) app.problem).getSecondaryObjectives()) {
                    System.out.println("Objective: " + secondaryObjective.getName());
                    final Results mainResults = resultsMap.get(secondaryObjective.getObjective());
                    app.printResults(secondaryObjective, mainResults);
                }
            }
        } else {
            System.out.println("Usage: MtgProblem <problem spec file> <decklist> <n games>");
        }
    }
}
