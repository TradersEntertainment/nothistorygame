#!/usr/bin/env python3
"""tests/audio_run.sh'ın düzey tablosundan bölümler arası ses sıçramalarını bulur (tests/out/audio/levels.csv).

Her bölümün yol başına ortanca düzeyini oyunun genel ortancasıyla karşılaştırır: konuşma bir bölümde ötekilerden
4 dB'den fazla kısık/yüksekse, müzik 6 dB'den fazla, SFX konuşmanın üstüne çıkıyorsa yazar. Bölümden bölüme geçen
oyuncu ses düğmesine uzanmamalı.

    python3 tools/audio_report.py [levels.csv]
"""
import csv, os, statistics, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "tests/out/audio/levels.csv")
rows = [r for r in csv.DictReader(open(path)) if r.get("scene") and r["scene"] != "scene"]
by = {}
for r in rows:
    try:
        by.setdefault(r["scene"], {})[r["bus"]] = (float(r["median_db"]), float(r["p95_db"]), float(r["active_share"]))
    except (ValueError, KeyError):
        continue          # paralel yazımda bozulmuş satır
LIMIT = {"Voice": 4.0, "Music": 6.0, "SFX": 6.0, "Master": 4.0}
ref = {b: statistics.median(v[b][0] for v in by.values() if b in v and v[b][0] > -100) for b in LIMIT}
print("Genel ortanca: " + ", ".join(f"{b} {ref[b]:.1f} dB" for b in LIMIT))
n = 0
for sc in sorted(by):
    v = by[sc]
    out = []
    for b, lim in LIMIT.items():
        if b in v and v[b][0] > -100 and abs(v[b][0] - ref[b]) > lim:
            out.append(f"{b} {v[b][0]:+.1f} dB ({v[b][0] - ref[b]:+.1f})")
    if "SFX" in v and "Voice" in v and v["SFX"][1] > v["Voice"][1] + 3 and v["Voice"][0] > -100:
        out.append(f"SFX tepesi konuşmanın {v['SFX'][1] - v['Voice'][1]:.1f} dB üstünde")
    if out:
        n += 1
        print(f"  {sc:12s} " + "; ".join(out))
print(f"{n} bölümde sapma")
