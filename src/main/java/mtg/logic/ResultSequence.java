package mtg.logic;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

/**
 * A sequence of hands, results, and mulligan decisions representing one complete test game.
 */
public class ResultSequence {
    public static enum Decision { KEEP, MULLIGAN, POWDER; }

    public static class Hand {
        private final List<String> hand;
        private final Results result;
        private final Decision decision;
        public Hand(final List<String> hand, final Results result, final Decision decision) {
            Objects.requireNonNull(hand);
            Objects.requireNonNull(result);
            Objects.requireNonNull(decision);
            this.hand = hand;
            this.result = result;
            this.decision = decision;
        }
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private final List<Hand> sequence;
        private List<String> currentHand = null;
        private Results currentResult = null;
        public Builder() {
            sequence = new ArrayList<>();
        }
        public Builder test(final String[] hand, final Results result) {
            Objects.requireNonNull(hand);
            Objects.requireNonNull(result);
            assert currentHand == null;
            assert currentResult == null;
            currentResult = result;
            currentHand = new ArrayList<>();
            Collections.addAll(currentHand, hand);
            return this;
        }
        public Builder decide(final Decision decision) {
            Objects.requireNonNull(currentHand);
            Objects.requireNonNull(currentResult);
            sequence.add(new Hand(currentHand, currentResult, decision));
            currentHand = null;
            currentResult = null;
            return this;
        }
        public Builder powder() {
            return decide(Decision.POWDER);
        }
        public Builder mulligan() {
            return decide(Decision.MULLIGAN);
        }
        public ResultSequence keepAndBuild() {
            assert sequence.size() > 0;
            decide(Decision.KEEP);
            return new ResultSequence(sequence);
        }
    }

    private final List<Hand> sequence;

    private ResultSequence(final List<Hand> sequence) {
        this.sequence = sequence;
    }

    public Results getFinalResult() {
        final Hand finalHand = sequence.get(sequence.size()-1);
        Objects.requireNonNull(finalHand);
        return finalHand.result;
    }

    public Results getResult(final int i) {
        return sequence.get(i).result;
    }

    public List<String> getHand(final int i) {
        return sequence.get(i).hand;
    }

    public Decision getDecision(final int i) {
        return sequence.get(i).decision;
    }

    public int size() {
        return sequence.size();
    }
}
