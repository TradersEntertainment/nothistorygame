#!/usr/bin/env python3
"""dalga.py <etiket>=<glob> ... : WAVERUNNER t= değerlerinden 1./2. dalga medyan [aralık] (=wide ayrı)."""
import glob, re, statistics, sys

def oz(xs):
    if not xs:
        return "—"
    xs = sorted(xs)
    return "%.1f [%.1f–%.1f] (n %d)" % (statistics.median(xs), xs[0], xs[-1], len(xs))

print("| küme | 1. dalga medyan [aralık] | 2. dalga medyan [aralık] |")
print("|---|---|---|")
for arg in sys.argv[1:]:
    et, gl = arg.split("::", 1)
    w = {1: [], 2: []}
    for f in sorted(glob.glob(gl)):
        for line in open(f, errors="replace"):
            m = re.search(r"WAVERUNNER wave=(\d)/2 won=\w+ t=([\d.]+)", line)
            if m:
                w[int(m.group(1))].append(float(m.group(2)))
    print("| %s | %s | %s |" % (et, oz(w[1]), oz(w[2])))
