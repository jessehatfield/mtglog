package mtg.logic;

public interface ResultConsumer {
    /**
     * Process a single result.
     * @param objective The objective that was run
     * @param deck The list that was tested
     * @param testResult Any results of that test
     */
    void consumeResult(SingleObjectivePrologProblem objective, Deck deck, ResultSequence testResult);
}
