#!/usr/bin/env python

import glob
import matplotlib.pyplot as plt
import pandas as pd
import re
import seaborn as sns
import sys

def plot(expNum, popsize, samples, bits, selection='*', generations=0):
    dataframes = []
    for filename in glob.glob(f"logs{expNum}/job.*.progress-{popsize}pop-{samples}test-{bits}bit-{selection}.tsv"):
        selection = re.compile(".*bit-(.*).tsv$").match(filename).group(1)
        print(filename, selection)
        df = pd.read_csv(filename, sep='\t')
        if generations > 0:
            df = df[df['generation'] < generations]
        df["selection"] = selection
        dataframes.append(df)
    merged_df = pd.concat(dataframes, ignore_index=True)
    print(merged_df)
    sns.set_style("whitegrid")
    palette = sns.color_palette("mako", 5)
    sns.lineplot(x='generation', y='ground truth', data=merged_df, hue="selection")
    plt.show()
    sns.lineplot(x='generation', y='entropy', data=merged_df, hue="selection")
    plt.show()

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print(f"Usage: {sys.argv[0]} <experiment num> <population size> <sample size> <genome length> [selection method] [num generations]")
        sys.exit(1)
    elif len(sys.argv) > 6:
        plot(int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), sys.argv[5], int(sys.argv[6]))
    elif len(sys.argv) > 5:
        plot(int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), sys.argv[5])
    else:
        plot(int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]))
