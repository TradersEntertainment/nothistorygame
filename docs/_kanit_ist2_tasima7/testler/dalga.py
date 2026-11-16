#!/usr/bin/env python3
# dalga.py <dizin>...  : süzülmüş koşu dosyalarından (WAVERUNNER t=) dalga başına medyan [aralık] (n); denetim sayısı
import re, sys, glob, statistics as st
for d in sys.argv[1:]:
    w = {}; den = 0; pas = 0; n = 0
    for f in sorted(glob.glob(d + "/*")):
        if f.endswith(".ham") or "." in f.split("/")[-1]:
            continue
        n += 1
        for l in open(f, errors="ignore"):
            m = re.search(r"WAVERUNNER wave=(\d+)/\d+ won=\S+ t=([\d.]+)", l)
            if m:
                w.setdefault(m.group(1), []).append(float(m.group(2)))
            if "VISAUDIT" in l or "SCRIPT ERROR" in l:
                den += 1
            if "AUTOTEST PASS" in l:
                pas += 1
    s = " · ".join("%s. dalga %.1f [%.1f–%.1f] (n %d)" % (k, st.median(v), min(v), max(v), len(v)) for k, v in sorted(w.items()))
    print("%s: koşu %d PASS %d denetim %d | %s" % (d, n, pas, den, s))
