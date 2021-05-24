package mtg.logic.ec.stochastic;

import ec.EvolutionState;
import ec.Individual;
import ec.Problem;
import ec.Subpopulation;
import ec.simple.SimpleProblemForm;

import java.util.ArrayList;

public abstract class StochasticProblem extends Problem implements SimpleProblemForm {
    protected int maxTrials = 0;

    @Override
    public void prepareToEvaluate(EvolutionState state, int threadnum) {
        super.prepareToEvaluate(state, threadnum);
        maxTrials = 0;
        for (final Subpopulation subpop : state.population.subpops) {
            for (final Individual ind : subpop.individuals) {
                if (ind.fitness instanceof IndividualDependentFitness) {
                    final IndividualDependentFitness fitness = (IndividualDependentFitness) ind.fitness;
                    fitness.prepare(ind);
                    maxTrials = Math.max(fitness.getNSamples(), maxTrials);
                } else {
                    ind.fitness.trials = new ArrayList();
                }
            }
        }
    }
}
