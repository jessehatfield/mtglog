package mtg.logic;

import mtg.logic.util.CheckedSupplier;
import org.yaml.snakeyaml.error.YAMLException;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Collection;
import java.util.List;
import java.util.Objects;

public interface PrologProblem {
    List<SingleObjectivePrologProblem> getObjectives();

    Collection<String> getSources();

    String getName();

    /**
     * Load a problem specification defined as a YAML file. See implementations for valid file
     * formats.
     * @param filename Name of YAML file specifying the problem
     * @return The corresponding hand evaluation problem specification
     * @throws IOException
     */
    static PrologProblem fromYaml(final String filename) throws IOException {
        Objects.requireNonNull(filename);
        return fromYaml(() -> new FileInputStream(filename));
    }

    /**
     * Load a problem specification defined as a YAML file. See implementations for valid file
     * formats.
     * @param getStream Function to invoke to construct an input stream to read the YAML (may be
     *                  reused to attempt reading different formats)
     * @return The corresponding hand evaluation problem specification
     * @throws IOException
     */
    static PrologProblem fromYaml(final CheckedSupplier<InputStream, IOException> getStream)
            throws IOException {
        try {
            try (final InputStream is = getStream.get()) {
                return MultiObjectivePrologProblem.fromYaml(is);
            }
        } catch (YAMLException e) {
            try (final InputStream is = getStream.get()) {
                return SingleObjectivePrologProblem.fromYaml(is);
            }
        }
    }
}
