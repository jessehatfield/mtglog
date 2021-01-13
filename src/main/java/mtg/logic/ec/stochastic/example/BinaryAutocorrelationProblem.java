package mtg.logic.ec.stochastic.example;

import ec.EvolutionState;
import ec.Individual;
import ec.vector.BitVectorIndividual;
import mtg.logic.ec.stochastic.StochasticFitness;
import mtg.logic.ec.stochastic.StochasticProblem;

public class BinaryAutocorrelationProblem extends StochasticProblem {
    private static final long serialVersionUID = 1;

    @Override
    public void evaluate(final EvolutionState evolutionState, final Individual individual,
                         final int subpopulation, final int threadnum) {
        if (individual.evaluated) {
            return;
        }
        final double p = probability((BitVectorIndividual) individual);
        final boolean success = evolutionState.random[threadnum].nextBoolean(p);
        final StochasticFitness fitness = (StochasticFitness) individual.fitness;
        fitness.setFitness(evolutionState, success ? 1.0 : 0.0, false);
        individual.evaluated = true;
    }

    public static double probability(final BitVectorIndividual individual) {
        final int n = individual.genomeLength();
        int max = 0;
        for (int lag = 1; lag < n; lag++) {
            int total = n;
            for (int i = 0; i < n; i++) {
                final int j = (i + lag) % n;
                final boolean match = individual.genome[i] == individual.genome[j];
                total += match ? 1 : -1;
            }
            max = Math.max(max, total);
        }
        return max / (2.0 * n);
    }
}
