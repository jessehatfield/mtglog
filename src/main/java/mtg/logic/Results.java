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

    // Running totals for metadata fields
    private final Map<String, Integer> intMetadataSums = new HashMap<>();
    private final Map<String, Map<String, Integer>> stringMetadataCounts = new HashMap<>();
    private final Map<String, Integer> booleanMetadataCounts = new HashMap<>();

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
                    booleanMetadataCounts.put(key, value.isJTrue() ? 1 : 0);
                } else if (value.isInteger()) {
                    final List<Integer> list = new ArrayList<>();
                    list.add(value.intValue());
                    intMetadata.put(key, list);
                    intMetadataSums.put(key, value.intValue());
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
                        booleanMetadataCounts.put(key, "true".equals(str) ? 1 : 0);
                    } else {
                        final List<String> list = new ArrayList<>();
                        list.add(str);
                        stringMetadata.put(key, list);
                        stringMetadataCounts.put(key, new LinkedHashMap<>());
                        stringMetadataCounts.get(key).put(str, 1);
                    }
                }
            });
            intMetadata.put("nMulligans", Collections.singletonList(mulliganCount));
            intMetadata.put("nPowders", Collections.singletonList(powderCount));
            intMetadataSums.put("nMulligans", mulliganCount);
            intMetadataSums.put("nPowders", powderCount);
            booleanMetadata.put("mulligan", Collections.singletonList(mulliganCount > 0));
            booleanMetadata.put("powder", Collections.singletonList(powderCount > 0));
            booleanMetadataCounts.put("mulligan", mulliganCount > 0 ? 1 : 0);
            booleanMetadataCounts.put("powder", powderCount > 0 ? 1 : 0);
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
        add(other, true);
    }

    public void add(Results other, boolean maintainLists) {
        nTotal += other.nTotal;
        nSuccesses += other.nSuccesses;
        nFailures += other.nFailures;
        for (String key : other.intMetadataSums.keySet()) {
            int oldSum = intMetadataSums.getOrDefault(key, 0);
            intMetadataSums.put(key, other.intMetadataSums.get(key) + oldSum);
        }
        for (String key : other.stringMetadataCounts.keySet()) {
            if (!stringMetadataCounts.containsKey(key)) {
                stringMetadataCounts.put(key, new LinkedHashMap<>());
            }
            final Set<String> values = new HashSet<>(stringMetadataCounts.get(key).keySet());
            values.addAll(other.stringMetadataCounts.get(key).keySet());
            for (String value : values) {
                int oldCount = stringMetadataCounts.get(key).getOrDefault(value, 0);
                int newCount = other.stringMetadataCounts.get(key).getOrDefault(value, 0);
                stringMetadataCounts.get(key).put(value, oldCount + newCount);
            }
        }
        for (String key : other.booleanMetadataCounts.keySet()) {
            final int oldCount = booleanMetadataCounts.getOrDefault(key, 0);
            final int additional = other.booleanMetadataCounts.get(key);
            booleanMetadataCounts.put(key, oldCount + additional);
        }
        if (maintainLists) {
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
        } else {
            intMetadata.clear();
            listMetadata.clear();
            stringMetadata.clear();
            booleanMetadata.clear();
            durations.clear();
            mulliganCounts.clear();
            powderCounts.clear();
        }
    }

    public void multiply(int n) {
        if (n <= 0) {
            throw new IllegalArgumentException("Can only multiply results a positive number of times, received n=" + n);
        }
        nTotal *= n;
        nSuccesses *= n;
        nFailures *= n;
        intMetadata.replaceAll((k, v) -> repeat(v, n));
        listMetadata.replaceAll((k, v) -> repeat(v, n));
        stringMetadata.replaceAll((k, v) -> repeat(v, n));
        booleanMetadata.replaceAll((k, v) -> repeat(v, n));
        intMetadataSums.replaceAll((k, v) -> v * n);
        for (String key : stringMetadataCounts.keySet()) {
            stringMetadataCounts.get(key).replaceAll((k, v) -> v * n);
        }
        booleanMetadataCounts.replaceAll((k, v) -> v * n);
        success.addAll(repeat(success, n - 1));
        durations.addAll(repeat(durations, n - 1));
        mulliganCounts.addAll(repeat(mulliganCounts, n - 1));
        powderCounts.addAll(repeat(powderCounts, n - 1));
    }

    private <T> List<T> repeat(final List<T> list, final int n) {
        ArrayList<T> newList = new ArrayList<>(list.size() * n);
        for (int i = 0; i < n; i++) {
            newList.addAll(list);
        }
        return newList;
    }

    public int getNTotal() { return nTotal; }
    public int getNSuccesses() { return nSuccesses; }
    public int getNFailures() { return nFailures; }
    public int getNWithProperty(final String property) {
        if (getNSuccesses() == 0) {
            return 0;
        }
        if (!booleanMetadataCounts.containsKey(property)) {
            throw new IllegalArgumentException("Results don't contain boolean property '"
                    + property + "'. Boolean properties found: " + booleanMetadataCounts);
        }
        return booleanMetadataCounts.get(property);
    }

    public int getPropertySum(final String property) {
        if (getNSuccesses() == 0) {
            return 0;
        }
        if (!intMetadataSums.containsKey(property)) {
            throw new IllegalArgumentException("Results don't contain integer property '"
                    + property + "'. Integer properties found: " + intMetadataSums);
        }
        return intMetadataSums.get(property);
    }

    public Map<String, Integer> getValueDistribution(final String key) {
        if (!stringMetadataCounts.containsKey(key)) {
            throw new IllegalArgumentException("Results don't contain string property '"
                    + key + "'. String properties found: " + stringMetadataCounts);
        }
        return stringMetadataCounts.get(key);
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
