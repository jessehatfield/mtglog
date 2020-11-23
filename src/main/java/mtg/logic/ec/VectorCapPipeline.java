package mtg.logic.ec;

import ec.vector.IntegerVectorIndividual;
import ec.vector.VectorDefaults;
import ec.BreedingPipeline;
import ec.EvolutionState;
import ec.Individual;
import ec.util.Parameter;

public class VectorCapPipeline extends BreedingPipeline {
    public static final String P_MUTATION = "mutate";
    public static final String P_TOTAL = "cap";
    public static final int NUM_SOURCES = 1;
    public int total;

    public Parameter defaultBase() { return VectorDefaults.base().push(P_MUTATION); }

    public void setup(final EvolutionState state, final Parameter base) {
        super.setup(state, base);
        Parameter def = defaultBase();
        total = state.parameters.getIntWithDefault(base.push(P_TOTAL),
                def.push(P_TOTAL), 60);
    }

    public int numSources() { return NUM_SOURCES; }

    public int produce(final int min, final int max, final int start,
            final int subpopulation, final Individual[] inds,
            final EvolutionState state, final int thread) {
        int n = sources[0].produce(min, max, start, subpopulation, inds, state, thread);
        int length;
        int sum;
        int k;
        IntegerVectorIndividual ind;
        for (int i = start; i < start+n; i++) {
            ind = (IntegerVectorIndividual) inds[i];
            length = ind.genomeLength();
            sum = 0;
            for (int j = 0; j < length; j++) {
                sum += ind.genome[j];
            }
            while (sum > total) {
                k = state.random[thread].nextInt(length);
                if (ind.genome[k] > 0) {
                    ind.genome[k]--;
                    sum--;
                }
            }
        }
        return n;
    }
}
