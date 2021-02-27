package mtg.logic.ec;

import ec.EvolutionState;
import ec.Individual;
import ec.Statistics;
import ec.Subpopulation;
import ec.multiobjective.MultiObjectiveFitness;
import ec.util.Parameter;
import mtg.logic.Deck;
import mtg.logic.DeckTemplate;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class DecklistWriter extends Statistics {
    public static final String P_DECKLISTS_FILE = "file";

    private int decklistLogNum;

    @Override
    public void setup(final EvolutionState state, final Parameter base) {
        super.setup(state, base);
        final File logFile = state.parameters.getFile(
                base.push(P_DECKLISTS_FILE), null);
        if (logFile == null) {
            state.output.warning("No filename given; writing decklists to standard out",
                    base.push(P_DECKLISTS_FILE));
            decklistLogNum = 0;
        } else {
            try {
                decklistLogNum = state.output.addLog(logFile, true);
            } catch (IOException e) {
                state.output.warning("Couldn't create/append to log file for recording decks",
                        base.push(P_DECKLISTS_FILE));
            }
        }
    }

    @Override
    public void postEvaluationStatistics(final EvolutionState state) {
        if (decklistLogNum >= 0) {
            DeckTemplate template = null;
            final List<DecklistVectorIndividual> front = new ArrayList<>();
            for (final Subpopulation subpop : state.population.subpops) {
                if (subpop.species instanceof DecklistVectorSpecies) {
                    for (final Individual ind : subpop.individuals) {
                        if (ind instanceof DecklistVectorIndividual) {
                            boolean dominated = false;
                            for (final Individual ind2 : subpop.individuals) {
                                if (ind2 instanceof DecklistVectorIndividual) {
                                    if (ind.fitness instanceof MultiObjectiveFitness
                                        && ind2.fitness instanceof MultiObjectiveFitness) {
                                        dominated = ((MultiObjectiveFitness) ind2.fitness)
                                                .paretoDominates((MultiObjectiveFitness) ind.fitness);
                                    } else {
                                        dominated = ind2.fitness.betterThan(ind.fitness);
                                    }
                                    if (dominated) {
                                        break;
                                    }
                                }
                            }
                            if (!dominated) {
                                front.add((DecklistVectorIndividual) ind);
                            }
                        }
                    }
                    template = ((DecklistVectorSpecies) subpop.species).template;
                }
            }
            for (int i = 0; i < front.size(); i++) {
                state.output.println("", decklistLogNum);
                state.output.println("# Generation " + state.generation, decklistLogNum);
                state.output.println("# Non-dominated individual " + i + ", "
                        + front.get(i).fitness.fitnessToStringForHumans() + "\n", decklistLogNum);
                final Deck deck = template.toDeck(front.get(i).genome);
                final String decklist = template.toString(deck);
                for (final String line : decklist.split("\n")) {
                    state.output.println(line, decklistLogNum);
                }
                state.output.println("", decklistLogNum);
            }
        }
    }
}
