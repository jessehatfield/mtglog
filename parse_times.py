#!/usr/bin/env python

import re
import sys
import pandas as pd
import matplotlib.pyplot as plt

def parse(filename):
    hand_re = re.compile("Testing hand: \[(.*)\]( \(must put back ([0-9]+)\))?")
    time_re = re.compile("\s*(failure.|success: \{.*\}) \[([0-9]+) ms\]")
    samples = []
    with open(filename, 'r') as f:
        for line in f:
            match = hand_re.match(line)
            if match:
                hand = match.group(1)
                mull = 0 if match.group(3) is None else int(match.group(3))
            else:
                match = time_re.match(line)
                if match:
                    win = match.group(1).startswith('success')
                    t = int(match.group(2))
                    samples.append({"ms": t, "hand": hand, "win": win, "mulligans": mull})
    return pd.DataFrame(samples).sort_values("ms", ascending=False)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <filename>")
        sys.exit(1)
    df = parse(sys.argv[1])
    ax = df.hist(column="ms", by="mulligans")
    plt.show()
    print(df.to_csv(sep='\t', index=False))
