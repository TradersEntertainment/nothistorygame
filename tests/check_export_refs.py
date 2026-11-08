#!/usr/bin/env python3
"""Paketli oyunda olmayan kod: export_presets.cfg tests/, tools/, docs/ klasörlerini dışarıda bırakır. Oyun kodu
(scripts/, scenes/) bu klasörlerdeki bir class_name'i adıyla kullanırsa paketli oyunda ana betik derlenmez: müzik
çalar, pencere gri kalır (v0.99.70-80, HeldCycle). Yol ile çalışırken yükleme (load("res://tests/..")) serbesttir."""
import re, glob, sys
defs = {}
for f in glob.glob("tests/**/*.gd", recursive=True) + glob.glob("tools/**/*.gd", recursive=True):
    m = re.search(r"^class_name\s+(\w+)", open(f, encoding="utf-8").read(), re.M)
    if m:
        defs[m.group(1)] = f
bad = []
for f in glob.glob("scripts/**/*.gd", recursive=True) + glob.glob("scenes/**/*.tscn", recursive=True):
    s = open(f, encoding="utf-8").read()
    for c, src in defs.items():
        if re.search(r"\b%s\b" % c, s):
            bad.append(f"{f}: {c} ({src} paketlenmez)")
    for m in re.findall(r'ext_resource[^\n]*path="res://(?:tests|tools|docs)/[^"]+"', s):
        bad.append(f"{f}: {m}")
for b in bad:
    print("EXPORTREF", b)
print("EXPORTREFS", "PASS" if not bad else "FAIL %d" % len(bad))
sys.exit(1 if bad else 0)
