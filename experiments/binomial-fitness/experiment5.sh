#!/bin/bash

popsize="64"
numtests="20"
genome="64"
elite_fraction="25"

filename="${popsize}pop-${numtests}test-${genome}bit"

for memory in "true" "false" ; do

    for samples in 0 1 5 ; do

        selection="mtg.logic.ec.stochastic.StochasticTournamentSelection"
        selection_short="StochasticTournamentSelection-${samples}-${elite_fraction}elite-${memory}"
        mvn exec:java@evolve -Dexec.args="-file experiments/binomial-fitness/evolve.params \
            -p jobs=50
            -p generations=150
            -p breed.elite-fraction.0=0.${elite_fraction}
            -p breed.reevaluate-elites.0=true
            -p stochastic.tournament.posterior.samples=${samples}
            -p pop.subpop.0.size=${popsize}
            -p pop.subpop.0.species.genome-size=${genome}
            -p pop.subpop.0.species.pipe.source.0.source.0=${selection}
            -p pop.subpop.0.species.pipe.source.0.source.1=${selection}
            -p eval.num-tests=${numtests}
            -p stat.child.0.file=\$experiments/binomial-fitness/logs5/progress-${filename}-${selection_short}.tsv
            -p pop.subpop.0.species.fitness.memory=${memory}
            "

    done

done
