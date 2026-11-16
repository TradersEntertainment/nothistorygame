#!/usr/bin/env python3
"""BİRLİK ölçümü: kare (AD.jpg) + kategori kimlik karesi (AD_id.png; tests/_ist/birlik_id.gd) → kategori başına
doygunluk (HSV, sRGB; ortalama ve %95), parlaklık aralığı (%5–%95), doku enerjisi (|Laplace|, ×100), doku öğe boyu
(yüksek geçirgen işaret değişimleri arası ortalama koşu, px), dış çizgi oranı (maske kenarında koyu piksel), toon ton
sayısı (parlaklık çizelgesinde tepe sayısı).
Kullanım: birlik_olc.py KLASÖR [KLASÖR...] [--tablo ETIKET] [--json DOSYA]
Kategori satırı en az 2 000 piksel tutuyorsa yazılır."""
import sys, os, json, glob
import numpy as np
from PIL import Image

RENK = {
    "tas": (255, 0, 0), "siva": (0, 255, 0), "kiremit": (0, 0, 255), "ahsap": (255, 255, 0),
    "zemin": (255, 0, 255), "bitki": (0, 255, 255), "kumas": (255, 128, 0), "kisi": (128, 0, 255),
    "metal": (0, 128, 0), "yapi": (128, 128, 128),
}


def hsv(a):
    a = a.astype(np.float32) / 255.0
    mx = a.max(axis=2)
    mn = a.min(axis=2)
    s = np.where(mx > 1e-4, (mx - mn) / np.maximum(mx, 1e-4), 0.0)
    return s, mx


def maske(idimg, rgb):
    d = np.abs(idimg.astype(np.int32) - np.array(rgb)[None, None, :]).sum(axis=2)
    return d < 40


def erode(m, k=2):
    o = m.copy()
    for dy in range(-k, k + 1):
        for dx in range(-k, k + 1):
            o &= np.roll(np.roll(m, dy, 0), dx, 1)
    return o


def blur(v, k=3):
    o = np.zeros_like(v)
    n = 0
    for dy in range(-k, k + 1):
        for dx in range(-k, k + 1):
            o += np.roll(np.roll(v, dy, 0), dx, 1)
            n += 1
    return o / n


def olc(jpg, idp):
    im = np.asarray(Image.open(jpg).convert("RGB"))
    idi = np.asarray(Image.open(idp).convert("RGB"))
    s, v = hsv(im)
    lap = np.abs(4 * v - np.roll(v, 1, 0) - np.roll(v, -1, 0) - np.roll(v, 1, 1) - np.roll(v, -1, 1))
    hp = v - blur(v, 3)
    out = {}
    for k, rgb in RENK.items():
        m = maske(idi, rgb)
        n = int(m.sum())
        if n < 2000:
            continue
        mi = erode(m, 2)
        r = {"px": n, "s_ort": float(s[m].mean()), "s_95": float(np.percentile(s[m], 95)),
             "v_05": float(np.percentile(v[m], 5)), "v_50": float(np.percentile(v[m], 50)),
             "v_95": float(np.percentile(v[m], 95))}
        if mi.sum() > 500:
            r["doku"] = float(lap[mi].mean() * 100.0)
            # öğe boyu: satır boyunca yüksek geçirgenin işaret değişimleri arası ortalama koşu (yalnız iç maske)
            sg = np.sign(hp) * mi
            ch = (sg[:, 1:] * sg[:, :-1] < 0).sum()
            r["oge_px"] = float(2.0 * mi.sum() / max(ch, 1))
        else:
            r["doku"] = float("nan")
            r["oge_px"] = float("nan")
        kenar = m & ~erode(m, 1)
        r["cizgi"] = float((v[kenar] < 0.16).mean()) if kenar.sum() > 0 else 0.0
        h, _ = np.histogram(v[mi] if mi.sum() > 500 else v[m], bins=24, range=(0, 1))
        h = np.convolve(h, [1, 2, 1], mode="same").astype(np.float32)
        tep = 0
        for i in range(1, 23):
            if h[i] > h[i - 1] and h[i] >= h[i + 1] and h[i] > 0.04 * h.sum():
                tep += 1
        r["ton"] = tep
        out[k] = r
    return out


def topla(kayitlar):
    """kategori → piksel ağırlıklı ortalama"""
    t = {}
    for o in kayitlar:
        for k, r in o.items():
            t.setdefault(k, []).append(r)
    s = {}
    for k, l in t.items():
        w = np.array([x["px"] for x in l], dtype=np.float64)
        d = {"px": int(w.sum()), "kare": len(l)}
        for f in ["s_ort", "s_95", "v_05", "v_50", "v_95", "doku", "oge_px", "cizgi", "ton"]:
            a = np.array([x[f] for x in l], dtype=np.float64)
            ok = ~np.isnan(a)
            d[f] = float((a[ok] * w[ok]).sum() / max(w[ok].sum(), 1)) if ok.any() else float("nan")
        s[k] = d
    return s


def main():
    args = sys.argv[1:]
    etiket = "olcum"
    js = None
    if "--tablo" in args:
        i = args.index("--tablo"); etiket = args[i + 1]; del args[i:i + 2]
    if "--json" in args:
        i = args.index("--json"); js = args[i + 1]; del args[i:i + 2]
    kay = []
    kareler = {}
    for d in args:
        for idp in sorted(glob.glob(os.path.join(d, "*_id.png"))):
            jpg = idp[:-7] + ".jpg"
            if not os.path.exists(jpg):
                continue
            o = olc(jpg, idp)
            kay.append(o)
            kareler[os.path.basename(jpg)] = o
    s = topla(kay)
    print(f"## {etiket} ({len(kay)} kare)")
    print("| kategori | piksel | S ort | S %95 | V %5 | V %50 | V %95 | doku (|∇²|×100) | öğe (px) | çizgi | ton |")
    print("|---|---|---|---|---|---|---|---|---|---|---|")
    for k in RENK:
        if k in s:
            r = s[k]
            print(f"| {k} | {r['px']} | {r['s_ort']:.2f} | {r['s_95']:.2f} | {r['v_05']:.2f} | {r['v_50']:.2f} | {r['v_95']:.2f} | {r['doku']:.1f} | {r['oge_px']:.1f} | {r['cizgi']:.2f} | {r['ton']:.1f} |")
    if js:
        with open(js, "w") as f:
            json.dump({"ozet": s, "kareler": kareler}, f, indent=1)


if __name__ == "__main__":
    main()
