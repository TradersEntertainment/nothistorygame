#!/usr/bin/env python3
# pafta.py yan <çıktı.jpg> <a.jpg> <b.jpg> [c.jpg ...] : kareleri yarım boy yan yana (etiketsiz; sıra: verilen sıra)
# pafta.py kirp <çıktı.jpg> x0 y0 x1 y1 <a.jpg> <b.jpg> <c.jpg> : aynı bölgeyi kesip yan yana (tam çözünürlük)
import sys
from PIL import Image
k = sys.argv[1]
out = sys.argv[2]
if k == "yan":
    ims = [Image.open(f).convert("RGB") for f in sys.argv[3:]]
    ims = [im.resize((im.width // 2, im.height // 2)) for im in ims]
else:
    x0, y0, x1, y1 = map(int, sys.argv[3:7])
    ims = [Image.open(f).convert("RGB").crop((x0, y0, x1, y1)) for f in sys.argv[7:]]
W = sum(i.width for i in ims) + 6 * (len(ims) - 1)
H = max(i.height for i in ims)
p = Image.new("RGB", (W, H), (255, 255, 255))
x = 0
for i in ims:
    p.paste(i, (x, 0))
    x += i.width + 6
p.save(out, quality=85)
