package mtg.logic;

import java.io.Serializable;

public class SecondaryObjective implements Serializable {
    private static final long serialVersionUID = 1;

    private String name;
    private String objective;
    private String filter;

    public String getName() {
                          return name;
                                      }

    public void setName(final String name) {
        this.name = name;
    }

    /**
     * @return The name of the main objective that this one builds on
     */
    public String getObjective() {
        return objective;
    }

    /**
     * @param objective The name of the main objective that this one builds on
     */
    public void setObjective(final String objective) {
        this.objective = objective;
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
}
