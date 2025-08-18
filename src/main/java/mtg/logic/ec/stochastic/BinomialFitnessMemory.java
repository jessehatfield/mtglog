package mtg.logic.ec.stochastic;

import ec.EvolutionState;
import ec.Individual;
import ec.vector.IntegerVectorIndividual;
import mtg.logic.Deck;
import mtg.logic.ResultConsumer;
import mtg.logic.ResultSequence;
import mtg.logic.SingleObjectivePrologProblem;
import mtg.logic.ec.DecklistVectorIndividual;
import mtg.logic.ec.DecklistVectorSpecies;

import java.io.IOException;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class BinomialFitnessMemory implements ResultConsumer {
    protected DecklistVectorSpecies species;
    protected final Map<String, GameCount> counts = new HashMap<>();

    public DecklistVectorSpecies getSpecies() {
        return species;
    }

    public void setSpecies(final DecklistVectorSpecies species) {
        this.species = species;
    }

    @Override
    public void consumeResult(final SingleObjectivePrologProblem objective,
                              final Deck deck,
                              final ResultSequence testResult) {
        final IntegerVectorIndividual ind = new IntegerVectorIndividual();
        ind.setGenome(species.getTemplate().toVector(deck));
        final String key = ind.genotypeToString();
        final int newSuccesses = testResult.getFinalResult().getNSuccesses();
        final int newN = testResult.getFinalResult().getNTotal();
        counts.merge(key, new GameCount(newSuccesses, newN), GameCount::sum);
    }

    public void writeTotals(final EvolutionState state, final int logNum) throws IOException {
        final List<Map.Entry<String, GameCount>> sortedEntries = counts.entrySet().stream()
                .sorted(Comparator.comparingDouble((Map.Entry<String, GameCount> entry) -> -entry.getValue().getP())
                        .thenComparingInt(entry -> -entry.getValue().nTotal)
                        .thenComparing(Map.Entry::getKey))
                .collect(Collectors.toList());
        state.output.println("\nRunning totals after generation " + state.generation + ":", logNum);
        state.output.println("cardCounts\tcode\tsuccesses\ttotal\tp", logNum);
        for (final Map.Entry<String, GameCount> entry : sortedEntries) {
            final DecklistVectorIndividual ind = new DecklistVectorIndividual(state, entry.getKey());
            final String counts = Arrays.stream(ind.genome)
                    .mapToObj(Integer::toString)
                    .collect(Collectors.joining(" "));
            state.output.println(
                    "[" + counts + "]"
                    + "\t[" + entry.getKey()
                    + "\t" + entry.getValue().nSuccesses
                    + "\t" + entry.getValue().nTotal
                    + "\t" + entry.getValue().getP(),
                    logNum);
        }
    }

    public int getNSuccesses(final Individual ind) {
        return counts.getOrDefault(ind.genotypeToString(), GameCount.EMPTY).nSuccesses;
    }

    public int getNTotal(final Individual ind) {
        return counts.getOrDefault(ind.genotypeToString(), GameCount.EMPTY).nTotal;
    }

    public static class GameCount {
        public static GameCount EMPTY = new GameCount(0, 0);

        int nSuccesses;
        int nTotal;

        public GameCount(int nSuccesses, int nTotal) {
            this.nSuccesses = nSuccesses;
            this.nTotal = nTotal;
        }

        public double getP() {
            return ((double) nSuccesses) / nTotal;
        }

        public static GameCount sum(final GameCount c1, final GameCount c2) {
            return new GameCount(c1.nSuccesses + c2.nSuccesses, c1.nTotal + c2.nTotal);
        }

        @Override
        public String toString() {
            return "[" + nSuccesses + " successes / " + nTotal + " games; p=" + getP() + "]";
        }
    }
}
