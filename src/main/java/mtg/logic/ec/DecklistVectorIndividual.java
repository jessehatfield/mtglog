package mtg.logic.ec;

import ec.EvolutionState;
import ec.util.Parameter;
import ec.vector.IntegerVectorIndividual;
import ec.vector.IntegerVectorSpecies;

public class DecklistVectorIndividual extends IntegerVectorIndividual {
    public static final String P_TOTAL = "size";
    public static final String P_MAX = "max";

    public int totalCards;
    public int maxCardCopies;

    @Override
    public void setup(EvolutionState state, Parameter base) {
        super.setup(state, base);
        final Parameter def = defaultBase();
        totalCards = state.parameters.getIntWithDefault(base.push(P_TOTAL),
                def.push(P_TOTAL), 60);
        maxCardCopies = state.parameters.getIntWithDefault(base.push(P_MAX),
                def.push(P_MAX), 4);
    }

    private void fillRandomly(EvolutionState state, int thread, int target) {
        int n = 0;
        while (n < target) {
            final int nextCard = state.random[thread].nextInt(genomeLength());
            if (genome[nextCard] < maxCardCopies)  {
                genome[nextCard]++;
                n++;
            }
        }
    }

    @Override
    public void reset(EvolutionState state, int thread) {
        for (int i = 0; i < genomeLength(); i++) {
            genome[i] = 0;
        }
        fillRandomly(state, thread, totalCards);
    }

    @Override
    public void defaultMutate(EvolutionState state, int thread) {
        final IntegerVectorSpecies s = (IntegerVectorSpecies) species;
        int cutCards = 0;
        for (int i = 0; i < genome.length; i++) {
            if (state.random[thread].nextBoolean(s.mutationProbability(i))
                    && genome[i] > 0) {
                genome[i]--;
                cutCards++;
            }
        }
        fillRandomly(state, thread, cutCards);
    }
}
