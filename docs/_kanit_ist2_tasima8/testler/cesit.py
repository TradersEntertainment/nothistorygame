import glob, os, re, sys
d = sys.argv[1]
rows = {}
for f in sorted(glob.glob(os.path.join(d, '*'))):
    if f.endswith('.ham'): continue
    n = os.path.basename(f)
    t = open(f, encoding='utf-8', errors='replace').read()
    au = re.findall(r'AUTOTEST (PASS|FAIL)', t)
    den = [l for l in t.splitlines() if re.search(r'SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID', l)]
    waves = re.findall(r'WAVERUNNER wave=(\d+)/(\d+) won=(\w+) t=([\d.]+)', t)
    ks = re.search(r'KOSU rc=-?\d+ sure=(\d+)', t)
    rows[n] = (au[0] if au else 'YOK', den, waves, ks.group(1) if ks else '?')
for n, (a, den, w, s) in rows.items():
    ws = ' '.join('%s/%s:%s' % (x[0], x[1], x[3]) for x in w)
    print('| %s | %s | %d | %s | %s |' % (n, a, len(den), ws, s))
    for l in den:
        print('|  ↳ | | | %s | |' % l[:220].replace('|', '/'))
