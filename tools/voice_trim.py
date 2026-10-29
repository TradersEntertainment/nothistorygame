#!/usr/bin/env python3
"""Seslendirmenin başındaki ölü sessizliği kırpar (v0.99.68, ses denetimi).

ElevenLabs bazı okumalara 1-1,7 sn sessizlikle başlıyor: altyazı çıkar, kimse konuşmaz, oyun takıldı sanılır
(D6A_T_01, D_CHICKEN_CATCH_2...). Başta 0,5 sn'den uzun (-45 dB altı) sessizlik 0,1 sn'ye iner; hız yorumu
(voice_tempo) korunur.

    python3 tools/voice_trim.py            # bütün tr/en dosyaları
"""
import os, re, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIMIT, KEEP = 0.5, 0.1


def lead(path):
    e = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", path, "-af", "silencedetect=n=-45dB:d=0.3",
                        "-f", "null", "-"], capture_output=True, text=True).stderr
    s = re.findall(r"silence_start: (-?[\d.e-]+)", e)
    en = re.findall(r"silence_end: ([\d.]+)", e)
    return float(en[0]) if s and float(s[0]) <= 0.01 and en else 0.0


def trim(path):
    t = lead(path)
    if t <= LIMIT:
        return None
    tmp = tempfile.mktemp(suffix=".mp3")
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", path, "-af", f"atrim=start={t - KEEP:.3f},asetpts=PTS-STARTPTS",
                    "-ar", "44100", "-c:a", "libmp3lame", "-b:a", "128k", tmp], check=True)
    os.replace(tmp, path)
    return os.path.relpath(path, ROOT), round(t, 2)


if __name__ == "__main__":
    fs = [os.path.join(d, f) for d in (os.path.join(ROOT, "assets/audio/voice", l) for l in ("tr", "en"))
          for f in sorted(os.listdir(d)) if f.endswith(".mp3")]
    with ThreadPoolExecutor(os.cpu_count() or 4) as ex:
        done = [r for r in ex.map(trim, fs) if r]
    for p, t in done:
        print(f"  {p}  {t} sn")
    print(f"{len(done)} dosyanın başı kırpıldı")
