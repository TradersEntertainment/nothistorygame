#!/usr/bin/env python3
"""docs/voice/CONSISTENCY.csv (voice_consistency.py çıktısı) -> scripts/autoload/voice_gain.gd.

Her replik için bir seviye düzeltmesi (dB) üretir: kısık ya da bağıran kayıtlar konuşmacının kendi
ortancasına, konuşmacılar da oyunun genel seviyesine çekilir (sınırlı: replik ±6 dB, konuşmacı ±4 dB).
Oyun hud.say'de bu düzeltmeyi uygular.
"""
import csv, os, statistics

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
rows = list(csv.DictReader(open(os.path.join(ROOT, "docs/voice/CONSISTENCY.csv"), encoding="utf-8")))
by = {}
for r in rows:
    by.setdefault(r["konusmaci"], []).append(float(r["seviye"]))
allmed = statistics.median(float(r["seviye"]) for r in rows)
gain = {}
for r in rows:
    lv = float(r["seviye"])
    smed = statistics.median(by[r["konusmaci"]])
    g = max(-6.0, min(6.0, (smed - lv) * 0.8)) + max(-4.0, min(4.0, allmed - smed))
    if abs(g) >= 1.0:
        gain[r["anahtar"]] = round(g, 1)
lines = ["extends RefCounted", "class_name VoiceGain",
         "## Seslendirme seviye düzeltmesi (dB): tools/voice_consistency.py ölçümünden üretildi.",
         "## Kısık/bağıran kayıtlar konuşmacının ve oyunun genel seviyesine çekilir. Yeniden üretmek için:",
         "##     python3 tools/voice_consistency.py && python3 tools/voice_gain.py", "const DB := {"]
lines += ['\t"%s": %s,' % (k, gain[k]) for k in sorted(gain)]
lines.append("}")
open(os.path.join(ROOT, "scripts/autoload/voice_gain.gd"), "w", encoding="utf-8").write("\n".join(lines) + "\n")
print(f"genel ortanca {allmed:.1f} dB, {len(gain)} replik düzeltildi")
