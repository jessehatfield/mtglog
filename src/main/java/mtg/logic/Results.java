package mtg.logic;

import org.jpl7.Term;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Contains the results of one or more experiment on a simulated hand.
 */
public class Results {
    private int nTotal = 0;
    private int nSuccesses = 0;
    private int nFailures = 0;

    // Fields that only apply for successes
    private final Map<String, List<Integer>> intMetadata = new HashMap<>();
    private final Map<String, List<List<String>>> listMetadata = new HashMap<>();
    private final Map<String, List<String>> stringMetadata = new HashMap<>();
    private final Map<String, List<Boolean>> booleanMetadata = new HashMap<>();

    // Fields that apply for every simulation
    private final List<Boolean> success = new ArrayList<>();
    private final List<Long> durations = new ArrayList<>();
    private final List<Integer> mulliganCounts = new ArrayList<>();
    private final List<Integer> powderCounts = new ArrayList<>();

    public Results() { }

    public Results(Map<String, Term> prologMetadata, long duration, int mulliganCount) {
        this(prologMetadata, duration, mulliganCount, 0);
    }

    public Results(Map<String, Term> prologMetadata, long duration, int mulliganCount, int powderCount) {
        this.nTotal = 1;
        success.add(prologMetadata != null);
        durations.add(duration);
        mulliganCounts.add(mulliganCount);
        powderCounts.add(powderCount);
        if (prologMetadata == null) {
            this.nSuccesses = 0;
            this.nFailures = 1;
        } else {
            this.nSuccesses = 1;
            this.nFailures = 0;
            prologMetadata.forEach((key, value) -> {
                if (value.isJTrue() || value.isJFalse()) {
                    final List<Boolean> list = new ArrayList<>();
                    list.add(value.isJTrue());
                    booleanMetadata.put(key, list);
                } else if (value.isInteger()) {
                    final List<Integer> list = new ArrayList<>();
                    list.add(value.intValue());
                    intMetadata.put(key, list);
                } else if (value.isList()) {
                    final Term[] terms = value.listToTermArray();
                    final List<List<String>> lists = new ArrayList<>();
                    lists.add(new ArrayList<>());
                    for (final Term term : terms) {
                        lists.get(0).add(term.toString());
                    }
                    listMetadata.put(key, lists);
                } else {
                    final String str = value.toString();
                    if ("true".equals(str) || "false".equals(str)) {
                        final List<Boolean> list = new ArrayList<>();
                        list.add("true".equals(str));
                        booleanMetadata.put(key, list);
                    } else {
                        final List<String> list = new ArrayList<>();
                        list.add(str);
                        stringMetadata.put(key, list);
                    }
                }
            });
            intMetadata.put("nMulligans", Collections.singletonList(mulliganCount));
            intMetadata.put("nPowders", Collections.singletonList(powderCount));
            booleanMetadata.put("mulligan", Collections.singletonList(mulliganCount > 0));
            booleanMetadata.put("powder", Collections.singletonList(powderCount > 0));
        }
    }

    public String toString() {
        return "Results{"
                + "nTotal=" + nTotal + ";"
                + "nSuccesses=" + nSuccesses + ";"
                + "nFailures=" + nFailures + ";"
                + "metadata=" + intMetadata
                + "," + stringMetadata
                + "," + listMetadata
                + "," + booleanMetadata + ";"
                + "durations=" + durations + ";"
                + "mulliganCounts=" + mulliganCounts + ";"
                + "powderCounts=" + powderCounts + "}";
    }

    public void add(Results other) {
        nTotal += other.nTotal;
        nSuccesses += other.nSuccesses;
        nFailures += other.nFailures;
        for (String key : other.intMetadata.keySet()) {
            final List<Integer> mergedList = intMetadata.getOrDefault(key, new ArrayList<>());
            mergedList.addAll(other.intMetadata.get(key));
            intMetadata.put(key, mergedList);
        }
        for (String key : other.stringMetadata.keySet()) {
            final List<String> mergedList = stringMetadata.getOrDefault(key, new ArrayList<>());
            mergedList.addAll(other.stringMetadata.get(key));
            stringMetadata.put(key, mergedList);
        }
        for (String key : other.listMetadata.keySet()) {
            final List<List<String>> mergedList = listMetadata.getOrDefault(key, new ArrayList<>());
            mergedList.addAll(other.listMetadata.get(key));
            listMetadata.put(key, mergedList);
        }
        for (String key : other.booleanMetadata.keySet()) {
            final List<Boolean> mergedList = booleanMetadata.getOrDefault(key, new ArrayList<>());
            mergedList.addAll(other.booleanMetadata.get(key));
            booleanMetadata.put(key, mergedList);
        }
        durations.addAll(other.durations);
        mulliganCounts.addAll(other.mulliganCounts);
        powderCounts.addAll(other.powderCounts);
    }

