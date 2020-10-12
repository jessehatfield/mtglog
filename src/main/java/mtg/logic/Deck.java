package mtg.logic;

import ec.util.MersenneTwisterFast;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.*;

public class Deck {
    private final List<String> maindeck = new ArrayList<String>();
    private final List<String> sideboard = new ArrayList<String>();
    private final int minSize;

    public Deck(String[] cards, int[] counts, int[] sb, int minSize) {
        this.minSize = minSize;
        for (int i = 0; i < counts.length; i++) {
            for (int j = 0; j < counts[i]; j++) {
                maindeck.add(cards[i]);
            }
            for (int j = 0; j < sb[i]; j++) {
                sideboard.add(cards[i]);
            }
        }
        int nUnknown = minSize - maindeck.size();
        for (int i = 0; i < nUnknown; i++) {
            maindeck.add("Unknown");
        }
    }

    public Deck(String[] cards, int[] counts, int[] sb) {
        this(cards, counts, sb, 60);
    }

    public Deck(String[] cards, int[] counts, int minSize) {
        this(cards, counts, new int[] {}, minSize);
    }

    public Deck(String[] cards, int[] counts) {
        this(cards, counts, new int[] {});
    }

    public int getSize() {
        return maindeck.size();
    }

    public int getMinSize() {
        return minSize;
    }

    public int numMain() {
        return maindeck.size();
    }

    public int numSide() {
        return sideboard.size();
    }

    public String[][] drawHand(MersenneTwisterFast rng, int n) {
        //shuffle
        for (int j = maindeck.size()-1; j > 0; j--) {
            int k = rng.nextInt(j+1);
            String temp = maindeck.get(k);
            maindeck.set(k, maindeck.get(j));
            maindeck.set(j, temp);
        }
        //draw hand
        String[] hand = new String[n];
        String[] library = new String[minSize-n];
        maindeck.subList(0, n).toArray(hand);
        maindeck.subList(n, minSize).toArray(library);
        String[][] parts = { hand, library };
        return parts;
    }

    public String[] getShuffled(MersenneTwisterFast rng) {
        String[] library = new String[maindeck.size()];
        maindeck.toArray(library);
        for (int j = library.length-1; j > 0; j--) {
            int k = rng.nextInt(j+1);
            String temp = library[k];
            library[k] = library[j];
            library[j] = temp;
        }
        return library;
    }

    public String[] getSideboard() {
        String[] side = new String[sideboard.size()];
        sideboard.toArray(side);
        return side;
    }

    public Map<String, Integer> getCounts() {
        Map<String, Integer> counts = new HashMap<>();
        for (String card : maindeck) {
            counts.put(card, counts.getOrDefault(card, 0) + 1);
        }
        return counts;
    }

    public String[] list() {
        return maindeck.toArray(new String[] {});
    }

    public static Deck fromFile(String[] cards, String filename) {
        Map<String, Integer> contents = new HashMap<String, Integer>();
        Map<String, Integer> sideboard = new HashMap<String, Integer>();
        Map<String, Integer> currentMap = contents;
        try {
            BufferedReader in = new BufferedReader(new FileReader(filename));
            String line = in.readLine();
            while (line != null) {
                line = line.trim(); 
                if (!line.startsWith("#")) {
                    String[] parts = line.split(" ", 2);
                    if (parts.length > 1) {
                        String countString = parts[0].trim();
                        String name = parts[1].trim().toLowerCase();
                        if (countString.endsWith("x")) {
                            countString = countString.substring(0, countString.length() - 1);
                        }
                        int count = Integer.parseInt(countString);
                        currentMap.put(name, count);
                    }
                    else if (parts[0].trim().toLowerCase().equals("sideboard")) {
                        currentMap = sideboard;
                    }
                }
                line = in.readLine();
            }
            in.close();
            int[] counts = new int[cards.length];
            int[] sb = new int[cards.length];
            int total = 0;
            for (int i = 0; i < cards.length; i++) {
                String lower = cards[i].toLowerCase();
                if (contents.containsKey(lower)) {
                    int num = contents.get(lower);
                    counts[i] = num;
                    contents.remove(lower);
                }
                else {
                    counts[i] = 0;
                }
                if (sideboard.containsKey(lower)) {
                    int num = sideboard.get(lower);
                    sb[i] = num;
                    sideboard.remove(lower);
                }
            }
            Deck d = new Deck(cards, counts, sb);
            System.out.println(d.numMain() + " cards (SB: " + d.numSide() + ")");
            for (String name : contents.keySet()) {
                System.out.println("Doesn't know how to use " + contents.get(name) + " " + name);
            }
            for (String name : sideboard.keySet()) {
                System.out.println("Doesn't know how to use (SB) " + sideboard.get(name) + " " + name );
            }
            return d;
        }
        catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
