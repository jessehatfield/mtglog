package mtg.logic.ec;

import ec.vector.*;
import ec.*;
import ec.util.*;
import java.util.*;

@Deprecated
public class DecklistMutatePipeline extends BreedingPipeline {
    public static final String P_MUTATION = "mutate";
    public static final String P_TOTAL = "size";
    public static final String P_MAX = "max";
    public static final String P_PROB = "p";
    public static final int NUM_SOURCES = 1;
    public double p;
    public int total;
    public int max_copies;

    public Parameter defaultBase() { return VectorDefaults.base().push(P_MUTATION); }

    public void setup(final EvolutionState state, final Parameter base) {
        super.setup(state, base);
        Parameter def = defaultBase();
        total = state.parameters.getIntWithDefault(base.push(P_TOTAL),
                def.push(P_TOTAL), 60);
        max_copies = state.parameters.getIntWithDefault(base.push(P_MAX),
                def.push(P_MAX), 4);
        p = state.parameters.getDoubleWithDefault(base.push(P_PROB),
                def.push(P_PROB), .05);
    }

    public int numSources() { return NUM_SOURCES; }

    public int produce(final int min, final int max, final int start,
            final int subpopulation, final Individual[] inds,
            final EvolutionState state, final int thread) {
        int n = sources[0].produce(min, max, start, subpopulation, inds, state, thread);

        if (!state.random[thread].nextBoolean(likelihood)) {
            return reproduce(n, start, subpopulation, inds, state, thread, false);
        }
        if (!(sources[0] instanceof BreedingPipeline)) {
            for (int i = start; i < start+n; i++) {
                inds[i] = (Individual) (inds[i].clone());
            }
        }

        for (int i = start; i < start+n; i++) {
            mutate((IntegerVectorIndividual) inds[i], state.random[thread]);
        }
        return n;
    }

    void mutate(IntegerVectorIndividual ind, MersenneTwisterFast rng) {
        final int length = ind.genomeLength();
        final List deck = new ArrayList(total);

        for (int j = 0; j < length; j++) {
            //With some probability, if ind[j] isn't already maximum, add a
            //[j].
            if (ind.genome[j] < max_copies && rng.nextDouble() < p) {
                ind.genome[j]++;
                ind.evaluated = false;
            }
            //Fill up a list with individual copies of cards
            for (int k = 0; k < ind.genome[j]; k++) {
                deck.add(j);
            }
        }

        //Shuffle the deck, then remove cards until we're not greater than
        //max size.
        Collections.shuffle(deck);
        int extra = deck.size() - total;
        for (int j = 0; j < extra; j++) {
            int index = (int) deck.get(j);
            ind.genome[index]--;
        }
    }
}
