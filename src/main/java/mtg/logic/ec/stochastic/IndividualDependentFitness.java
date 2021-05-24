package mtg.logic.ec.stochastic;

import ec.Individual;

/**
 * Interface for a type of fitness that needs to be prepared in the context of
 * the specific individual it applies to.
 */
public interface IndividualDependentFitness {
    /**
     * Do any preparation in advance of being evaluated, such as deciding
     * whether to keep old samples if the individual has been seen before or
     * re-initialize if the individual is new.
     * @ind the individual whose Fitness this represents
     */
    void prepare(final Individual ind);

    /**
     * Get the number of historical samples tracked.
     */
    default int getNSamples() {
        return 0;
    }
}
