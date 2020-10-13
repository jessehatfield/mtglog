package mtg.logic.ec;

import ec.EvolutionState;
import ec.util.Parameter;
import ec.vector.IntegerVectorIndividual;
import ec.vector.IntegerVectorSpecies;

/**
 * Individual represented by a vector of integers with a constant sum. Based on
 * IntegerVectorIndividual but enforces the constant sum constraint after mutation by randomly
 * incrementing/decrementing a random gene (whichever is necessary) until the sum is restored to
 * the required number.
 */
public class DecklistVectorIndividual extends IntegerVectorIndividual {
    public static final String P_TOTAL = "size";

    public int genomeTotal;
    public int minSumIndividual;
    public int maxSumIndividual;

    @Override
    public void setup(EvolutionState state, Parameter base) {
        super.setup(state, base);
        final Parameter def = defaultBase();
        genomeTotal = state.parameters.getIntWithDefault(base.push(P_TOTAL),
                def.push(P_TOTAL), 60);
        minSumIndividual = 0;
        maxSumIndividual = 0;
        for (int i = 0; i < genomeLength(); i++) {
            minSumIndividual += ((IntegerVectorSpecies) species).minGene(i);
            maxSumIndividual += ((IntegerVectorSpecies) species).maxGene(i);
        }
    }

    /**
     * Increment genes at random or decrement genes at random until the genome sum is equal to the
     * required sum (incrementing if the starting total is less than desired, or decrementing if
     * the starting total is greater than desired), ensuring that the individual numbers remain
     * individually valid (i.e. don't increment beyond a gene's maximum or decrement below its
     * minimum).
     * @param state Evolution state providing RNGs
     * @param thread Index into the threaded objects of the state
     */
    public void ensureValidSum(EvolutionState state, int thread) {
        final IntegerVectorSpecies s = (IntegerVectorSpecies) species;
        int currentTotal = 0;
        int actualTarget = Math.min(Math.max(genomeTotal, minSumIndividual), maxSumIndividual);
        for (int i = 0; i < genome.length; i++) {
            currentTotal += genome[i];
        }
        while (currentTotal != actualTarget) {
            final int i = state.random[thread].nextInt(genomeLength());
            if (currentTotal < actualTarget && genome[i] < s.maxGene(i))  {
                genome[i]++;
                currentTotal++;
            } else if (currentTotal > actualTarget && genome[i] > s.minGene(i)) {
                genome[i]--;
                currentTotal--;
            }
        }
    }

    @Override
    public void reset(EvolutionState state, int thread) {
        super.reset(state, thread);
        ensureValidSum(state, thread);
    }

    @Override
    public void defaultMutate(EvolutionState state, int thread) {
        super.defaultMutate(state, thread);
        ensureValidSum(state, thread);
    }
}
