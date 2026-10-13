#!/usr/bin/env python3
"""docs/voice/INLINE.json (duygu etiketli seslendirme metni) ile i18n/strings.csv (altyazı) aynı cümle mi?
Altyazı düzeltilip INLINE eski kalırsa ses eski cümleyi okur (Edirne: Radu 'Orası çok sıkıcıydı' diyordu, altyazıda
başka cümle vardı). Etiketler ([excited]) ve sahne notları ((Telsiz)) yok sayılır. Sorun varsa çıkış kodu 1."""
import csv, json, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "tools"))
from voice_gen import inline_norm  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..")
inl = json.load(open(os.path.join(ROOT, "docs/voice/INLINE.json"), encoding="utf-8"))
strings = {}
for r in csv.reader(open(os.path.join(ROOT, "i18n/strings.csv"), encoding="utf-8")):
    if len(r) >= 3:
        strings[r[0]] = {"tr": r[1], "en": r[2]}
bad = []
for k, v in inl.items():
    if k.startswith("_"):
        continue
    if k not in strings:
        bad.append(f"{k}: strings.csv'de yok (silinmiş replik)")
        continue
    for lang in ("tr", "en"):
        if v.get(lang) and inline_norm(v[lang]) != inline_norm(strings[k][lang]):
            bad.append(f"{k} ({lang}): INLINE '{v[lang][:60]}' ≠ altyazı '{strings[k][lang][:60]}'")
for b in bad:
    print("INLINECHECK", b)
print("INLINECHECK %s (%d anahtar, %d sorun)" % ("PASS" if not bad else "FAIL", len(inl), len(bad)))
sys.exit(1 if bad else 0)
