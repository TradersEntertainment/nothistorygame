#!/usr/bin/env python3
"""Fizik-3 kare paftası: fizik3_pafta.py <kare klasörü> <ad> <çıktı.jpg> [başlık] [ÖNCE klasörü]
<ad>_0.jpg … <ad>_5.jpg (0,15 sn arayla) 3×2 ızgarada (her biri 640x360); ÖNCE klasörü verilirse üstte ÖNCE sırası."""
import sys, os
from PIL import Image, ImageDraw
d, ad, out = sys.argv[1], sys.argv[2], sys.argv[3]
title = sys.argv[4] if len(sys.argv) > 4 else ad
once = sys.argv[5] if len(sys.argv) > 5 else None
W, H = 640, 360
def sira(k):
    fs, i = [], 0
    while os.path.exists(os.path.join(k, f"{ad}_{i}.jpg")):
        fs.append(os.path.join(k, f"{ad}_{i}.jpg")); i += 1
    return fs
rows = ([("ÖNCE", sira(once))] if once else []) + [("SONRA" if once else "", sira(d))]
cols = 3
nr = sum((len(r[1]) + cols - 1) // cols for r in rows)
img = Image.new("RGB", (W * cols, H * nr + 28), (20, 20, 20))
dr = ImageDraw.Draw(img)
dr.text((8, 7), title, fill=(255, 255, 255))
y = 28
for lab, fs in rows:
    for i, f in enumerate(fs):
        im = Image.open(f).resize((W, H))
        img.paste(im, ((i % cols) * W, y + (i // cols) * H))
        dr.text(((i % cols) * W + 6, y + (i // cols) * H + 4), f"{lab} {i} (+{i * 0.15:.2f} sn)".strip(), fill=(255, 255, 0))
    y += H * ((len(fs) + cols - 1) // cols)
img.save(out, quality=85)
