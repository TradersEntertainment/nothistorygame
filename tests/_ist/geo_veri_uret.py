import pickle,json,math,numpy as np
from shapely.geometry import Polygon, LineString, Point, box, MultiPolygon
from shapely.ops import unary_union, nearest_points, substring
from scipy.ndimage import distance_transform_edt, gaussian_filter
from PIL import Image, ImageDraw
C=pickle.load(open('/root/is2/osm/coast.pkl','rb'))
land=C['land']; Y=C['yarimada']
LAT0,LON0=41.0086,28.9802
KY=111132.0; KX=111320.0*math.cos(math.radians(LAT0))
def ll(la,lo): return ((lo-LON0)*KX,(la-LAT0)*KY)
parts=lambda g: list(g.geoms) if hasattr(g,'geoms') else [g]
# --- kara suru: Fatih siniri, kiyi disindaki kismi
import json
g=json.load(open('/root/is2/osm/fatih.json'))[1]['geojson']
F=Polygon([ll(c[1],c[0]) for c in g['coordinates'][0]])
ring=list(F.exterior.coords)
# bati siniri: e < -2900 ve (n>-2400) ; kiyidan uzak noktalar
sea=box(-12000,-9000,12000,11000).difference(land)
def far(p,d=120): return sea.distance(Point(p))>d
idx=[i for i,p in enumerate(ring) if p[0]<-2900 and far(p,60)]
# en uzun ardisik dizi
runs=[];cur=[]
N=len(ring)
for i in range(N):
    if i in set(idx): cur.append(i)
    else:
        if cur: runs.append(cur); cur=[]
if cur: runs.append(cur)
if len(runs)>1 and runs[0][0]==0 and runs[-1][-1]==N-1: runs[0]=runs[-1]+runs[0]; runs.pop()
run=max(runs,key=len)
wall=[ring[i] for i in run]
if wall[0][1]>wall[-1][1]: wall=wall[::-1]   # guneyden kuzeye
# uclari kiyiya uzat (yarimada kiyisina en yakin nokta)
Yb=Y.exterior
def snap(p): q=nearest_points(Yb,Point(p))[0]; return (q.x,q.y)
wall=[snap(wall[0])]+wall+[snap(wall[-1])]
WL=LineString(wall).simplify(4)
print('kara suru uzunluk',WL.length, 'uc',wall[0],wall[-1])
# --- yarimada kiyisi: kara suru uclari arasi deniz tarafi
yc=list(Y.exterior.coords)[:-1]
def nearest_i(p): return min(range(len(yc)),key=lambda i:(yc[i][0]-p[0])**2+(yc[i][1]-p[1])**2)
iS=nearest_i(wall[0]); iN=nearest_i(wall[-1]); iT=nearest_i(ll(41.0165,28.9870))
def walk(a,b):
    out=[];i=a
    while True:
        out.append(yc[i])
        if i==b: break
        i=(i+1)%len(yc)
    return out
c1=walk(iS,iN); c2=walk(iN,iS)
coast=c1 if len(c1)<len(c2) and iT in [nearest_i(p) for p in c1] else (c1 if any(abs(p[0]-yc[iT][0])<1 and abs(p[1]-yc[iT][1])<1 for p in c1) else c2)
if coast[0]!=yc[iS]: coast=coast[::-1]
k=coast.index(yc[iT])
marm=LineString(coast[:k+1]).simplify(4); halic=LineString(coast[k:]).simplify(4)
print('marmara',marm.length,'halic',halic.length)
# iceri 6 m kaydir (sur su kenarinda, karada)
def inset(L,d=6):
    o=L.parallel_offset(d,'left'); 
    if o.is_empty or Y.contains(o.interpolate(0.5,normalized=True))==False: o=L.parallel_offset(d,'right')
    if hasattr(o,'geoms'): o=max(o.geoms,key=lambda q:q.length)
    return o
