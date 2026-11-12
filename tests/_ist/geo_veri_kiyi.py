import json,math,glob
from shapely.geometry import Polygon, MultiPolygon, box, Point, LineString
from shapely.ops import unary_union
LAT0,LON0=41.0086,28.9802
KY=111132.0; KX=111320.0*math.cos(math.radians(LAT0))
def en(lon,lat): return ((lon-LON0)*KX,(lat-LAT0)*KY)
def ll2en(lat,lon): return en(lon,lat)
def load(f,idx=0):
    g=json.load(open(f'/root/is2/osm/{f}.json'))[idx]['geojson']
    polys=[g['coordinates']] if g['type']=='Polygon' else g['coordinates']
    out=[]
    for p in polys:
        out.append(Polygon([en(*c) for c in p[0]]).buffer(0))
    return unary_union(out)
EXT=box(-12000,-9000,12000,11000)
fatih=load('fatih',1)
eu=[fatih]+[load(f) for f in ['BeyoluIstanbul','EypsultanIstanbul','BeiktaIstanbul','ZeytinburnuIstanbul','iliIstanbul','BakrkyIstanbul','d_SaryerIstanbul','d_BayrampaaIstanbul','d_GaziosmanpaaIstanbul','d_EsenlerIstanbul','d_GngrenIstanbul','d_BahelievlerIstanbul','d_BaclarIstanbul','d_SultangaziIstanbul','d_KkekmeceIstanbul']]+[load('KathaneIstanbul',1)]
asia=[load(f) for f in ['skdarIstanbul','KadkyIstanbul','d_BeykozIstanbul','d_AtaehirIstanbul','d_mraniyeIstanbul','d_MaltepeIstanbul']]
def fill(g):
    g=g.buffer(30).buffer(-30)
    if isinstance(g,Polygon): return Polygon(g.exterior)
    return unary_union([Polygon(p.exterior) for p in g.geoms])
EU=fill(unary_union(eu)).intersection(EXT)
AS=fill(unary_union(asia)).intersection(EXT)
# inland fillers (far edges of box)
EU=unary_union([EU, box(-12000,6000,-3000,11000).difference(AS)]).intersection(EXT)
AS=unary_union([AS, box(9000,-2000,12000,11000)]).intersection(EXT)
land=unary_union([EU,AS])
sea=EXT.difference(land)
# 1453: dolgulari geri al
grow=[sea.buffer(60)]
marm=Polygon([(-5200,-700),(-5200,-4000),(1500,-4000),(1500,300),(700,300),(-1000,-500)])  # yarimada guneyi
grow.append(sea.buffer(40).intersection(marm))
emin=Polygon([(-1800,600),(-1800,1500),(1200,1500),(1200,300),(400,300)])  # Eminonu-Sarayburnu
grow.append(sea.buffer(130).intersection(emin))
hayd=Polygon([(2300,-1500),(2300,1200),(4200,1200),(4200,-1500)]) # Harem-Haydarpasa-Kadikoy
grow.append(sea.buffer(160).intersection(hayd))
kara=Polygon([(-1200,1300),(-1200,1900),(800,2600),(800,1300)])   # Karakoy-Tophane
grow.append(sea.buffer(70).intersection(kara))
sea2=unary_union(grow)
# Marmara sur hatti (kestirim, 1453): Mermer Kule -> Kumkapi; altindaki her sey deniz
WL=[(-5300,-1900),(-4950,-1850),(-4700,-1780),(-4450,-1640),(-4200,-1420),(-3950,-1120),(-3750,-900),(-3500,-880),(-3250,-860),(-3000,-850),(-2500,-830),(-2000,-810),(-1500,-790),(-1250,-770),(-1150,-800)]
sea2=unary_union([sea2, Polygon(WL+[(-1150,-3500),(-5300,-3500)])])
# Kontoskalion havuzu (Kumkapi), kucuk girinti
sea2=unary_union([sea2, box(-1330,-860,-1080,-650).buffer(25)])
land2=EXT.difference(sea2)
# Kiz Kulesi adacigi
kk=Point(*ll2en(41.02110,29.00410)).buffer(28)
land2=unary_union([land2,kk])
land2=land2.buffer(5).buffer(-5)
def parts(g):
    return list(g.geoms) if hasattr(g,'geoms') else [g]
# bolgeler
P=[p for p in parts(land2) if p.area>2000]
print('parca',len(P),[int(p.area) for p in P][:20])
fat1453=fatih.intersection(land2)
fat1453=max(parts(fat1453),key=lambda p:p.area)
res={'yarimada':fat1453}
res['land']=land2
json.dump({'land':[ [list(p.exterior.coords)]+[list(i.coords) for i in p.interiors] for p in P],
           'yarimada':list(fat1453.exterior.coords)},open('/root/is2/osm/coast1453.json','w'))
import pickle; pickle.dump({'land':land2,'yarimada':fat1453,'EU':EU,'AS':AS,'sea':sea2},open('/root/is2/osm/coast.pkl','wb'))
# cizim
from PIL import Image, ImageDraw
def draw(fn,cx,cy,S,W=1400,H=1400):
    im=Image.new('RGB',(W,H),(60,110,160));d=ImageDraw.Draw(im)
    tr=lambda e,n:(W/2+(e-cx)*S,H/2-(n-cy)*S)
    for p in P:
        d.polygon([tr(*c) for c in p.exterior.coords],fill=(200,190,150),outline=(0,0,0))
        for i in p.interiors: d.polygon([tr(*c) for c in i.coords],fill=(60,110,160))
    for r in parts(land):
        d.line([tr(*c) for c in r.exterior.coords],fill=(255,0,0),width=1)
    d.line([tr(*c) for c in fat1453.exterior.coords],fill=(0,120,0),width=2)
    for g in range(-12000,12001,1000):
        d.line([tr(g,-12000),tr(g,12000)],fill=(255,255,255)); d.line([tr(-12000,g),tr(12000,g)],fill=(255,255,255))
    im.save(fn)
draw('/root/is2/osm/c_all.png',0,1000,0.055)
draw('/root/is2/osm/c_pen.png',-1800,800,0.2)
