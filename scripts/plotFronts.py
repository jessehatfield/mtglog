#!/usr/bin/env python

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import beta

import numpy as np
import math
import re
import sys

p1_key = 'Objective 1 Success Rate'
p2_key = 'Objective 2 Success Rate'
beta_prior = 1
num_posterior_samples = 1000

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <filename>")
        sys.exit(1)
    filename = sys.argv[1]
    re_gen = re.compile('^Generation: (\d+)$')
    re_ind = re.compile('^\s+individual ')
    re_rank = re.compile('^\s*Rank: (\d+)$')
    re_counts = re.compile('^\s*Counts: \[([0-9]+)/([0-9]+) , ([0-9]+)/([0-9]+)\]$')
    re_end = re.compile(".*PARETO FRONTS.*")
    current_gen = 0
    current_rank = 0
    read_ind = False
    data = []
    with open(filename, 'r') as f:
        for line in f:
            match = re_gen.match(line)
            if match:
                current_gen = int(match.group(1))
                read_ind = False
                continue
            match = re_ind.match(line)
            if match:
                read_ind = True
                continue
            if not read_ind:
                continue
            match = re_rank.match(line)
            if match:
                current_rank = int(match.group(1))
                continue
            match = re_counts.match(line)
            if match:
                successes_1 = int(match.group(1))
                n_1 = int(match.group(2))
                p_1 = float(successes_1) / n_1
                stddev_1 = math.sqrt(p_1 * (1-p_1) * n_1) / n_1
                successes_2 = int(match.group(3))
                n_2 = int(match.group(4))
                p_2 = float(successes_2) / n_2
                stddev_2 = math.sqrt(p_2 * (1-p_2) * n_2) / n_2
                individual = {'Generation': current_gen, 'Pareto Rank': current_rank,
                    p1_key: p_1, p2_key: p_2,
                    'stddev1': stddev_1, 'stddev2': stddev_2,
                    'p1_lower': p_1-stddev_1, 'p1_upper': p_1+stddev_1,
                    'p2_lower': p_2-stddev_2, 'p2_upper': p_2+stddev_2,
                    'success_1': successes_1, 'failure_1': n_1-successes_1,
                    'success_2': successes_2, 'failure_2': n_2-successes_2
                    }
                if len(data) > 0 \
                        and data[-1]['Generation'] == current_gen and data[-1]['Pareto Rank'] == current_rank \
                        and data[-1][p1_key] == p_1 and data[-1][p2_key] == p_2:
                    if data[-1]['success_1'] >= successes_1 and data[-1]['success_2'] >= successes_2:
                        continue
                    elif data[-1]['success_1'] <= successes_1 and data[-1]['success_2'] <= successes_2:
                        data[-1] = individual
                        continue
                data.append(individual)
                continue
            if re_end.match(line):
                break

    df = pd.DataFrame(data)
    front_df = df[df['Pareto Rank'] == 0]
    final_df = df[df['Generation'] == current_gen]
    final_front = front_df[df['Generation'] == current_gen]
    with pd.option_context('display.max_rows', None, 'display.max_columns', None):
        print(final_front)

    posterior_samples = []
    for index, front_point in final_front.iterrows():
        a1 = 10*front_point['success_1'] + beta_prior
        b1 = 10*front_point['failure_1'] + beta_prior
        a2 = 10*front_point['success_2'] + beta_prior
        b2 = 10*front_point['failure_2'] + beta_prior
        samples1 = beta.rvs(a1, b1, size=num_posterior_samples)
        samples2 = beta.rvs(a2, b2, size=num_posterior_samples)
        index = np.ones(num_posterior_samples) * index
        samples = np.vstack([index, samples1, samples2]).transpose()
        posterior_samples.append(pd.DataFrame(samples, columns=['index', p1_key, p2_key]))
    posterior_front = pd.concat(posterior_samples)

    sns.set_style("darkgrid")
    sns.set_context("notebook")

    ax = plt.gca()
    cmap = sns.color_palette("rocket_r", current_gen+1)
    sns.kdeplot(posterior_front[p1_key], posterior_front[p2_key], shade=True, cmap="rocket_r",
            levels=5, alpha=.25)
    ax.collections[0].set_alpha(0)
    sns.lineplot(data=front_df, x=p1_key, y=p2_key, hue='Generation', palette=cmap, legend=False, ax=ax)
    sns.scatterplot(data=front_df, x=p1_key, y=p2_key, hue='Generation', palette=cmap,
            legend='brief', ax=ax)
    ax.set_ybound(lower=0, upper=1)
    ax.set_xbound(lower=0, upper=1)
    ax.set(aspect="equal")
    plt.show()

    ax = plt.gca()
    cmap = sns.color_palette("mako", final_df['Pareto Rank'].max()+1)
    sns.kdeplot(posterior_front[p1_key], posterior_front[p2_key], shade=True, cmap="mako_r",
            levels=5, alpha=.25)
    ax.collections[0].set_alpha(0)
    sns.lineplot(data=final_df, x=p1_key, y=p2_key, hue='Pareto Rank', palette=cmap, legend=False, ax=ax)
    sns.scatterplot(data=final_df, x=p1_key, y=p2_key, hue='Pareto Rank', palette=cmap,
            legend='full', ax=ax)
    ax.set_ybound(lower=0, upper=1)
    ax.set_xbound(lower=0, upper=1)
    ax.set(aspect="equal")
    plt.show()
