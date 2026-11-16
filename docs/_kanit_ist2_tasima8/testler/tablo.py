import glob, os, re, collections
d = '/root/is/t8/g'
def oku(n):
    t = open(os.path.join(d, n), encoding='utf-8', errors='replace').read()
    au = re.findall(r'AUTOTEST (PASS|FAIL)', t)
    den = [l for l in t.splitlines() if re.search(r'SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID', l)]
    w = re.findall(r'WAVERUNNER wave=(\d+)/(\d+) won=\w+ t=([\d.]+)', t)
    return (au[0] if au else 'YOK'), den, w
rows = collections.OrderedDict()
for f in sorted(glob.glob(d + '/*')):
    n = os.path.basename(f)
    if n.endswith('.ham') or n.startswith('menu'): continue
    m = re.match(r'([ye])(26o?)_(.+?)(?:_(\d+))?$', n)
    if not m: continue
    s, ch, v, k = m.groups()
    rows.setdefault((ch, v), {'y': [], 'e': []})[s].append((n,) + oku(n))
for ch in ['26', '26o']:
    print('\n#### Çeşit tablosu %s (yeni = son kod; eski = `--eskisur=%s`)' % (ch, ch))
    print('| Çeşit | Yeni koşu | Yeni PASS | Denetim (yeni) | Eski | Dalga süreleri yeni (sn) | Dalga eski (sn) |')
    print('|---|---|---|---|---|---|---|')
    for (c, v), r in rows.items():
        if c != ch or v.startswith('yuru'): continue
        yp = sum(1 for x in r['y'] if x[1] == 'PASS')
        yd = sum(len(x[2]) for x in r['y'])
        ep = ' '.join('%s, denetim %d' % (x[1], len(x[2])) for x in r['e']) or '—'
        wy = '; '.join(' '.join(t for (_, _, t) in x[3]) for x in r['y'][:3])
        we = '; '.join(' '.join(t for (_, _, t) in x[3]) for x in r['e'][:1])
        print('| %s | %d | %d/%d | %d | %s | %s | %s |' % (v if v != 'def' else '""', len(r['y']), yp, len(r['y']), yd, ep, wy, we))
print('\n#### Bağımlı bölümler (×1, son ortak kod)')
print('| Bölüm | Sonuç | Denetim | Dalgalar |')
print('|---|---|---|---|')
for f in sorted(glob.glob(d + '/d_*')):
    n = os.path.basename(f)
    if n.endswith('.ham'): continue
    a, den, w = oku(n)
    print('| %s | %s | %d | %s |' % (n[2:], a, len(den), ' '.join('%s/%s:%s' % x for x in w)))