marm_s=inset(marm); halic_s=inset(halic)
# yonleri: marmara kara surundan sarayburnuna, halic sarayburnundan ayvansaraya
def orient(L,start):
    c=list(L.coords)
    if Point(c[0]).distance(Point(start))>Point(c[-1]).distance(Point(start)): c=c[::-1]
    return LineString(c)
marm_s=orient(marm_s,wall[0]); halic_s=orient(halic_s,yc[iT])
# --- Galata
galpoly=Polygon([(-1150,1380),(-1110,1650),(-870,1880),(-540,1965),(-300,1935),(-80,1800),(110,1620),(260,1400),(-300,1100),(-1150,1150)])
G=galpoly.intersection(land)
G=max(parts(G),key=lambda p:p.area)
# galata suru: halka (kara tarafi + kiyi)
gal_s=LineString(list(G.exterior.coords))
# --- mese
P=lambda la,lo: ll(la,lo)
milion=(-230,-30); kforum=(-756,-11); tauri=(-1554,211); phil=(-1900,520)
havariyun=(-2450,1150); arkad=(-3330,-450); bous=(-2540,-70)
def on_wall(p): q=nearest_points(WL,Point(p))[0]; return (q.x,q.y)
edirnek=on_wall((-3545,2413)); altink=on_wall((-4797,-1679))
mese=[milion,(-480,-20),kforum,(-1100,90),tauri,phil]
mk=[phil,(-2150,800),havariyun,(-2950,1750),edirnek]
mg=[phil,(-2250,250),bous,(-2950,-250),arkad,(-4000,-1050),altink]
# lykos
lyk_in=[(-6800,2500),(-5600,1700),(-4600,1150),(-4200,950),(-3600,600),(-2900,250),(-2350,-150),(-2250,-500),(-2230,-900)]
# zincir
def on_coast(Lc,p): q=nearest_points(Lc,Point(p))[0]; return (q.x,q.y)
eug=on_coast(halic_s,(-336,878)); kast=on_coast(G.exterior,(-504,1434))
boz=[(-2460,1000),(-1600,730)]
# blakherna: kara surunun kuzey ucu (Tekfur'dan Halic'e)
wl=list(WL.coords)
tek=nearest_points(WL,Point(-3612,2880))[0]
dist_tek=WL.project(tek)
blak=substring(WL,dist_tek-30,WL.length)
# --- bolgeler
EU=C['EU']; AS=C['AS']
# --- izgara
X0,Z0,ST=-6000.0,-5500.0,10.0   # dunya
NX,NZ=1201,1001
xs=X0+np.arange(NX)*ST; zs=Z0+np.arange(NZ)*ST
E=xs[None,:]*2.0; Nn=-zs[:,None]*2.0
E=np.broadcast_to(E,(NZ,NX)); Nn=np.broadcast_to(Nn,(NZ,NX))
def rast(geom,val,img=None):
    im=img or Image.new('L',(NX,NZ),0); d=ImageDraw.Draw(im)
    for p in parts(geom):
        tr=[((e*0.5-X0)/ST,(-n*0.5-Z0)/ST) for e,n in p.exterior.coords]
        d.polygon(tr,fill=val)
        for r in p.interiors: d.polygon([((e*0.5-X0)/ST,(-n*0.5-Z0)/ST) for e,n in r.coords],fill=0)
    return im
