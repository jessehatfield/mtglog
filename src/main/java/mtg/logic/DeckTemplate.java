package mtg.logic;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Defines a template for a specific deck with some room for variation between
 * lists.
 *
 * Input files should resemble those understood by {@link Deck} except
 * that counts can be an inclusive range instead of a number, or can be omitted
 * entirely to range from the default minimum (typically 0) to the default
 * maximum (typically 4).
 *
 * Example:
 *     # Required
 *     4 A
 *     1-4 B
 *     # Optional
 *     C
 *     0-2 D
 * will yield a template that accepts distributions over [A, B, C, D] that range
 * from [4, 1, 0, 0] to [4, 4, 0, 2]
 */
public class DeckTemplate implements Serializable {
    private static final long serialVersionUID = 1;

    public final static Pattern RANGE_PATTERN = Pattern.compile(
            "^([0-9])+[xX]?\\s*-\\s*([0-9]+)[xX]?\\s+(.*)$");
    public final static Pattern EXACT_PATTERN = Pattern.compile("^([0-9])+[xX]?\\s+(.*)$");
    public final static Pattern SIDEBOARD_PATTERN = Pattern.compile(
            "^(/+\\s*)?sideboard$", Pattern.CASE_INSENSITIVE);
    public final static Pattern COMMENT_PATTERN = Pattern.compile("^(.*)(#|%|//).*$");

    public final static int DEFAULT_MAX_COUNT = 4;

    private final List<Segment> segments = new ArrayList<>();

    private final Map<String, Boolean> distinct = new LinkedHashMap<>();

    private final int numEntries;

    /**
     * Instantiate a template from a file.
     * @param filename Path to the template file
     */
    public DeckTemplate(final String filename) throws IOException {
        this(new FileReader(filename));
    }

    /**
     * Instantiate a template from an input stream.
     * @param in Input stream that will provide the template specification
     */
    public DeckTemplate(final InputStream in) throws IOException {
        this(new InputStreamReader(in));
    }

    /**
     * Instantiate a template from a Reader.
     * @param reader Reader that will provide the template specification
     */
    public DeckTemplate(final Reader reader) throws IOException {
        final List<List<Entry>> entryLists = new ArrayList<>();
        entryLists.add(new ArrayList<>());
        try (final BufferedReader in = new BufferedReader(reader)) {
            String line = in.readLine();
            boolean newBlock = false;
            while (line != null) {
                line = line.trim();
                // If line demarcates the sideboard, switch over to the next segment
                if (SIDEBOARD_PATTERN.matcher(line).matches()) {
                    entryLists.add(new ArrayList<>());
                } else {
                    final Matcher commentMatch = COMMENT_PATTERN.matcher(line);
                    if (commentMatch.matches()) {
                        // Remove trailing comments
                        line = commentMatch.group(1).trim();
                    }
                    // Skip whitespace or lines starting with '#' or '//'
                    // Three forms of entry are valid:
                    // <min>[x]-<max>[x] <name>
                    // <number>[x] <name>
                    // <name>
                    if (line.isEmpty()) {
                        // Comments or whitespace indicate new block, except for first card
                        newBlock = !distinct.isEmpty();
                    } else {
                        final Matcher rangeMatch = RANGE_PATTERN.matcher(line);
                        int minCount = 0;
                        int maxCount = DEFAULT_MAX_COUNT;
                        String name = line;
                        if (rangeMatch.matches()) {
                            minCount = Integer.parseInt(rangeMatch.group(1));
                            maxCount = Integer.parseInt(rangeMatch.group(2));
                            name = rangeMatch.group(3);
                        } else {
                            final Matcher exactMatch = EXACT_PATTERN.matcher(line);
                            if (exactMatch.matches()) {
                                minCount = Integer.parseInt(exactMatch.group(1));
                                maxCount = minCount;
                                name = exactMatch.group(2);
                            }
                        }
                        entryLists.get(entryLists.size() - 1).add(new Entry(name, minCount, maxCount));
                        distinct.putIfAbsent(name, newBlock);
                        newBlock = false;
                    }
                }
                line = in.readLine();
            }
        }
        final int numSegments = entryLists.size();
        if (numSegments < 1 || numSegments > 2) {
            throw new IOException("Error reading template: " + numSegments + " distinct segments");
        } else {
            segments.add(new Segment(entryLists.get(0), 60, 60));
            if (numSegments > 1) {
                segments.add(new Segment(entryLists.get(1), 15, 15));
            }
        }
        this.numEntries = segments.stream().map(s -> s.entries.size()).reduce(0, Integer::sum);
    }

