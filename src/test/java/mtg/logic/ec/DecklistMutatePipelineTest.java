package mtg.logic.ec;

import ec.util.MersenneTwisterFast;
import ec.vector.IntegerVectorIndividual;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class DecklistMutatePipelineTest {
    private DecklistMutatePipeline pipeline;
    private MersenneTwisterFast rng;

    @Before
    public void setup() {
        pipeline = new DecklistMutatePipeline();
        pipeline.max_copies = 4;
        pipeline.total = 20;
        pipeline.p = 0.1;
        rng = new MersenneTwisterFast();
    }

    @Test
    public void testMutate() {
        IntegerVectorIndividual ind = new IntegerVectorIndividual();
        ind.setGenome(new int[] {1, 2, 3, 4, 1, 2, 3, 4});
        pipeline.mutate(ind, rng);
        Assert.assertEquals(20, total(ind.genome));
    }

    private int total(int[] values) {
        int total = 0;
        for (int i = 0; i < values.length; i++) {
            total += values[i];
        }
        return total;
    }
}