    public int getNTotal() { return nTotal; }
    public int getNSuccesses() { return nSuccesses; }
    public int getNFailures() { return nFailures; }
    public int getNWithProperty(final String property) {
        if (getNSuccesses() == 0) {
            return 0;
        }
        if (!booleanMetadata.containsKey(property)) {
            throw new IllegalArgumentException("Results don't contain boolean property '"
                    + property + "'. Boolean properties found: " + booleanMetadata);
        }
        return (int) booleanMetadata.get(property).stream().filter(b -> b).count();
    }

    public int getPropertySum(final String property) {
        if (getNSuccesses() == 0) {
            return 0;
        }
        if (!intMetadata.containsKey(property)) {
            throw new IllegalArgumentException("Results don't contain integer property '"
                    + property + "'. Integer properties found: " + intMetadata);
        }
        return intMetadata.get(property).stream().reduce(Integer::sum).orElse(0);
    }

    public Map<String, Integer> getValueDistribution(final String key) {
        final Map<String, Integer> distribution = new LinkedHashMap<>();
        if (!stringMetadata.containsKey(key)) {
            throw new IllegalArgumentException("Results don't contain string property '"
                    + key + "'. String properties found: " + stringMetadata);
        }
        for (final String value : stringMetadata.get(key)) {
            distribution.put(value, distribution.getOrDefault(value, 0) + 1);
        }
        return distribution;
    }

    public Map<String, Integer> getIntMetadata(final int i) {
        return intMetadata.entrySet().stream().collect(Collectors.toMap(
                Map.Entry::getKey, e -> e.getValue().get(i)));
    }
    public Map<String, List<String>> getListMetadata(final int i) {
        return listMetadata.entrySet().stream().collect(Collectors.toMap(
                Map.Entry::getKey, e -> e.getValue().get(i)));
    }
    public Map<String, String> getStringMetadata(final int i) {
        return stringMetadata.entrySet().stream().collect(Collectors.toMap(
                Map.Entry::getKey, e -> e.getValue().get(i)));
    }
    public Map<String, Boolean> getBooleanMetadata(final int i) {
        return booleanMetadata.entrySet().stream().collect(Collectors.toMap(
                Map.Entry::getKey, e -> e.getValue().get(i)));
    }

    public List<Integer> getIntMetadata(final String key) {
        return intMetadata.getOrDefault(key, Collections.emptyList());
    }
    public List<List<String>> getListMetadata(final String key) {
        return listMetadata.getOrDefault(key, Collections.emptyList());
    }
    public List<String> getStringMetadata(final String key) {
        return stringMetadata.getOrDefault(key, Collections.emptyList());
    }
    public List<Boolean> getBooleanMetadata(final String key) {
        return booleanMetadata.getOrDefault(key, Collections.emptyList());
    }

    public List<Long> getDurations() { return durations; }

    public long getDuration(final int i) {
        return durations.get(i);
    }

    public List<Integer> getMulliganCounts() { return mulliganCounts; }

    public List<Integer> getPowderCounts() { return powderCounts; }

    public int getMulliganCounts(final int i) {
        return mulliganCounts.get(i);
    }

    public int getPowderCounts(final int i) {
        return powderCounts.get(i);
    }

    public boolean isSuccess(final int i) {
        return success.get(i);
    }

    public double getPSuccess() {
        return ((double) getNSuccesses()) / nTotal;
    }

    public double getP(final String booleanVar) {
        return ((double) getNWithProperty(booleanVar)) / nTotal;
    }

    public double getStdDevSuccesses() {
        final double p = getPSuccess();
        return Math.sqrt(nTotal * p * (1 - p));
    }

    public double getStdDev(final String booleanVar) {
        final double p = getP(booleanVar);
        return Math.sqrt(nTotal * p * (1 - p));
    }
}
