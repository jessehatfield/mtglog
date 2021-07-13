package mtg.logic;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;
import org.junit.Assert;
import org.junit.Test;

import java.io.FileReader;
import java.io.IOException;
import java.io.StringReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.IntStream;

public class PrologEngineIT {
    @Test
    public void testSampleHands_oops() throws IOException {
        testSampleHands("oopsProblem.yaml", "oops.dec", "oopsSamples.tsv");
    }

    @Test
    public void testSerumPowder_oops() throws IOException {
        testSerumPowder("oopsProblem.yaml", "oops.dec", "oopsPowder.tsv");
    }

    private void testSampleHands(final String problemFile, final String deckFile, final String samplesFile) throws IOException {
        final URL problemURL = PrologEngineIT.class.getClassLoader().getResource(problemFile);
        final URL deckURL = PrologEngineIT.class.getClassLoader().getResource(deckFile);
        final URL sampleHandURL = PrologEngineIT.class.getClassLoader().getResource(samplesFile);
        Assert.assertNotNull(problemURL);
        Assert.assertNotNull(deckURL);
        Assert.assertNotNull(sampleHandURL);
        final PrologProblem problem = PrologProblem.fromYaml(problemURL.getPath());
        final Deck deck = new DeckTemplate(deckURL.getPath()).toDeck(new int[]{});
        final PrologEngine engine = new PrologEngine("src/main/prolog");
        engine.setProblem(problem);
        final String[] sideboard = new String[]{};
        try (final FileReader in = new FileReader(sampleHandURL.getPath())) {
            final Iterable<CSVRecord> records = CSVFormat.TDF.withFirstRecordAsHeader().parse(in);
            int i = 0;
            int falseNegatives = 0;
            int falsePositives = 0;
            for (final CSVRecord record : records) {
                final String[] hand = new String[7];
                final String handStr = record.get("hand");
                try (final StringReader handIn = new StringReader(handStr)) {
                    final Iterable<CSVRecord> cardReader = CSVFormat.RFC4180
                            .withHeader("0", "1", "2", "3", "4", "5", "6")
                            .parse(handIn);
                    final CSVRecord handRecord = cardReader.iterator().next();
                    for (int j = 0; j < 7; j++) {
                        hand[j] = handRecord.get(j).trim();
                    }
                }
                final String[] library = deck.getRemainder(hand);
                final int putBack = Integer.parseInt(record.get("mulligans"));
                final boolean expectedWin = Boolean.parseBoolean(record.get("win"));
                if (i % 100 == 0) {
                    System.out.printf("Testing hand %s:%05d+", samplesFile, i);
                } else {
                    System.out.print(".");
                    if (i % 100 == 99) {
                        System.out.println();
                    }
                }
                final SingleObjectivePrologProblem objective = problem.getObjectives().get(0);
                final Results result = engine.testHand(objective, hand, library, sideboard, putBack, 0);
                final boolean win = result.isSuccess(0);
                if (win != expectedWin) {
                    System.err.println("\nERROR[hand " + i + "]: Expected win=" + expectedWin
                            + " for hand=[" + Arrays.deepToString(hand) + "], was "
                            + win + " (" + result + ")");
                    if (expectedWin) {
                        falseNegatives++;
                    } else {
                        falsePositives++;
                    }
                }
                i++;
            }
            System.out.println();
            Assert.assertEquals(falseNegatives + " false negatives and " + falsePositives + " false positives -- ",
                    0, falseNegatives + falsePositives);
        }
    }

