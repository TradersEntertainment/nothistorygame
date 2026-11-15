import re,sys,glob
for f in sorted(sys.argv[1:]):
    n=0; who=[]
    for l in open(f,errors='ignore'):
        if 'an=sonra_set' not in l: continue
        m=re.search(r'team=(\d) state=(\w+) target=\w+ vis=(\w+) withdrawn=\w+ qdel=(\w+) at=\(([-\d.]+), ([-\d.]+), ([-\d.]+)\)',l)
        t,st,vis,qd,x,y,z=m.groups(); x,y,z=float(x),float(y),float(z)
        if vis=='true' and qd=='false' and abs(x)<4.5 and 11.7<z<13.5 and y>-0.5:
            n+=1; who.append('team%s/%s@(%.1f,%.1f,%.1f)'%(t,st,x,y,z))
    va=sum(1 for l in open(f,errors='ignore') if l.startswith('VISAUDIT'))
    gb=[l.strip() for l in open(f,errors='ignore') if l.startswith('GEDIKBOSALT')]
    print(f.split('/')[-1], 'kutu_icinde=%d'%n, ' '.join(who), 'visaudit=%d'%va, ' '.join(gb))
