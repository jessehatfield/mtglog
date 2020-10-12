## Test a Specific List

mvn exec:java@goldfish -Dexec.args="path/to/decklist/.txt <num games>"

## Run Evolutionary Computation

mvn exec:java@evolve -Dexec.args="-file path/to/evolve.params" -Dmtg.eval.games=10

## Convert an EC Int Vector into a Decklist

mvn exec:java@convert -Dexec.args="0 1 4 5 [...]"
