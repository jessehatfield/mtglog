package mtg.logic;

import org.junit.Assert;
import org.junit.Test;

import java.io.IOException;
import java.net.URL;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class MultiObjectivePrologProblemTest {
    @Test
    public void testLoadYaml() throws IOException {
        final MultiObjectivePrologProblem oops;
        final URL specFile = this.getClass().getClassLoader().getResource("oopsProblemMulti.yaml");
        Assert.assertNotNull(specFile);
        oops = MultiObjectivePrologProblem.fromYaml(specFile.getFile());
        Assert.assertEquals("Oops All Spells -- Legacy, Multiobjective", oops.getName());
        Assert.assertEquals(Arrays.asList(
                "mana.pl", "cards.pl", "oops.pl", "test.pl"),
                oops.getSources());
        final List<SingleObjectivePrologProblem> objectives = oops.getObjectives();
        Assert.assertEquals(2, objectives.size());
        Assert.assertEquals("win", objectives.get(0).getName());
        Assert.assertEquals(3, objectives.get(0).getMaxMulligans());
        Assert.assertEquals("play_oops_hand", objectives.get(0).getPredicate());
        Assert.assertTrue(objectives.get(0).getParams().get("protection") instanceof Integer);
        Assert.assertEquals(1, objectives.get(0).getParams().get("protection"));
        Assert.assertTrue(objectives.get(0).getParams().get("greedy_mulligans") instanceof Integer);
        Assert.assertEquals(0, objectives.get(0).getParams().get("greedy_mulligans"));
        Assert.assertEquals(Collections.singletonList("isProtected"), objectives.get(0).getBooleanOutputs());
        Assert.assertEquals("protectedWin", objectives.get(1).getName());
        Assert.assertEquals(4, objectives.get(1).getMaxMulligans());
        Assert.assertEquals("play_oops_hand", objectives.get(1).getPredicate());
        Assert.assertTrue(objectives.get(1).getParams().get("protection") instanceof Integer);
        Assert.assertEquals(1, objectives.get(1).getParams().get("protection"));
        Assert.assertTrue(objectives.get(1).getParams().get("greedy_mulligans") instanceof Integer);
        Assert.assertEquals(4, objectives.get(1).getParams().get("greedy_mulligans"));
        Assert.assertEquals(Collections.singletonList("isProtected"), objectives.get(1).getBooleanOutputs());
    }
}
