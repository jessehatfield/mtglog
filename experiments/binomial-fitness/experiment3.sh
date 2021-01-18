#!/bin/bash

genome="64"
popsize="64"

for numtests in 10 20 50 ; do

    filename="${popsize}pop-${numtests}test-${genome}bit"

    for samples in 0 1 2 3 4 5 ; do
        selection="mtg.logic.ec.stochastic.StochasticTournamentSelection"
        selection_short="StochasticTournamentSelection-${samples}"
        mvn exec:java@evolve -Dexec.args="-file experiments/binomial-fitness/evolve.params \
            -p stochastic.tournament.posterior.samples=${samples}
            -p pop.subpop.0.size=${popsize}
            -p pop.subpop.0.species.genome-size=${genome}
            -p pop.subpop.0.species.pipe.source.0.source.0=${selection}
            -p pop.subpop.0.species.pipe.source.0.source.1=${selection}
            -p eval.num-tests=${numtests}
            -p stat.file=\$experiments/binomial-fitness/logs3/log-${filename}-${selection_short}.stat
            -p stat.child.0.file=\$experiments/binomial-fitness/logs3/progress-${filename}-${selection_short}.tsv
            "
    done

done
