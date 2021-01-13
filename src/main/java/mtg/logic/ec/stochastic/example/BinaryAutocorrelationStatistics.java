package mtg.logic.ec.stochastic.example;

import ec.EvolutionState;
import ec.Individual;
import ec.Statistics;
import ec.Subpopulation;
import ec.util.Parameter;
import ec.vector.BitVectorIndividual;
import ec.vector.BitVectorSpecies;

import java.io.File;
import java.io.IOException;

public class BinaryAutocorrelationStatistics extends Statistics {
    public static final String P_STATISTICS_FILE = "file";

    private int logNum = -1;

    @Override
    public void setup(final EvolutionState state, final Parameter base) {
        super.setup(state, base);
        final File logFile = state.parameters.getFile(
                base.push(P_STATISTICS_FILE), null);
        if (logFile == null) {
            state.output.warning("Not logging ground truth; provide filename to keep track of best per generation",
                    base.push(P_STATISTICS_FILE));
            logNum = -1;
        } else {
            try {
                logNum = state.output.addLog(logFile, true);
                state.output.println("generation\tsubpopulation\tbest estimate\tgenome\tground truth\tentropy", logNum);
            } catch (IOException e) {
                state.output.warning("Couldn't create/append to log file for recording fitness",
                        base.push(P_STATISTICS_FILE));
            }
        }
    }

    @Override
    public void postEvaluationStatistics(final EvolutionState state) {
        if (logNum >= 0) {
            for (int i = 0; i < state.population.subpops.length; i++) {
                final Subpopulation subpop = state.population.subpops[i];
                int n = ((BitVectorSpecies) subpop.species).genomeSize;
                int[] numTrue = new int[n];
                for (int j = 0; j < n; j++) {
                    numTrue[j] = 0;
                }
                double maxEstimate = 0.0;
                double maxP = 0.0;
                BitVectorIndividual maxInd = null;
                for (final Individual ind : subpop.individuals) {
                    final double f = ind.fitness.fitness();
                    if (maxInd == null || f > maxEstimate) {
                        final double p = BinaryAutocorrelationProblem.probability((BitVectorIndividual) ind);
                        maxInd = (BitVectorIndividual) ind;
                        maxP = p;
                        maxEstimate = f;
                    }
                    final boolean[] genome = ((BitVectorIndividual) ind).genome;
                    for (int j = 0; j < n; j++) {
                        if (genome[j]) {
                            numTrue[j]++;
                        }
                    }
                }
                double entropy = 0.0;
                for (int j = 0; j < n; j++) {
                    final double p = numTrue[j] / ((double) subpop.individuals.length);
                    if (p > 0) {
                        entropy -= p * Math.log(p) / Math.log(2);
                    }
                    if (p < 1) {
                        entropy -= (1 - p) * Math.log(1 - p) / Math.log(2);
                    }
                }
                entropy /= n;
                final String logMessage = state.generation + "\t" + i
                        + "\t" + maxEstimate
                        + "\t" + maxInd.genotypeToStringForHumans()
                        + "\t" + maxP
                        + "\t" + entropy;
                state.output.println(logMessage, logNum);
            }
        }
    }
}
