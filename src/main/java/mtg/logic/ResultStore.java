package mtg.logic;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public abstract class ResultStore implements ResultConsumer {
    protected SingleObjectivePrologProblem objective;
    protected Deck deck;
    protected String deckRepr = null;
    protected String objectiveRepr = null;
    protected List<ResultSequence> resultCache = new ArrayList<>();

    private int maxCacheSize = 1;

    public void setCacheSize(final int maxCacheSize) {
        this.maxCacheSize = maxCacheSize;
    }

    @Override
    public void consumeResult(final SingleObjectivePrologProblem objective,
                              final Deck deck,
                              final ResultSequence testResult) {
        if (this.objective != objective || this.deck != deck) {
            if (this.objective != null && this.deck != null) {
                flushResults();
            }
            this.objective = objective;
            this.deck = deck;
            this.objectiveRepr = getObjectiveRepr(objective);
            this.deckRepr = getDeckRepr(deck);
        }
        resultCache.add(testResult);
        if (resultCache.size() >= maxCacheSize) {
            flushResults();
        }
    }

    private String getDeckRepr(final Deck deck) {
        final Map<String, Integer> counts = deck.getCounts();
        return counts.keySet().stream().sorted()
                .map(c -> counts.get(c) + " " + c)
                .collect(Collectors.joining("\n"));
    }

    private String getObjectiveRepr(final SingleObjectivePrologProblem objective) {
        return objective.toYaml();
    }

    public abstract void flushResults();

    public void close() {
        flushResults();
    }
}
