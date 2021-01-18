package mtg.logic;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;
import org.junit.Assert;
import org.junit.Test;

import java.io.FileReader;
import java.io.IOException;
import java.io.StringReader;
import java.net.URL;
import java.util.Arrays;

public class PrologEngineIT {
    @Test
    public void testSampleHands_oops() throws IOException {
        testSampleHands("oopsProblem.yaml", "oops.dec", "oopsSamples.tsv");
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
        final String[] sideboard = new String[] {};
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
                final Results result = engine.testHand(objective, hand, library, sideboard, putBack);
                final boolean win = result.isSuccess(0);
                if (win != expectedWin) {
                    System.err.println("\nERROR[hand " + i + "]: Expected win=" + expectedWin
                            + " for hand=[" + Arrays.deepToString(hand) + "], was "
                            + win + " (" + result+ ")");
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
}
