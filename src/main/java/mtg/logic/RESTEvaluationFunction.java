package mtg.logic;

import mtg.logic.util.CheckedSupplier;
import org.yaml.snakeyaml.TypeDescription;
import org.yaml.snakeyaml.Yaml;
import org.yaml.snakeyaml.constructor.Constructor;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

/**
 * Defines an evaluation function that entails sending a decklist to a REST service and parsing the result.
 */
public class RESTEvaluationFunction {
    /**
     * A numeric property returned by the REST call that can be used as a fitness (or cost).
     */
    public static class Objective {
        private String name;
        private String path;
        private boolean minimize = false;

        /**
         * @return a human-readable identifier for this objective
         */
        public String getName() {
            return name;
        }

        /**
         * @param name a human-readable identifier for this objective
         */
        public void setName(final String name) {
            this.name = name;
        }

        /**
         * @return a JSONPath expression to extract this objective's value from the data returned from the REST call
         */
        public String getPath() {
            return path;
        }

        /**
         * @param path a JSONPath expression to extract this objective's value from the data returned from the REST call
         */
        public void setPath(final String path) {
            this.path = path;
        }

        /**
         * @return whether this is a cost to be minimized, rather than a fitness to be maximized
         */
        public boolean isMinimize() {
            return minimize;
        }

        /**
         * @param minimize whether this is a cost to be minimized, rather than a fitness to be maximized
         */
        public void setMinimize(final boolean minimize) {
            this.minimize = minimize;
        }
    }

    private String name;
    private String url;
    private List<Objective> objectives;

    /**
     * @return a human-readable name for this function
     */
    public String getName() {
        return name;
    }

    /**
     * @param name a human-readable name for this function
     */
    public void setName(final String name) {
        this.name = name;
    }

    /**
     * @return the URL to post data to to invoke the function
     */
    public String getUrl() {
        return url;
    }

    /**
     * @param url the URL to post data to to invoke the function
     */
    public void setUrl(final String url) {
        this.url = url;
    }

    /**
     * @return the list of fitness/cost values the function returns (should be at least one)
     */
    public List<Objective> getObjectives() {
        return Collections.unmodifiableList(objectives);
    }

    /**
     * @param objectives the list of fitness/cost values the function returns (should be at least one)
     */
    public void setObjectives(final List<Objective> objectives) {
        this.objectives = objectives;
    }

    /**
     * Load a problem specification defined as a YAML file.
     * @param filename Name of YAML file specifying the problem
     * @return The corresponding deck evaluation problem specification
     * @throws IOException if problems are encountered reading or parsing the file
     */
    public static RESTEvaluationFunction fromYaml(final String filename) throws IOException {
        Objects.requireNonNull(filename);
        return fromYaml(() -> new FileInputStream(filename));
    }

    /**
     * Load a problem specification defined as a YAML file.
     *
     * Expects properties:
     *   name: String
     *   url: String
     *   objectives: one or more fitness targets, themselves including:
     *      "name" (human-readable identifier),
     *      "path" (JSON path expression to locate them in the REST response),
     *      and optional property "minimize" (default false) if it is a cost instead of a fitness
     * @param getStream Input stream for reading the YAML specification of the problem
     * @return The corresponding deck evaluation problem specification
     */
    public static RESTEvaluationFunction fromYaml(final CheckedSupplier<InputStream, IOException> getStream)
            throws IOException {
        final Constructor constructor = new Constructor(RESTEvaluationFunction.class);
        final TypeDescription objectiveDescription = new TypeDescription(RESTEvaluationFunction.class);
        objectiveDescription.putListPropertyType("objectives", Objective.class);
        constructor.addTypeDescription(objectiveDescription);
        final Yaml yaml = new Yaml(constructor);
        try (final InputStream is = getStream.get()) {
            return yaml.load(is);
        }
    }
}
