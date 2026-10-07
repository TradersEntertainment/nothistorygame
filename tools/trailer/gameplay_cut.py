#!/usr/bin/env python3
"""Oynanış fragmanının kesimi: gameplay.tscn'in ham kaydından ("MONTAGE in/out" kare numaraları) yalnız pencereleri
alır, sırayla birleştirir (kara bekleme kısımları atılır).

  python3 tools/trailer/gameplay_cut.py oynanis_ham.avi oynanis.log oynanis.mp4 [--fps 30] [--vcodec libx264]

NVIDIA kartlı ve libx264'süz ffmpeg'de: --vcodec h264_nvenc (kalite -cq 18).
"""
import argparse
import re
import subprocess
import sys


def segments(log_path):
    segs, cur = [], None
    rx = re.compile(r"MONTAGE (in|out) seg=(\d+) frame=(\d+)")
    with open(log_path, encoding="utf-8", errors="replace") as f:
        for line in f:
            m = rx.search(line)
            if not m:
                continue
            kind, frame = m.group(1), int(m.group(3))
            if kind == "in":
                cur = frame
            elif cur is not None:
                if frame > cur:
                    segs.append((cur, frame))
                cur = None
    return segs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("raw")
    ap.add_argument("log")
    ap.add_argument("out")
    ap.add_argument("--fps", type=float, default=30.0)
    ap.add_argument("--vcodec", default="libx264")
    ap.add_argument("--ffmpeg", default="ffmpeg")
    a = ap.parse_args()
    segs = segments(a.log)
    if not segs:
        sys.exit("Kayıtta MONTAGE kesim satırı yok (Godot'un çıktısı dosyaya yazıldı mı?)")
    parts, labels = [], []
    for i, (s, e) in enumerate(segs):
        t0, t1 = s / a.fps, e / a.fps
        parts.append(f"[0:v]trim=start_frame={s}:end_frame={e},setpts=PTS-STARTPTS[v{i}];"
                     f"[0:a]atrim=start={t0:.4f}:end={t1:.4f},asetpts=PTS-STARTPTS[a{i}];")
        labels.append(f"[v{i}][a{i}]")
    fc = "".join(parts) + "".join(labels) + f"concat=n={len(segs)}:v=1:a=1[v][a]"
    q = ["-cq", "18", "-preset", "p6"] if "nvenc" in a.vcodec else ["-crf", "18", "-preset", "slow"]
    cmd = [a.ffmpeg, "-y", "-i", a.raw, "-filter_complex", fc, "-map", "[v]", "-map", "[a]",
           "-r", f"{a.fps:g}", "-c:v", a.vcodec, *q, "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "192k", a.out]
    total = sum(e - s for s, e in segs) / a.fps
    print(f"{len(segs)} parça, toplam {total:.1f} sn")
    subprocess.run(cmd, check=True)


if __name__ == "__main__":
    main()
