## Test a Specific List

mvn exec:java@goldfish -Dexec.args="path/to/problem/spec.yaml path/to/decklist/.txt <num games>"

## Run Evolutionary Computation

mvn exec:java@evolve -Dexec.args="-file path/to/evolve.params"

## Convert an EC Int Vector into a Decklist

mvn exec:java@convert -Dexec.args="path/to/template.dec 0 1 4 5 [...]"

## Make a REST call to evaluate a decklist

mvn exec:java@client -Dexec.args="path/to/rest/spec.yaml path/to/decklist.dec"

## Run a local Spring server that can handle REST calls

mvn spring-boot:run -Dspring-boot.run.arguments="path/to/problem/spec.yaml path/to/decklist.txt"
