#!/usr/bin/env python3
# butce.py <eski.log> <yeni.log> : =kare günlüklerinden an başına çizim/ilkel ESKİ | YENİ tablosu (markdown)
import re, sys
def oku(f):
    out = {}
    for l in open(f, errors="ignore"):
        m = re.search(r"KARE an_(\d+)_(\S+)\.jpg .*cizim=(\d+) ilkel=(\d+)", l)
        if m:
            out[m.group(2)] = (int(m.group(3)), int(m.group(4)))
    return out
e, y = oku(sys.argv[1]), oku(sys.argv[2])
print("| an | çizim eski → yeni | ilkel eski → yeni |")
print("|---|---|---|")
for k in y:
    if k in e:
        (ec, ep), (yc, yp) = e[k], y[k]
        print("| %s | %s → %s (%+.0f%%) | %.2f M → %.2f M (%+.0f%%) |" % (k, f"{ec:,}".replace(",", "."), f"{yc:,}".replace(",", "."),
              (yc - ec) * 100.0 / ec, ep / 1e6, yp / 1e6, (yp - ep) * 100.0 / ep))
