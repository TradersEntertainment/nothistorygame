#!/usr/bin/env python3
"""Koddaki metin anahtarları strings.csv'de var mı; boş çeviri var mı.
   python3 tests/check_keys.py   (çıkış kodu: eksik varsa 1)"""
import csv, glob, re, sys

rows = {}
with open('i18n/strings.csv', encoding='utf-8') as f:
    r = csv.reader(f)
    hdr = next(r)
    for row in r:
        if row:
            rows[row[0]] = row
used = {}
pat = re.compile(r'"((?:D|UI|SPK|FLOW|SIEGE|NOTE|CH|BARK|ITEM|EV)[A-Z0-9]*_[A-Z0-9_]+)"')
for p in glob.glob('scripts/**/*.gd', recursive=True):
    for m in pat.finditer(open(p, encoding='utf-8').read()):
        used.setdefault(m.group(1), p)
bad = 0
for k, p in sorted(used.items()):
    if k not in rows and not k.endswith('_'):
        print('EKSIK', k, p)
        bad += 1
for k, row in rows.items():
    for i, c in enumerate(row[1:], 1):
        if c.strip() == '':
            print('BOS', k, hdr[i])
            bad += 1
print('anahtar:', len(used), 'sorun:', bad)
sys.exit(1 if bad else 0)
