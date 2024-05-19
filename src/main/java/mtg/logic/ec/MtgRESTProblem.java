package mtg.logic.ec;

import com.google.gson.Gson;
import com.jayway.jsonpath.JsonPath;
import ec.EvolutionState;
import ec.Individual;
import ec.Problem;
import ec.multiobjective.MultiObjectiveFitness;
import ec.simple.SimpleFitness;
import ec.simple.SimpleProblemForm;
import ec.util.Parameter;
import ec.vector.IntegerVectorIndividual;
import mtg.logic.Deck;
import mtg.logic.RESTEvaluationFunction;
import org.apache.hc.client5.http.impl.classic.BasicHttpClientResponseHandler;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.HttpClientBuilder;
import org.apache.hc.core5.http.ClassicHttpRequest;
import org.apache.hc.core5.http.ContentType;
import org.apache.hc.core5.http.io.support.ClassicRequestBuilder;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

/**
 * An evolutionary computation problem whose fitness function sends a decklist to a REST service.
 */
public class MtgRESTProblem extends Problem implements SimpleProblemForm {
    private static final long serialVersionUID = 1;
    private static final org.slf4j.Logger logger = LoggerFactory.getLogger(MtgRESTProblem.class);

    public static final String P_PROBLEM_SPEC = "spec";

    private static class DecklistEntry {
        String name;
        int number;
        DecklistEntry(final String name, final int count) {
            this.name = name;
            this.number = count;
        }
    }

    private static class Decklist {
        List<DecklistEntry> main;
        Decklist(final Deck deck) {
            main = deck.getCounts().entrySet().stream()
                    .map(entry -> new DecklistEntry(entry.getKey(), entry.getValue()))
                    .collect(Collectors.toList());
        }
    }

    private RESTEvaluationFunction problem;
    private CloseableHttpClient httpClient;
    private final Gson gson = new Gson();

    @Override
    public Parameter defaultBase() {
        return new Parameter("mtg.problem");
    }

    private double[] evaluateDeck(final Deck deck) throws IOException {
        final List<RESTEvaluationFunction.Objective> objectives = problem.getObjectives();
        final double[] results = new double[objectives.size()];
        final String json = gson.toJson(new Decklist(deck));
        logger.debug("Sending: " + json);
        final ClassicHttpRequest request = ClassicRequestBuilder
                .post(problem.getUrl())
                .setEntity(json, ContentType.APPLICATION_JSON)
                .build();
        final String responseText = httpClient.execute(request, new BasicHttpClientResponseHandler());
        logger.debug("Received: " + responseText);
        for (int i = 0; i < objectives.size(); i++) {
            final String value = JsonPath.read(responseText, objectives.get(i).getPath()).toString();
            results[i] = Double.parseDouble(value);
            if (objectives.get(i).isMinimize()) {
                results[i] *= -1;
            }
        }
        return results;
    }

    @Override
    public void evaluate(final EvolutionState state, final Individual ind,
                         final int subpopulation, final int threadnum) {
        if (ind.evaluated) {
            return;
        }
        final IntegerVectorIndividual vectorInd = (IntegerVectorIndividual) ind;
        final DecklistVectorSpecies species = (DecklistVectorSpecies) ind.species;
        final Deck deck = species.template.toDeck(vectorInd.genome);
        final double[] fitnesses;
        try {
            fitnesses = evaluateDeck(deck);
        } catch (final IOException e) {
            throw new RuntimeException(e);
        }
        if (vectorInd.fitness instanceof MultiObjectiveFitness) {
            ((MultiObjectiveFitness) vectorInd.fitness).setObjectives(state, fitnesses);
        } else {
            ((SimpleFitness) vectorInd.fitness).setFitness(state, fitnesses[0], false);
        }
        vectorInd.evaluated = true;
    }

    @Override
    public void setup(final EvolutionState state, final Parameter base) {
        final Parameter def = defaultBase();
        final Parameter specA = base.push(P_PROBLEM_SPEC);
        final Parameter specB = def.push(P_PROBLEM_SPEC);
        try {
            problem = RESTEvaluationFunction.fromYaml(() -> state.parameters.getResource(specA, specB));
        } catch (Exception e) {
            state.output.fatal("Failed to load REST service specification file: "
                    + state.parameters.getString(specA, specB),
                    specA, specB);
        }
    }

    @Override
    public void describe(final EvolutionState state,
                        final Individual ind,
                        final int subpopulation,
                        final int threadnum,
                        final int log) {
        for (int i = 0; i < state.population.subpops.length; i++) {
            for (int j = 0; j < state.population.subpops[i].individuals.length; j++) {
                final DecklistVectorIndividual decklistInd = (DecklistVectorIndividual)
                        state.population.subpops[i].individuals[j];
                state.output.println("\tindividual "
                        + decklistInd.genotypeToStringForHumans() + "; "
                        + decklistInd.fitness.fitnessToStringForHumans().replaceAll("\n", "\n\t\t"),
                        log);
            }
        }
    }

    @Override
    public void initializeContacts(final EvolutionState state) {
        httpClient = HttpClientBuilder.create().build();
    }

    @Override
    public void reinitializeContacts(final EvolutionState state) {
        closeContacts(state, 0);
        initializeContacts(state);
    }

    @Override
    public void closeContacts(final EvolutionState state, int result) {
        if (httpClient != null) {
            try {
                httpClient.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) throws IOException {
        if (args.length >= 2) {
            final MtgRESTProblem app = new MtgRESTProblem();
            app.problem = RESTEvaluationFunction.fromYaml(args[0]);
            app.initializeContacts(null);
            final String decklistFile = args[1];
            final Deck deck = Deck.fromFile(decklistFile);
            final double[] results = app.evaluateDeck(deck);
            final List<RESTEvaluationFunction.Objective> objectives = app.problem.getObjectives();
            for (int i = 0; i < objectives.size(); i++) {
                System.out.println(objectives.get(i).getName() + ": " + results[i]);
            }
            app.closeContacts(null, 0);
        } else {
            System.out.println("Usage: MtgRESTProblem <problem spec file> <decklist>");
        }
    }
}
