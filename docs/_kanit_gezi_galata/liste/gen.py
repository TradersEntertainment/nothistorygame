import re,math
src=open('/home/user/nothistorygame/scripts/world/ist/geo.gd').read()
m=re.search(r'static var R_GALATA := PackedVector2Array\(\[(.*?)\]\)',src)
pts=[(float(a),float(b)) for a,b in re.findall(r'Vector2\(([-\d.]+),([-\d.]+)\)',m.group(1))]
def inside(x,y):
    c=False;n=len(pts)
    for i in range(n):
        x1,y1=pts[i];x2,y2=pts[(i+1)%n]
        if (y1>y)!=(y2>y) and x<(x2-x1)*(y-y1)/(y2-y1)+x1: c=not c
    return c
xs=[p[0] for p in pts];ys=[p[1] for p in pts]
print(min(xs),max(xs),min(ys),max(ys),len(pts))
grid=[];dirs={'K':0,'D':90,'G':180,'B':270}
for x in range(-1000,0,60):
    for y in range(1500,2000,60):
        if inside(x,y): grid.append((x,y))
print(len(grid))
with open('izgara.txt','w') as f:
    for i,(x,y) in enumerate(grid):
        for d,a in dirs.items():
            f.write(f"izg_{i:03d}_{x}_{y}_{d} {x} {y} 1.7 {a} 0\n")
with open('gece.txt','w') as f:
    for i,(x,y) in enumerate(grid):
        if i%3==0:
            for d,a in (('K',0),('G',180)):
                f.write(f"gece_{i:03d}_{x}_{y}_{d} {x} {y} 1.7 {a} 0\n")
