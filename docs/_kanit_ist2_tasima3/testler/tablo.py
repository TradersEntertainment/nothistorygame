import re,sys,glob,os,collections
d=sys.argv[1]
files=sorted(glob.glob(d+'/*'))
ozet=collections.Counter(); kotu=[]
for f in files:
    if f.endswith('.ham'): continue
    t=open(f,errors='ignore').read()
    p=t.count('AUTOTEST PASS'); fl=t.count('AUTOTEST FAIL')
    den=[l for l in t.splitlines() if re.match(r'(SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID)',l)]
    rc=re.search(r'rc=(\d+)',t)
    ozet['dosya']+=1; ozet['pass']+=p; ozet['fail']+=fl; ozet['denetim']+=len(den)
    if den or (p==0 and 'sozlesme' not in f): kotu.append((os.path.basename(f),den[:3],rc.group(1) if rc else '?'))
print(dict(ozet))
for k in kotu: print('KOTU',k)
# alan tabloları
rows=collections.defaultdict(list)
for f in files:
    if f.endswith('.ham'): continue
    for l in open(f,errors='ignore'):
        m=re.match(r'AUTOTEST PASS chapter=(\S+) variant=(\S*) (.*)',l.strip())
        if m:
            rows[(m.group(1),m.group(2) or 'def')].append(m.group(3))
for k in sorted(rows):
    print(k[0],k[1],' | '.join(rows[k]))
