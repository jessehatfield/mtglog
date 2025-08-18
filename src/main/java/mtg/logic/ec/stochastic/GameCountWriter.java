package mtg.logic.ec.stochastic;

import ec.EvolutionState;
import ec.Statistics;
import ec.util.Parameter;

import java.io.File;
import java.io.IOException;

public class GameCountWriter extends Statistics {
    public static final String P_COUNTS_FILE = "file";

    private int gameCountsLogNum;
    private BinomialFitnessMemory history;

    @Override
    public void setup(final EvolutionState state, final Parameter base) {
        super.setup(state, base);
        final File logFile = state.parameters.getFile(base.push(P_COUNTS_FILE), null);
        if (logFile == null) {
            state.output.warning("No filename given; writing accumulated game counts to standard out",
                    base.push(P_COUNTS_FILE));
            gameCountsLogNum = 0;
        } else {
            try {
                gameCountsLogNum = state.output.addLog(logFile, true);
            } catch (IOException e) {
                state.output.warning("Couldn't create/append to log file for recording accumulated counts",
                        base.push(P_COUNTS_FILE));
            }
        }
    }

    @Override
    public void postEvaluationStatistics(final EvolutionState state) {
        if (history == null) {
            state.output.error("GameCountWriter has no attached history object to write");
        } else {
            try {
                history.writeTotals(state, gameCountsLogNum);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }

    public void setHistory(final BinomialFitnessMemory history) {
        this.history = history;
    }
}
