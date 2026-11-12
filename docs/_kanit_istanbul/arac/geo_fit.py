import math, numpy as np
A=(41.0086,28.9802)
def en(lat,lon):
    return ((lon-A[1])*111320*math.cos(math.radians(41.01)), (lat-A[0])*111320)
pts={ # ad: (lat,lon), (world x,z)
"ayasofya":((41.0086,28.9802),(-560,-1480)),
"hippodrome":((41.0060,28.9752),(-470,-1440)),
"column":((41.0086,28.9712),(-470,-1300)),
"forum_tauri":((41.0105,28.9640),(-390,-1130)),
"apostles":((41.0193,28.9497),(-330,-760)),
"pantokrator":((41.0198,28.9567),(-540,-930)),
"pammakaristos":((41.0296,28.9465),(-575,-470)),
"petrion_gate":((41.0302,28.9500),(-700,-650)),
"khora":((41.0312,28.9392),(-500,-85)),
"blachernae_palace":((41.0339,28.9406),(-668,-72)),
"harisios":((41.0296,28.9353),(-460,0)),
"romanos":((41.0186,28.9214),(0,0)),
"pege":((41.0047,28.9178),(340,0)),
"golden_gate":((40.9939,28.9226),(650,-10)),
"studios":((41.0003,28.9289),(540,-158)),
"eugenius":((41.0163,28.9877),(-690,-1525)),
"galata_tower":((41.0256,28.9742),(-971,-1330)),
"damalis":((41.0211,29.0041),(-560,-2072)),
"eyup":((41.0478,28.9340),(-690,250)),
}
R=[];W=[]
for k,(ll,w) in pts.items():
    e,n=en(*ll); R.append([e,n,1]); W.append(w); pts[k]=(ll,w,(e,n))
R=np.array(R);W=np.array(W,float)
M,res,_,_=np.linalg.lstsq(R,W,rcond=None)
print("M=",M.T.round(5))
P=R@M
for (k,v),p in zip(pts.items(),P):
    e,n=v[2]; print(f"{k:18s} real=({e:7.0f},{n:7.0f}) world={v[1]} fit=({p[0]:7.1f},{p[1]:7.1f}) err={math.dist(p,v[1]):6.1f}")
a,b=M[0,0],M[1,0]; c,d=M[0,1],M[1,1]
print("det",a*d-b*c,"scale",math.sqrt(abs(a*d-b*c)))
print("---- GD")
for k,v in pts.items():
    e,n=v[2]; print(f'\t["{k}", Vector2({e:.0f}, {n:.0f}), Vector2({v[1][0]:.1f}, {v[1][1]:.1f})],')
print(M)
print("---- fold")
A=np.array([[M[0,0],M[1,0]],[M[0,1],M[1,1]]]); Tt=np.array([M[2,0],M[2,1]])
an=[(np.array(v[2]),np.array(v[1],float)) for v in pts.values()]
resd=[w-(A@r+Tt) for r,w in an]
def fw(r):
    s=0;acc=np.zeros(2)
    for (ra,_),rs in zip(an,resd):
        d2=((r-ra)**2).sum()
        if d2<1: return _+0
        w=1/d2;s+=w;acc+=rs*w
    return A@r+Tt+acc/s
# jacobian det sign over grid
neg=0;tot=0
for e in range(-6000,2500,100):
  for n in range(-2000,4500,100):
    r=np.array([e,n],float); f=fw(r)
    jx=(fw(r+[1,0])-f); jy=(fw(r+[0,1])-f); d=jx[0]*jy[1]-jy[0]*jx[1]
    tot+=1
    if d>0: neg+=1
print("fold cells",neg,"of",tot)
