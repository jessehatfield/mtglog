package mtg.logic.ec;

import ec.EvolutionState;
import ec.Evolve;
import ec.util.Parameter;
import ec.util.ParameterDatabase;
import ec.vector.IntegerVectorSpecies;
import ec.vector.VectorDefaults;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import java.util.Arrays;

public class DecklistVectorIndividualTest {
    private EvolutionState state;
    private IntegerVectorSpecies species;

    @Before
    public void setup() {
        final ParameterDatabase parameters = new ParameterDatabase();
        parameters.setProperty("breedthreads", "1");
        parameters.setProperty("evalthreads", "1");
        parameters.setProperty("seed.0", "0");
        parameters.setProperty("state", "ec.simple.SimpleEvolutionState");
        parameters.setProperty("vector.species.genome-size", "20");
        parameters.setProperty("vector.species.min-gene", "0");
        parameters.setProperty("vector.species.max-gene", "4");
        parameters.setProperty("vector.species.min-gene.0", "0");
        parameters.setProperty("vector.species.max-gene.0", "1");
        parameters.setProperty("vector.species.min-gene.1", "1");
        parameters.setProperty("vector.species.max-gene.1", "2");
        parameters.setProperty("vector.species.mutation-prob", "0.5");
        parameters.setProperty("vector.species.pipe", "ec.vector.breed.VectorMutationPipeline");
        parameters.setProperty("vector.species.ind", "mtg.logic.ec.DecklistVectorIndividual");
        parameters.setProperty("vector.pipe.source.0", "ec.select.TournamentSelection");
        parameters.setProperty("select.tournament.size", "2");
        parameters.setProperty("vector.species.fitness", "ec.simple.SimpleFitness");
        state = Evolve.initialize(parameters, 0);
        species = new IntegerVectorSpecies();
        final Parameter base = VectorDefaults.base();
        species.setup(state, base);
    }

    @Test
    public void testMutate() {
        final DecklistVectorIndividual ind = (DecklistVectorIndividual) species.newIndividual(state, 0);
        ind.setup(state, VectorDefaults.base());
        System.out.println(Arrays.toString(ind.genome));
        Assert.assertEquals(0, currentTotal(ind));
        ind.defaultMutate(state, 0);
        System.out.println(Arrays.toString(ind.genome));
        Assert.assertEquals(60, currentTotal(ind));
        assertValidGenes(ind);
        ind.reset(state, 0);
        System.out.println(Arrays.toString(ind.genome));
        Assert.assertEquals(60, currentTotal(ind));
        assertValidGenes(ind);
        ind.defaultMutate(state, 0);
        System.out.println(Arrays.toString(ind.genome));
        Assert.assertEquals(60, currentTotal(ind));
        assertValidGenes(ind);
        ind.defaultMutate(state, 0);
        System.out.println(Arrays.toString(ind.genome));
        Assert.assertEquals(60, currentTotal(ind));
        assertValidGenes(ind);
        ind.reset(state, 0);
        System.out.println(Arrays.toString(ind.genome));
        Assert.assertEquals(60, currentTotal(ind));
        assertValidGenes(ind);
    }

    @Test
    public void testEnsureValidSum() {
        final DecklistVectorIndividual ind = (DecklistVectorIndividual) species.newIndividual(state, 0);
        ind.setup(state, VectorDefaults.base());
        ind.genome[1] = 2;
        ind.genome[2] = 4;
        System.out.println(Arrays.toString(ind.genome));
        Assert.assertEquals(6, currentTotal(ind));
        assertValidGenes(ind);
        ind.ensureValidSum(state, 0);
        System.out.println(Arrays.toString(ind.genome));
        Assert.assertEquals(60, currentTotal(ind));
        assertValidGenes(ind);
        for (int i = 2, changes = 0; i < ind.genome.length && changes < 5; i++) {
            if (ind.genome[i] < 4) {
                ind.genome[i]++;
                changes++;
            }
        }
        System.out.println(Arrays.toString(ind.genome));
        Assert.assertEquals(65, currentTotal(ind));
        ind.ensureValidSum(state, 0);
        System.out.println(Arrays.toString(ind.genome));
        Assert.assertEquals(60, currentTotal(ind));
        assertValidGenes(ind);
    }

    private int currentTotal(final DecklistVectorIndividual ind) {
        return Arrays.stream(ind.genome).reduce(0, Integer::sum);
    }

    private void assertValidGenes(final DecklistVectorIndividual ind) {
        for (int i = 0; i < ind.genomeLength(); i++) {
            Assert.assertTrue(ind.genome[i] >= 0);
            Assert.assertTrue(ind.genome[i] <= 4);
            Assert.assertTrue(ind.genome[i] >= species.minGene(i));
            Assert.assertTrue(ind.genome[i] <= species.maxGene(i));
        }
    }
}
