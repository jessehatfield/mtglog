package mtg.logic;

import org.jpl7.Term;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Results {
    int nTotal = 0;
    int nSuccesses = 0;
    int nFailures = 0;
    Map<String, List<Integer>> intMetadata = new HashMap<>();
    Map<String, List<List<String>>> listMetadata = new HashMap<>();
    Map<String, List<String>> stringMetadata = new HashMap<>();

    public Results() { }

    public Results(Map<String, Term> prologMetadata) {
        this.nTotal = 1;
        if (prologMetadata == null) {
            this.nSuccesses = 0;
            this.nFailures = 1;
        } else {
            this.nSuccesses = 1;
            this.nFailures = 0;
            prologMetadata.forEach((key, value) -> {
                if (value.isInteger()) {
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
                    final List<String> list = new ArrayList<>();
                    list.add(value.toString());
                    stringMetadata.put(key, list);
                }
            });
        }
    }

    public String toString() {
        final StringBuilder sb = new StringBuilder("Results{");
        sb.append("nTotal=").append(nTotal).append(";");
        sb.append("nSuccesses=").append(nSuccesses).append(";");
        sb.append("nFailures=").append(nFailures).append(";");
        sb.append("metadata=").append(intMetadata)
                .append(",").append(stringMetadata)
                .append(",").append(listMetadata);
        sb.append("}");
        return sb.toString();
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
    }
}
