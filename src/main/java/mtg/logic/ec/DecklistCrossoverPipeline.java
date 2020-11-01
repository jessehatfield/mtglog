package mtg.logic.ec;

import ec.vector.*;
import ec.*;
import ec.util.*;
import java.util.*;

public class DecklistCrossoverPipeline extends BreedingPipeline {
    public static final String P_CROSSOVER = "crossover";
    public static final String P_TOTAL = "size";
    public static final String P_MAX = "max";
    public static final int NUM_SOURCES = 2;
    public int total;
    public int max_copies;

    IntegerVectorIndividual parents[];

    public DecklistCrossoverPipeline() { parents = new IntegerVectorIndividual[2]; }
    public Parameter defaultBase() { return VectorDefaults.base().push(P_CROSSOVER); }
    public int numSources() { return NUM_SOURCES; }

    public Object clone() {
        DecklistCrossoverPipeline c = (DecklistCrossoverPipeline)(super.clone());
        c.parents = (IntegerVectorIndividual[]) parents.clone();
        return c;
    }

    public void setup(final EvolutionState state, final Parameter base) {
        super.setup(state, base);
        Parameter def = defaultBase();
        total = state.parameters.getIntWithDefault(base.push(P_TOTAL),
                def.push(P_TOTAL), 60);
        max_copies = state.parameters.getIntWithDefault(base.push(P_MAX),
                def.push(P_MAX), 4);
    }

    public int typicalIndsProduced() { return minChildProduction(); }

    public int produce(final int min, final int max, final int start,
            final int subpopulation, final Individual[] inds,
            final EvolutionState state, final int thread) {
        int n = typicalIndsProduced();
        if (n < min) n = min;
        if (n > max) n = max;

        if (!state.random[thread].nextBoolean(likelihood)) {
            return reproduce(n, start, subpopulation, inds, state, thread, true);
        }

        for (int i = start; i < start+n;) {
            //Get two individuals (parents)
            if (sources[0] == sources[1]) {
                sources[0].produce(2, 2, 0, subpopulation, parents, state, thread);
                if (!(sources[0] instanceof BreedingPipeline)) {
                    parents[0] = (IntegerVectorIndividual) (parents[0].clone());
                    parents[1] = (IntegerVectorIndividual) (parents[1].clone());
                }
            } else {
                sources[0].produce(1, 1, 0, subpopulation, parents, state, thread);
                sources[1].produce(1, 1, 1, subpopulation, parents, state, thread);
                if (!(sources[0] instanceof BreedingPipeline)) {
                    parents[0] = (IntegerVectorIndividual) (parents[0].clone());
                }
                if (!(sources[1] instanceof BreedingPipeline)) {
                    parents[1] = (IntegerVectorIndividual) (parents[1].clone());
                }
            }

            // Cross the two parents over, then add the result to inds and increment i
            inds[i] = crossover(parents[0], parents[1], state.random[thread]);
            i++;
        }
        return n;
    }

    /*
    void crossover(IntegerVectorIndividual parent1,
                   IntegerVectorIndividual parent2, MersenneTwisterFast rng) {
        // For each card, average the counts of the two parents.
        // If the average is fractional (e.g. 1 and 4 -> 2.5), truncate
        // (the new count is 2) and add a copy to the extra pile.
        // Add in the extras until they run out or the deck is full.
        LinkedList extras = new LinkedList();
        int length = parents[0].genomeLength();
        int size = 0;
        for (int j = 0; j < length; j++) {
            int sum = parents[0].genome[j] + parents[1].genome[j];
            if (sum % 2 > 0) {
                extras.add(j);
            }
            parents[0].genome[j] = sum / 2;
            size += parents[0].genome[j];
        }
        Collections.shuffle(extras);
        for (int j = 0; j < total-size; j++) {
            if (extras.size() == 0) {
                break;
            }
            parents[0].genome[(int)(extras.pop())]++;
        }
        parents[0].evaluated = false;
    }
     */

    IntegerVectorIndividual crossover(IntegerVectorIndividual parent1,
                   IntegerVectorIndividual parent2, MersenneTwisterFast rng) {
        final IntegerVectorSpecies species = (IntegerVectorSpecies) parent1.species;
        // Collect all cards from both parents as a 2n-sized list of indices,
        // with placeholders for required cards
        final int[] shuffled = new int[total * 2];
        int nCards = 0;
        for (int cardIndex = 0; cardIndex < parent1.genomeLength(); cardIndex++) {
            int totalCopies = parent1.genome[cardIndex] + parent2.genome[cardIndex];
            int requiredCopies = species == null ? 0 : (int) species.minGene(cardIndex);
            int freeCopies = totalCopies - requiredCopies;
            for (int i = 0; i < freeCopies; i++) {
                shuffled[nCards] = cardIndex;
                nCards++;
            }
            for (int i = 0; i < requiredCopies; i++) {
                shuffled[nCards] = -1;
                nCards++;
            }
        }
        // Shuffle all the combined cards
        for (int i = 0; i < shuffled.length-1; i++) {
            final int j = rng.nextInt(shuffled.length-i) + i;
            final int temp = shuffled[i];
            shuffled[i] = shuffled[j];
            shuffled[j] = temp;
        }
        // Initialize child with minimum, then deal out free cards, obeying max restrictions
        IntegerVectorIndividual child = (IntegerVectorIndividual) parent1.clone();
        nCards = 0;
        for (int i = 0; i < child.genomeLength(); i++) {
            child.genome[i] = species == null ? 0 : (int) species.minGene(i);
            nCards += child.genome[i];
        }
        for (int cardIndex : shuffled) {
            if (cardIndex < 0) {
                continue;
            }
            final int max_gene = species == null ? Integer.MAX_VALUE : (int) species.maxGene(cardIndex);
            final int max_card_copies = Math.min(max_copies, max_gene);
            if (child.genome[cardIndex] < max_card_copies || max_card_copies < 0) {
                child.genome[cardIndex]++;
                nCards++;
                if (nCards >= total) {
                    break;
                }
            }
        }
        child.evaluated = false;
        return child;
    }
}
