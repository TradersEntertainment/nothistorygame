#!/usr/bin/env python3
"""Fizik-ayak: ayak_kos.sh günlüklerinden ÖNCE|SONRA tabloları (Markdown).
Kullanım: python3 tests/_fizik/ayak_tablo.py <günlük klasörü> <bölüm[:çeşit]>...
AYAKAUDIT satır sayısı (yakın ≤ 25 m / hepsi), AUTOTEST sonucu, öteki denetim satırları ve AYAKPERF ortalamaları."""
import re, sys, os

d = sys.argv[1]
chs = sys.argv[2:]
DEN = re.compile(r"SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|POSEAUDIT|WARN_FX|WARN_FLY|WARN_VOID")


def oku(kip, c):
    p = os.path.join(d, "%s_%s.log" % (kip, c.replace(":", "_")))
    if not os.path.exists(p):
        return None
    L = open(p, encoding="utf-8", errors="replace").read().splitlines()
    r = {"pass": any(l.startswith("AUTOTEST PASS") for l in L), "fail": any("AUTOTEST FAIL" in l for l in L),
         "yakin": sum(1 for l in L if l.startswith("AYAKAUDIT yakin")), "hepsi": sum(1 for l in L if l.startswith("AYAKAUDIT")),
         "den": len(set(l for l in L if DEN.search(l))), "perf": []}
    for l in L:
        m = re.match(r"AYAKPERF kare=(\d+) proc_ms=([\d.]+) ik_us=([\d.]+) ik_kisi=([\d.]+) isin=([\d.]+)", l)
        if m:
            r["perf"].append([float(x) for x in m.groups()])
    return r


def ort(perf, i):
    w = sum(p[0] for p in perf)
    return sum(p[i] * p[0] for p in perf) / w if w else float("nan")


print("| Bölüm | ÖNCE sonuç | ÖNCE AYAKAUDIT yakın / hepsi | SONRA sonuç | SONRA AYAKAUDIT yakın / hepsi | öteki denetim (ÖNCE → SONRA) |")
print("|---|---|---|---|---|---|")
top = [0, 0, 0, 0]
for c in chs:
    o, s = oku("once", c), oku("sonra", c)
    if not o or not s:
        print("| %s | – | – | – | – | günlük yok |" % c)
        continue
    sn = lambda r: "PASS" if r["pass"] else ("FAIL" if r["fail"] else "yarım")
    print("| %s | %s | %d / %d | %s | **%d** / %d | %d → %d |" % (c, sn(o), o["yakin"], o["hepsi"], sn(s), s["yakin"], s["hepsi"], o["den"], s["den"]))
    top[0] += o["yakin"]; top[1] += o["hepsi"]; top[2] += s["yakin"]; top[3] += s["hepsi"]
print("| **toplam** | | **%d** / %d | | **%d** / %d | |" % tuple(top))
print()
print("| Bölüm | ÖNCE işlem ms/kare | SONRA işlem ms/kare | fark | SONRA IK µs/kare | IK'lı kişi/kare | ışın/kare | IK payı (SONRA işlemin %) |")
print("|---|---|---|---|---|---|---|---|")
for c in chs:
    o, s = oku("once", c), oku("sonra", c)
    if not o or not s or not o["perf"] or not s["perf"]:
        continue
    po, ps = ort(o["perf"], 1), ort(s["perf"], 1)
    ik = ort(s["perf"], 2)
    print("| %s | %.2f | %.2f | %+.1f%% | %.0f | %.1f | %.2f | %.2f%% |" % (c, po, ps, (ps - po) / po * 100.0, ik, ort(s["perf"], 3),
        ort(s["perf"], 4), ik / 1000.0 / ps * 100.0))
