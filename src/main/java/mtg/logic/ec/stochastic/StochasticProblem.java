package mtg.logic.ec.stochastic;

import ec.EvolutionState;
import ec.Individual;
import ec.Problem;
import ec.Subpopulation;
import ec.simple.SimpleProblemForm;

import java.util.ArrayList;

public abstract class StochasticProblem extends Problem implements SimpleProblemForm {
    @Override
    public void prepareToEvaluate(EvolutionState state, int threadnum) {
        super.prepareToEvaluate(state, threadnum);
        for (final Subpopulation subpop : state.population.subpops) {
            for (final Individual ind : subpop.individuals) {
                if (ind.fitness instanceof IndividualDependentFitness) {
                    ((IndividualDependentFitness) ind.fitness).prepare(ind);
                } else {
                    ind.fitness.trials = new ArrayList();
                }
            }
        }
    }
}
