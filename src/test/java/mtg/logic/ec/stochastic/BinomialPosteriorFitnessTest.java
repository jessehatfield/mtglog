package mtg.logic.ec.stochastic;

import ec.EvolutionState;
import ec.Individual;
import ec.simple.SimpleEvolutionState;
import ec.util.Output;
import ec.util.Parameter;
import ec.util.ParameterDatabase;
import ec.vector.IntegerVectorIndividual;
import org.junit.Assert;
import org.junit.Test;

public class BinomialPosteriorFitnessTest {
    private static Individual makeIndividual() {
        IntegerVectorIndividual ind = new IntegerVectorIndividual();
        ind.setGenome(new int[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 0});
        return ind;
    }

    @Test
    public void testSetFitness() {
        final EvolutionState state1 = new SimpleEvolutionState();
        final EvolutionState state2 = new SimpleEvolutionState();
        state1.output = new Output(true);
        state2.output = new Output(true);
        final Parameter base = new Parameter("base");
        state1.parameters = new ParameterDatabase();
        state2.parameters = new ParameterDatabase();
        state1.parameters.set(base.push("n"), "10");
        state2.parameters.set(base.push("n"), "100");
        BinomialPosteriorFitness fitness1 = new BinomialPosteriorFitness();
        BinomialPosteriorFitness fitness2 = new BinomialPosteriorFitness();
        fitness1.setup(state1, base);
        fitness2.setup(state2, base);
        fitness1.prepare(makeIndividual());
        fitness1.setFitness(state1, 2, false);
        Assert.assertEquals(10, fitness1.trials.size());
        Assert.assertEquals(.2, fitness1.getP(), 1e-10);
        Assert.assertEquals(.2, fitness1.fitness(), 1e-10);
        fitness2.prepare(makeIndividual());
        fitness2.setFitness(state2, 59, false);
        Assert.assertEquals(100, fitness2.trials.size());
        Assert.assertEquals(.59, fitness2.getP(), 1e-10);
        Assert.assertEquals(.59, fitness2.fitness(), 1e-10);
        fitness1.prepare(makeIndividual());
        fitness1.setFitness(state1, 6, false);
        Assert.assertEquals(10, fitness1.trials.size());
        Assert.assertEquals(.60, fitness1.getP(), 1e-10);
        Assert.assertEquals(.60, fitness1.fitness(), 1e-10);
    }

    @Test
    public void testSetFitness_useLowerBound() {
        final EvolutionState state1 = new SimpleEvolutionState();
        final EvolutionState state2 = new SimpleEvolutionState();
        state1.output = new Output(true);
        state2.output = new Output(true);
        final Parameter base = new Parameter("base");
        state1.parameters = new ParameterDatabase();
        state2.parameters = new ParameterDatabase();
        state1.parameters.set(base.push("n"), "10");
        state2.parameters.set(base.push("n"), "100");
        state1.parameters.set(base.push("lowerbound.conf"), ".95");
        state2.parameters.set(base.push("lowerbound.conf"), ".95");
        BinomialPosteriorFitness fitness1 = new BinomialPosteriorFitness();
        BinomialPosteriorFitness fitness2 = new BinomialPosteriorFitness();
        fitness1.setup(state1, base);
        fitness2.setup(state2, base);
        fitness1.prepare(makeIndividual());
        fitness1.setFitness(state1, 2, false);
        System.out.println(fitness1.fitnessToStringForHumans());
        Assert.assertEquals(10, fitness1.trials.size());
        Assert.assertEquals(.2, fitness1.getP(), 1e-10);
        Assert.assertEquals(.07882004613131567, fitness1.fitness(), 1e-10);
        Assert.assertTrue(fitness1.fitness() < fitness1.getP());
        fitness2.prepare(makeIndividual());
        fitness2.setFitness(state2, 59, false);
        System.out.println(fitness2.fitnessToStringForHumans());
        Assert.assertEquals(100, fitness2.trials.size());
        Assert.assertEquals(.59, fitness2.getP(), 1e-10);
        Assert.assertEquals(.5074404087806941, fitness2.fitness(), 1e-10);
        Assert.assertTrue(fitness1.fitness() < fitness2.getP());
        fitness1.prepare(makeIndividual());
        fitness1.setFitness(state1, 6, false);
        System.out.println(fitness1.fitnessToStringForHumans());
        Assert.assertEquals(10, fitness1.trials.size());
        Assert.assertEquals(.60, fitness1.getP(), 1e-10);
        Assert.assertEquals(.3498115346025346, fitness1.fitness(), 1e-10);
        Assert.assertTrue(fitness1.getP() > fitness2.getP());
        Assert.assertTrue(fitness1.fitness() < fitness2.fitness());
    }
}
