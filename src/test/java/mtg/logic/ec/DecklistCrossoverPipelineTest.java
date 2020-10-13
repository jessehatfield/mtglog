package mtg.logic.ec;

import ec.util.MersenneTwisterFast;
import ec.vector.IntegerVectorIndividual;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class DecklistCrossoverPipelineTest {
    private DecklistCrossoverPipeline pipeline;

    @Before
    public void setup() {
        pipeline = new DecklistCrossoverPipeline();
        pipeline.total = 20;
        pipeline.max_copies = 4;
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
