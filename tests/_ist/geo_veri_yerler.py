import csv,pickle
from shapely.geometry import Point
from shapely.ops import nearest_points
Y=pickle.load(open('/root/is2/out/yollar.pkl','rb'))
rows=list(csv.reader(open('/home/user/nothistorygame/docs/ISTANBUL_YERLER.csv',encoding='utf-8')))
hdr=rows[0]; out=[]
for i,r in enumerate(rows[1:],start=2):
    d=dict(zip(hdr,r)); e=float(d['dogu_m']); n=float(d['kuzey_m']); e0,n0=e,n; nt=''
    if d['tur']=='kapi':
        t=d['durum_1453']
        key='halic' if 'Haliç deniz' in t else ('marm' if 'Marmara deniz' in t else 'WL')
        q=nearest_points(Y[key],Point(e,n))[0]; dd=q.distance(Point(e,n))
        e,n=q.x,q.y; nt=f'{ {"halic":"Haliç suru","marm":"Marmara suru","WL":"kara suru"}[key]} hattına oturtuldu ({dd:.0f} m)'
    def q(s): return '"'+s.replace('\\','\\\\').replace('"','\\"')+'"'
    out.append(f'\t[{q(d["ad_tr"])}, {q(d["tur"])}, {e:.1f}, {n:.1f}, {e0:.1f}, {n0:.1f}, {i}, {q(nt)}],')
open('/root/is2/out/yerler.gd','w').write('const YERLER_HAM := [\n'+'\n'.join(out)+'\n]\n')
