package mtg.logic;

import mtg.logic.ec.MtgProblem;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import mtg.logic.util.SampleHand;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class Server {
    private PrologProblem problem;
    private PrologEngine prolog;
    private Deck deck;

    @RestController
    public class Controller {
        @RequestMapping(value="/evaluate", method= RequestMethod.POST)
        public Map<String, SingleResult> testHand(@RequestBody final SampleHand hand) {
            final Map<String, SingleResult> response = new HashMap<>();
            for (final SingleObjectivePrologProblem objective : problem.getObjectives()) {
                final Results results = prolog.testHand(
                        objective,
                        hand.getHand(),
                        hand.getLibrary(deck),
                        hand.getSideboard(deck),
                        hand.getMulligans(), 0);
                final SingleResult result = new SingleResult();
                assert results.getNTotal() == 1;
                result.setSuccess(results.isSuccess(0));
                result.setDuration(results.getDuration(0));
                if (result.isSuccess()) {
                    result.setIntMetadata(results.getIntMetadata(0));
                    result.setStringMetadata(results.getStringMetadata(0));
                    result.setBooleanMetadata(results.getBooleanMetadata(0));
                    result.setListMetadata(results.getListMetadata(0));
                }
                response.put(objective.getName(), result);
            }
            return response;
        }
    }

    @Bean
    public CommandLineRunner commandLineRunner(final ApplicationContext context) {
        return args -> {
            if (args.length >= 2) {
                problem = PrologProblem.fromYaml(args[0]);
                final String decklistFile = args[1];
                deck = Deck.fromFile(decklistFile);
                final String prologSrcDir = System.getProperty(
                        MtgProblem.PROLOG_SRC_PROPERTY, System.getProperty("user.dir"));
                prolog = new PrologEngine(prologSrcDir);
                prolog.setProblem(problem);
            } else {
                System.out.println("Expected arguments: <problem spec file> <decklist file>");
                System.exit(1);
            }
        };
    }

    public static void main(String[] args) throws IOException {
        System.out.println(args.length + " arguments: [main]");
        for (final String arg : args) {
            System.out.println("\t" + arg);
        }
        SpringApplication.run(Server.class, args);
    }
}
