package mtg.logic.ec.stochastic;

import ec.EvolutionState;
import ec.Fitness;
import ec.Individual;
import ec.multiobjective.nsga2.NSGA2MultiObjectiveFitness;
import ec.util.Code;
import ec.util.Parameter;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.io.LineNumberReader;
import java.util.Arrays;

/**
 * Multiobjective fitness for use with NSGA2 that interprets each objective as
 * the estimated success rate for some binomial variable. Keeps track of the
 * sampled success/failure counts to refine that estimate over multiple
 * generations.
 */
public class BinomialNSGA2Fitness extends NSGA2MultiObjectiveFitness implements IndividualDependentFitness {
    public static String P_NUM_SAMPLES = "samples";

    private int[] numTrials;

    private boolean resetCounts = true;
    private int[] successCounts;
    private int[] failureCounts;
    private int[] prevSuccessCounts;
    private int[] prevFailureCounts;
    private Individual latestInd;

    @Override
    public void setup(final EvolutionState state, final Parameter base) {
        super.setup(state, base);
        successCounts = new int[objectives.length];
        failureCounts = new int[objectives.length];
        prevSuccessCounts = new int[objectives.length];
        prevFailureCounts = new int[objectives.length];
        numTrials = new int[objectives.length];
        final Parameter def = defaultBase();
        final int globalNumTrials = state.parameters.getIntWithDefault(
                base.push(P_NUM_SAMPLES), def.push(P_NUM_SAMPLES), 1);
        for (int i = 0; i < objectives.length; i++) {
            numTrials[i] = state.parameters.getIntWithDefault(
                    base.push(P_NUM_SAMPLES).push("" + i),
                    def.push(P_NUM_SAMPLES).push("" + i),
                    globalNumTrials);
        }
    }

    @Override
    public void setObjectives(final EvolutionState state, final double[] newObjectives) {
        for (int i = 0; i < newObjectives.length; i++) {
            final int newSuccesses = (int) Math.round(newObjectives[i] * numTrials[i]);
            successCounts[i] += newSuccesses;
            failureCounts[i] += (numTrials[i] - newSuccesses);
        }
        setObjectivesFromCounts(state);
    }

    private void setObjectivesFromCounts(final EvolutionState state) {
        final double[] newObjectives = new double[objectives.length];
        for (int i = 0; i < successCounts.length; i++) {
            final double n = (double) successCounts[i] + failureCounts[i];
            newObjectives[i] = successCounts[i] / n;
        }
        super.setObjectives(state, newObjectives);
    }

    @Override
    public void prepare(final Individual ind) {
        if (!ind.equals(latestInd)) {
            latestInd = (Individual) ind.clone();
            resetCounts = true;
            for (int i = 0; i < successCounts.length; i++) {
                successCounts[i] = 0;
                failureCounts[i] = 0;
            }
        } else {
            resetCounts = false;
        }
        for (int i = 0; i < successCounts.length; i++) {
            prevSuccessCounts[i] = successCounts[i];
            prevFailureCounts[i] = failureCounts[i];
        }
    }

    @Override
    public void setToMeanOf(EvolutionState state, Fitness[] fitnesses) {
        // preserve *this* fitness's current state if appropriate but use the
        // first fitness in the array to figure out whether we should.
        // Reasoning: this object may not have been prepared but the fitnesses
        // with their values set have been; however we don't keep all of their
        // histories because we assume they have redundant copies (note: may
        // cause problems if used in coevolution)
        if (fitnesses.length > 0) {
            latestInd = ((BinomialNSGA2Fitness) fitnesses[0]).latestInd;
            resetCounts = ((BinomialNSGA2Fitness) fitnesses[0]).resetCounts;
        }
        if (resetCounts) {
            for (int i = 0; i < successCounts.length; i++) {
                successCounts[i] = 0;
                failureCounts[i] = 0;
                prevSuccessCounts[i] = 0;
                prevFailureCounts[i] = 0;
            }
        }
        for (final Fitness fitness : fitnesses) {
            final BinomialNSGA2Fitness f = (BinomialNSGA2Fitness) fitness;
            for (int i = 0; i < successCounts.length; i++) {
                successCounts[i] += f.successCounts[i] - f.prevSuccessCounts[i];
                failureCounts[i] += f.failureCounts[i] - f.prevFailureCounts[i];
            }
        }
        setObjectivesFromCounts(state);
    }

    @Override
    public void writeFitness(final EvolutionState state, final DataOutput dataOutput) throws IOException {
        super.writeFitness(state, dataOutput);
        for (int i = 0; i < successCounts.length; i++) {
            dataOutput.writeInt(successCounts[i]);
            dataOutput.writeInt(failureCounts[i]);
        }
    }

    @Override
    public void readFitness(final EvolutionState state, final DataInput dataInput) throws IOException {
        super.readFitness(state, dataInput);
        for (int i = 0; i < successCounts.length; i++) {
            successCounts[i] = dataInput.readInt();
            failureCounts[i] = dataInput.readInt();
        }
    }

    public String fitnessToString() {
        String s = super.fitnessToString();
        for (int i = 0; i < successCounts.length; i++) {
            s = s + "\nsuccesses: " + Code.encode(successCounts[i])
                    + "\nfailures: " + Code.encode(failureCounts[i]);
        }
        return s;
    }

    @Override
    public void readFitness(final EvolutionState state, final LineNumberReader reader) throws IOException {
        super.readFitness(state, reader);
        for (int i = 0; i < successCounts.length; i++) {
            successCounts[i] = Code.readIntegerWithPreamble("successes: ", state, reader);
            failureCounts[i] = Code.readIntegerWithPreamble("failures: ", state, reader);
        }
    }

    @Override
    public String fitnessToStringForHumans() {
        String s = super.fitnessToStringForHumans() + "\nCounts: [";
        for (int i = 0; i < successCounts.length; i++) {
            if (i > 0) {
                s += " , ";
            }
            final int n = successCounts[i] + failureCounts[i];
            s = s + successCounts[i] + "/" + n;
        }
        s = s + "]";
        return s;
    }

    @Override
    public Object clone() {
        final BinomialNSGA2Fitness other = (BinomialNSGA2Fitness) super.clone();
        final int k = objectives.length;
        other.resetCounts = this.resetCounts;
        other.successCounts = Arrays.copyOf(this.successCounts, k);
        other.failureCounts = Arrays.copyOf(this.failureCounts, k);
        other.prevSuccessCounts = Arrays.copyOf(this.prevSuccessCounts, k);
        other.prevFailureCounts = Arrays.copyOf(this.prevFailureCounts, k);
        other.numTrials = Arrays.copyOf(this.numTrials, k);
        other.latestInd = latestInd == null ? null : (Individual) latestInd.clone();
        return other;
    }
}
