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
# Akış şeması etiketleri ve tespit notları sabit sonuç numarası taşımaz: ekrandaki numara tarafa ve sıraya göre
# değişir (Bölüm 26 Bizans'ta 24, Osmanlı'da 30). Numarayı akış şeması kendisi yazar; metin içinde anılan sonuç
# {o:13.6} biçiminde yazılır (GameState.fill_outcomes).
num = re.compile(r'(?<![\w.{:])(?:\d+[A-Za-z]?|[A-Z])\.\d[a-z]?(?![\w.])')
for k, row in rows.items():
    if not (k.startswith('FLOW') or k.startswith('SIEGE_NOTE')):
        continue
    for i, c in enumerate(row[1:], 1):
        m = num.search(re.sub(r'\{o:[^}]*\}', '', c))
        if m:
            print('SABIT_NUMARA', k, hdr[i], repr(m.group(0)), '→ {o:…} kullan ya da sil')
            bad += 1
# Kodun çaldığı her efektin dosyası var mı (yoksa Audio.sfx sessizce hiçbir şey çalmaz: deklanşör, gıcırtı...)
import os
have = {f[:-4] for f in os.listdir('assets/audio/sfx') if f.endswith('.ogg')}
for p in glob.glob('scripts/**/*.gd', recursive=True):
    for i, ln in enumerate(open(p, encoding='utf-8')):
        for m in re.finditer(r'Audio\.sfx(?:_at)?\(\s*"([a-z0-9_]+)"', ln):
            if m.group(1) not in have and m.group(1) + '_1' not in have:
                print('EKSIK_SES', m.group(1), '%s:%d' % (p, i + 1), '(tools/sfx_gen.py)')
                bad += 1
# Fotoğraf kartının altyazısı "PHOTO_" + kim: tespit karesi (TespitCam.new(..., "siegeNN")) ve selfie görevinin
# kişileri. Anahtar yoksa kartta ham anahtar yazar (Tespit · PHOTO_SIEGE29 · 1453).
who = set()
for p in glob.glob('scripts/**/*.gd', recursive=True):
    for m in re.finditer(r'TespitCam\.new\([^)]*"([a-z0-9_]+)"\)', open(p, encoding='utf-8').read()):
        who.add((m.group(1), p))
q = open('scripts/quests.gd', encoding='utf-8').read()
sel = re.search(r'"selfie":\s*\{[^}]*"targets":\s*\[([^\]]*)\]', q)
for t in re.findall(r'"([a-z_]+)"', sel.group(1) if sel else ''):
    who.add((t, 'scripts/quests.gd'))
for w, p in sorted(who):
    if 'PHOTO_' + w.upper() not in rows:
        print('EKSIK_ALTYAZI', 'PHOTO_' + w.upper(), p)
        bad += 1
print('anahtar:', len(used), 'sorun:', bad)
sys.exit(1 if bad else 0)
