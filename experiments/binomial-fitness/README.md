## Theory

Suppose an individual in an EC problem in some way maps to an unobservable parameter defining
probability distribution, that the overall objective is defined with respect to that parameter, and
that the only evaluation function available is to sample from the distribution.

Specifically, let f(x) be a function that maps individuals to the success parameter p of a binomial
distribution, and suppose f is not directly computable but that we can sample from the distribution
Binom(N, f(x)) for some choice of N. Finally, suppose the goal of the evolutionary computation
process is to find an individual x that maximizes E[f(x)].

These experiments will investigate the influence of different selection mechanisms on the
performance of such an EC problem.


## Instantiation: Binary Autocorrelation

Let the individuals X be binary vectors of length k, which will be treated as bipolar sequences,
i.e. use g(0) = -1, g(1)= 1. Then define the cyclical autocorrelation with lag l:

    R(x,l) = sum[j=0 to k-1]{ g(x[j]) * g(x[(j+l) % k]) }

This value ranges between -k and k, and is always k when l % k == 0. So we will map x to a value
between 0 and 1 by restricting l to [1,  k-1], choosing the value of l which maximizes R, and
normalizing:

    f(x) = max[l=1 to k-1]{ (R(x,l) + k) / (2k) }

Thus the value f(x) is maximized when the vector is periodic according to some non-trivial lag
parameter, which has many optimal solutions.

Experiment: Attempt to maximize f(x) using an optimization process that can only sample from
Binom(f(x), N). We can evaluate the success of the process with respect to two main criteria:

    - How quickly and consistently it maximizes the ground truth f(x)
    - The diversity of individuals generated, especially among high-fitness individuals

## Experiment 1: Stochastic Tournament Selection

Implemented a variant of tournament selection that decides the winner by first evaluating the
posterior distributions over f(x) (having observed samples from Binom(f(x), N)), and then randomly
samples potential values for f(x) from those posteriors. Sample a new f(x) every time a comparison
between individuals is made, i.e. resample from the posterior for every tournament, so that
tournaments are i.i.d. given the individuals' sets of samples from the underlying binomial
distribution.

For a random variable Successes ~ Binom(f(x), N), the posterior distribution for f(x)
is given by Beta(alpha + successes, beta + (N-successes)) given a prior distribution
Beta(alpha, beta). For these experiments, assume a prior of Beta(1, 1), so that the posterior
distribution is defined as Beta(1 + successes, 1 + N - successes).

Experiment 1 compares ordinary tournament selection to stochastic tournament selection at a variety
of population sizes, genome lengths, and number of samples N drawn from Binom(f(x), N) for each
individual at each generation. For ordinary tournament selection, the fitness is the sample success
rate: successes / (N - successes). Ideally, the hypothesis was that resampling for each tournament would
prevent a single "lucky" sample from a less fit individual from allowing it to defeat potentially
many similar or better individuals if selected for multiple tournaments. In other words, this should
prevent premature exploitation of values that arise from noise, possibly preserving population
diversity for longer and allowing better solutions to arise.

In practice, this hypothesis does not appear to hold. While the stochastic approach does preserve
diversity compared to the traditional approach (as measured by the average information entropy over
bits in the genome, where an individual bit's entropy is assessed over the population), this
corresponds with consistently lower true fitness (as evaluated according to the ground truth formula
for f(x), which is not known to the algorithm but is defined above). This suggests that the
stochastic approach does delay or diminish exploitation but does not suggest that this is helpful,
at least for this problem.


## Experiment 2 and 3: Stochastic Tournament Selection with Averaging

In experiment 2, stochastic tournament selection is extended so that a tournament samples
multiple values from the posterior distribution and declares the individual with the higher average
to be the winner. Selected sample sizes were 1 (equivalent to the previous implementation), 10,
and 100. Results from all cases except the 1-sample setting closely matched the results of
traditional tournament selection, which provides some validation that the posterior was implemented
reasonably but doesn't demonstrate any particular value in the averaging parameter.

For experiment 3, the averaging parameter was instead varied from 0 to 5 (where zero is equivalent
to traditional tournament selection). This supports the finding from the previous experiment, but
with somewhat of a gradient: increasing sample sizes from 1 rapidly increases the performance in
terms of ground truth fitness, up until the results match those of traditional tournament selection.

In both experiments, genome size and population size were set to 64, and N was varied between 10, 20,
and 50.


## Experiments 4 and 5: Elitism and Memory

Implemented a memory mechanism so that the same individual, if tested more than once, can accumulate
samples over the generations it lives through. In theory, this should help traditional tournament
selection by allowing the traditional fitness score to regress toward the true value if kept alive
on the basis of a lucky sample, and should assist the stochastic tournament selection by narrowing
the posterior distribution. The purposes of this experiment were to establish whether the presence
of elitism and memory helps in either case and/or affects the comparison between them. Here the
averaging parameter was again varied from 0 to 5; elitism was varied between 0%, 25%, 50%, and 75%
of the population; and all combinations were tested with and without memory. Genome size and
population were both set to 64, and N was set to 20.

Results clearly show that elitism improves success, with either kind of selection and both with
and without memory. The different elitism proportions are much closer, but with 25% and 50%
generally outperforming 75%. The other variables overlap too much to make definitive conclusions,
but in the presence of memory, the average ground truth fitness of 1-sample and 5-sample stochastic
tournament selection in the 25% elitism case was slightly bettern than traditional tournament
selection, in contrast to the previous experiments. Without memory, however, the comparison between
selection methods was consistent with the previous findings.

With stochastic tournament selection, memory seems to improve results relative to no memory.
With traditional tournament selection, memory seems to have little effect. But these effects were
small and needed to be tested further.

With this in mind, experiment 5 fixed the elitism proportion to 25%, increased the number of jobs to
50, and tested sample sizes of 1, 5, and 0 (tournament selection) with and without memory. These six
configurations performed substantially similarly, but the average ground truth fitness was slightly
higher for the runs with memory than the runs without. The worst performer was single-sample
stochastic selection with no memory. Among the three cases with memory, the observed differences
were much smaller, with single-sample stochastic tournament selection actually outperforming the
others on average, but the difference is far too small to make definitive conclusions without more
experiments.


## Conclusion

In general, it seems that some elitism with memory aids success in the case of this stochastic
problem. Stochastic sampling appears to be a bad idea in the absence of memory, but may be neutral
or positive alongside elitism and memory, compared to traditional tournament selection. However, any
difference is likely to be very small. In all experiments, entropy within the population tracked
closely with ground truth fitness: for example, I observed no situation where two configurations
performed similarly but one had a more diverse population.

Tentative recommendation based on these results is to use some kind of elitism and some
kind of mechanism to incorporate past samples into future evaluations, such as the standard elitism
plus straightforward memory mechanism here, for fitness functions like this. Future work may
investigate other optimization algorithms that inherently have some ability to remember past
performance, possibly in a way that can be communicated between individuals, such as ACO. 