im=rast(land.intersection(EU.buffer(400)),3)
im=rast(land.difference(EU.buffer(400)),4,im)
im=rast(Y,1,im); im=rast(G,2,im)
REG=np.array(im,dtype=np.uint8)
LAND=REG>0
dl=distance_transform_edt(LAND)*ST*2.0   # gercek m
ds=distance_transform_edt(~LAND)*ST*2.0
def gauss(e0,n0,s): return np.exp(-((E-e0)**2+(Nn-n0)**2)/(2*s*s))
def segdist(pts):
    D=np.full(E.shape,1e9)
    T=np.zeros(E.shape)
    acc=0.0; L=sum(math.dist(pts[i],pts[i+1]) for i in range(len(pts)-1))
    for i in range(len(pts)-1):
        ax,ay=pts[i];bx,by=pts[i+1]; dx,dy=bx-ax,by-ay; l2=dx*dx+dy*dy
        t=np.clip(((E-ax)*dx+(Nn-ay)*dy)/l2,0,1)
        d=np.hypot(E-(ax+t*dx),Nn-(ay+t*dy))
        m=d<D; D[m]=d[m]; T[m]=(acc+t[m]*math.sqrt(l2))/L
        acc+=math.sqrt(l2)
    return D,T
# yarimada hedef yukseklik (gercek m)
hills=[(250,250,40,330),(-740,0,50,330),(-1360,520,60,420),(-2450,1150,60,420),(-2600,1850,60,380),(-3700,2300,70,520),(-3400,-480,60,480),(-90,0,36,250)]
T=np.full(E.shape,14.0)
for e0,n0,hh,s in hills: T=np.maximum(T,hh*gauss(e0,n0,s)**0.6)
# sirt: tepeleri baglar
for a,b in [((250,250,40),(-740,0,50)),((-740,0,50),(-1360,520,60)),((-1360,520,60),(-2450,1150,60)),((-2450,1150,60),(-2600,1850,60)),((-2450,1150,60),(-3700,2300,70)),((-3700,2300,70),(-4300,2700,62)),((-3400,-480,60),(-4400,-900,45)),((-3400,-480,60),(-4200,400,58)),((-1360,520,60),(-2900,700,48))]:
    D,t=segdist([a[:2],b[:2]]); hh=a[2]+(b[2]-a[2])*t
    T=np.maximum(T,(hh-6)*np.exp(-D**2/(2*330**2)))
# bati yayla (surlar boyu)
T=np.maximum(T,52*np.clip((-E-3000)/1200,0,1)*np.exp(-np.maximum(Nn-2900,0)**2/(2*400**2)))
# Lykos vadisi
D,t=segdist(lyk_in); floor=np.interp(t,[0,0.3,0.45,0.6,0.8,1],[45,38,30,16,6,2])
w=np.exp(-D**2/(2*230**2))
Hp=T*(1-w)+np.minimum(T,floor)*w
# diger karalar
H=np.full(E.shape,20.0)
H+= 35*np.clip((-E-4500)/2500,0,1)  # trakya yayla
H=np.maximum(H, 60*gauss(-512,1889,500)**0.7)  # galata tepesi
H=np.maximum(H, 85*gauss(500,3300,1200)**0.8)  # pera sirti
H=np.maximum(H, 90*gauss(-1500,4200,1300)**0.8) # okmeydani
H=np.maximum(H, 80*gauss(-3880,5160,900)**0.8)  # eyup sirti
H=np.maximum(H, 70*gauss(2000,6500,2500)**0.8)  # besiktas yamaclari
# Asya
asia=REG==4
Ha=40+50*np.clip((E-2500)/3500,0,1)+190*gauss(7470,2050,1300)**0.9+60*gauss(6600,3000,900)
H=np.where(asia,Ha,H)
# kasimpasa vadisi, kagithane/alibey dereleri, lykos dis
for pts,wid,fl in [([(-900,1700),(-700,2800),(-300,4200)],200,4),([(-2700,4300),(-2000,5300),(-1200,7000),(-500,9000)],300,3),([(-3300,4500),(-4300,6500),(-5000,9000)],280,4)]:
    D,t=segdist(pts); w=np.exp(-D**2/(2*wid**2)); H=H*(1-w)+fl*w
