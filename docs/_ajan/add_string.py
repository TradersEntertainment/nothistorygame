#!/usr/bin/env python3
"""i18n/strings.csv'ye kilitli, güvenli satır ekler. Kullanım: add_string.py ANAHTAR "türkçe" "english"
Anahtar zaten varsa dokunmaz (çıkış 0, 'var' yazar)."""
import csv, fcntl, io, sys
P = '/home/user/nothistorygame/i18n/strings.csv'
key, tr, en = sys.argv[1], sys.argv[2], sys.argv[3]
with open(P, 'r+', encoding='utf-8') as f:
    fcntl.flock(f, fcntl.LOCK_EX)
    s = f.read()
    if ('\n' + key + ',') in s or s.startswith(key + ','):
        print('var:', key); sys.exit(0)
    b = io.StringIO(); csv.writer(b, lineterminator='').writerow([key, tr, en])
    if not s.endswith('\n'):
        s += '\n'
    s += b.getvalue() + '\n'
    f.seek(0); f.write(s); f.truncate()
print('eklendi:', key)
