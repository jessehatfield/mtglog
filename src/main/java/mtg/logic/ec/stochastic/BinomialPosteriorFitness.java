package mtg.logic.ec.stochastic;

import ec.EvolutionState;
import ec.Fitness;
import ec.Individual;
import ec.util.MersenneTwisterFast;
import ec.util.Parameter;
import org.apache.commons.math3.distribution.BetaDistribution;

import java.util.ArrayList;

/**
 * Fitness that represents samples from a binomial distribution, and is evaluated by sampling from
 * the posterior distribution of the success parameter given that sample data.
 */
public class BinomialPosteriorFitness extends StochasticFitness {
    public static final String P_PRIOR_ALPHA = "prior.alpha";
    public static final String P_PRIOR_BETA = "prior.beta";
    public static final String P_DATA_SAMPLES = "n";
    public static final String P_MEMORY = "memory";
    public static final String P_LB_CONFIDENCE = "lowerbound.conf";

    private int nDataSamples;
    private double priorAlpha;
    private double priorBeta;
    private Individual latestInd;
    private boolean resetTrials = true;
    private int historySize = 0;
    private boolean useMemory = false;
    private double lowerBoundConfidence = 0;

    private int successes;
    private int failures;

    @Override
    public Object clone() {
        final BinomialPosteriorFitness other = (BinomialPosteriorFitness) super.clone();
        other.nDataSamples = nDataSamples;
        other.priorAlpha = priorAlpha;
        other.priorBeta = priorBeta;
        other.latestInd = latestInd == null ? null : (Individual) latestInd.clone();
        other.historySize = historySize;
        other.resetTrials = resetTrials;
        other.useMemory = useMemory;
        other.lowerBoundConfidence = lowerBoundConfidence;
        other.successes = successes;
        other.failures = failures;
        return other;
    }

    @Override
    public Parameter defaultBase() {
        return new Parameter("fitness.stochastic.binomial");
    }

    @Override
    public void setup(final EvolutionState state, final Parameter base) {
        super.setup(state, base);
        final Parameter def = defaultBase();
        nDataSamples = state.parameters.getIntWithDefault(
                base.push(P_DATA_SAMPLES), def.push(P_DATA_SAMPLES), 1);
        priorAlpha = state.parameters.getDoubleWithDefault(
                base.push(P_PRIOR_ALPHA), def.push(P_PRIOR_ALPHA), 1.0);
        priorBeta = state.parameters.getDoubleWithDefault(
                base.push(P_PRIOR_BETA), def.push(P_PRIOR_BETA), 1.0);
        useMemory = state.parameters.getBoolean(
                base.push(P_MEMORY), def.push(P_MEMORY), false);
        lowerBoundConfidence = state.parameters.getDouble(
                base.push(P_LB_CONFIDENCE), def.push(P_LB_CONFIDENCE), 0);
        if (!state.parameters.exists(base.push(P_MEMORY), def.push(P_MEMORY))) {
            state.output.warning("Not specified whether to preserve trials "
                    + "across generations for unchanged individuals, "
                    + "defaulting to false",
                    base.push(P_MEMORY), def.push(P_MEMORY));
        }
    }

    @Override
    double sample(EvolutionState state, int threadnum) {
        final double alpha = priorAlpha + successes;
        final double beta = priorBeta + failures;
        return sample_beta(alpha, beta, state.random[threadnum]);
    }

    @Override
    public void setToMeanOf(EvolutionState state, Fitness[] fitnesses) {
        // preserve *this* fitness's current state if appropriate but use the
        // first fitness in the array to figure out whether we should.
        // Reasoning: this object may not have been prepared but the fitnesses
        // with their values set have been; however we don't keep all of their
        // histories because we assume they have redundant copies (note: may
        // cause problems if used in coevolution)
        if (fitnesses.length > 0 && fitnesses[0] instanceof BinomialPosteriorFitness) {
            latestInd = (Individual) ((BinomialPosteriorFitness) fitnesses[0]).latestInd.clone();
            resetTrials = ((BinomialPosteriorFitness) fitnesses[0]).resetTrials;
        }
        if (trials == null || resetTrials) {
            trials = new ArrayList<>();
        }
        historySize = trials.size();
        // add all the other fitness's new trials to this one's, which may or may not be empty now
        for (final Fitness fitness : fitnesses) {
            int skip = fitness instanceof BinomialPosteriorFitness
                    ? ((BinomialPosteriorFitness) fitness).historySize
                    : 0;
            for (int i = skip; i < fitness.trials.size(); i++) {
                trials.add(fitness.trials.get(i));
            }
        }
        // Set the fitness based on the merged list of trials
        setFitnessFromTrials(state);
    }

