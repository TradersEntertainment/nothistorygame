import re,sys,glob,statistics as st
# dalga.py <etiket=glob> ... : WAVERUNNER t= medyan [aralık] (n), gunner=a/b, CESET4 düşen, AUTOTEST PASS/FAIL, denetim satırı
DEN=re.compile(r'^(SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID)')
for arg in sys.argv[1:]:
    et,pat=arg.split('=',1)
    w1=[];w2=[];gun=[];dus=[];pas=0;fail=0;den=0;n=0
    for f in sorted(glob.glob(pat)):
        if not f.endswith('.ham'): continue
        n+=1
        seen=set()
        for l in open(f,errors='ignore'):
            if l in seen: continue
            seen.add(l)
            m=re.match(r'WAVERUNNER wave=(\d)/2 won=\w+ t=([\d.]+)',l)
            if m: (w1 if m.group(1)=='1' else w2).append(float(m.group(2)))
            m=re.search(r'AUTOTEST (PASS|FAIL).*gunner=(\d+)/(\d+)',l)
            if m: gun.append('%s/%s'%(m.group(2),m.group(3)))
            if 'AUTOTEST PASS' in l: pas+=1
            if 'AUTOTEST FAIL' in l: fail+=1
            m=re.search(r'CESET4 .* dusen=(\d+) en_derin=(-?[\d.]+)',l)
            if m: dus.append((int(m.group(1)),float(m.group(2))))
            if DEN.match(l): den+=1
    f=lambda a: '%.1f [%.1f–%.1f] (n %d)'%(st.median(a),min(a),max(a),len(a)) if a else '-'
    print('| %s | %d/%d | %s | %s | %s | %s | %d |'%(et,pas,n,f(w1),f(w2),' '.join(gun),
        ('düşen %d/%d koşu, en derin %.1f'%(sum(1 for d in dus if d[0]>0),len(dus),min(d[1] for d in dus))) if dus else '-',den))
