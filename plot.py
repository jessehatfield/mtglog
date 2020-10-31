#!/usr/bin/env python

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

import math
import re
import sys

if __name__ == "__main__":
    filename = sys.argv[1]
    re_gen = re.compile('^Generation (\d+)$')
    re_fitness = re.compile('^.* out of ([0-9]+) ; fitness=([0-9.]+)$')
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
                n = int(match.group(1))
                fitness = float(match.group(2))
                intpart = math.floor(fitness)
                fractionpart = fitness - intpart
                p1 = float(intpart) / n
                stddev1 = math.sqrt(p1 * (1-p1) * n)
                stddev2 = math.sqrt(fractionpart * (1-fractionpart) * n)
                data.append({'generation': int(current_gen), 'fitness': fitness,
                    'fitness1': intpart, 'fitness2': fractionpart,
                    'stddev1': stddev1, 'stddev2': stddev2})
                continue
    df = pd.DataFrame(data)
    sns.violinplot(x='generation', y='fitness', data=df, inner=None, color=".8")
    sns.stripplot(x='generation', y='fitness', data=df)
    ax = df.boxplot(column='fitness1', by='generation')
    max_ids = df.groupby(['generation'], sort=True)['fitness'].transform(max) == df['fitness']
    df[max_ids].plot(x='generation', y='fitness1', yerr='stddev1')
    df.boxplot(column='fitness2', by='generation')
    plt.show()