    @Override
    public void setFitness(EvolutionState state, double _f, boolean _isIdeal) {
        for (int i = 0; i < nDataSamples; i++) {
            trials.add(i < _f);
        }
        setFitnessFromTrials(state);
    }

    private void setFitnessFromTrials(final EvolutionState state) {
        successes = 0;
        failures = 0;
        for (Object trial : trials) {
            if ((boolean) trial) {
                successes++;
            } else {
                failures++;
            }
        }
        if (lowerBoundConfidence > 0 && lowerBoundConfidence < 1) {
            super.setFitness(state, getQuantile(1-lowerBoundConfidence), false);
        } else {
            super.setFitness(state, getP(), false);
        }
    }

    public double getP() {
        return ((double) successes) / trials.size();
    }

    public double getQuantile(final double q) {
        return new BetaDistribution(priorAlpha + successes, priorBeta + failures)
                .inverseCumulativeProbability(q);
    }

    public double getUpperBound(final double quantile) {
        return new BetaDistribution(priorAlpha + successes, priorBeta + failures)
                .inverseCumulativeProbability(quantile);
    }

    @Override
    public void prepare(final Individual ind) {
        if (trials == null || !useMemory || !ind.equals(latestInd)) {
            historySize = 0;
            trials = new ArrayList<>();
            latestInd = (Individual) ind.clone();
            resetTrials = true;
        } else {
            historySize = trials.size();
            resetTrials = false;
        }
    }

    /**
     * Sample from a Gamma(alpha, 1) distribution.
     * @param alpha the shape parameter
     * @param random a random number generator
     * @return a single Gamma-distributed random variate
     */
    public static double sample_gamma(final double alpha, final MersenneTwisterFast random) {
        assert alpha >= 1;
        final double d = alpha - (1.0/3);
        final double c = 1 / (Math.sqrt(9*d));
        while (true) {
            final double x = random.nextGaussian();
            final double v = Math.pow(1 + c * x, 3);
            if (v > 0) {
                final double u = random.nextDouble(false, true);
                if (Math.log(u) < (x * x / 2 + d - d * v + d * Math.log(v))) {
                    return d * v;
                }
            }
        }
    }

    /**
     * Sample from a Beta distribution whose parameters are integers.
     * @param alpha
     * @param beta
     * @return a single Beta-distributed random variate
     */
    public static double sample_beta(final double alpha, final double beta, final MersenneTwisterFast random) {
        final double x = sample_gamma(alpha, random);
        final double y = sample_gamma(beta, random);
        return x / (x + y);
    }

    @Override
    public String fitnessToStringForHumans() {
        final double lb = getQuantile(1-.95);
        final double ub = getQuantile(.95);
        String printable = "Fitness: " + fitness();
        printable += " (stddev: " + stddev() + "; "
                + "90% confidence: [" + lb + ", " + ub + "]"
                + "; " + trials.size() + " trials: ";
        for (Object trial : trials) {
            printable += (boolean) trial ? "1" : "0";
        }
        printable += ")";
        return printable;
    }

    public double stddev() {
        final double p = fitness();
        final double q = 1 - p;
        return Math.sqrt(trials.size() * p * q) / trials.size();
    }

    public static void main(final String[] args) {
        final long n = args.length > 0 ? Long.parseLong(args[0]) : 100L;
        final double alpha = args.length > 1 ? Double.parseDouble(args[1]) : 10.0;
        final double beta = args.length > 2 ? Double.parseDouble(args[2]) : alpha;
        final MersenneTwisterFast random = new MersenneTwisterFast();
        System.out.println("# Sampling from  Beta(" + alpha + "; " + beta + ")");
        double sum = 0.0;
        double sum_sq = 0.0;
        double min = Double.POSITIVE_INFINITY;
        double max = Double.NEGATIVE_INFINITY;
        for (long i = 0L; i < n; i++) {
            double x = BinomialPosteriorFitness.sample_beta(alpha, beta, random);
            sum += x;
            sum_sq += x*x;
            min = Math.min(x, min);
            max = Math.max(x, max);
            System.out.println(x);
        }
        double mean = sum/n;
        double var = sum_sq/n - mean*mean;
        double stddev = Math.sqrt(var);
        System.out.println("# mean=" + mean + " ; stddev=" + stddev
                + " ; range=[" + min + " , " + max + "]");
    }
}
