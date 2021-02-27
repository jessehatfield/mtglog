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
 * Furthermore, multiple entries on the same line will be consolidated into a
 * single entry representing all of them, with the understanding that the first
 * such entry must be filled before allocating the remaining quantity to the
 * next, and so on.
 *
 * Example:
 *     # Required
 *     4 A
 *     1-4 B
 *     # Optional
 *     C
 *     0-2 D
 *     # Sequential
 *     1-2 E > F > 0-2 G
 * will yield a template that accepts distributions over [A, B, C, D, E>F>G]
 * that range from [4, 1, 0, 0, 1] to [4, 4, 0, 2, 8] (such that for example
 * a value of 6 for the last entry results in 2 E plus 4 F).
 */
public class DeckTemplate implements Serializable {
    private static final long serialVersionUID = 1;

    public final static String SPLIT_STR = ">";
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
                        final String[] parts = line.split(SPLIT_STR);
                        Entry entry = null;
                        for (final String part : parts) {
                            String name = part.trim();
                            final Matcher rangeMatch = RANGE_PATTERN.matcher(name);
                            int minCount = 0;
                            int maxCount = DEFAULT_MAX_COUNT;
                            if (rangeMatch.matches()) {
                                minCount = Integer.parseInt(rangeMatch.group(1));
                                maxCount = Integer.parseInt(rangeMatch.group(2));
                                name = rangeMatch.group(3);
                            } else {
                                final Matcher exactMatch = EXACT_PATTERN.matcher(name);
                                if (exactMatch.matches()) {
                                    minCount = Integer.parseInt(exactMatch.group(1));
                                    maxCount = minCount;
                                    name = exactMatch.group(2);
                                }
                            }
                            distinct.putIfAbsent(name, newBlock);
                            if (entry == null) {
                                entry = new Entry(name, minCount, maxCount);
                            } else {
                                entry.add(name, minCount, maxCount);
                            }
                        }
                        entryLists.get(entryLists.size() - 1).add(entry);
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
        final int numMdCards = mdEntries.stream().map(Entry::getNumCards).reduce(0, Integer::sum);
        final int numSbCards = sbEntries.stream().map(Entry::getNumCards).reduce(0, Integer::sum);
        final String[] cards = new String[numMdCards + numSbCards];
        final int[] md = new int[numMdCards + numSbCards];
        final int[] sb = new int[numMdCards + numSbCards];
        int countIndex = 0;
        int cardIndex = 0;
        for (final Entry entry : mdEntries) {
            final int count = countIndex < counts.length ? counts[countIndex] : entry.getMinCount();
            for (int j = 0; j < entry.getNumCards(); j++) {
                cards[cardIndex] = entry.getName(j);
                md[cardIndex] = entry.getCardCount(count, cards[cardIndex]);
                sb[cardIndex] = 0;
                cardIndex++;
            }
            countIndex++;
        }
        for (final Entry entry : sbEntries) {
            final int count = countIndex < counts.length ? counts[countIndex] : entry.getMinCount();
            for (int j = 0; j < entry.getNumCards(); j++) {
                cards[cardIndex] = entry.getName(j);
                md[cardIndex] = 0;
                sb[cardIndex] = entry.getCardCount(count, cards[cardIndex]);
                cardIndex++;
            }
            countIndex++;
        }
        return new Deck(cards, md, sb);
    }

    /**
     * Convert an instantiation of the deck to a vector representation with one
     * entry per free parameter.
     * @param deck A valid decklist according to this template
     * @return A vector that would produce the same deck if passed to toDeck
     */
    public int[] toVector(final Deck deck) {
        final int[] counts = new int[numEntries];
        final Map<String, Integer> cardCounts = deck.getCounts();
        final List<Entry> mdEntries = segments.get(0).entries;
        int countIndex = 0;
        for (final Entry entry : mdEntries) {
            for (int j = 0; j < entry.getNumCards(); j++) {
                final String cardName = entry.getName(j);
                counts[countIndex] += cardCounts.getOrDefault(cardName, 0);
            }
            countIndex++;
        }
        return counts;
    }

    private static int addMin(final Collection<Entry> entries) {
        return entries.stream().map(e -> e.getMinCount()).reduce(0, Integer::sum);
    }

    private static int addMax(final Collection<Entry> entries) {
        return entries.stream().map(e -> e.getMaxCount()).reduce(0, Integer::sum);
    }

    public int getMin(int i) {
        return getEntry(i).getMinCount();
    }

    public int getMax(int i) {
        return getEntry(i).getMaxCount();
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
        private final List<String> names = new ArrayList<>();
        private final List<Integer> minCounts = new ArrayList<>();
        private final List<Integer> maxCounts = new ArrayList<>();
        Entry(final String name, final int minCount, final int maxCount) {
            this.names.add(name);
            this.minCounts.add(minCount);
            this.maxCounts.add(maxCount);
        }
        void add(final String name, final int minCount, final int maxCount) {
            this.names.add(name);
            this.minCounts.add(minCount);
            this.maxCounts.add(maxCount);
        }
        String getName() {
            return names.stream().reduce((s1, s2) -> s1 + ">" + s2).orElse("");
        }
        String getName(int index) {
            return names.get(index);
        }
        int getMinCount() {
            return minCounts.stream().reduce(0, Integer::sum);
        }
        int getMaxCount() {
            return maxCounts.stream().reduce(0, Integer::sum);
        }
        int getNumCards() {
            return names.size();
        }
        int getCardCount(final int totalCount, final String cardName) {
            int remainder = totalCount;
            for (int i = 0; i < names.size(); i++) {
                final int cardCount = Math.max(
                        Math.min(maxCounts.get(i), remainder),
                        minCounts.get(i));
                if (names.get(i).equals(cardName)) {
                    return cardCount;
                } else {
                    remainder -= cardCount;
                }
            }
            return 0;
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
