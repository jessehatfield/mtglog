package mtg.logic.ec.stochastic;

import ec.EvolutionState;
import ec.Individual;
import ec.select.TournamentSelection;
import ec.util.Parameter;

public class StochasticTournamentSelection extends TournamentSelection {
    public static final String P_POSTERIOR_SAMPLES = "posterior.samples";
    public static final String PARAMETER_BASE = "stochastic.tournament";

    private int numSamples;

    @Override
    public Object clone() {
        final StochasticTournamentSelection other = (StochasticTournamentSelection) super.clone();
        other.numSamples = numSamples;
        return other;
    }

    @Override
    public void setup(final EvolutionState state, final Parameter base) {
        super.setup(state, base);
        final Parameter def = new Parameter(PARAMETER_BASE);
        numSamples = state.parameters.getIntWithDefault(
                base.push(P_POSTERIOR_SAMPLES), def.push(P_POSTERIOR_SAMPLES), 1);
        if (!state.parameters.exists(base.push(P_POSTERIOR_SAMPLES), def.push(P_POSTERIOR_SAMPLES))) {
            state.output.warning("Number of posterior samples for stochastic "
                            + "tournament selection not set, defaulting to " + numSamples
                            + "(fitnesses are compared based on the averages of this "
                            + "many samples from their respective posterior distributions)",
                    base.push(P_POSTERIOR_SAMPLES), def.push(P_POSTERIOR_SAMPLES));
        }
        if (numSamples == 0) {
            state.output.warning("Stochastic tournament selection initialized with number of "
                            + "samples == 0; equivalent to ordinary tournament selection",
                    base.push(P_POSTERIOR_SAMPLES), def.push(P_POSTERIOR_SAMPLES));
        }
    }

    @Override
    public boolean betterThan(Individual first, Individual second, int subpopulation, EvolutionState state, int thread) {
        StochasticFitness fitness1 = (StochasticFitness) first.fitness;
        StochasticFitness fitness2 = (StochasticFitness) second.fitness;
        return fitness1.betterThan(fitness2, state, thread, numSamples);
    }
}