    public int getNumEntries() {
        return numEntries;
    }

    public String[] getDistinctItems() {
        return distinct.keySet().toArray(new String[]{});
    }

    /**
     * Converts an integer vector to a Deck according to the template.
     * @param counts An ordered list of counts for all cards, maindeck followed by sideboard
     * @return a new Deck instance with the appropriate contents
     */
    public Deck toDeck(final int[] counts) {
        if (counts.length > numEntries) {
            System.err.println("Warning: received " + counts.length +
                    " numbers, but only uses the first " + numEntries);
        } else if (counts.length < numEntries) {
            System.err.println("Warning: received " + counts.length + " numbers, but expected " +
                    numEntries + "; setting remaining counts to their minimum values");
        }
        if (segments.isEmpty()) {
            return new Deck(new String[0], new int[0]);
        }
        final List<Entry> mdEntries = segments.get(0).entries;
        final List<Entry> sbEntries = segments.size() > 1 ? segments.get(1).entries : Collections.emptyList();
        final String[] cards = new String[mdEntries.size() + sbEntries.size()];
        final int[] md = new int[mdEntries.size() + sbEntries.size()];
        final int[] sb = new int[mdEntries.size() + sbEntries.size()];
        int i = 0;
        for (final Entry entry : mdEntries) {
            cards[i] = entry.name;
            md[i] = i < counts.length ? counts[i] : entry.minCount;
            sb[i] = 0;
            i++;
        }
        for (final Entry entry : sbEntries) {
            cards[i] = entry.name;
            md[i] = 0;
            sb[i] = i < counts.length ? counts[i] : entry.minCount;
            i++;
        }
        return new Deck(cards, md, sb);
    }

    private static int addMin(final Collection<Entry> entries) {
        return entries.stream().map(e -> e.minCount).reduce(0, Integer::sum);
    }

    private static int addMax(final Collection<Entry> entries) {
        return entries.stream().map(e -> e.maxCount).reduce(0, Integer::sum);
    }

    public int getMin(int i) {
        return getEntry(i).minCount;
    }

    public int getMax(int i) {
        return getEntry(i).maxCount;
    }

    private Entry getEntry(int i) {
        int remainder = i;
        for (final Segment segment : segments) {
            if (remainder < segment.entries.size()) {
                return segment.entries.get(remainder);
            } else {
                remainder -= segment.entries.size();
            }
        }
        throw new IndexOutOfBoundsException("Template only defines " + getNumEntries()
                + " total entries; index " + i + " out of bounds");
    }

    static class Segment implements Serializable {
        private static final long serialVersionUID = 1;
        final List<Entry> entries;
        final int minTotal;
        final int maxTotal;
        Segment(final List<Entry> entries, final int minTotal, final int maxTotal) {
            this.entries = entries;
            this.minTotal = Math.max(minTotal, addMin(entries));
            this.maxTotal = Math.min(maxTotal, addMax(entries));
        }
    }

    static class Entry implements Serializable {
        private static final long serialVersionUID = 1;
        final String name;
        final int minCount;
        final int maxCount;
        Entry(final String name, final int minCount, final int maxCount) {
            this.name = name;
            this.minCount = minCount;
            this.maxCount = maxCount;
        }
    }

    public static void main(final String[] args) throws IOException {
        if (args.length < 1) {
            System.out.println("Usage: DeckTemplate <template file> <vector of length <= distinct cards>");
            System.exit(1);
        }
        final String filename = args[0];
        final DeckTemplate template = new DeckTemplate(filename);
        final int maxCards = template.getNumEntries();
        if (args.length > maxCards + 1) {
            System.out.println("Usage: DeckTemplate <template file> <vector of length <= " + maxCards + ">");
            System.exit(1);
        }
        final int[] vector = new int[args.length - 1];
        for (int i = 0; i < vector.length; i++) {
            vector[i] = Integer.parseInt(args[i+1]);
        }
        final Deck deck = template.toDeck(vector);
        System.out.println(template.toString(deck));
    }

    public String toString(final Deck deck) {
        final StringBuilder sb = new StringBuilder();
        final Map<String, Integer> counts = deck.getCounts();
        boolean newBlock = false;
        for (String card : getDistinctItems()) {
            newBlock = newBlock || distinct.get(card);
            final int n = counts.getOrDefault(card, 0);
            if (n > 0) {
                if (newBlock) {
                    sb.append("\n");
                }
                sb.append(n + " " + card + "\n");
                newBlock = false;
            }
        }
        return sb.toString();
    }
}
