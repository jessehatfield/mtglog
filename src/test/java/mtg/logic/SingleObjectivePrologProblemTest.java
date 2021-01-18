package mtg.logic;

import org.junit.Assert;
import org.junit.Test;

import java.io.IOException;
import java.net.URL;
import java.util.Arrays;
import java.util.Collections;

public class SingleObjectivePrologProblemTest {
    @Test
    public void testLoadYaml() throws IOException {
        final SingleObjectivePrologProblem oops;
        final URL specFile = this.getClass().getClassLoader().getResource("oopsProblem.yaml");
        Assert.assertNotNull(specFile);
        oops = SingleObjectivePrologProblem.fromYaml(specFile.getFile());
        Assert.assertEquals("Oops All Spells -- Legacy", oops.getName());
        Assert.assertEquals(3, oops.getMaxMulligans());
        Assert.assertEquals("play_oops_hand", oops.getPredicate());
        Assert.assertEquals(Arrays.asList(
                "mana.pl", "cards.pl", "oops.pl", "test.pl"),
                oops.getSources());
        Assert.assertTrue(oops.getParams().get("protection") instanceof Integer);
        Assert.assertEquals(1, oops.getParams().get("protection"));
        Assert.assertTrue(oops.getParams().get("greedy_mulligans") instanceof Integer);
        Assert.assertEquals(0, oops.getParams().get("greedy_mulligans"));
        Assert.assertEquals(Collections.singletonList("isProtected"), oops.getBooleanOutputs());
    }
}
