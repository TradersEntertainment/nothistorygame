#!/usr/bin/env python3
"""Ses tutarlılık denetimi: her konuşmacının replikleri aynı ses gibi mi duyuluyor?

Her seslendirme dosyası için ses perdesi (F0, otokorelasyon), tını (spektral ağırlık merkezi) ve
seviye (dBFS) ölçülür; konuşmacının kendi ortancasından çok sapan replikler "aykırı" sayılır.
Tipik yakaladıkları: bir replikte sesin birden gençleşmesi / incelmesi, başka bir sesle üretilmiş
satır, çok kısık ya da bağıran kayıt.

    python3 tools/voice_consistency.py [--lang tr] [--speaker SPK_HIKMET]

Çıktı: docs/voice/CONSISTENCY.csv (her replik, ölçümler, sapma puanı) ve ekranda aykırılar listesi.
Aykırıları yeniden üretmek için: python tools/voice_gen.py redo ANAHTAR [ANAHTAR ...] --force
Gerekenler: numpy, ffmpeg (PATH'te ya da FFMPEG ortam değişkeninde).
"""
import argparse, csv, os, subprocess, sys

import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SR = 16000
FFMPEG = os.environ.get("FFMPEG", "ffmpeg")


def load(path):
    raw = subprocess.run([FFMPEG, "-v", "error", "-i", path, "-ac", "1", "-ar", str(SR), "-f", "s16le", "-"],
                         capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768.0


def features(x):
    frame, hop = 640, 320            # 40 ms / 20 ms
    if len(x) < frame * 3:
        return None
    n = 1 + (len(x) - frame) // hop
    idx = np.arange(frame)[None, :] + hop * np.arange(n)[:, None]
    fr = x[idx] * np.hanning(frame)[None, :]
    rms = np.sqrt((fr ** 2).mean(axis=1) + 1e-12)
    voiced = rms > max(rms.max() * 0.12, 0.004)
    if voiced.sum() < 5:
        return None
    f = fr[voiced]
    # Ses perdesi: otokorelasyonun 70-400 Hz aralığındaki tepesi
    spec = np.fft.rfft(f, 2 * frame, axis=1)
    ac = np.fft.irfft(np.abs(spec) ** 2, axis=1)[:, :frame]
    lo, hi = SR // 400, SR // 70
    lag = lo + ac[:, lo:hi].argmax(axis=1)
    strength = ac[np.arange(len(lag)), lag] / (ac[:, 0] + 1e-9)
    good = strength > 0.35
    f0 = float(np.median(SR / lag[good])) if good.sum() >= 3 else float("nan")
    mag = np.abs(np.fft.rfft(f, axis=1))
    freqs = np.fft.rfftfreq(frame, 1 / SR)
    centroid = float(np.median((mag * freqs).sum(axis=1) / (mag.sum(axis=1) + 1e-9)))
    level = float(20 * np.log10(np.median(rms[voiced]) + 1e-9))
    return f0, centroid, level


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--lang", default="tr")
    ap.add_argument("--speaker", default="")
    ap.add_argument("--z", type=float, default=3.0, help="aykırılık eşiği (ortanca mutlak sapma birimi)")
    a = ap.parse_args()
    spk_of = {}
    for name in ("docs/voice/VOICE_MAP.csv", "docs/voice/SPEAKERS_SEEN.csv"):
        p = os.path.join(ROOT, name)
        if os.path.exists(p):
            for r in csv.DictReader(open(p, encoding="utf-8")):
                spk_of[r["anahtar"]] = r.get("konusmaci", spk_of.get(r["anahtar"], ""))
    vdir = os.path.join(ROOT, "assets/audio/voice", a.lang)
    rows = []
    files = sorted(f for f in os.listdir(vdir) if f.endswith(".mp3"))
    for i, fn in enumerate(files):
        key = fn[:-4]
        spk = spk_of.get(key, "?")
        if a.speaker and spk != a.speaker:
            continue
        try:
            ft = features(load(os.path.join(vdir, fn)))
        except subprocess.CalledProcessError:
            ft = None
        if ft:
            rows.append({"anahtar": key, "konusmaci": spk, "f0": ft[0], "tini": ft[1], "seviye": ft[2]})
        if i % 200 == 0:
            print(f"{i}/{len(files)}", file=sys.stderr)
    by = {}
    for r in rows:
        by.setdefault(r["konusmaci"], []).append(r)
    flagged = []
    for spk, rs in by.items():
        if len(rs) < 6:
            continue
        for m in ("f0", "tini", "seviye"):
            v = np.array([r[m] for r in rs], dtype=float)
            ok = ~np.isnan(v)
            if ok.sum() < 6:
                continue
            med = np.median(v[ok])
            mad = np.median(np.abs(v[ok] - med)) * 1.4826
            # Taban: az replikli ya da çok tekdüze konuşmacıda küçük farklar aşırı büyümesin
            mad = max(mad, 1.5 if m == "seviye" else 0.06 * abs(med), 1e-6)
            for r, x in zip(rs, v):
                z = 0.0 if np.isnan(x) else abs(x - med) / mad
                r["z_" + m] = round(float(z), 2)
        for r in rs:
            score = max(r.get("z_f0", 0), r.get("z_tini", 0) * 0.8, r.get("z_seviye", 0) * 0.6)
            r["sapma"] = round(score, 2)
            if score >= a.z:
                flagged.append(r)
    out = os.path.join(ROOT, "docs/voice/CONSISTENCY.csv")
    cols = ["anahtar", "konusmaci", "sapma", "f0", "tini", "seviye", "z_f0", "z_tini", "z_seviye"]
    with open(out, "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=cols, extrasaction="ignore")
        w.writeheader()
        for r in sorted(rows, key=lambda r: -r.get("sapma", 0)):
            w.writerow({k: (round(v, 1) if isinstance(v, float) else v) for k, v in r.items()})
    flagged.sort(key=lambda r: -r["sapma"])
    print(f"\n{len(flagged)} aykırı replik (eşik {a.z}):")
    for r in flagged:
        print(f"  {r['anahtar']:28s} {r['konusmaci']:16s} sapma={r['sapma']:5.1f}  F0={r['f0']:.0f}Hz tını={r['tini']:.0f} seviye={r['seviye']:.1f}dB")
    print(f"\nTablo: {out}")


if __name__ == "__main__":
    main()
