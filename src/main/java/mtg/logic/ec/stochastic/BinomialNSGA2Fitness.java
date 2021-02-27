package mtg.logic.ec.stochastic;

import ec.EvolutionState;
import ec.Fitness;
import ec.Individual;
import ec.multiobjective.nsga2.NSGA2MultiObjectiveFitness;
import ec.util.Code;
import ec.util.Parameter;
import ec.util.ParameterDatabase;
import org.apache.commons.math3.distribution.BetaDistribution;

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
    public static String P_FITNESS_STAT = "stat";
    public static String P_CONFIDENCE = "conf";
    public static String P_PRIOR_ALPHA = "prior.alpha";
    public static String P_PRIOR_BETA = "prior.beta";

    public static String FITNESS_STAT_MLE = "mle";
    public static String FITNESS_STAT_MPE = "mpe";
    public static String FITNESS_STAT_POSTERIOR_LB = "posterior-lb";

    private int[] numTrials;

    private boolean resetCounts = true;
    private int[] successCounts;
    private int[] failureCounts;
    private int[] prevSuccessCounts;
    private int[] prevFailureCounts;
    private Individual latestInd;
    private double priorAlpha;
    private double priorBeta;
    private double confidence;
    private String fitnessStat;

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
        fitnessStat = state.parameters.getStringWithDefault(
                base.push(P_FITNESS_STAT), def.push(P_FITNESS_STAT), FITNESS_STAT_MLE);
        if (fitnessStat.equals(FITNESS_STAT_POSTERIOR_LB) || fitnessStat.equals(FITNESS_STAT_POSTERIOR_LB)) {
            requireParam(state, base, P_PRIOR_ALPHA, "Fitness stat '" + fitnessStat
                    + "' based on Bayesian posterior requires priors alpha and beta");
            requireParam(state, base, P_PRIOR_BETA, "Fitness stat '" + fitnessStat
                    + "' based on Bayesian posterior requires priors alpha and beta");
            if (fitnessStat.equals(FITNESS_STAT_POSTERIOR_LB)) {
                requireParam(state, base, P_CONFIDENCE, "Fitness stat '" + fitnessStat
                        + "' based on Bayesian posterior requires a confidence interval"
                        + " (fitness will be the lower bound, i.e. CDF(fitness) == (1-conf)/2");
            }
        } else if (!fitnessStat.equals(FITNESS_STAT_MLE)) {
            state.output.error("Unrecognized statistic for fitness value",
                    base.push(P_FITNESS_STAT), def.push(P_FITNESS_STAT));
        }
        priorAlpha = state.parameters.getDoubleWithDefault(
                base.push(P_PRIOR_ALPHA), def.push(P_PRIOR_ALPHA), 1.0);
        priorBeta = state.parameters.getDoubleWithDefault(
                base.push(P_PRIOR_BETA), def.push(P_PRIOR_BETA), 1.0);
        confidence = state.parameters.getDoubleWithDefault(
                base.push(P_CONFIDENCE), def.push(P_CONFIDENCE), .90);
    }

    private boolean requireParam(final EvolutionState state, final Parameter base,
                                 final String key, final String message) {
        final Parameter def = defaultBase();
        if (!state.parameters.exists(base.push(key), def.push(key))) {
            state.output.error(message, base.push(key), def.push(key));
            return false;
        }
        return true;
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
            if (fitnessStat.equals(FITNESS_STAT_MLE)) {
                newObjectives[i] = successCounts[i] / n;
            } else if (fitnessStat.equals(FITNESS_STAT_MPE)) {
                newObjectives[i] = getMPE(i);
            } else if (fitnessStat.equals(FITNESS_STAT_POSTERIOR_LB)) {
                newObjectives[i] = getPosterior(i).inverseCumulativeProbability((1-confidence)/2);
            }
        }
        super.setObjectives(state, newObjectives);
    }

    public BetaDistribution getPosterior(final int objectiveIndex) {
        return new BetaDistribution(priorAlpha + successCounts[objectiveIndex],
            priorBeta + failureCounts[objectiveIndex]);
    }

    private double getMPE(final int objectiveIndex) {
        // Mode of the Beta distribution
        final double alpha = priorAlpha + successCounts[objectiveIndex];
        final double beta = priorBeta + failureCounts[objectiveIndex];
        if (alpha == 1 && beta == 1) {
            return 0.5;
        } else if (alpha <= 1) {
            if (beta > 1) {
                return 0.0;
            } else {
                return 1.0;
            }
        } else if (beta <= 1) {
            return 1.0;
        } else {
            return (alpha - 1) / (alpha + beta - 2);
        }
    }

    private double getMLE(final int objectiveIndex) {
        final double n = successCounts[objectiveIndex] + failureCounts[objectiveIndex];
        if (n > 0) {
            return successCounts[objectiveIndex] / n;
        } else {
            return Double.NaN;
        }
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
        final String s = super.fitnessToStringForHumans();
        String counts = "\nCounts: [";
        String cis = String.format("\n%3.1f%% CIs: [", confidence*100);
        String mpes = "\nMaximum Posterior Estimates: [";
        String mles = "\nMaximum Likelihood Estimates: [";
        for (int i = 0; i < successCounts.length; i++) {
            if (i > 0) {
                counts += " , ";
                cis += " , ";
                mpes += " , ";
                mles += " , ";
            }
            final int n = successCounts[i] + failureCounts[i];
            counts += successCounts[i] + "/" + n;
            final BetaDistribution posterior = getPosterior(i);
            cis += String.format(" [%.4f : %.4f] ",
                    posterior.inverseCumulativeProbability((1-confidence)/2),
                    posterior.inverseCumulativeProbability(1-(1-confidence)/2));
            mpes += getMPE(i);
            mles += getMLE(i);
        }
        counts += "]";
        cis += "]";
        mpes += "]";
        mles += "]";
        return s + counts + cis + mpes + mles;
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
        other.priorAlpha = priorAlpha;
        other.priorBeta = priorBeta;
        other.confidence = confidence;
        other.fitnessStat = fitnessStat;
        return other;
    }
}
