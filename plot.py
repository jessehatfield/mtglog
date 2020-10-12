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
    re_fitness = re.compile('^.*fitness=([0-9.]+)$')
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
                fitness = float(match.group(1))
                intpart = math.floor(fitness)
                fractionpart = fitness - intpart
                data.append({'generation': int(current_gen), 'fitness': fitness,
                    'fitness1': intpart, 'fitness2': fractionpart})
                continue
    df = pd.DataFrame(data)
    sns.violinplot(x='generation', y='fitness', data=df, inner=None, color=".8")
    sns.stripplot(x='generation', y='fitness', data=df)
    df.boxplot(column='fitness', by='generation')
    df.boxplot(column='fitness2', by='generation')
    plt.show()
