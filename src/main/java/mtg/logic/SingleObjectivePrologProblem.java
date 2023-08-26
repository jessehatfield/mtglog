package mtg.logic;

import org.yaml.snakeyaml.Yaml;
import org.yaml.snakeyaml.constructor.Constructor;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Defines a hand evaluation problem and how to invoke its Prolog implementation.
 *
 * Implementation should be a single predicate of arity 6:
 *     - hand (as a list),
 *     - remaining library (in order, as a list)
 *     - sideboard (as a list)
 *     - number of cards to put back (i.e. mulligans being resolved)
 *     - additional parameters (Dict of problem-specific parameters)
 *     - outputs (Dict of problem-specific details about the solution)
 *
 * This specification should provide the list of Prolog source files needed,
 * the name of the evaluation predicate, any required default parameters,
 * the max number of mulligans, and any expected outputs, divided into
 * categories based on how they should be reported (count, etc).
 */
public class SingleObjectivePrologProblem implements Serializable, PrologProblem {
    private static final long serialVersionUID = 1;

    private String name;
    private String predicate;
    private String serumPowderPredicate;
    private List<String> sources;
    private int maxMulligans;
    private int startingMulligans = 0;
    private Map<String, Object> params;
    private Map<String, List<String>> outputs;
    private String filter;

    @Override
    public String getName() {
        return name;
    }

    public void setName(final String name) {
        this.name = name;
    }

    public String getPredicate() {
        return predicate;
    }

    public String getSerumPowderPredicate() {
        return serumPowderPredicate;
    }

    public void setPredicate(final String predicate) {
        this.predicate = predicate;
    }

    public void setSerumPowderPredicate(final String serumPowderPredicate) {
        this.serumPowderPredicate = serumPowderPredicate;
    }

    @Override
    public List<SingleObjectivePrologProblem> getObjectives() {
        return Collections.singletonList(this);
    }

    @Override
    public List<String> getSources() {
        return sources;
    }

    public void setSources(final List<String> sources) {
        this.sources = sources;
    }

    public int getMaxMulligans() {
        return maxMulligans;
    }

    public void setMaxMulligans(final int maxMulligans) {
        this.maxMulligans = maxMulligans;
    }

    public int getStartingMulligans() {
        return startingMulligans;
    }

    public void setStartingMulligans(final int startingMulligans) {
        this.startingMulligans = startingMulligans;
    }

    public Map<String, Object> getParams() {
        return params;
    }

    public void setParams(final Map<String, Object> params) {
        this.params = params;
    }

    public Map<String, List<String>> getOutputs() {
        return outputs;
    }

    public void setOutputs(final Map<String, List<String>> outputs) {
        this.outputs = outputs;
    }

    public int getHandSize() {
        return 7;
    }

    public List<String> getBooleanOutputs() {
        return outputs.getOrDefault("boolean", Collections.emptyList());
    }

    /**
     * @return The name of a boolean property that needs to be true for a full
     *         success, or null if there is no such requirement
     */
    public String getFilter() {
        return filter;
    }

    /**
     * Set an output property that needs to be true for a full success
     * @param filter The name of an expected boolean property
     */
    public void setFilter(final String filter) {
        this.filter = filter;
    }

    /**
     * Serialize a problem specification as a YAML file.
     * @return a string specification of the problem.
     */
    public String toYaml() {
        final Yaml yaml = new Yaml(new Constructor(SingleObjectivePrologProblem.class));
        return yaml.dump(this);
    }

    /**
     * Load a problem specification defined as a YAML file.
     *
     * Expects properties:
     *   name (String)
     *   sources (list of strings): prolog files to load
     *   predicate (string): name of prolog predicate to test hands
     *   max_mulligans (int): number of times to mulligan failed hands before declaring complete failure for that trial
     *   params (map): additional parameters required for the given predicate
     * Optional properties:
     *   serumPowderPredicate (string): name of prolog predicate to check whether a hand can safely Serum Powder
     *   filter (string): name of boolean output property that, if false, indicates a result should be treated as a
     *                    failure, i.e. allows a success criterion that isn't considered during mulligans
     * @param filename Name of YAML file specifying the problem
     * @return The corresponding hand evaluation problem specification
     */
    public static SingleObjectivePrologProblem fromYaml(final String filename) throws IOException {
        Objects.requireNonNull(filename);
        try (final InputStream is = new FileInputStream(filename)) {
            return fromYaml(is);
        }
    }

    /**
     * Load a problem specification defined as a YAML file.
     *
     * Expects properties:
     *   name (String)
     *   sources (list of strings): prolog files to load
     *   predicate (string): name of prolog predicate to test hands
     *   max_mulligans (int): number of times to mulligan failed hands before declaring complete failure for that trial
     *   params (map): additional parameters required for the given predicate
     * Optional properties:
     *   serumPowderPredicate (string): name of prolog predicate to check whether a hand can safely Serum Powder
     *   filter (string): name of boolean output property that, if false, indicates a result should be treated as a
     *                    failure, i.e. allows a success criterion that isn't considered during mulligans
     * @param is Input stream for reading the YAML specification of the problem
     * @return The corresponding hand evaluation problem specification
     */
    public static SingleObjectivePrologProblem fromYaml(final InputStream is) {
        Objects.requireNonNull(is);
        final Yaml yaml = new Yaml(new Constructor(SingleObjectivePrologProblem.class));
        SingleObjectivePrologProblem spec = yaml.load(is);
        return spec;
    }
}
