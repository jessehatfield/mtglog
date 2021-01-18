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
import mtg.logic.PrologEngine;
import mtg.logic.PrologProblem;
import mtg.logic.SingleObjectivePrologProblem;
import mtg.logic.Results;
import mtg.logic.ec.stochastic.StochasticProblem;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

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
     * Single-objective fitness function that gets the success rate of the first (or only) objective
     * defined in the problem specification.
     */
    private double fitness(final IntegerVectorIndividual ind, final Deck deck,
                           final EvolutionState state, final int threadnum) {
        final SingleObjectivePrologProblem singleObjective = problem.getObjectives().get(0);
        final Results results = evaluateDeck(singleObjective, deck, state.random[threadnum]);
        final double f = results.getPSuccess();
        return f;
    }

    /**
     * Multi-objective fitness function that gets the success rates of all objectives defined in the
     * problem specification, in order.
     */
    private double[] objectives(final IntegerVectorIndividual ind, final Deck deck,
                           final EvolutionState state, final int threadnum) {
        final List<SingleObjectivePrologProblem> objectives = problem.getObjectives();
        final double[] results = new double[objectives.size()];
        int i = 0;
        for (final SingleObjectivePrologProblem objective : objectives) {
            results[i] = evaluateDeck(objective, deck, state.random[threadnum]).getPSuccess();
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
        if (vectorInd.fitness instanceof MultiObjectiveFitness) {
            final double[] o = objectives(vectorInd, deck, state, threadnum);
            ((MultiObjectiveFitness)vectorInd.fitness).setObjectives(state, o);
        } else {
            final double f = fitness(vectorInd, deck, state, threadnum);
            ((SimpleFitness)vectorInd.fitness).setFitness(state, f, false);
        }
        vectorInd.evaluated = true;
    }

    @Override
    public void setup(final EvolutionState state, final Parameter base) {
        final Parameter def = defaultBase();
        trials = state.parameters.getIntWithDefault(
                base.push(P_N_GAMES), def.push(P_N_GAMES), 1);
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
                + " ], trials [" + trials + "]...",
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
                                 final Deck deck, final MersenneTwisterFast rng) {
        return prolog.simulateGames(objective, deck, trials, rng);
    }

    private void printResults(final SingleObjectivePrologProblem objective,
                              final Results results) {
        System.out.println(results.getNSuccesses() + " wins (stddev="
                + results.getStdDevSuccesses() + " ; p="
                + results.getPSuccess() + ")");
        for (final String booleanVar : objective.getBooleanOutputs()) {
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
            app.trials = Integer.parseInt(args[2]);
            app.initProlog(null);
            final Deck deck = Deck.fromFile(decklistFile);
            final MersenneTwisterFast rng = new MersenneTwisterFast();
            for (final SingleObjectivePrologProblem objective : app.problem.getObjectives()) {
                System.out.println("Objective: " + objective.getName());
                app.printResults(objective, app.evaluateDeck(objective, deck, rng));
            }
        } else {
            System.out.println("Usage: MtgProblem <problem spec file> <decklist> <n games>");
        }
    }
}
