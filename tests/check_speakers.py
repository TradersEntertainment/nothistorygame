#!/usr/bin/env python3
"""Seslendirme konuşmacı denetimi (v0.99.12): betiklerde bir repliği söyleten karakter (hud.say/bark("SPK_X", "ANAHTAR")
ve COUNCIL / COUNCIL_SPK gibi yan yana sabit diziler) ses haritasındaki (docs/voice/VOICE_MAP.csv) konuşmacıyla aynı
olmalı. Bölüm 25'teki konseyde Halil Paşa'nın iki repliği haritada SPK_HIKMET'ti: Halil, Hikmet'in sesiyle konuşuyordu.
Çıkış kodu: uyuşmazlık varsa 1."""
import csv, glob, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
vm = {r["anahtar"]: r["konusmaci"] for r in csv.DictReader(open(os.path.join(ROOT, "docs/voice/VOICE_MAP.csv"), encoding="utf-8"))}
pair = re.compile(r'\b(?:say|bark|say_wait)\w*\(\s*"(SPK_[A-Z0-9_]+)"\s*,\s*"([A-Z0-9_]+)"')
arrays = re.compile(r'const (\w+) := \[([^\]]*)\]\s*\nconst \1_SPK := \[([^\]]*)\]')
bad = []
for f in sorted(glob.glob(os.path.join(ROOT, "scripts/**/*.gd"), recursive=True)):
    s = open(f, encoding="utf-8").read()
    found = [m.groups() for m in pair.finditer(s)]
    for m in arrays.finditer(s):
        found += list(zip(re.findall(r'"(SPK_[A-Z0-9_]+)"', m.group(3)), re.findall(r'"([A-Z0-9_]+)"', m.group(2))))
    for spk, key in found:
        if key in vm and vm[key] != spk:
            bad.append(f"{key}: kodda {spk}, ses haritasında {vm[key]} ({os.path.relpath(f, ROOT)})")
for b in sorted(set(bad)):
    print("SPEAKERCHECK " + b)
print("SPEAKERCHECK %s" % ("FAIL" if bad else "PASS"))
sys.exit(1 if bad else 0)
