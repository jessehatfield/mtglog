package mtg.logic.ec.stochastic;

import ec.EvolutionState;
import ec.Individual;
import ec.simple.SimpleFitness;

import java.util.ArrayList;

public abstract class StochasticFitness extends SimpleFitness implements IndividualDependentFitness {
    public boolean isIdealFitness() {
        return false;
    }

    public boolean betterThan(final StochasticFitness _fitness,
                              final EvolutionState state,
                              final int threadnum,
                              int numSamples) {
        if (numSamples > 0) {
            double sum1 = 0.0;
            double sum2 = 0.0;
            for (int i = 0; i < numSamples; i++) {
                sum1 += this.sample(state, threadnum);
                sum2 += _fitness.sample(state, threadnum);
            }
            return sum1 > sum2;
        } else {
            return super.betterThan(_fitness);
        }
    }

    /**
     * Do any preparation in advance of being evaluated. By default, this clears
     * the list of samples, but subclasses may choose to preserve old trials if
     * they still apply, though they should take care that merging behavior
     * works properly.
     * @ind the individual whose Fitness this represents
     */
    @Override
    public void prepare(final Individual ind) {
        trials = new ArrayList<>();
    }

    abstract double sample(final EvolutionState state, final int threadnum);
}