    private void testSerumPowder(final String problemFile, final String deckFile, final String samplesFile) throws IOException {
        final URL problemURL = PrologEngineIT.class.getClassLoader().getResource(problemFile);
        final URL deckURL = PrologEngineIT.class.getClassLoader().getResource(deckFile);
        final URL sampleHandURL = PrologEngineIT.class.getClassLoader().getResource(samplesFile);
        Assert.assertNotNull(problemURL);
        Assert.assertNotNull(deckURL);
        Assert.assertNotNull(sampleHandURL);
        final PrologProblem problem = PrologProblem.fromYaml(problemURL.getPath());
        final Deck deck = new DeckTemplate(deckURL.getPath()).toDeck(new int[]{});
        final PrologEngine engine = new PrologEngine("src/main/prolog");
        engine.setProblem(problem);
        final String[] sideboard = new String[]{};
        int nErrors = 0;
        try (final FileReader in = new FileReader(sampleHandURL.getPath())) {
            final Iterable<CSVRecord> records = CSVFormat.TDF.withFirstRecordAsHeader().parse(in);
            int i = 0;
            for (final CSVRecord record : records) {
                final int handSize = Integer.parseInt(record.get("handSize"));
                final String handStr = record.get("hand");
                final int mulligans = Integer.parseInt(record.get("mulligans"));
                final boolean powder = Boolean.parseBoolean(record.get("powder"));
                final String bottomStr = record.get("bottom");
                final String[] hand = new String[handSize];
                try (final StringReader handIn = new StringReader(handStr)) {
                    final String[] header = IntStream.range(0, handSize)
                            .mapToObj(String::valueOf)
                            .toArray(String[]::new);
                    final Iterable<CSVRecord> cardReader = CSVFormat.RFC4180
                            .withHeader(header)
                            .parse(handIn);
                    final CSVRecord handRecord = cardReader.iterator().next();
                    for (int j = 0; j < handSize; j++) {
                        hand[j] = handRecord.get(j).trim();
                    }
                }
                final List<String> expectedBottom = new ArrayList<>(mulligans);
                try (final StringReader bottomIn = new StringReader(bottomStr)) {
                    final String[] header = IntStream.range(0, mulligans)
                            .mapToObj(String::valueOf)
                            .toArray(String[]::new);
                    final Iterable<CSVRecord> cardReader = CSVFormat.RFC4180
                            .withHeader(header)
                            .parse(bottomIn);
                    if (cardReader.iterator().hasNext()) {
                        final CSVRecord bottomRecord = cardReader.iterator().next();
                        for (int j = 0; j < mulligans; j++) {
                            expectedBottom.add(bottomRecord.get(j).trim());
                        }
                    }
                }
                final String[] library = deck.getRemainder(hand);
                System.out.printf("Testing hand %s:%05d+: ", samplesFile, i);

                final SingleObjectivePrologProblem objective = problem.getObjectives().get(0);
                final List<String> bottom = engine.canSerumPowder(objective, hand, library, mulligans);
                if (powder) {
                    if (bottom == null) {
                        nErrors++;
                        System.out.println("fail.");
                        System.err.println("ERROR[hand " + i + "]: Expected powder=True"
                                + " for hand=[" + Arrays.deepToString(hand) + "], was "
                                + " False (expected bottom cards: " + expectedBottom + ")");
                    } else {
                        if (expectedBottom.equals(bottom)) {
                            System.out.println("pass.");
                        } else {
                            nErrors++;
                            System.out.println("fail.");
                            System.err.println("ERROR[hand " + i + "]: Correctly determined powder=True"
                                    + " for hand=[" + Arrays.deepToString(hand) + "], but "
                                    + " expected bottom cards: " + expectedBottom
                                    + " and received bottom cards: " + bottom);
                        }
                    }
                } else {
                    if (bottom == null) {
                        System.out.println("pass.");
                    } else {
                        nErrors++;
                        System.out.println("fail.");
                        System.err.println("ERROR[hand " + i + "]: Expected powder=False"
                                + " for hand=[" + Arrays.deepToString(hand) + "], was "
                                + " True (with bottom cards: " + bottom + ")");
                    }
                }
                i++;
            }
        }
        Assert.assertEquals(0, nErrors);
    }
}
