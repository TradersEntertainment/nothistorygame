#!/usr/bin/env python3
# cesit.py <dizin> [önek]: çeşit başına (dosya adı _rN / _N sonekleri atılır) dalga medyanları
import re, sys, glob, statistics as st, os
d = sys.argv[1]; on = sys.argv[2] if len(sys.argv) > 2 else ""
g = {}
for f in sorted(glob.glob(d + "/" + on + "*")):
    b = os.path.basename(f)
    if "." in b:
        continue
    k = re.sub(r"(_r?\d+)$", "", b)
    for l in open(f, errors="ignore"):
        m = re.search(r"WAVERUNNER wave=(\d+)/\d+ won=\S+ t=([\d.]+)", l)
        if m:
            g.setdefault(k, {}).setdefault(m.group(1), []).append(float(m.group(2)))
for k, w in sorted(g.items()):
    print("%-22s %s" % (k, " | ".join("%s: %.1f (n %d)" % (x, st.median(v), len(v)) for x, v in sorted(w.items()))))
