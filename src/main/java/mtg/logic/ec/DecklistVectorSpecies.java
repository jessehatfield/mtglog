package mtg.logic.ec;

import ec.EvolutionState;
import ec.util.Parameter;
import ec.vector.IntegerVectorSpecies;
import mtg.logic.DeckTemplate;

import java.io.InputStream;

public class DecklistVectorSpecies extends IntegerVectorSpecies {
    public static final String P_TEMPLATE_FILE = "template";

    protected DeckTemplate template;

    public DecklistVectorSpecies() {
    }

    @Override
    public Parameter defaultBase() {
        return new Parameter("mtg.deck");
    }

    @Override
    public void setup(EvolutionState state, Parameter base) {
        final Parameter def = this.defaultBase();
        final Parameter tempA = base.push(P_TEMPLATE_FILE);
        final Parameter tempB = def.push(P_TEMPLATE_FILE);
        try (final InputStream templateInput = state.parameters.getResource(tempA, tempB)) {
            template = new DeckTemplate(templateInput);
        } catch (Exception e) {
                state.output.fatal("Failed to load template file: "
                        + state.parameters.getString(tempA, tempB),
                        tempA, tempB);
        }
        final int configuredSize = state.parameters.getIntWithDefault(
                base.push("genome-size"), def.push("genome-size"), -1);
        final int defaultSize = template.getNumEntries();
        if (configuredSize < 0 || configuredSize > defaultSize) {
            if (configuredSize < 0) {
                state.output.print("genome-size not given; ", 1);
            } else {
                state.output.print("genome-size=" + configuredSize
                        + "exceeds number of cards in template; ", 1);
            }
            state.output.println("using default derived from template: " + defaultSize, 1);
            state.parameters.set(base.push("genome-size"), Integer.toString(defaultSize));
            this.genomeSize = defaultSize;
        } else {
            this.genomeSize = configuredSize;
        }
        int overallMax = Integer.MIN_VALUE;
        int overallMin = Integer.MAX_VALUE;
        for (int i = 0; i < this.genomeSize; i++) {
            final int min = template.getMin(i);
            final int max = template.getMax(i);
            state.parameters.set(base.push("min-gene").push("" + i), "" + min);
            state.parameters.set(base.push("max-gene").push("" + i), "" + max);
            overallMin = Math.min(min, overallMin);
            overallMax = Math.max(max, overallMin);
        }
        state.parameters.set(base.push("min-gene"), "" + overallMin);
        state.parameters.set(base.push("max-gene"), "" + overallMax);
        super.setup(state, base);
    }
}
