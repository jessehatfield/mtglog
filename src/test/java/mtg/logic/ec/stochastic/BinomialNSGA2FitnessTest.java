package mtg.logic.ec.stochastic;

import ec.EvolutionState;
import ec.Fitness;
import ec.Individual;
import ec.multiobjective.MultiObjectiveFitness;
import ec.simple.SimpleEvolutionState;
import ec.util.Output;
import ec.util.Parameter;
import ec.util.ParameterDatabase;
import ec.vector.IntegerVectorIndividual;
import org.junit.Assert;
import org.junit.Test;

public class BinomialNSGA2FitnessTest {
    private static Individual makeIndividual(int x) {
        IntegerVectorIndividual ind = new IntegerVectorIndividual();
        ind.setGenome(new int[]{1, 2, 3, 4, 5, 6, 7, 8, 9, x});
        return ind;
    }

    @Test
    public void testSetObjectives() {
        final EvolutionState state1 = new SimpleEvolutionState();
        final EvolutionState state2 = new SimpleEvolutionState();
        state1.output = new Output(true);
        state2.output = new Output(true);
        final Parameter base = new Parameter("base");
        state1.parameters = new ParameterDatabase();
        state2.parameters = new ParameterDatabase();
        state1.parameters.set(base.push("num-objectives"), "3");
        state2.parameters.set(base.push("num-objectives"), "3");
        state1.parameters.set(base.push("samples"), "10");
        state2.parameters.set(base.push("samples"), "10");
        state2.parameters.set(base.push("samples.1"), "100");
        BinomialNSGA2Fitness fitness1 = new BinomialNSGA2Fitness();
        BinomialNSGA2Fitness fitness2 = new BinomialNSGA2Fitness();
        fitness1.setup(state1, base);
        fitness2.setup(state2, base);
        Individual ind1 = makeIndividual(0);
        Individual ind2 = makeIndividual(0);
        fitness1.prepare(ind1);
        fitness2.prepare(ind2);
        fitness1.setObjectives(state1, new double[]{1.0, 0.5, 0.0});
        System.out.println(fitness1.fitnessToStringForHumans());
        Assert.assertEquals(1.0, fitness1.getObjective(0), 1e-10);
        Assert.assertEquals(0.5, fitness1.getObjective(1), 1e-10);
        Assert.assertEquals(0.0, fitness1.getObjective(2), 1e-10);
        fitness2.setObjectives(state2, new double[]{0.0, 0.5, 1.0});
        System.out.println(fitness2.fitnessToStringForHumans());
        Assert.assertEquals(0.0, fitness2.getObjective(0), 1e-10);
        Assert.assertEquals(0.5, fitness2.getObjective(1), 1e-10);
        Assert.assertEquals(1.0, fitness2.getObjective(2), 1e-10);
        ind1.fitness = fitness1;
        ind2.fitness = fitness2;
        int[] ranks = MultiObjectiveFitness.getRankings(new Individual[]{ind1, ind2});
        Assert.assertEquals(0, ranks[0]);
        Assert.assertEquals(0, ranks[1]);
        ind1 = makeIndividual(1);
        fitness1.prepare(ind1);
        fitness1.setObjectives(state1, new double[]{0.0, 0.2, 0.3});
        System.out.println(fitness1.fitnessToStringForHumans());
        Assert.assertEquals(0.0, fitness1.getObjective(0), 1e-10);
        Assert.assertEquals(0.2, fitness1.getObjective(1), 1e-10);
        Assert.assertEquals(0.3, fitness1.getObjective(2), 1e-10);
        ind1.fitness = fitness1;
        ranks = MultiObjectiveFitness.getRankings(new Individual[]{ind1, ind2});
        Assert.assertEquals(1, ranks[0]);
        Assert.assertEquals(0, ranks[1]);
        fitness2.prepare(ind2);
        fitness2.setObjectives(state2, new double[]{0.3, 0.2, 0.0});
        System.out.println(fitness2.fitnessToStringForHumans());
        Assert.assertEquals(0.15, fitness2.getObjective(0), 1e-10);
        Assert.assertEquals(0.35, fitness2.getObjective(1), 1e-10);
        Assert.assertEquals(0.50, fitness2.getObjective(2), 1e-10);
        ranks = MultiObjectiveFitness.getRankings(new Individual[]{ind1, ind2});
        Assert.assertEquals(1, ranks[0]);
        Assert.assertEquals(0, ranks[1]);
    }

    @Test
    public void testSetToMeanOf() {
        final EvolutionState state1 = new SimpleEvolutionState();
        final EvolutionState state2 = new SimpleEvolutionState();
        state1.output = new Output(true);
        state2.output = new Output(true);
        final Parameter base = new Parameter("base");
        state1.parameters = new ParameterDatabase();
        state1.parameters.set(base.push("num-objectives"), "2");
        state1.parameters.set(base.push("samples"), "10");
        state1.parameters.set(base.push("samples.1"), "100");
        state2.parameters = new ParameterDatabase();
        state2.parameters.set(base.push("num-objectives"), "2");
        state2.parameters.set(base.push("samples"), "10");
        final BinomialNSGA2Fitness baseFitness = new BinomialNSGA2Fitness();
        baseFitness.setup(state1, base);
        final BinomialNSGA2Fitness fitness1 = (BinomialNSGA2Fitness) baseFitness.clone();
        final BinomialNSGA2Fitness fitness2 = new BinomialNSGA2Fitness();
        fitness2.setup(state2, base);
        Individual ind = makeIndividual(0);
        fitness1.prepare(ind);
        fitness2.prepare(ind);
        fitness1.setObjectives(state1, new double[]{0.9, 0.5});
        fitness2.setObjectives(state1, new double[]{0.5, 0.9});
        baseFitness.setToMeanOf(state1, new Fitness[]{fitness1, fitness2});
        System.out.println(baseFitness.fitnessToStringForHumans());
        Assert.assertEquals(0.7, baseFitness.getObjective(0), 1e-10);
        Assert.assertEquals(59.0/110, baseFitness.getObjective(1), 1e-10);
        // Add more samples with the equivalent individual: should update rates
        ind = makeIndividual(0);
        fitness1.prepare(ind);
        fitness2.prepare(ind);
        fitness1.setObjectives(state1, new double[]{0.5, 0.5});
        fitness2.setObjectives(state1, new double[]{0.0, 1.0});
        baseFitness.setToMeanOf(state1, new Fitness[]{fitness1, fitness2});
        System.out.println(baseFitness.fitnessToStringForHumans());
        Assert.assertEquals(19.0/40, baseFitness.getObjective(0), 1e-10);
        Assert.assertEquals(119.0/220, baseFitness.getObjective(1), 1e-10);
        // Change the individual: next set of samples should overwrite
        ind = makeIndividual(1);
        fitness1.prepare(ind);
        fitness2.prepare(ind);
        fitness1.setObjectives(state1, new double[]{0.5, 0.5});
        fitness2.setObjectives(state1, new double[]{0.0, 1.0});
        baseFitness.setToMeanOf(state1, new Fitness[]{fitness1, fitness2});
        System.out.println(baseFitness.fitnessToStringForHumans());
        Assert.assertEquals(5.0/20, baseFitness.getObjective(0), 1e-10);
        Assert.assertEquals(60.0/110, baseFitness.getObjective(1), 1e-10);
    }
}
