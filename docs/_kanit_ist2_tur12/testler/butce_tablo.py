#!/usr/bin/env python3
# butce_tablo.py <bolum>... : butce/<bolum>.txt → markdown (yön başına çizim/ilkel ÖNCE → SONRA)
import re, sys
print("| bölüm | yön | çizim ÖNCE → SONRA | ilkel ÖNCE → SONRA |")
print("|---|---|---|---|")
for b in sys.argv[1:]:
    d = {"ONCE": {}, "SONRA": {}}
    for l in open(f"butce/{b}.txt"):
        m = re.match(r"(ONCE|SONRA) T12BUTCE yon=(\d) cizim=(\d+) ilkel=(\d+)", l)
        if m:
            d[m.group(1)][m.group(2)] = (int(m.group(3)), int(m.group(4)))
    for y in sorted(set(d["ONCE"]) & set(d["SONRA"])):
        (oc, op), (sc, sp) = d["ONCE"][y], d["SONRA"][y]
        print(f"| {b[1:]} | {y} | {oc} → {sc} ({(sc-oc)*100/oc:+.1f}%) | {op/1e6:.2f} M → {sp/1e6:.2f} M ({(sp-op)*100/op:+.2f}%) |")
