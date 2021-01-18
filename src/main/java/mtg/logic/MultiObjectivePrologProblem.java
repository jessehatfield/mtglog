package mtg.logic;

import org.yaml.snakeyaml.TypeDescription;
import org.yaml.snakeyaml.Yaml;
import org.yaml.snakeyaml.constructor.Constructor;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * Defines a single hand evaluation problem with multiple objectives.
 *
 * This specification should provide the list of Prolog source files needed,
 * and for each objective: the name of the evaluation predicate, any required
 * default parameters, the max number of mulligans, and any expected outputs,
 * divided into categories based on how they should be reported (count, etc).
 */
public class MultiObjectivePrologProblem implements Serializable, PrologProblem {
    private static final long serialVersionUID = 1;

    private String name;
    private List<SingleObjectivePrologProblem> objectives;
    private List<String> sources;

    @Override
    public String getName() {
        return name;
    }

    public void setName(final String name) {
        this.name = name;
    }

    @Override
    public List<SingleObjectivePrologProblem> getObjectives() {
        return objectives;
    }

    public void setObjectives(final List<SingleObjectivePrologProblem> objectives) {
        this.objectives = objectives;
        if (sources == null) {
            sources = new ArrayList<>();
        }
        for (final SingleObjectivePrologProblem objective : objectives) {
            for (final String source : objective.getSources()) {
                if (sources.contains(source)) {
                    sources.add(source);
                }
            }
        }
    }

    public void setSources(final List<String> sources) {
        this.sources = sources;
    }

    @Override
    public List<String> getSources() {
        return sources;
    }

    /**
     * Load a multi-objective problem specification defined as a YAML file.
     *
     * Expects properties:
     *   name (String)
     *   sources (list of strings): prolog files to load
     *   objectives (list of {@link SingleObjectivePrologProblem} specifications): objectives to test
     * @param filename Name of YAML file specifying the problem
     * @return The corresponding multi-objective problem specification
     */
    public static MultiObjectivePrologProblem fromYaml(final String filename) throws IOException {
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
     *   objectives (list of {@link SingleObjectivePrologProblem} specifications): objectives to test
     * @param is Input stream for reading the YAML specification of the problem
     * @return The corresponding multi-objective problem specification
     */
    public static MultiObjectivePrologProblem fromYaml(final InputStream is) {
        Objects.requireNonNull(is);
        final Constructor constructor = new Constructor(MultiObjectivePrologProblem.class);
        final TypeDescription objectiveDescription = new TypeDescription(MultiObjectivePrologProblem.class);
        objectiveDescription.putListPropertyType("objectives", SingleObjectivePrologProblem.class);
        constructor.addTypeDescription(objectiveDescription);
        final Yaml yaml = new Yaml(constructor);
        MultiObjectivePrologProblem spec = yaml.load(is);
        return spec;
    }
}
