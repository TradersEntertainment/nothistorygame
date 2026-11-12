import re,sys,statistics as st
def load(p):
    d={}
    for l in open(p,errors='ignore'):
        m=re.match(r'DSHOT key=(\S+) draws=(\d+) prims=(\d+)',l)
        if m and m.group(1) not in d: d[m.group(1)]=(int(m.group(2)),int(m.group(3)))
    return d
a=load(sys.argv[1]); b=load(sys.argv[2])
ks=[k for k in a if k in b]
rows=[]
for k in ks:
    dd=b[k][0]-a[k][0]; dp=(b[k][1]-a[k][1])/a[k][1]*100
    rows.append((k,a[k],b[k],dd,dp))
print("ortak an:",len(rows))
print("cizim fark ortanca %.0f, en iyi %d, en kotu %d; artan an: %d"%(st.median(r[3] for r in rows),min(r[3] for r in rows),max(r[3] for r in rows),sum(1 for r in rows if r[3]>0)))
print("ucgen %% ortanca %.2f en kotu %.2f; >8%% an: %d"%(st.median(r[4] for r in rows),max(r[4] for r in rows),sum(1 for r in rows if r[4]>8)))
for r in sorted(rows,key=lambda r:-r[4])[:int(sys.argv[3]) if len(sys.argv)>3 else 6]: print("  %-24s draws %d->%d (%+d) prims %d->%d (%+.1f%%)"%(r[0],r[1][0],r[2][0],r[3],r[1][1],r[2][1],r[4]))
print(" cizim en cok artan:")
for r in sorted(rows,key=lambda r:-r[3])[:4]: print("  %-24s draws %d->%d (%+d) prims (%+.1f%%)"%(r[0],r[1][0],r[2][0],r[3],r[4]))