D,t=segdist(lyk_in[:4]); w=np.exp(-D**2/(2*260**2)); H=H*(1-w)+np.minimum(H,40)*w
# hafif dalga
H+= 4*np.sin(E/700.0+1.3)*np.sin(Nn/530.0+0.4)+2.5*np.sin(E/260.0)*np.cos(Nn/310.0)
yar=REG==1
H=np.where(yar,Hp+1.5*np.sin(E/300.0)*np.sin(Nn/270.0),H)
H=gaussian_filter(H,1.2)
# kiyi rampasi
R=np.where(yar,220.0,np.where(REG==2,120.0,260.0))
s=np.clip(dl/R,0,1); s=s*s*(3-2*s)
Hl=1.6+(H-1.6)*s
# deniz tabani
dep=np.minimum(3+0.09*ds,70)
Hs=-dep
Hreal=np.where(LAND,Hl,Hs)
# kiyi gecisi yumusak (kara kenari ~1.6, deniz ilk hucre ~ -2)
HW=(Hreal*0.5).astype(np.float32)
print('h aralik',HW.min(),HW.max(),'yarimada max',HW[yar].max())
import os
os.makedirs('/root/is2/out',exist_ok=True)
HW.tofile('/root/is2/out/h.bin'); REG.tofile('/root/is2/out/reg.bin')
# cizim
v=np.clip((HW+10)/60,0,1)
rgb=np.stack([v*200+40*(~LAND),v*180+60,np.where(LAND,v*120,200)],-1).astype(np.uint8)
Image.fromarray(rgb).save('/root/is2/out/hmap.png')
# --- GDScript sabitleri (dunya koordinat)
def W(pts): return [(round(e*0.5,2),round(-n*0.5,2)) for e,n in pts]
def gd(name,pts):
    s=", ".join(f"Vector2({x},{z})" for x,z in W(pts))
    return f"static var {name} := PackedVector2Array([{s}])\n"
outs=""
yar_s=Y.simplify(3)
outs+=gd("K_YARIMADA",list(yar_s.exterior.coords)[:-1])
outs+=gd("K_GALATA",list(G.simplify(3).exterior.coords)[:-1])
# anadolu & trakya: buyuk parcalar (kaba)
AL=[p for p in parts(land) if p.intersects(Point(5000,0))]
AL=max(parts(land.intersection(AS.buffer(400))),key=lambda p:p.area).simplify(12)
TL=max(parts(land.intersection(EU.buffer(400)).difference(Y.buffer(1)).difference(G.buffer(1))),key=lambda p:p.area).simplify(12)
outs+=gd("K_ANADOLU",list(AL.exterior.coords)[:-1])
outs+=gd("K_TRAKYA",list(TL.exterior.coords)[:-1])
outs+=gd("Y_KARA",list(WL.coords))
outs+=gd("Y_BLAKHERNA",list(blak.coords))
outs+=gd("Y_MARMARA",list(marm_s.simplify(3).coords))
outs+=gd("Y_HALIC",list(halic_s.simplify(3).coords))
outs+=gd("Y_GALATA",list(gal_s.simplify(3).coords))
outs+=gd("Y_MESE",mese); outs+=gd("Y_MESE_K",mk); outs+=gd("Y_MESE_G",mg)
outs+=gd("Y_LYKOS",lyk_in); outs+=gd("Y_ZINCIR",[eug,kast]); outs+=gd("Y_BOZDOGAN",boz)
open('/root/is2/out/sabitler.gd','w').write(outs)
print('nokta: yarimada',len(yar_s.exterior.coords),'galata',len(G.simplify(3).exterior.coords),'anadolu',len(AL.exterior.coords),'trakya',len(TL.exterior.coords),'kara',len(WL.coords))
pickle.dump({'WL':WL,'marm':marm_s,'halic':halic_s,'G':G,'mese':mese,'mk':mk,'mg':mg,'lyk':lyk_in,'zin':[eug,kast],'boz':boz,'blak':blak},open('/root/is2/out/yollar.pkl','wb'))
