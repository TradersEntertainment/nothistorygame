import math, numpy as np, re
exec(open('/root/isw/py/fit.py').read().split('R=[];W=[]')[0])
for k,(ll,w) in list(pts.items()): pts[k]=(ll,w,en(*ll))
names=list(pts); P=np.array([pts[k][2] for k in names])/1000.0; W=np.array([pts[k][1] for k in names],float)
n=len(P)
def U(d): 
    with np.errstate(divide='ignore',invalid='ignore'):
        r=np.where(d>0,d*d*np.log(d),0.0)
    return r
K=U(np.linalg.norm(P[:,None]-P[None],axis=2))
lam=0.0
L=np.zeros((n+3,n+3)); L[:n,:n]=K+lam*np.eye(n); L[:n,n]=1; L[:n,n+1:]=P; L[n,:n]=1; L[n+1:,:n]=P.T
Y=np.zeros((n+3,2)); Y[:n]=W
S=np.linalg.solve(L,Y); w=S[:n]; a=S[n:]
def f(r):
    r=np.array(r)/1000.0; d=np.linalg.norm(P-r,axis=1)
    return a[0]+a[1]*r[0]+a[2]*r[1]+U(d)@w
neg=0;tot=0
for e in range(-6000,2600,100):
  for nn in range(-2000,4600,100):
    r=np.array([e,nn],float); f0=f(r); jx=f(r+[1,0])-f0; jy=f(r+[0,1])-f0; d=jx[0]*jy[1]-jy[0]*jx[1]
    tot+=1; neg+= d>0
print("TPS fold",neg,tot, "anchor err", max(np.linalg.norm(f(np.array(pts[k][2]))-np.array(pts[k][1])) for k in names))
print("A=",a.round(7).tolist())
for k,wi in zip(names,w): print(f'\t["{k}", Vector2({pts[k][2][0]:.2f}, {pts[k][2][1]:.2f}), Vector2({pts[k][1][0]:.1f}, {pts[k][1][1]:.1f}), Vector2({wi[0]:.7f}, {wi[1]:.7f})],')
