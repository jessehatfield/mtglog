package mtg.logic.ec;

import ec.EvolutionState;
import ec.Evolve;
import ec.Statistics;
import ec.util.Parameter;
import ec.util.ParameterDatabase;
import mtg.logic.Deck;

import java.io.DataOutputStream;
import java.io.File;
import java.io.IOException;

import static ec.Evolve.cleanup;

public class PopulationWriter extends Statistics {
    public static final String P_POP_FILE = "file";

    private int populationLogNum;

    @Override
    public void setup(final EvolutionState state, final Parameter base) {
        super.setup(state, base);
        final File logFile = state.parameters.getFile(
                base.push(P_POP_FILE), null);
        if (logFile == null) {
            state.output.warning("No filename given; serializing individuals to standard out",
                    base.push(P_POP_FILE));
            populationLogNum = 0;
        } else {
            try {
                populationLogNum = state.output.addLog(logFile, true);
            } catch (IOException e) {
                state.output.warning("Couldn't create/append to log file for recording individuals",
                        base.push(P_POP_FILE));
            }
        }
    }

    @Override
    public void postEvaluationStatistics(final EvolutionState state) {
        if (populationLogNum >= 0) {
            state.output.println("", populationLogNum);
            state.output.println("Generation " + state.generation + ":", populationLogNum);
            state.population.printPopulation(state, populationLogNum);
        }
    }

    public static void main(String[] args) throws IOException {
        if (args.length >= 2) {
            final String paramFile = args[0];
            final ParameterDatabase parameters = Evolve.loadParameterDatabase(new String[]{Evolve.A_FILE, paramFile});
            parameters.setProperty("stat", "ec.simple.SimpleStatistics");
            parameters.setProperty("stat.silent", "true");
            parameters.setProperty("stat.num-children", "0");
            parameters.setProperty("pop.subpop.0.file", "");
            parameters.setProperty("pop.subpop.0.size", Integer.toString(args.length - 1));
            final EvolutionState state = Evolve.initialize(parameters, 0);
            state.setup(state, null);
            state.population = state.initializer.initialPopulation(state, 0);
            final DecklistVectorSpecies species = (DecklistVectorSpecies) state.population.subpops[0].species;
            for (int i = 1; i < args.length; i++) {
                final String decklistFile = args[i];
                final Deck deck = Deck.fromFile(decklistFile);
                ((DecklistVectorIndividual) state.population.subpops[0].individuals[i-1]).genome
                        = species.template.toVector(deck);
            }
            state.population.subpops[0].printSubpopulation(state, 0);
            cleanup(state);
        } else {
            System.out.println("Usage: PopulationWriter <EC parameter file> <decklist> [<decklist> ...]");
        }
    }
}
