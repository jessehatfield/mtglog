package mtg.logic.ec.stochastic.example;

import ec.EvolutionState;
import ec.Evolve;
import ec.util.ParameterDatabase;
import ec.vector.BitVectorIndividual;
import ec.vector.BitVectorSpecies;
import ec.vector.VectorDefaults;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class BinaryAutocorrelationProblemTest {
    private EvolutionState state;
    private BitVectorSpecies species;
    private ParameterDatabase parameters;

    @Before
    public void setup() {
        parameters = new ParameterDatabase();
        parameters.setProperty("breedthreads", "1");
        parameters.setProperty("evalthreads", "1");
        parameters.setProperty("seed.0", "0");
        parameters.setProperty("state", "ec.simple.SimpleEvolutionState");
        parameters.setProperty("vector.ind", "ec.vector.BitVectorIndividual");
        parameters.setProperty("vector.mutation-prob", "0.0");
        parameters.setProperty("vector.species.pipe", "ec.vector.breed.VectorMutationPipeline");
        parameters.setProperty("vector.pipe.source.0", "ec.select.TournamentSelection");
        parameters.setProperty("select.tournament.size", "2");
        parameters.setProperty("vector.species.fitness", "mtg.logic.ec.stochastic.BinomialPosteriorFitness");
        species = new BitVectorSpecies();
    }

    @Test
    public void testProbability_16bits() {
        parameters.setProperty("vector.species.genome-size", "16");
        state = Evolve.initialize(parameters, 0);
        species.setup(state, VectorDefaults.base());
        BitVectorIndividual ind = (BitVectorIndividual) species.newIndividual(state, 0);
        ind.genome = new boolean[] {false, false, false, false, false, false, false, false,
                false, false, false, false, false, false, false, false};
        Assert.assertEquals(1.0, BinaryAutocorrelationProblem.probability(ind), 1e-10);
        ind.genome[0] = true; //  1000000000000000 -> 0100000000000000 -> 14 - 2 -> (12+16)/32
        Assert.assertEquals(.875, BinaryAutocorrelationProblem.probability(ind), 1e-10);
        ind.genome[1] = true; //  1100000000000000 -> 0110000000000000 -> 14 - 2 -> (12+16)/32
        Assert.assertEquals(.875, BinaryAutocorrelationProblem.probability(ind), 1e-10);
        ind.genome[3] = true; //  1101000000000000 -> 0110100000000000 -> 12 - 4 -> (8+16)/32
        Assert.assertEquals(.75, BinaryAutocorrelationProblem.probability(ind), 1e-10);
        ind.genome[6] = true; //  1101001000000000 -> 0001101001000000 -> 12 - 4 -> (8+16)/32
        Assert.assertEquals(.75, BinaryAutocorrelationProblem.probability(ind), 1e-10);
        ind.genome[10] = true; // 1101001000100000 -> 0001101001000100 -> 10 - 6 -> (4+16)/32
        Assert.assertEquals(.625, BinaryAutocorrelationProblem.probability(ind), 1e-10);
        ind.genome[15] = true; // 1101001000100001 -> 0100001110100100 -> 10 - 6 -> (4+16)/32
        Assert.assertEquals(.625, BinaryAutocorrelationProblem.probability(ind), 1e-10);
        for (int i = 0; i < 16; i++) {
            ind.genome[i] = true;
        }
        Assert.assertEquals(1.0, BinaryAutocorrelationProblem.probability(ind), 1e-10);
    }

    @Test
    public void testProbability_2bits() {
        parameters.setProperty("vector.species.genome-size", "2");
        state = Evolve.initialize(parameters, 0);
        species.setup(state, VectorDefaults.base());
        BitVectorIndividual ind = (BitVectorIndividual) species.newIndividual(state, 0);
        ind.genome = new boolean[] {true, false}; // 10 -> 01 -> 0 - 2 -> (2 - 2) / 4
        Assert.assertEquals(0.0, BinaryAutocorrelationProblem.probability(ind), 1e-10);
        ind.genome[0] = false; // 00 -> 00 -> 2 - 0 -> (2+2)/4
        Assert.assertEquals(1.0, BinaryAutocorrelationProblem.probability(ind), 1e-10);
        ind.genome[1] = true; // 01 -> 10 -> 0 - 2 -> (2 - 2) / 4
        Assert.assertEquals(0.0, BinaryAutocorrelationProblem.probability(ind), 1e-10);
        ind.genome[0] = true; // 11 -> 11 -> 2 - 0 -> (2+2)/4
        Assert.assertEquals(1.0, BinaryAutocorrelationProblem.probability(ind), 1e-10);
    }

    @Test
    public void testProbability_1bit() {
        parameters.setProperty("vector.species.genome-size", "1");
        state = Evolve.initialize(parameters, 0);
        species.setup(state, VectorDefaults.base());
        BitVectorIndividual ind = (BitVectorIndividual) species.newIndividual(state, 0);
        ind.genome = new boolean[] {true};
        Assert.assertEquals(0.0, BinaryAutocorrelationProblem.probability(ind), 1e-10);
        ind.genome[0] = false;
        Assert.assertEquals(0.0, BinaryAutocorrelationProblem.probability(ind), 1e-10);
    }
}
