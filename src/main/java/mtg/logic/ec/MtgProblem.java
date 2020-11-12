package mtg.logic.ec;

import ec.EvolutionState;
import ec.Individual;
import ec.Problem;
import ec.simple.SimpleFitness;
import ec.simple.SimpleProblemForm;
import ec.util.Log;
import ec.util.Parameter;
import ec.vector.IntegerVectorIndividual;
import mtg.logic.Deck;
import mtg.logic.PrologEngine;

import java.io.IOException;
import java.util.Arrays;
import java.util.Map;

public class MtgProblem extends Problem implements SimpleProblemForm {
//    protected abstract Deck createDeck(int[] genome);

    protected final PrologEngine prolog;
    protected int trials;
    protected final boolean autoMull;
    protected final int minProtection;
    protected final int greedyMullCount;

    public static String PROLOG_SRC_PROPERTY = "prolog.src.dir";
    public static String N_TRIALS_PROPERTY = "mtg.eval.games";
    public static String AUTO_MULL_PROPERTY = "mtg.eval.automull";
    public static String MIN_PROTECTION_PROPERTY = "mtg.eval.protection";
    public static String GREEDY_MULL_COUNT = "mtg.eval.mull.greedy";

    public static String P_N_GAMES = "games";
    public static String P_PROLOG_FILES = "src";

    @Override
    public Parameter defaultBase() {
        return new Parameter("mtg");
    }

    public MtgProblem() throws IOException {
        String prologDir = System.getProperty(PROLOG_SRC_PROPERTY, System.getProperty("user.dir"));
        this.prolog = new PrologEngine(prologDir);
//        this.trials = Integer.parseInt(System.getProperty(N_TRIALS_PROPERTY, "1"));
        this.autoMull = Boolean.parseBoolean(System.getProperty(AUTO_MULL_PROPERTY, "true"));
        this.minProtection = Integer.parseInt(System.getProperty(MIN_PROTECTION_PROPERTY, "0"));
        this.greedyMullCount = autoMull ? Integer.parseInt(System.getProperty(GREEDY_MULL_COUNT, "0")) : 0;
    }

    /**
     * Fitness function that combines protected wins with overall wins, with protected wins taking
     * precedence and overall wins breaking ties.
     *
     * To achieve this: use == <n protected wins> + <p overall wins>
     * Relies on the fact that the smallest possible difference in the former is 1
     * (A has one more protected win than B), and the largest possible difference in the latter
     * is also 1 (B has N total wins while A has 0), but both can't apply at the same time so
     * the absolute value of the former difference will always be greater than that of the
     * latter unless the former is actually 0.
     */
    /*
    private double fitnessPrioritizeProtection(final IntegerVectorIndividual ind, final Deck deck, final EvolutionState state, final int threadnum) {
        final Map<String, Integer> results = prolog.simulateGames(deck, trials, 7, false, autoMull, minProtection, greedyMullCount, state.random[threadnum]);
        final int w = results.get("wins");
        final int wp = results.get("protected");
        final float pWin = ((float) w) / trials;
        final float pProtected = ((float) wp) / trials;
        // Fitness calculation: Protected wins should take precedence, with overall wins breaking
        final double f = wp + pWin;
        System.out.println("\tindividual " + Arrays.toString(ind.genome)
                + ": " + w + " wins with " + wp + " protected wins out of " + trials
                + " ; fitness=" + f);
        return f;
    }
    */

    /**
     * Fitness function that combines protected wins with overall wins, with overall wins taking
     * precedence and protected wins breaking ties.
     *
     * To achieve this: use == <n overall wins> + <p protected wins>
     * Relies on the fact that the smallest possible difference in the former is 1
     * (A has one more win than B), and the largest possible difference in the latter
     * is also 1 (B has N protected wins while A has 0), but both can't apply at the same time so
     * the absolute value of the former difference will always be greater than that of the
     * latter unless the former is actually 0.
     */
    private double fitness(final IntegerVectorIndividual ind, final Deck deck, final EvolutionState state, final int threadnum) {
        final Map<String, Integer> results = prolog.simulateGames(deck, trials, 7, false, autoMull, minProtection, greedyMullCount, state.random[threadnum]);
        System.out.println(results);
        final int w = results.get("wins");
        final int wp = results.get("protected");
        final float pWin = ((float) w) / trials;
        final float pProtected = ((float) wp) / trials;
        // Fitness calculation: Overall wins should take precedence, with protected wins breaking ties
        final double f = w + pProtected;
        System.out.println("\tindividual " + Arrays.toString(ind.genome)
                + ": " + w + " wins with " + wp + " protected wins out of " + trials
                + " ; fitness=" + f);
        return f;
    }

    /**
     * Fitness function that only cares about the number of wins overall, with any number of
     * protection spells.
     */
    /*
    private double fitnessWinOnly(final IntegerVectorIndividual ind, final Deck deck, final EvolutionState state, final int threadnum) {
        final Map<String, Integer> results = prolog.simulateGames(deck, trials, 7, false, autoMull, minProtection, greedyMullCount, state.random[threadnum]);
        final int w = results.get("wins");
        final int wp = results.get("protected");
        final double f = ((double) w) / trials;
        System.out.println("\tindividual " + Arrays.toString(ind.genome)
                + ": " + w + " wins with " + wp + " protected wins out of " + trials
                + " ; fitness=" + f);
        return f;
    }
     */

    @Override
    public void evaluate(final EvolutionState state, final Individual ind,
                         final int subpopulation, final int threadnum) {
        if (ind.evaluated) {
            return;
        }
        final IntegerVectorIndividual ind2 = (IntegerVectorIndividual) ind;
        final DecklistVectorSpecies species = (DecklistVectorSpecies) ind.species;
        final Deck deck = species.template.toDeck(ind2.genome);
        System.out.println("Evaluating " + Arrays.toString(ind2.genome) + " (" + deck.getSize() + " cards)...");
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
        final Parameter def = this.defaultBase();
        this.trials = state.parameters.getIntWithDefault(
                base.push(P_N_GAMES), def.push(P_N_GAMES), 1);
        final String plFiles = state.parameters.getStringWithDefault(
                base.push(P_PROLOG_FILES), def.push(P_PROLOG_FILES), "");
        for (final String filename : plFiles.split("\\s|,|;|:|\\|")) {
            if (!filename.trim().isEmpty()) {
                state.output.println("Consulting " + filename.trim() + " ...", Log.D_STDOUT);
                prolog.consultFile(filename.trim());
            }
            System.out.println("Prolog files loaded.");
        }
    }
}
