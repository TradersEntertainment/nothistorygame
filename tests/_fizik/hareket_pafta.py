#!/usr/bin/env python3
"""Hareket hissi paftası: <klasör> <senaryo> [n] → ÖNCE (üst) | SONRA (alt) satırları, 0,1 sn arayla n kare.
Çıktı: <klasör>/pafta_<senaryo>.jpg (her kare 320×180). Değerlendirme TAM BOY karelerle yapılır; pafta özet içindir."""
import sys, os
from PIL import Image, ImageDraw
d, sen = sys.argv[1], sys.argv[2]
n = int(sys.argv[3]) if len(sys.argv) > 3 else 6
W, H = 320, 180
out = Image.new("RGB", (W * n + 70, H * 2 + 4), (20, 20, 20))
dr = ImageDraw.Draw(out)
for r, on in enumerate(["ONCE", "SONRA"]):
    dr.text((6, r * (H + 4) + H // 2), on, fill=(255, 220, 80))
    for i in range(n):
        f = os.path.join(d, "%s_%s_%d.jpg" % (sen, on, i))
        if os.path.exists(f):
            out.paste(Image.open(f).resize((W, H)), (70 + i * W, r * (H + 4)))
out.save(os.path.join(d, "pafta_%s.jpg" % sen), quality=85)
print("pafta", sen)
