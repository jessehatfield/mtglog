package mtg.logic;

import org.junit.Assert;
import org.junit.Test;

import java.io.IOException;
import java.net.URL;
import java.util.List;

public class RESTEvaluationFunctionTest {
    @Test
    public void testLoadYaml() throws IOException {
        final RESTEvaluationFunction oops;
        final URL specFile = this.getClass().getClassLoader().getResource("oopsREST.yaml");
        Assert.assertNotNull(specFile);
        oops = RESTEvaluationFunction.fromYaml(specFile.getFile());
        Assert.assertEquals("Oops All Spells -- REST Client", oops.getName());
        Assert.assertEquals("http://localhost:3000/api/sample", oops.getUrl());
        final List<RESTEvaluationFunction.Objective> objectives = oops.getObjectives();
        Assert.assertEquals("win", objectives.get(0).getName());
        Assert.assertEquals("$.stats.winProbability", objectives.get(0).getPath());
        Assert.assertFalse(objectives.get(0).isMinimize());
        Assert.assertEquals("protectedWin", objectives.get(1).getName());
        Assert.assertEquals("$.stats.protectedWinProbability", objectives.get(1).getPath());
        Assert.assertFalse(objectives.get(1).isMinimize());
        Assert.assertEquals("deckSize", objectives.get(2).getName());
        Assert.assertEquals("$.deckSize", objectives.get(2).getPath());
        Assert.assertTrue(objectives.get(2).isMinimize());
    }
}
