#!/usr/bin/env python

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

import math
import re
import sys

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <filename>")
        sys.exit(1)
    filename = sys.argv[1]
    re_gen = re.compile('^Generation (\d+)$')
    re_fitness = re.compile('^.* ([0-9]+) successes out of ([0-9]+) ; fitness=([0-9.]+)$')
    current_gen = 0
    data = []
    with open(filename, 'r') as f:
        for line in f:
            match = re_gen.match(line)
            if match:
                current_gen = match.group(1)
                continue
            match = re_fitness.match(line)
            if match:
                successes = int(match.group(1))
                n = int(match.group(2))
                fitness = float(match.group(3))
                p = float(successes) / n
                k = max(math.ceil(math.log10(n)), 3)
                remainder = (fitness - p) * (10**k)
                stddev = math.sqrt(p * (1-p) * n) / n
                data.append({'generation': int(current_gen), 'fitness': fitness,
                    'p': p, 'stddev': stddev, 'remainder': remainder,
                    'p_lower': p-stddev, 'p_upper': p+stddev})
                continue
    df = pd.DataFrame(data)
    max_ids = df.groupby(['generation'], sort=True)['fitness'].transform(max) == df['fitness']
    best_lower = df[max_ids]['p_lower']
    best_upper = df[max_ids]['p_upper']

    sns.set_style("whitegrid")
    palette = sns.color_palette("mako", 5)
    c_best = palette[3]
    c_box = palette[4]
    c_point = palette[1]
    ax = plt.gca()
    ax.fill_between(range(0, int(current_gen)+1), y1=best_lower, y2=best_upper, color=c_best, alpha=.2, zorder=0)
    sns.lineplot(x='generation', y='p_lower', data=df[max_ids], ax=ax, color=c_best, alpha=.25,
        size=1, zorder=1, legend=False)
    sns.lineplot(x='generation', y='p_upper', data=df[max_ids], ax=ax, color=c_best, alpha=.25,
        size=1, zorder=1, legend=False)
    sns.boxplot(x='generation', y='p', data=df, ax=ax, color=c_box, zorder=100, showfliers=False,
        saturation=.3, boxprops={"zorder": 100}, whiskerprops={"zorder": 100})
    sns.lineplot(x='generation', y='p', data=df[max_ids], ax=ax, color=c_best, zorder=200)
    sns.swarmplot(x='generation', y='p', data=df, ax=ax, color=c_point, zorder=300)
    ax.set_ybound(lower=0)

    plt.show()
