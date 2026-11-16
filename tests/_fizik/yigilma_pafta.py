#!/usr/bin/env python3
"""Yığılma kare paftası: yigilma_pafta.py <kare klasörü> <ad> <çıktı.jpg> [ÖNCE klasörü]
<ad>_0.jpg … <ad>_k.jpg yan yana (her biri 426x240); ÖNCE klasörü verilirse üst sıra ÖNCE, alt sıra SONRA."""
import sys, os
from PIL import Image, ImageDraw
d, ad, out = sys.argv[1], sys.argv[2], sys.argv[3]
once = sys.argv[4] if len(sys.argv) > 4 else None
W, H = 426, 240
def sira(k):
    fs = []
    i = 0
    while os.path.exists(os.path.join(k, f"{ad}_{i}.jpg")):
        fs.append(os.path.join(k, f"{ad}_{i}.jpg")); i += 1
    return fs
rows = ([("ÖNCE", sira(once))] if once else []) + [("SONRA", sira(d))]
n = max(len(r[1]) for r in rows)
cols = min(n, 3)
nr = sum((len(r[1]) + cols - 1) // cols for r in rows)
img = Image.new("RGB", (W * cols, H * nr), (20, 20, 20))
dr = ImageDraw.Draw(img)
y = 0
for lab, fs in rows:
    for i, f in enumerate(fs):
        im = Image.open(f).resize((W, H))
        img.paste(im, ((i % cols) * W, y + (i // cols) * H))
        dr.text(((i % cols) * W + 6, y + (i // cols) * H + 4), f"{lab} {i}", fill=(255, 255, 0))
    y += H * ((len(fs) + cols - 1) // cols)
img.save(out, quality=85)
