package mtg.logic.ec;

import ec.EvolutionState;
import ec.simple.SimpleEvolutionState;
import ec.util.Log;
import ec.util.MersenneTwisterFast;
import ec.util.Output;
import ec.util.Parameter;
import ec.util.ParameterDatabase;
import ec.vector.IntegerVectorIndividual;
import ec.vector.IntegerVectorSpecies;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class DecklistCrossoverPipelineTest {
    private DecklistCrossoverPipeline pipeline;

    @Before
    public void setup() {
        pipeline = new DecklistCrossoverPipeline();
        pipeline.total = 20;
        pipeline.default_max_copies = 4;
        pipeline.parents[0] = new IntegerVectorIndividual();
        pipeline.parents[1] = new IntegerVectorIndividual();
    }

    @Test
    public void testCrossover() {
        MersenneTwisterFast rng = new MersenneTwisterFast(1);
        IntegerVectorIndividual a = new IntegerVectorIndividual();
        IntegerVectorIndividual b = new IntegerVectorIndividual();
        a.setGenome(new int[] {1, 2, 3, 4, 1, 2, 3, 4});
        b.setGenome(new int[] {1, 2, 3, 4, 1, 2, 3, 4});
        IntegerVectorIndividual c = pipeline.crossover(a, b, rng);
        Assert.assertArrayEquals(new int[] {1, 2, 3, 4, 1, 2, 3, 4}, a.genome);
        Assert.assertArrayEquals(new int[] {1, 2, 3, 4, 1, 2, 3, 4}, b.genome);
        Assert.assertEquals(8, c.genomeLength());
        Assert.assertEquals(20, total(c.genome));
        Assert.assertTrue(min(c.genome) >= 0);
        Assert.assertTrue(max(c.genome) <= 4);
        Assert.assertArrayEquals(new int[] {2, 2, 4, 4, 1, 1, 3, 3}, c.genome);
    }

    @Test
    public void testCrossover_species() {
        EvolutionState state = new SimpleEvolutionState();
        Parameter base = new Parameter("param");
        state.parameters = new ParameterDatabase();
        state.output = new Output(true);
        state.output.addLog(Log.D_STDERR, true);
        IntegerVectorSpecies species = new IntegerVectorSpecies();
        state.parameters.set(base.push("genome-size"), "8");
        state.parameters.set(base.push("min-gene"), "0");
        state.parameters.set(base.push("max-gene"), "4");
        state.parameters.set(base.push("min-gene.0"), "0");
        state.parameters.set(base.push("max-gene.0"), "1");
        state.parameters.set(base.push("min-gene.1"), "2");
        state.parameters.set(base.push("max-gene.1"), "3");
        state.parameters.set(base.push("min-gene.2"), "3");
        state.parameters.set(base.push("max-gene.2"), "3");
        state.parameters.set(base.push("ind"), "ec.vector.IntegerVectorIndividual");
        state.parameters.set(base.push("mutation-type"), "reset");
        state.parameters.set(base.push("mutation-prob"), "0");
        state.parameters.set(base.push("crossover-type"), "one");
        state.parameters.set(base.push("pipe"), "ec.vector.breed.VectorMutationPipeline");
        state.parameters.set(base.push("pipe.source.0"), "ec.select.FirstSelection");
        state.parameters.set(base.push("fitness"), "ec.simple.SimpleFitness");
        species.setup(state, base);
        MersenneTwisterFast rng = new MersenneTwisterFast(1);
        IntegerVectorIndividual a = new IntegerVectorIndividual();
        IntegerVectorIndividual b = new IntegerVectorIndividual();
        a.species = species;
        b.species = species;
        a.setGenome(new int[] {1, 2, 3, 4, 1, 2, 3, 4});
        b.setGenome(new int[] {1, 2, 3, 4, 1, 2, 3, 4});
        IntegerVectorIndividual c = pipeline.crossover(a, b, rng);
        Assert.assertArrayEquals(new int[] {1, 2, 3, 4, 1, 2, 3, 4}, a.genome);
        Assert.assertArrayEquals(new int[] {1, 2, 3, 4, 1, 2, 3, 4}, b.genome);
        Assert.assertEquals(8, c.genomeLength());
        Assert.assertEquals(20, total(c.genome));
        Assert.assertTrue(min(c.genome) >= 0);
        Assert.assertTrue(max(c.genome) <= 4);
        Assert.assertArrayEquals(new int[] {1, 3, 3, 4, 1, 2, 3, 3}, c.genome);
    }

    private int total(int[] values) {
        int total = 0;
        for (int i = 0; i < values.length; i++) {
            total += values[i];
        }
        return total;
    }

    private int max(int[] values) {
        int x = Integer.MIN_VALUE;
        for (int i = 0; i < values.length; i++) {
            if (values[i] > x) {
                x = values[i];
            }
        }
        return x;
    }

    private int min(int[] values) {
        int x = Integer.MAX_VALUE;
        for (int i = 0; i < values.length; i++) {
            if (values[i] < x) {
                x = values[i];
            }
        }
        return x;
    }
}
