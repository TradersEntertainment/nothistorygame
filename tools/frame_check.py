#!/usr/bin/env python3
"""tests/visual_run.sh'ın karelerini sayıyla denetler ve göz denetimi için 2x2 paftalar yapar.

Bulgular (FRAME tür kare ...):
  dark    kapkara kare (ortalama parlaklık < 6): sahne kurulmamış, kamera duvarın içinde, perde kalkmamış
  white   bembeyaz kare (> 245): patlama/ışık sönmemiş
  flat    tek renk kare (renk sapması çok düşük): gökyüzüne/duvara gömülmüş kamera
  frozen  art arda 4+ oynanış karesi birebir aynı (oyun donmuş ya da oyuncu bir yerde takılmış)
Kararma geçişi (bölüm başı/sonu) olağandır: ilk ve son iki kare sayılmaz.

    python3 tools/frame_check.py tests/out/visual/20     # bulgular + tests/out/visual/20/sheets/*.jpg
"""
import os, subprocess, sys

def stats(path):
    """Kareyi 64x36 griye indirip (ffmpeg) ortalama, sapma ve ham baytları döner."""
    raw = subprocess.run(["ffmpeg", "-loglevel", "error", "-i", path, "-vf", "scale=64:36", "-f", "rawvideo",
                          "-pix_fmt", "gray", "-"], capture_output=True).stdout
    if not raw:
        return None
    n = len(raw)
    mean = sum(raw) / n
    sd = (sum((b - mean) ** 2 for b in raw) / n) ** 0.5
    return mean, sd, raw

def main(d):
    shots = sorted(f for f in os.listdir(d) if f.endswith(".jpg"))
    snaps = [f for f in shots if f.startswith("t") and f[1:5].isdigit()]
    lines = [f for f in shots if f not in snaps]
    found = []
    st = {f: stats(os.path.join(d, f)) for f in shots}
    edge = set(snaps[:2] + snaps[-2:])
    def kind(f):
        s = st.get(f)
        if s is None:
            return ""
        mean, sd, _ = s
        return "dark" if mean < 6 else "white" if mean > 245 else "flat" if sd < 4 else ""
    # Oynanış karelerinde tek kara/beyaz kare sahne geçişidir (kararma, tarih kartı): art arda iki kare (8+ sn) sayılır.
    # Replik karesi tek başına sayılır: biri konuşurken ekran kapkara olmamalı
    for i, f in enumerate(snaps):
        k = kind(f)
        if k and f not in edge and i + 1 < len(snaps) and kind(snaps[i + 1]) == k:
            found.append(f"FRAME {k} {f}+{snaps[i + 1]} mean={st[f][0]:.0f} sd={st[f][1]:.1f}")
    for f in lines:
        k = kind(f)
        if k:
            found.append(f"FRAME {k} {f} (replik) mean={st[f][0]:.0f} sd={st[f][1]:.1f}")
    run = 1
    for a, b in zip(snaps, snaps[1:]):
        sa, sb = st[a], st[b]
        same = sa and sb and sum(abs(x - y) for x, y in zip(sa[2], sb[2])) / len(sa[2]) < 0.6
        run = run + 1 if same else 1
        if run == 4:
            found.append(f"FRAME frozen {b} (4 kare aynı)")
    for x in found:
        print(x)
    # Paftalar: oynanış kareleri dörder dörder, sonra replik kareleri (göz denetimi)
    out = os.path.join(d, "sheets")
    os.makedirs(out, exist_ok=True)
    seq = snaps + lines
    for i in range(0, len(seq), 4):
        grp = seq[i:i + 4]
        while len(grp) < 4:
            grp.append(grp[-1])
        cmd = ["ffmpeg", "-nostdin", "-loglevel", "error", "-y"]
        for g in grp:
            cmd += ["-i", os.path.join(d, g)]
        fc = ";".join(f"[{k}]scale=640:360,drawtext=text='{grp[k][:-4]}':x=8:y=8:fontsize=18:fontcolor=yellow:box=1:boxcolor=black@0.6[v{k}]" for k in range(4))
        fc += ";[v0][v1][v2][v3]xstack=inputs=4:layout=0_0|w0_0|0_h0|w0_h0"
        subprocess.run(cmd + ["-filter_complex", fc, os.path.join(out, f"s{i // 4:03d}.jpg")])
    print(f"KARE {len(snaps)} oynanış + {len(lines)} replik, {len(found)} bulgu, pafta {os.path.relpath(out)}")

if __name__ == "__main__":
    main(sys.argv[1])
